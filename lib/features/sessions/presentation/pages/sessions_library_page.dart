// lib/features/sessions/presentation/pages/sessions_library_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/onboarding/page_onboarding.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/sessions_providers.dart';
import '../../application/public_activity_stats_providers.dart';
import '../../domain/session_models.dart';
import '../session_library_models.dart';

class SessionsLibraryPage extends ConsumerStatefulWidget {
  const SessionsLibraryPage({super.key, this.bodyCategory});

  final String? bodyCategory;

  @override
  ConsumerState<SessionsLibraryPage> createState() =>
      _SessionsLibraryPageState();
}

class _SessionsLibraryPageState extends ConsumerState<SessionsLibraryPage> {
  final GlobalKey _trainingSessionsGuideKey = GlobalKey(debugLabel: 'training_sessions_guide');

  final String _searchQuery = '';
  final SessionLibraryCategory _selectedCategory = SessionLibraryCategory.all;
  final SessionLibrarySort _selectedSort = SessionLibrarySort.recommended;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      ref.invalidate(sessionSummariesProvider);
      ref.invalidate(globalPopularSessionIdsProvider);
      ref.invalidate(accessSnapshotProvider);
    });

    final sessionsAsync = ref.watch(sessionSummariesProvider);
    final globalPopularAsync = ref.watch(globalPopularSessionIdsProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(widget.bodyCategory == null ? 'Explore' : _bodyPageTitle(widget.bodyCategory!)),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        return sessionsAsync.when(
          loading: () => ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
            children: const [
              ResponsiveContentSection(
                spacing: 14,
                children: [
                  _SkeletonBox(height: 180),
                  _SkeletonBox(height: 82),
                  _SkeletonBox(height: 360),
                ],
              ),
            ],
          ),
          error: (error, _) => ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
            children: [
              ResponsiveContentSection(
                spacing: 14,
                children: [
                  _MessageCard(
                    title: t.get(
                      'sessions_load_error_title',
                      fallback: 'Training could not load.',
                    ),
                    body: error.toString(),
                    actionLabel: t.get('common_retry', fallback: 'Retry'),
                    onAction: () => ref.invalidate(sessionSummariesProvider),
                  ),
                ],
              ),
            ],
          ),
          data: (allSessions) {
            final visibleSessions = widget.bodyCategory == null
                ? _visibleSessions(allSessions)
                : allSessions.where((session) =>
                    _matchesBodyPage(session, widget.bodyCategory!)).toList();
            return PageOnboarding(
              pageId: 'training_guide_v1',
              tips: [
                OnboardingTip(
                  targetKey: _trainingSessionsGuideKey,
                  icon: Icons.self_improvement_rounded,
                  title: t.get('guide_training_sessions_title', fallback: 'Sessions are single resets'),
                  body: t.get('guide_training_sessions_body', fallback: 'Use sessions when you want one quick recovery exercise right now.'),
                ),
              ],
              child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sessionSummariesProvider);
                ref.invalidate(globalPopularSessionIdsProvider);
                await ref.read(sessionSummariesProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
                children: [
                  ResponsiveContentSection(
                    spacing: 14,
                    children: [
                      if (visibleSessions.isEmpty)
                        _MessageCard(
                          title: t.get(
                            'sessions_no_results_title',
                            fallback: 'No sessions available yet.',
                          ),
                          body: t.get(
                            'sessions_no_results_body',
                            fallback: 'Pull down to refresh the session library.',
                          ),
                          actionLabel: t.get('common_retry', fallback: 'Retry'),
                          onAction: () => ref.invalidate(sessionSummariesProvider),
                        )
                      else
                        KeyedSubtree(
                          key: _trainingSessionsGuideKey,
                          child: widget.bodyCategory == null
                              ? _TrainingDiscoverySections(
                                  sessions: visibleSessions,
                                  popularIds: globalPopularAsync.value ?? const <String>[],
                                  accessSnapshot: accessSnapshot,
                                )
                              : _BodySessionList(
                                  sessions: visibleSessions,
                                  accessSnapshot: accessSnapshot,
                                ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }


  List<SessionSummary> _visibleSessions(List<SessionSummary> sessions) {
    final query = _searchQuery.trim().toLowerCase();

    final result = sessions.where((session) {
      if (!_matchesCategory(session, _selectedCategory)) return false;
      if (query.isNotEmpty && !_matchesSearch(session, query)) return false;
      return true;
    }).toList(growable: true);

    // The repository already returns sessions in Supabase sort_order.
    // Keep that curated order for the default "Recommended" view.
    if (_selectedSort != SessionLibrarySort.recommended) {
      result.sort((a, b) => _compareSessions(a, b, _selectedSort));
    }
    return result;
  }

  bool _matchesCategory(
    SessionSummary session,
    SessionLibraryCategory category,
  ) {
    switch (category) {
      case SessionLibraryCategory.all:
        return true;
      case SessionLibraryCategory.neckShoulders:
        return _targetsAny(session, const ['neck', 'shoulder', 'shoulders']);
      case SessionLibraryCategory.upperBack:
        return _targetsAny(session, const ['upper_back', 'thoracic', 'chest']);
      case SessionLibraryCategory.lowerBackHips:
        return _targetsAny(session, const [
          'lower_back',
          'low_back',
          'lumbar',
          'hips',
          'hip',
          'glutes',
          'glute',
          'hips_glutes',
          'hamstrings',
        ]);
      case SessionLibraryCategory.wristsHands:
        return _targetsAny(session, const [
          'wrists',
          'wrist',
          'forearms',
          'forearm',
          'hands',
          'hand',
          'fingers',
          'finger',
        ]);
    }
  }

  bool _targetsAny(SessionSummary session, List<String> targets) {
    final targetSet = targets.map(_canonicalBodyCode).toSet();
    final codes = <String>{
      ...session.painTargets.map((item) => _canonicalBodyCode(item.code)),
      ...session.tags.map((item) => _canonicalBodyCode(item.code)),
    };

    return targetSet.any(codes.contains);
  }

  String _canonicalBodyCode(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'shoulder':
      case 'shoulders':
        return 'shoulders';
      case 'thoracic':
      case 'chest':
      case 'upper_back':
        return 'upper_back';
      case 'back':
      case 'low_back':
      case 'lumbar':
      case 'lower_back':
      case 'core':
        return 'lower_back';
      case 'hip':
      case 'hips':
      case 'glute':
      case 'glutes':
      case 'hips_glutes':
        return 'hips_glutes';
      case 'wrist':
      case 'wrists':
        return 'wrists';
      case 'forearm':
      case 'forearms':
      case 'mouse_arm':
        return 'forearms';
      case 'hand':
      case 'hands':
      case 'finger':
      case 'fingers':
        return 'hands';
      default:
        return raw.trim().toLowerCase();
    }
  }

  bool _matchesSearch(SessionSummary session, String query) {
    final haystack = [
      session.id,
      session.titleFallback,
      session.subtitleFallback,
      session.shortDescriptionFallback,
      ...session.painTargets.map((e) => e.code),
      ...session.painTargets.map((e) => e.labelFallback),
      ...session.tags.map((e) => e.code),
      ...session.tags.map((e) => e.labelFallback),
      ...session.goals.map((e) => e.name),
      ...session.requiredEquipment.map((e) => e.toString()),
      session.equipmentLevel,
    ].join(' ').toLowerCase();

    return haystack.contains(query);
  }

  int _compareSessions(
    SessionSummary a,
    SessionSummary b,
    SessionLibrarySort sort,
  ) {
    switch (sort) {
      case SessionLibrarySort.durationShortest:
        return a.durationMinutes.compareTo(b.durationMinutes);
      case SessionLibrarySort.alphabetical:
        return a.titleFallback.toLowerCase().compareTo(b.titleFallback.toLowerCase());
      case SessionLibrarySort.recommended:
        return 0;
    }
  }
}



class _SearchSortBar extends StatefulWidget {
  const _SearchSortBar({
    required this.searchQuery,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortChanged,
  });

  final String searchQuery;
  final SessionLibrarySort selectedSort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<SessionLibrarySort> onSortChanged;

  @override
  State<_SearchSortBar> createState() => _SearchSortBarState();
}

class _SearchSortBarState extends State<_SearchSortBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.searchQuery,
  );
  late final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant _SearchSortBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchClear();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: TextField(
                  key: const ValueKey('sessions_library_search_field'),
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    setState(() {});
                    widget.onSearchChanged(value);
                  },
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: t.get(
                      'sessions_search_hint_compact',
                      fallback: 'Search sessions',
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 21),
                    suffixIcon: _controller.text.trim().isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: _clearSearch,
                          ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.56),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<SessionLibrarySort>(
              initialValue: widget.selectedSort,
              onSelected: widget.onSortChanged,
              itemBuilder: (context) => SessionLibrarySort.values
                  .map(
                    (sort) => PopupMenuItem(
                      value: sort,
                      child: Text(_sortLabel(context, sort)),
                    ),
                  )
                  .toList(growable: false),
              child: _SortButton(label: _sortShortLabel(context, widget.selectedSort)),
            ),
          ],
        ),
      ],
    );
  }
}








