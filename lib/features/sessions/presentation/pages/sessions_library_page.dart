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
import '../../../programs/application/recovery_program_providers.dart';
import '../../../programs/domain/recovery_program_models.dart';
import '../../application/sessions_providers.dart';
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
  final GlobalKey _trainingFiltersGuideKey = GlobalKey(debugLabel: 'training_filters_guide');
  final GlobalKey _trainingSessionsGuideKey = GlobalKey(debugLabel: 'training_sessions_guide');

  String _searchQuery = '';
  SessionLibraryCategory _selectedCategory = SessionLibraryCategory.all;
  SessionLibrarySort _selectedSort = SessionLibrarySort.recommended;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      ref.invalidate(sessionSummariesProvider);
      ref.invalidate(accessSnapshotProvider);
    });

    final sessionsAsync = ref.watch(sessionSummariesProvider);
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

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = SessionLibraryCategory.all;
      _selectedSort = SessionLibrarySort.recommended;
    });
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

class _ProgramRail extends StatelessWidget {
  const _ProgramRail({
    required this.programs,
    required this.activeProgram,
  });

  final List<RecoveryProgramSummary> programs;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final hasActive = activeProgram != null && !activeProgram!.isCompleted;
    final sorted = _sortedPrograms(programs, activeProgram);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionBlockHeader(
          icon: Icons.route_rounded,
          title: t.get('training_programs_title', fallback: 'Programs'),
          subtitle: hasActive
              ? t
                  .get(
                    'training_programs_active_subtitle',
                    fallback:
                        'Continue your active recovery journey — Mission {day} of {total}.',
                  )
                  .replaceAll('{day}', activeProgram!.currentDay.toString())
                  .replaceAll('{total}', activeProgram!.durationDays.toString())
              : t.get(
                  'training_programs_subtitle',
                  fallback: 'Guided therapy journeys for structured recovery.',
                ),
          actionLabel: t.get('common_view_all', fallback: 'View all'),
          onAction: () => context.pushNamed('recovery-programs'),
        ),
        const SizedBox(height: 10),
        if (sorted.isEmpty)
          const _SkeletonBox(height: 160)
        else
          SizedBox(
            height: hasActive ? 190 : 158,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final program = sorted[index];
                final isActive = activeProgram?.programId == program.id;
                return SizedBox(
                  width: isActive ? 300 : 238,
                  child: _MiniProgramPoster(
                    program: program,
                    activeProgram: activeProgram,
                    isActive: isActive,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  List<RecoveryProgramSummary> _sortedPrograms(
    List<RecoveryProgramSummary> programs,
    RecoveryProgramDashboardProgress? active,
  ) {
    final list = [...programs];
    final activeId = active?.programId;
    if (activeId != null) {
      list.sort((a, b) {
        if (a.id == activeId) return -1;
        if (b.id == activeId) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    }
    return list;
  }
}

class _MiniProgramPoster extends StatelessWidget {
  const _MiniProgramPoster({
    required this.program,
    required this.activeProgram,
    required this.isActive,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDashboardProgress? activeProgram;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final completed = isActive ? activeProgram!.completedDayCount : 0;
    final displayDay = isActive ? activeProgram!.currentDay : 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'recovery-program-detail',
            pathParameters: {'id': program.id},
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: _programGradient(program.id),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RemoteProgramCoverImage(
                  programId: program.id,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  fallbackBuilder: (_) => const SizedBox.shrink(),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.30),
                        Colors.black.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WhitePill(
                        label: isActive
                            ? t.get('program_active_badge', fallback: 'Active')
                            : '${program.durationDays} ${t.get('program_day_unit', fallback: 'missions')}',
                      ),
                      const Spacer(),
                      if (isActive) ...[
                        Text(
                          'MISSION $displayDay',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                      SizedBox(
                        width: isActive ? 190 : 154,
                        child: Text(
                          t.get(program.titleKey, fallback: program.titleFallback),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      _MiniProgress(
                        completed: completed,
                        total: program.durationDays,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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


const List<SessionLibraryCategory> _visibleSessionCategories = [
  SessionLibraryCategory.all,
  SessionLibraryCategory.neckShoulders,
  SessionLibraryCategory.upperBack,
  SessionLibraryCategory.lowerBackHips,
  SessionLibraryCategory.wristsHands,
];

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.selectedCategory,
    required this.onChanged,
  });

  final SessionLibraryCategory selectedCategory;
  final ValueChanged<SessionLibraryCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _visibleSessionCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final category = _visibleSessionCategories[index];
          return _CategoryStoryItem(
            label: _categoryLabel(context, category),
            imagePath: _categoryImagePath(category),
            fallbackIcon: _categoryFallbackIcon(category),
            selected: selectedCategory == category,
            onTap: () => onChanged(category),
          );
        },
      ),
    );
  }
}

class _CategoryStoryItem extends StatelessWidget {
  const _CategoryStoryItem({
    required this.label,
    required this.imagePath,
    required this.fallbackIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final IconData fallbackIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 58 : 56,
                height: selected ? 58 : 56,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary,
                            colors.tertiary,
                          ],
                        )
                      : null,
                  color: selected
                      ? null
                      : isDark
                          ? const Color(0xFF26324A)
                          : const Color(0xFFDCE5F0),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF101827)
                        : colors.surface,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              fallbackIcon,
                              size: 27,
                              color: selected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  height: 1.05,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryImagePath(SessionLibraryCategory category) {
  switch (category) {
    case SessionLibraryCategory.all:
      return 'assets/images/filters/all.png';
    case SessionLibraryCategory.neckShoulders:
      return 'assets/images/filters/neck_shoulders.png';
    case SessionLibraryCategory.upperBack:
      return 'assets/images/filters/upper_back.png';
    case SessionLibraryCategory.lowerBackHips:
      return 'assets/images/filters/lower_back_hips.png';
    case SessionLibraryCategory.wristsHands:
      return 'assets/images/filters/wrists_hands.png';
  }
}

IconData _categoryFallbackIcon(SessionLibraryCategory category) {
  switch (category) {
    case SessionLibraryCategory.all:
      return Icons.apps_rounded;
    case SessionLibraryCategory.neckShoulders:
      return Icons.accessibility_new_rounded;
    case SessionLibraryCategory.upperBack:
      return Icons.airline_seat_recline_normal_rounded;
    case SessionLibraryCategory.lowerBackHips:
      return Icons.self_improvement_rounded;
    case SessionLibraryCategory.wristsHands:
      return Icons.pan_tool_alt_rounded;
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
    required this.accessSnapshot,
  });

  final List<SessionSummary> sessions;
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
    if (code.contains('neck') || code.contains('shoulder')) return 'neck';
    if (code.contains('upper_back') || code.contains('thoracic') ||
        code.contains('chest')) return 'upper_back';
    if (code.contains('lower_back') || code.contains('low_back') ||
        code.contains('lumbar') || code == 'back') return 'lower_back';
    if (code.contains('hip') || code.contains('glute') ||
        code.contains('hamstring')) return 'hips';
    if (code.contains('wrist') || code.contains('hand') ||
        code.contains('finger') || code.contains('forearm')) return 'hands';
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SessionSummary>>{
      for (final id in _groupIds) id: <SessionSummary>[],
    };
    final topSessions = _rankedPopularSessions(sessions);
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
          if (id == 'upper_back' && topSessions.isNotEmpty) ...[
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
const _popularSessionIds = <String>[
  'sess_cervical_isometric_stability_07',
  'sess_towel_deep_neck_flexor_control_07',
  'sess_serratus_wall_slide_miniband_07',
  'sess_shoulder_release_04',
  'sess_hip_flexor_release_glute_rebalance_07',
  'sess_band_rotator_cuff_scapular_control_08',
  'sess_pec_minor_ball_release_band_row_07',
  'sess_ball_upper_trap_levator_reset_07',
  'sess_chair_core_bracing_low_back_support_07',
  'sess_desk_thoracic_rotation_scapular_integration_07',
];

List<SessionSummary> _rankedPopularSessions(List<SessionSummary> sessions) {
  final byId = {for (final session in sessions) session.id: session};
  return [
    for (final id in _popularSessionIds)
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
    final colors = Theme.of(context).colorScheme;
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
          const Text('MOST CHOSEN', style: TextStyle(
            color: Color(0xFF78E1C6), fontSize: 11,
            letterSpacing: 1.8, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 7),
          const Text('Top 10 sessions', style: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 5),
          const Text('Popular picks from real session starts',
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
                    rank: _popularSessionIds.indexOf(displayed[i].id) + 1,
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
                  child: _RemoteSessionCoverImage(
                    sessionId: session.id, fit: BoxFit.cover,
                    alignment: Alignment.center,
                    fallbackBuilder: (_) => const _SessionCoverFallback(iconSize: 20),
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
    const options = <({String id, String label, IconData icon})>[
      (id: 'neck', label: 'Neck & shoulders', icon: Icons.self_improvement_rounded),
      (id: 'back', label: 'Upper back', icon: Icons.accessibility_new_rounded),
      (id: 'lower_back', label: 'Lower back', icon: Icons.airline_seat_recline_normal_rounded),
      (id: 'hips', label: 'Hips & legs', icon: Icons.directions_walk_rounded),
      (id: 'hands', label: 'Hands & wrists', icon: Icons.back_hand_outlined),
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
                        child: Icon(option.icon, color: colors.onPrimaryContainer, size: 26),
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
                      child: const _ImageGlassBadge(icon: Icons.lock_rounded),
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

class _SessionCardGrid extends StatelessWidget {
  const _SessionCardGrid({
    required this.sessions,
    required this.accessSnapshot,
  });

  final List<SessionSummary> sessions;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = _gridColumnsForWidth(width);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sessions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: _gridMainAxisExtentForWidth(width),
      ),
      itemBuilder: (context, index) {
        return _SessionTile(
          session: sessions[index],
          accessSnapshot: accessSnapshot,
        );
      },
    );
  }

  int _gridColumnsForWidth(double width) {
    if (width < 380) return 1;
    if (width < 720) return 2;
    if (width < 1100) return 3;
    return 4;
  }

  double _gridMainAxisExtentForWidth(double width) {
    if (width < 380) return 326;
    if (width < 560) return 238;
    if (width < 720) return 246;
    if (width < 900) return 258;
    if (width < 1100) return 274;
    return 292;
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
          Positioned(
            left: 9,
            top: 9,
            child: _ImageGlassBadge(
              icon: isLocked ? Icons.lock_rounded : Icons.bolt_rounded,
            ),
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
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
        color: isLocked ? colors.onSurfaceVariant : Colors.white,
        size: 24,
      ),
    );
  }
}



class _SectionBlockHeader extends StatelessWidget {
  const _SectionBlockHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF101827) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: colors.primary, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total;
    final value = (completed / safeTotal).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: Colors.white.withValues(alpha: 0.28),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? colors.primary
              : isDark
                  ? const Color(0xFF101827)
                  : Colors.white,
          border: Border.all(
            color: selected
                ? colors.primary
                : isDark
                    ? const Color(0xFF26324A)
                    : const Color(0xFFDCE5F0),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
        ),
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

List<Color> _programGradient(String programId) {
  switch (programId) {
    case 'prog_desk_neck_shoulder_reset_14':
      return const [Color(0xFF0891B2), Color(0xFF1D4ED8)];
    case 'prog_lower_back_hip_relief_14':
      return const [Color(0xFF6D28D9), Color(0xFF1E1B4B)];
    case 'prog_wrist_forearm_mouse_recovery_10':
      return const [Color(0xFF0F766E), Color(0xFF0F172A)];
    case 'prog_upper_back_posture_control_14':
      return const [Color(0xFF2563EB), Color(0xFF312E81)];
    case 'prog_full_desk_body_reset_21':
      return const [Color(0xFF0EA5E9), Color(0xFF0F172A)];
    default:
      return const [Color(0xFF2563EB), Color(0xFF0F172A)];
  }
}


String _categoryLabel(BuildContext context, SessionLibraryCategory category) {
  final t = AppText.of(context);
  switch (category) {
    case SessionLibraryCategory.all:
      return t.get('sessions_category_all', fallback: 'All');
    case SessionLibraryCategory.neckShoulders:
      return t.get('sessions_category_neck_shoulders', fallback: 'Neck & shoulders');
    case SessionLibraryCategory.upperBack:
      return t.get('sessions_category_upper_back', fallback: 'Upper back');
    case SessionLibraryCategory.lowerBackHips:
      return t.get('sessions_category_lower_back_hips', fallback: 'Lower back & hips');
    case SessionLibraryCategory.wristsHands:
      return t.get('sessions_category_wrists_hands', fallback: 'Wrists & hands');
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


const String _remoteProgramCoverBaseUrl =
    'https://weglabs.com/data/desk-workout/covers/programs';

String _remoteProgramCoverUrl(String programId) =>
    '$_remoteProgramCoverBaseUrl/$programId.webp';

class _RemoteProgramCoverImage extends StatelessWidget {
  const _RemoteProgramCoverImage({
    required this.programId,
    required this.fit,
    required this.alignment,
    required this.fallbackBuilder,
  });

  final String programId;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WidgetBuilder fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _remoteProgramCoverUrl(programId),
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallbackBuilder(context);
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        ProgramPosterAsset.pathForProgramId(programId),
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallbackBuilder(context),
      ),
    );
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
    this.dark = false,
  });

  final double iconSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
