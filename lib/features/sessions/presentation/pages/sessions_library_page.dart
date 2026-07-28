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
  const SessionsLibraryPage({super.key});

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
      title: Text(t.get('sessions_title', fallback: 'Training')),
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
            final visibleSessions = _visibleSessions(allSessions);
            return PageOnboarding(
              pageId: 'training_guide_v1',
              tips: [
                OnboardingTip(
                  targetKey: _trainingSessionsGuideKey,
                  icon: Icons.self_improvement_rounded,
                  title: t.get('guide_training_sessions_title', fallback: 'Sessions are single resets'),
                  body: t.get('guide_training_sessions_body', fallback: 'Use sessions when you want one quick recovery exercise right now.'),
                ),
                OnboardingTip(
                  targetKey: _trainingFiltersGuideKey,
                  icon: Icons.search_rounded,
                  title: t.get('guide_training_filter_title', fallback: 'Search and filter'),
                  body: t.get('guide_training_filter_body', fallback: 'Filter by body zone, duration, intensity, or desk-friendly sessions.'),
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
                      KeyedSubtree(
                        key: _trainingFiltersGuideKey,
                        child: _SearchSortBar(
                          searchQuery: _searchQuery,
                          selectedSort: _selectedSort,
                          visibleCount: visibleSessions.length,
                          totalCount: allSessions.length,
                          onSearchChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          onSearchClear: () {
                            setState(() => _searchQuery = '');
                          },
                          onSortChanged: (value) {
                            setState(() => _selectedSort = value);
                          },
                        ),
                      ),
                      _CategoryRail(
                        selectedCategory: _selectedCategory,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                      if (visibleSessions.isEmpty)
                        _MessageCard(
                          title: t.get(
                            'sessions_no_results_title',
                            fallback: 'No sessions match your filters.',
                          ),
                          body: t.get(
                            'sessions_no_results_body',
                            fallback: 'Try another body zone or clear your search.',
                          ),
                          actionLabel: t.get('common_clear', fallback: 'Clear'),
                          onAction: _resetFilters,
                        )
                      else
                        KeyedSubtree(
                          key: _trainingSessionsGuideKey,
                          child: _SessionCardGrid(
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

    result.sort((a, b) => _compareSessions(a, b, _selectedSort));
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
      case SessionLibraryCategory.lowerBack:
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
      case SessionLibraryCategory.wristsForearms:
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
      case SessionLibraryCategory.focus:
        return session.goals.contains(SessionGoal.focusPrep);
      case SessionLibraryCategory.recovery:
        return session.goals.contains(SessionGoal.recovery) ||
            session.goals.contains(SessionGoal.painRelief);
      case SessionLibraryCategory.quietDesk:
        return session.environmentCompatibility.quietFriendly;
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
      case SessionLibrarySort.durationLongest:
        return b.durationMinutes.compareTo(a.durationMinutes);
      case SessionLibrarySort.intensityLowest:
        return _intensityRank(a.intensity).compareTo(_intensityRank(b.intensity));
      case SessionLibrarySort.intensityHighest:
        return _intensityRank(b.intensity).compareTo(_intensityRank(a.intensity));
      case SessionLibrarySort.alphabetical:
        return a.titleFallback.toLowerCase().compareTo(b.titleFallback.toLowerCase());
      case SessionLibrarySort.recommended:
        final aScore = _recommendationScore(a);
        final bScore = _recommendationScore(b);
        if (aScore != bScore) return bScore.compareTo(aScore);
        return a.durationMinutes.compareTo(b.durationMinutes);
    }
  }

  int _recommendationScore(SessionSummary session) {
    var score = 0;
    if (session.environmentCompatibility.deskFriendly) score += 2;
    if (session.goals.contains(SessionGoal.painRelief)) score += 2;
    if (session.goals.contains(SessionGoal.recovery)) score += 1;
    if (session.isBeginnerFriendly) score += 1;
    return score;
  }

  int _intensityRank(SessionIntensity value) {
    switch (value) {
      case SessionIntensity.gentle:
        return 0;
      case SessionIntensity.light:
        return 1;
      case SessionIntensity.moderate:
        return 2;
      case SessionIntensity.strong:
        return 3;
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
                        const SizedBox(height: 7),
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
    required this.visibleCount,
    required this.totalCount,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortChanged,
  });

  final String searchQuery;
  final SessionLibrarySort selectedSort;
  final int visibleCount;
  final int totalCount;
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
        _SectionBlockHeader(
          icon: Icons.self_improvement_rounded,
          title: t.get('training_sessions_section_title', fallback: 'Sessions'),
          subtitle: t.get(
            'training_sessions_section_subtitle',
            fallback: 'Single recovery sessions you can start anytime.',
          ),
          trailing: Text(
            t
                .get(
                  'sessions_visible_count',
                  fallback: '{visible}/{total}',
                )
                .replaceAll('{visible}', widget.visibleCount.toString())
                .replaceAll('{total}', widget.totalCount.toString()),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
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
  SessionLibraryCategory.lowerBack,
  SessionLibraryCategory.wristsForearms,
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
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _visibleSessionCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
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
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 68 : 64,
                height: selected ? 68 : 64,
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
                      width: 56,
                      height: 56,
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
    case SessionLibraryCategory.lowerBack:
      return 'assets/images/filters/lower_back_hips.png';
    case SessionLibraryCategory.wristsForearms:
      return 'assets/images/filters/wrists_hands.png';
    case SessionLibraryCategory.focus:
      return 'assets/images/filters/focus.png';
    case SessionLibraryCategory.recovery:
      return 'assets/images/filters/recovery.png';
    case SessionLibraryCategory.quietDesk:
      return 'assets/images/filters/quiet_desk.png';
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
    case SessionLibraryCategory.lowerBack:
      return Icons.self_improvement_rounded;
    case SessionLibraryCategory.wristsForearms:
      return Icons.pan_tool_alt_rounded;
    case SessionLibraryCategory.focus:
      return Icons.center_focus_strong_rounded;
    case SessionLibraryCategory.recovery:
      return Icons.spa_rounded;
    case SessionLibraryCategory.quietDesk:
      return Icons.volume_off_rounded;
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
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF26324A)
                  : const Color(0xFFDCE5F0),
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
                            const SizedBox(height: 8),
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
    case SessionLibraryCategory.lowerBack:
      return t.get('sessions_category_lower_back', fallback: 'Lower back / hips');
    case SessionLibraryCategory.wristsForearms:
      return t.get('sessions_category_wrists', fallback: 'Wrists / hands');
    case SessionLibraryCategory.focus:
      return t.get('sessions_category_focus', fallback: 'Focus');
    case SessionLibraryCategory.recovery:
      return t.get('sessions_category_recovery', fallback: 'Recovery');
    case SessionLibraryCategory.quietDesk:
      return t.get('sessions_category_quiet', fallback: 'Quiet');
  }
}

String _sortLabel(BuildContext context, SessionLibrarySort sort) {
  final t = AppText.of(context);
  switch (sort) {
    case SessionLibrarySort.recommended:
      return t.get('sessions_sort_recommended', fallback: 'Recommended');
    case SessionLibrarySort.durationShortest:
      return t.get('sessions_sort_shortest', fallback: 'Duration: shortest');
    case SessionLibrarySort.durationLongest:
      return t.get('sessions_sort_longest', fallback: 'Duration: longest');
    case SessionLibrarySort.intensityLowest:
      return t.get('sessions_sort_low_intensity', fallback: 'Intensity: low');
    case SessionLibrarySort.intensityHighest:
      return t.get('sessions_sort_high_intensity', fallback: 'Intensity: high');
    case SessionLibrarySort.alphabetical:
      return t.get('sessions_sort_alpha', fallback: 'Alphabetical');
  }
}

String _sortShortLabel(BuildContext context, SessionLibrarySort sort) {
  final t = AppText.of(context);
  switch (sort) {
    case SessionLibrarySort.recommended:
      return t.get('sessions_sort_short_recommended', fallback: 'Best');
    case SessionLibrarySort.durationShortest:
      return t.get('sessions_sort_short_shortest', fallback: 'Shortest');
    case SessionLibrarySort.durationLongest:
      return t.get('sessions_sort_short_longest', fallback: 'Longest');
    case SessionLibrarySort.intensityLowest:
      return t.get('sessions_sort_short_low', fallback: 'Light');
    case SessionLibrarySort.intensityHighest:
      return t.get('sessions_sort_short_high', fallback: 'Strong');
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