/// Goal-first browsing: show meaningful situations rather than a long grid.
/// Each row is derived from current Supabase session metadata; empty groups
/// are hidden, and the complete library remains available at the bottom.
String _bodyPageTitle(String id) {
  const titles = <String, String>{
    'neck': 'Neck & shoulders',
    'back': 'Upper back',
    'lower_back': 'Lower back',
    'hips': 'Hips & legs',
    'hands': 'Hands & wrists',
  };
  return titles[id] ?? 'Body focus';
}

bool _matchesBodyPage(SessionSummary session, String id) {
  const mapping = <String, List<String>>{
    'neck': ['neck', 'shoulder', 'shoulders'],
    'back': ['upper_back', 'thoracic', 'chest'],
    'lower_back': ['lower_back', 'low_back', 'lumbar', 'back'],
    'hips': ['hip', 'hips', 'glute', 'glutes', 'hips_glutes', 'hamstrings'],
    'hands': ['wrist', 'wrists', 'hand', 'hands', 'forearm', 'forearms'],
  };
  final options = mapping[id] ?? const <String>[];
  final values = {
    ...session.painTargets.map((e) => e.code.toLowerCase()),
    ...session.tags.map((e) => e.code.toLowerCase()),
  };
  return options.any(values.contains);
}

class _TrainingDiscoverySections extends StatelessWidget {
  const _TrainingDiscoverySections({
    required this.sessions,
    required this.popularIds,
    required this.accessSnapshot,
  });

  final List<SessionSummary> sessions;
  final List<String> popularIds;
  final AccessSnapshot accessSnapshot;

  static const _groupIds = <String>[
    'neck', 'upper_back', 'lower_back', 'hips', 'hands', 'other',
  ];

  String _primaryGroup(SessionSummary session) {
    // Priority is authoritative primary pain target; fallback to the
    // first declared goal/tag only if no target was supplied.
    final targets = [...session.painTargets]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    final codes = targets.isNotEmpty
        ? targets.map((e) => e.code).toList()
        : session.tags.map((e) => e.code).toList();
    if (codes.isEmpty) return 'other';
    final code = codes.first.toLowerCase().replaceAll('-', '_');
    if (code.contains('neck') || code.contains('shoulder')) {
      return 'neck';
    }
    if (code.contains('upper_back') || code.contains('thoracic') ||
        code.contains('chest')) {
      return 'upper_back';
    }
    if (code.contains('lower_back') || code.contains('low_back') ||
        code.contains('lumbar') || code == 'back') {
      return 'lower_back';
    }
    if (code.contains('hip') || code.contains('glute') ||
        code.contains('hamstring')) {
      return 'hips';
    }
    if (code.contains('wrist') || code.contains('hand') ||
        code.contains('finger') || code.contains('forearm')) {
      return 'hands';
    }
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SessionSummary>>{
      for (final id in _groupIds) id: <SessionSummary>[],
    };
    final topSessions = _rankedPopularSessions(sessions, popularIds);
    for (final session in sessions) {
      // Popular highlights remain discoverable in their primary body category.
      grouped[_primaryGroup(session)]!.add(session);
    }
    const titles = <String, String>{
      'neck': 'Neck & shoulders feel tight?',
      'upper_back': 'Tension between your shoulders?',
      'lower_back': 'Give your lower back a break',
      'hips': 'Hips stiff after sitting?',
      'hands': 'Hands & wrists need relief?',
      'other': 'Move and feel better',
    };
    const subtitles = <String, String>{
      'neck': 'A reset for the neck and shoulders',
      'upper_back': 'Open up after a long day at your desk',
      'lower_back': 'Comfortable movement for your back',
      'hips': 'Loosen up your hips and legs',
      'hands': 'Small movements with a big difference',
      'other': 'Discover more ways to move',
    };
    const icons = <String, IconData>{
      'neck': Icons.self_improvement_rounded,
      'upper_back': Icons.accessibility_new_rounded,
      'lower_back': Icons.airline_seat_recline_normal_rounded,
      'hips': Icons.directions_walk_rounded,
      'hands': Icons.back_hand_outlined,
      'other': Icons.spa_outlined,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final id in _groupIds) ...[
          if (id == 'upper_back') ...[
            if (topSessions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: _PopularSessionsShowcase(sessions: topSessions),
              ),
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: _BodyFocusNavigation(),
            ),
          ],
          if (grouped[id]!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: _TrainingDiscoveryRow(
                title: titles[id]!,
                subtitle: subtitles[id]!,
                icon: icons[id]!,
                sessions: grouped[id]!,
                accessSnapshot: accessSnapshot,
                layoutIndex: _groupIds.indexOf(id),
              ),
            ),
        ],
        if (topSessions.isEmpty) const _BodyFocusNavigation(),
      ],
    );
  }
}

// Snapshot based on actual session_run starts observed on 29 October 2026.
// Never manufacture rankings from session sort order. Refresh via a future
// aggregate endpoint when approved.
List<SessionSummary> _rankedPopularSessions(
  List<SessionSummary> sessions,
  List<String> rankedIds,
) {
  final byId = {for (final session in sessions) session.id: session};
  return [
    for (final id in rankedIds)
      if (byId.containsKey(id)) byId[id]!,
  ];
}

class _PopularSessionsShowcase extends StatefulWidget {
  const _PopularSessionsShowcase({required this.sessions});
  final List<SessionSummary> sessions;

  @override
  State<_PopularSessionsShowcase> createState() => _PopularSessionsShowcaseState();
}

class _PopularSessionsShowcaseState extends State<_PopularSessionsShowcase> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final displayed = expanded ? widget.sessions : widget.sessions.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34), topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16), bottomRight: Radius.circular(34),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF172B45), Color(0xFF234D57)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMMUNITY FAVORITES', style: TextStyle(
            color: Color(0xFF78E1C6), fontSize: 11,
            letterSpacing: 1.8, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 7),
          const Text('Top 10 most played sessions', style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 5),
          const Text('Based on completed sessions across Desk Workout',
            style: TextStyle(color: Color(0xFFD5E2E7), fontSize: 12)),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (var i = 0; i < displayed.length; i++) ...[
                  _PopularSessionRow(
                    session: displayed[i],
                    rank: i + 1,
                  ),
                  if (i < displayed.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          if (widget.sessions.length > 3) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => setState(() => expanded = !expanded),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEBF5F3),
                  foregroundColor: const Color(0xFF183C47),
                ),
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(expanded ? 'Show less' : 'View more'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PopularSessionRow extends StatelessWidget {
  const _PopularSessionRow({required this.session, required this.rank});
  final SessionSummary session;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          'session-detail', pathParameters: {'id': session.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              SizedBox(
                width: 25,
                child: Text('$rank', style: const TextStyle(
                  color: Color(0xFF7AE4C9), fontSize: 20,
                  fontWeight: FontWeight.w900,
                )),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68, height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _RemoteSessionCoverImage(
                        sessionId: session.id, fit: BoxFit.cover,
                        alignment: Alignment.center,
                        fallbackBuilder: (_) => const _SessionCoverFallback(iconSize: 20),
                      ),
                      if (session.accessTier == AccessTier.coreAccess)
                        Positioned(
                          top: 3, left: 3,
                          child: Image.asset('assets/images/premium-badge.png',
                            width: 21, height: 21,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFD58A), size: 19)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.get(session.titleKey, fallback: session.titleFallback),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('${session.durationMinutes} min · ${_sessionLevelLabel(session)}',
                    style: const TextStyle(color: Color(0xFFCFDCE2), fontSize: 11)),
                ],
              )),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyFocusNavigation extends StatelessWidget {
  const _BodyFocusNavigation();

  @override
  Widget build(BuildContext context) {
    const options = <({String id, String label, String image, IconData icon})>[
      (id: 'neck', label: 'Neck & shoulders', image: 'assets/images/filters/neck_shoulders.png', icon: Icons.self_improvement_rounded),
      (id: 'back', label: 'Upper back', image: 'assets/images/filters/upper_back.png', icon: Icons.accessibility_new_rounded),
      (id: 'lower_back', label: 'Lower back', image: 'assets/images/filters/lower_back.png', icon: Icons.airline_seat_recline_normal_rounded),
      (id: 'hips', label: 'Hips & legs', image: 'assets/images/filters/hips.png', icon: Icons.directions_walk_rounded),
      (id: 'hands', label: 'Hands & wrists', image: 'assets/images/filters/wrists_hands.png', icon: Icons.back_hand_outlined),
    ];
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Focus on an area', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 102,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 2),
            itemBuilder: (context, index) {
              final option = options[index];
              return InkWell(
                onTap: () => context.pushNamed('body-sessions',
                  pathParameters: {'category': option.id}),
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 75,
                  child: Column(
                    children: [
                      Container(
                        height: 56, width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryContainer,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: Image.asset(
                            option.image,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) => Icon(
                              option.icon,
                              color: colors.onPrimaryContainer,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(option.label, maxLines: 2, textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrainingDiscoveryRow extends StatelessWidget {
  const _TrainingDiscoveryRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sessions,
    required this.accessSnapshot,
    required this.layoutIndex,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<SessionSummary> sessions;
  final AccessSnapshot accessSnapshot;
  final int layoutIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = layoutIndex.isOdd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.onPrimaryContainer, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              )),
            ],
          )),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: compact ? 172 : 292,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: compact ? 330 : 266,
              child: compact
                  ? _TrainingHorizontalTile(
                      session: sessions[index],
                      accessSnapshot: accessSnapshot,
                    )
                  : _SessionTile(
                      session: sessions[index],
                      accessSnapshot: accessSnapshot,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

String _sessionLevelLabel(SessionSummary session) {
  switch (session.sessionLevelTag) {
    case SessionLevelTag.flagship:
      return 'Signature';
    case SessionLevelTag.advancedTherapy:
      return 'Advanced therapy';
    case SessionLevelTag.therapy:
      return 'Therapy';
    case SessionLevelTag.freeStarter:
      return session.isBeginnerFriendly ? 'Beginner' : 'All levels';
  }
}

bool _isAdvancedSession(SessionSummary session) =>
    session.sessionLevelTag == SessionLevelTag.advancedTherapy ||
    session.sessionLevelTag == SessionLevelTag.flagship;

class _TrainingHorizontalTile extends StatelessWidget {
  const _TrainingHorizontalTile({
    required this.session,
    required this.accessSnapshot,
  });

  final SessionSummary session;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppText.of(context);
    final locked = session.accessTier == AccessTier.coreAccess &&
        !accessSnapshot.hasCoreAccess;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': session.id},
        ),
        child: Row(
          children: [
            SizedBox(
              width: 142,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RemoteSessionCoverImage(
                    sessionId: session.id,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    fallbackBuilder: (_) => const _SessionCoverFallback(iconSize: 32),
                  ),
                  if (locked)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Image.asset(
                        'assets/images/premium-badge.png',
                        width: 33,
                        height: 33,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFFFD58A),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        t.get(session.titleKey, fallback: session.titleFallback),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${session.durationMinutes} ${t.get('session_duration_unit_min', fallback: 'min')} · ${_sessionLevelLabel(session)}',
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _isAdvancedSession(session)
                            ? colors.onTertiaryContainer
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.arrow_forward_rounded, color: colors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodySessionList extends StatelessWidget {
  const _BodySessionList({
    required this.sessions,
    required this.accessSnapshot,
  });
  final List<SessionSummary> sessions;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 172,
              width: double.infinity,
              child: _TrainingHorizontalTile(
                session: session,
                accessSnapshot: accessSnapshot,
              ),
            ),
          ),
      ],
    );
  }
}


class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.accessSnapshot,
  });

  final SessionSummary session;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isLocked = session.accessTier == AccessTier.coreAccess &&
        !accessSnapshot.hasCoreAccess;

    final title = t.get(session.titleKey, fallback: session.titleFallback);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': session.id},
        ),
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: colors.surface,
            border: Border.all(
              color: colors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.16)
                    : const Color(0xFF3E5874).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PremiumSessionImage(
                      sessionId: session.id,
                      isLocked: isLocked,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w900,
                                    height: 1.02,
                                    letterSpacing: -0.15,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _sessionLevelLabel(session),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _isAdvancedSession(session)
                                    ? colors.onTertiaryContainer
                                    : colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _SessionMetaPill(
                                  label:
                                      '${session.durationMinutes} ${t.get('session_duration_unit_min', fallback: 'min')}',
                                  icon: Icons.timer_outlined,
                                ),
                                const Spacer(),
                                _SessionOpenButton(isLocked: isLocked),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumSessionImage extends StatelessWidget {
  const _PremiumSessionImage({
    required this.sessionId,
    required this.isLocked,
  });

  final String sessionId;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: 1.50,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _RemoteSessionCoverImage(
            sessionId: sessionId,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            fallbackBuilder: (_) => const _SessionCoverFallback(iconSize: 34),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.00),
                  Colors.black.withValues(alpha: 0.16),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          if (isLocked)
            Positioned(
              left: 9, top: 9,
              child: Image.asset('assets/images/premium-badge.png',
                width: 29, height: 29,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFD58A), size: 26)),
            ),
          if (isLocked)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageGlassBadge extends StatelessWidget {
  const _ImageGlassBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white.withValues(alpha: 0.78),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFF5364F6),
        size: 17,
      ),
    );
  }
}

class _SessionMetaPill extends StatelessWidget {
  const _SessionMetaPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFEFF5FA),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE0EAF3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontSize: 10.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionOpenButton extends StatelessWidget {
  const _SessionOpenButton({required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: isLocked
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFF5B6CFF),
                  Color(0xFF16A3B8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isLocked ? colors.surfaceContainerHighest : null,
        boxShadow: [
          BoxShadow(
            color: isLocked
                ? Colors.black.withValues(alpha: 0.06)
                : const Color(0xFF5B6CFF).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: isLocked
          ? Image.asset('assets/images/premium-badge.png', width: 27, height: 27,
              errorBuilder: (_, __, ___) => Icon(Icons.workspace_premium_rounded,
                color: colors.onSurfaceVariant, size: 24))
          : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
    );
  }
}






class _SortButton extends StatelessWidget {
  const _SortButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.56),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded, size: 19),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}


class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF101827) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: colors.primary, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
      ),
    );
  }
}

class ProgramPosterAsset {
  const ProgramPosterAsset._();

  static String pathForProgramId(String programId) {
    return 'assets/images/programs/$programId.png';
  }
}



String _sortLabel(BuildContext context, SessionLibrarySort sort) {
  final t = AppText.of(context);
  switch (sort) {
    case SessionLibrarySort.recommended:
      return t.get('sessions_sort_recommended', fallback: 'Default order');
    case SessionLibrarySort.durationShortest:
      return t.get('sessions_sort_shortest', fallback: 'Duration: shortest');
    case SessionLibrarySort.alphabetical:
      return t.get('sessions_sort_alpha', fallback: 'Alphabetical');
  }
}

String _sortShortLabel(BuildContext context, SessionLibrarySort sort) {
  final t = AppText.of(context);
  switch (sort) {
    case SessionLibrarySort.recommended:
      return t.get('sessions_sort_short_recommended', fallback: 'Default');
    case SessionLibrarySort.durationShortest:
      return t.get('sessions_sort_short_shortest', fallback: 'Shortest');
    case SessionLibrarySort.alphabetical:
      return t.get('sessions_sort_short_az', fallback: 'A–Z');
  }
}



const String _remoteSessionCoverBaseUrl =
    'https://weglabs.com/data/desk-workout/covers/sessions';

String _remoteSessionCoverUrl(String sessionId) =>
    '$_remoteSessionCoverBaseUrl/$sessionId.webp';

class _RemoteSessionCoverImage extends StatelessWidget {
  const _RemoteSessionCoverImage({
    required this.sessionId,
    required this.fit,
    required this.alignment,
    required this.fallbackBuilder,
  });

  final String sessionId;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WidgetBuilder fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _remoteSessionCoverUrl(sessionId),
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallbackBuilder(context);
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/sessions/$sessionId.png',
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallbackBuilder(context),
      ),
    );
  }
}

class _SessionCoverFallback extends StatelessWidget {
  const _SessionCoverFallback({
    this.iconSize = 34,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  colors.primary.withValues(alpha: 0.30),
                  colors.tertiary.withValues(alpha: 0.16),
                  const Color(0xFF0F172A),
                ]
              : [
                  colors.primary.withValues(alpha: 0.16),
                  colors.tertiary.withValues(alpha: 0.10),
                  const Color(0xFFF7FAFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.self_improvement_rounded,
        color: dark ? Colors.white.withValues(alpha: 0.80) : colors.primary,
        size: iconSize,
      ),
    );
  }
}
