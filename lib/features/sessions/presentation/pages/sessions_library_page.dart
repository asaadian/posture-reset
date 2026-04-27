import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/adaptive_section_title.dart';
import '../../application/sessions_providers.dart';
import '../../domain/session_models.dart';
import '../session_library_models.dart';
import '../widgets/session_card.dart';
import '../widgets/session_horizontal_list.dart';
import '../widgets/sessions_category_tabs.dart';
import '../widgets/sessions_search_bar.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';

class SessionsLibraryPage extends ConsumerStatefulWidget {
  const SessionsLibraryPage({super.key});

  @override
  ConsumerState<SessionsLibraryPage> createState() =>
      _SessionsLibraryPageState();
}

class _SessionsLibraryPageState extends ConsumerState<SessionsLibraryPage> {
  String _searchQuery = '';
  SessionLibraryCategory _selectedCategory = SessionLibraryCategory.all;
  SessionLibrarySort _selectedSort = SessionLibrarySort.recommended;
  bool _silentOnly = false;
  bool _beginnerOnly = false;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final sessionsAsync = ref.watch(sessionSummariesProvider);
    final accessSnapshotAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('sessions_title', fallback: 'Sessions')),
      bodyBuilder: (context, pageInfo) {
        return sessionsAsync.when(
          loading: () => ListView(
            children: [
              ResponsiveContentSection(
                spacing: pageInfo.sectionSpacing,
                children: [
                  _SearchAndSortRow(
                    searchQuery: _searchQuery,
                    selectedSort: _selectedSort,
                    onSearchChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSearchClear: () {
                      setState(() => _searchQuery = '');
                    },
                    onSortSelected: (value) {
                      setState(() => _selectedSort = value);
                    },
                  ),
                  SessionsCategoryTabs(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const _LibraryLoadingCard(),
                  const _LibraryLoadingCard(),
                ],
              ),
            ],
          ),
          error: (error, _) => ListView(
            children: [
              ResponsiveContentSection(
                spacing: pageInfo.sectionSpacing,
                children: [
                  _SearchAndSortRow(
                    searchQuery: _searchQuery,
                    selectedSort: _selectedSort,
                    onSearchChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSearchClear: () {
                      setState(() => _searchQuery = '');
                    },
                    onSortSelected: (value) {
                      setState(() => _selectedSort = value);
                    },
                  ),
                  SessionsCategoryTabs(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  _LibraryErrorCard(
                    error: error.toString(),
                    onRetry: () => ref.invalidate(sessionSummariesProvider),
                  ),
                ],
              ),
            ],
          ),
          data: (allSessions) {
            final accessSnapshot = accessSnapshotAsync.maybeWhen(
              data: (value) => value,
              orElse: () => AccessSnapshot.guest,
            );

            final visibleSessions = _buildVisibleSessions(allSessions);
            final featuredSessions = _buildFeaturedSessions(visibleSessions);

            final hasAnySessions = allSessions.isNotEmpty;
            final hasVisibleSessions = visibleSessions.isNotEmpty;

            return ListView(
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
                  children: [
                    if (featuredSessions.isNotEmpty) ...[
                      AdaptiveSectionTitle(
                        titleKey: 'sessions_featured_title',
                        titleFallback: 'Featured Sessions',
                      ),
                      SessionHorizontalList(
                        sessions: featuredSessions,
                        accessSnapshot: accessSnapshot,
                      ),
                    ],
                    _SearchAndSortRow(
                      searchQuery: _searchQuery,
                      selectedSort: _selectedSort,
                      onSearchChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onSearchClear: () {
                        setState(() => _searchQuery = '');
                      },
                      onSortSelected: (value) {
                        setState(() => _selectedSort = value);
                      },
                    ),
                    SessionsCategoryTabs(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                    if (!hasAnySessions)
                      const _LibraryEmptyCard()
                    else if (!hasVisibleSessions && _hasActiveFilters)
                      _LibraryNoResultsCard(
                        onClearFilters: _resetFilters,
                      )
                    else ...[
                      AdaptiveSectionTitle(
                        titleKey: 'sessions_all_results_title',
                        titleFallback: 'All Sessions',
                      ),
                      _SessionsResultSummary(
                        visibleCount: visibleSessions.length,
                        totalCount: allSessions.length,
                      ),
                      _SessionsGrid(
                        sessions: visibleSessions,
                        accessSnapshot: accessSnapshot,
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool get _hasActiveFilters {
    return _searchQuery.trim().isNotEmpty ||
        _selectedCategory != SessionLibraryCategory.all ||
        _selectedSort != SessionLibrarySort.recommended ||
        _silentOnly ||
        _beginnerOnly;
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = SessionLibraryCategory.all;
      _selectedSort = SessionLibrarySort.recommended;
      _silentOnly = false;
      _beginnerOnly = false;
    });
  }

  List<SessionSummary> _buildVisibleSessions(List<SessionSummary> allSessions) {
    final normalizedQuery = _normalizeSearchText(_searchQuery);
    final queryTerms = _extractSearchTerms(_searchQuery);
    final canUseSilentFilter = _hasSilentFilterValue(allSessions);
    final canUseBeginnerFilter = _hasBeginnerFilterValue(allSessions);

    final result = allSessions.where((session) {
      if (!_matchesCategory(session, _selectedCategory)) {
        return false;
      }

      if (canUseSilentFilter && _silentOnly && !session.isSilentFriendly) {
        return false;
      }

      if (canUseBeginnerFilter &&
          _beginnerOnly &&
          !session.isBeginnerFriendly) {
        return false;
      }

      if (normalizedQuery.isNotEmpty &&
          !_matchesSearch(session, normalizedQuery, queryTerms)) {
        return false;
      }

      return true;
    }).toList(growable: true);

    result.sort((a, b) => _compareSessions(a, b, _selectedSort));
    return result;
  }

  List<SessionSummary> _buildFeaturedSessions(List<SessionSummary> sessions) {
    const featuredIds = <String>[
      'sess_neck_reset_02',
      'sess_wrist_relief_02',
      'sess_pre_focus_activation_02',
      'sess_silent_desk_reset_03',
      'sess_lower_back_unload_04',
    ];

    final orderMap = {
      for (var i = 0; i < featuredIds.length; i++) featuredIds[i]: i,
    };

    final featured = sessions
        .where((session) => orderMap.containsKey(session.id))
        .toList(growable: true);

    featured.sort((a, b) {
      final aOrder = orderMap[a.id] ?? 999999;
      final bOrder = orderMap[b.id] ?? 999999;
      return aOrder.compareTo(bOrder);
    });

    return featured;
  }
}

class _SearchAndSortRow extends StatelessWidget {
  const _SearchAndSortRow({
    required this.searchQuery,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortSelected,
  });

  final String searchQuery;
  final SessionLibrarySort selectedSort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<SessionLibrarySort> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SessionsSearchBar(
            value: searchQuery,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 56,
            maxWidth: 170,
          ),
          child: _SortButton(
            selectedSort: selectedSort,
            onSelected: onSortSelected,
          ),
        ),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.selectedSort,
    required this.onSelected,
  });

  final SessionLibrarySort selectedSort;
  final ValueChanged<SessionLibrarySort> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = _sortLabel(context, selectedSort);
    final theme = Theme.of(context);

    return PopupMenuButton<SessionLibrarySort>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SessionLibrarySort.recommended,
          child: Text(_sortLabel(context, SessionLibrarySort.recommended)),
        ),
        PopupMenuItem(
          value: SessionLibrarySort.durationShortest,
          child: Text(_sortLabel(context, SessionLibrarySort.durationShortest)),
        ),
        PopupMenuItem(
          value: SessionLibrarySort.durationLongest,
          child: Text(_sortLabel(context, SessionLibrarySort.durationLongest)),
        ),
        PopupMenuItem(
          value: SessionLibrarySort.intensityLowest,
          child: Text(_sortLabel(context, SessionLibrarySort.intensityLowest)),
        ),
        PopupMenuItem(
          value: SessionLibrarySort.intensityHighest,
          child: Text(_sortLabel(context, SessionLibrarySort.intensityHighest)),
        ),
        PopupMenuItem(
          value: SessionLibrarySort.alphabetical,
          child: Text(_sortLabel(context, SessionLibrarySort.alphabetical)),
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_vert, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _sortLabel(BuildContext context, SessionLibrarySort sort) {
  final t = AppText.of(context);

  switch (sort) {
    case SessionLibrarySort.recommended:
      return t.get('sessions_sort_recommended', fallback: 'Recommended');
    case SessionLibrarySort.durationShortest:
      return t.get(
        'sessions_sort_duration_shortest',
        fallback: 'Shortest',
      );
    case SessionLibrarySort.durationLongest:
      return t.get(
        'sessions_sort_duration_longest',
        fallback: 'Longest',
      );
    case SessionLibrarySort.intensityLowest:
      return t.get(
        'sessions_sort_intensity_lowest',
        fallback: 'Lowest intensity',
      );
    case SessionLibrarySort.intensityHighest:
      return t.get(
        'sessions_sort_intensity_highest',
        fallback: 'Highest intensity',
      );
    case SessionLibrarySort.alphabetical:
      return t.get(
        'sessions_sort_alphabetical',
        fallback: 'A–Z',
      );
  }
}

class _SessionsResultSummary extends StatelessWidget {
  const _SessionsResultSummary({
    required this.visibleCount,
    required this.totalCount,
  });

  final int visibleCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final template = t.get(
      'sessions_results_summary',
      fallback: 'Showing {visible} of {total} sessions',
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        template
            .replaceAll('{visible}', visibleCount.toString())
            .replaceAll('{total}', totalCount.toString()),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _SessionsGrid extends StatelessWidget {
  const _SessionsGrid({
    required this.sessions,
    required this.accessSnapshot,
  });

  final List<SessionSummary> sessions;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final t = AppText.of(context);

    final crossAxisCount = width >= 1200
        ? 3
        : width >= 700
            ? 2
            : 1;

    final mainAxisExtent = crossAxisCount == 1
        ? 250.0
        : crossAxisCount == 2
            ? 285.0
            : 300.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isLocked = !AccessPolicy.canAccessTier(
          snapshot: accessSnapshot,
          tier: session.accessTier,
        ).allowed;

        return SessionCard.fromSummary(
          session: session,
          t: t,
          width: double.infinity,
          isLocked: isLocked,
        );
      },
    );
  }
}

class _LibraryLoadingCard extends StatelessWidget {
  const _LibraryLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _LibraryErrorCard extends StatelessWidget {
  const _LibraryErrorCard({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get(
                'sessions_error_title',
                fallback: 'Could not load sessions',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              t.get(
                'sessions_error_body',
                fallback:
                    'The session library could not be loaded. Try again.',
              ),
            ),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(t.get('common_retry', fallback: 'Retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryEmptyCard extends StatelessWidget {
  const _LibraryEmptyCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get(
                'sessions_empty_title',
                fallback: 'No sessions available',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              t.get(
                'sessions_empty_body',
                fallback:
                    'No active sessions are available in the catalog right now.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryNoResultsCard extends StatelessWidget {
  const _LibraryNoResultsCard({
    required this.onClearFilters,
  });

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get(
                'sessions_no_results_title',
                fallback: 'No matching sessions',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              t.get(
                'sessions_no_results_body',
                fallback:
                    'Try a different search, category, or sort setting.',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onClearFilters,
              child: Text(
                t.get(
                  'sessions_clear_filters_cta',
                  fallback: 'Clear filters',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _hasSilentFilterValue(List<SessionSummary> sessions) {
  if (sessions.isEmpty) {
    return false;
  }

  final silentCount =
      sessions.where((session) => session.isSilentFriendly).length;
  return silentCount > 0 && silentCount < sessions.length;
}

bool _hasBeginnerFilterValue(List<SessionSummary> sessions) {
  if (sessions.isEmpty) {
    return false;
  }

  final beginnerCount =
      sessions.where((session) => session.isBeginnerFriendly).length;
  return beginnerCount > 0 && beginnerCount < sessions.length;
}

bool _matchesSearch(
  SessionSummary session,
  String normalizedQuery,
  Set<String> queryTerms,
) {
  final normalizedHaystack = _buildSearchHaystack(session);
  if (normalizedHaystack.contains(normalizedQuery)) {
    return true;
  }

  if (queryTerms.isEmpty) {
    return false;
  }

  return queryTerms.every(normalizedHaystack.contains);
}

String _buildSearchHaystack(SessionSummary session) {
  final parts = <String>[
    session.id,
    session.titleKey,
    session.titleFallback,
    session.subtitleKey,
    session.subtitleFallback,
    session.shortDescriptionKey,
    session.shortDescriptionFallback,
    ...session.tags.map((tag) => tag.code),
    ...session.tags.map((tag) => tag.labelKey),
    ...session.tags.map((tag) => tag.labelFallback),
    ...session.painTargets.map((target) => target.code),
    ...session.painTargets.map((target) => target.labelKey),
    ...session.painTargets.map((target) => target.labelFallback),
    ...session.goals.map(_goalSearchToken),
    ..._environmentSearchTokens(session),
    ..._modeSearchTokens(session),
    ..._painTargetSynonyms(session),
    ..._tagSynonyms(session),
  ];

  return _normalizeSearchText(parts.join(' '));
}

Set<String> _extractSearchTerms(String rawQuery) {
  final normalized = _normalizeSearchText(rawQuery);
  if (normalized.isEmpty) {
    return const <String>{};
  }

  final directTerms = normalized
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toSet();

  final expandedTerms = <String>{...directTerms};
  for (final term in directTerms) {
    expandedTerms.addAll(_expandSearchSynonyms(term));
  }

  if (normalized.contains(' ')) {
    expandedTerms.add(normalized);
    expandedTerms.addAll(_expandSearchSynonyms(normalized));
  }

  return expandedTerms;
}

String _normalizeSearchText(String value) {
  var result = value.toLowerCase().trim();

  const replacements = <String, String>{
    '‌': ' ',
    '_': ' ',
    '-': ' ',
    '/': ' ',
    '،': ' ',
    ',': ' ',
    '.': ' ',
    '(': ' ',
    ')': ' ',
    ':': ' ',
    ';': ' ',
    '  ': ' ',
    'ك': 'ک',
    'ي': 'ی',
    'ۀ': 'ه',
    'ؤ': 'و',
    'إ': 'ا',
    'أ': 'ا',
    'آ': 'ا',
  };

  replacements.forEach((from, to) {
    result = result.replaceAll(from, to);
  });

  result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
  return result;
}

Set<String> _expandSearchSynonyms(String term) {
  final normalized = _normalizeSearchText(term);

  const groups = <List<String>>[
    ['neck', 'nacken', 'گردن'],
    ['shoulder', 'shoulders', 'schulter', 'schultern', 'شانه', 'شونه'],
    ['upper back', 'oberer rucken', 'oberer ruecken', 'بالای کمر', 'پشت بالا', 'پشت'],
    ['lower back', 'unterer rucken', 'unterer ruecken', 'lumbar', 'کمر', 'پایین کمر'],
    ['back', 'rucken', 'ruecken', 'کمر', 'پشت'],
    ['wrist', 'wrists', 'handgelenk', 'handgelenke', 'مچ', 'مچ دست'],
    ['forearm', 'forearms', 'unterarm', 'unterarme', 'ساعد'],
    ['hand', 'hands', 'hande', 'haende', 'دست', 'دست ها', 'دستها'],
    ['desk', 'desk safe', 'desk friendly', 'schreibtisch', 'میز'],
    ['office', 'office friendly', 'büro', 'buero', 'اداره', 'محیط کار'],
    ['quiet', 'silent', 'leise', 'ruhig', 'بی صدا', 'بیصدا', 'ساکت'],
    ['focus', 'focus prep', 'fokus', 'تمرکز'],
    ['recovery', 'erholung', 'ریکاوری', 'بازیابی'],
    ['pain', 'pain relief', 'schmerz', 'schmerzen', 'درد'],
    ['posture', 'haltung', 'پوسچر', 'وضعیت', 'وضعیت بدنی'],
    ['typing', 'keyboard', 'tastatur', 'تایپ', 'کیبورد'],
  ];

  for (final group in groups) {
    if (group.contains(normalized)) {
      return group.map(_normalizeSearchText).toSet();
    }
  }

  if (normalized.contains(' ')) {
    final expanded = <String>{normalized};
    for (final part in normalized.split(' ')) {
      if (part.isNotEmpty) {
        expanded.addAll(_expandSearchSynonyms(part));
      }
    }
    return expanded;
  }

  return {normalized};
}

List<String> _painTargetSynonyms(SessionSummary session) {
  final synonyms = <String>{};

  for (final target in session.painTargets) {
    final code = _normalizeSearchText(target.code);
    final label = _normalizeSearchText(target.labelFallback);

    synonyms.addAll(_expandSearchSynonyms(code));
    synonyms.addAll(_expandSearchSynonyms(label));

    if (code.contains('neck')) {
      synonyms.addAll(_expandSearchSynonyms('neck'));
    }
    if (code.contains('shoulder')) {
      synonyms.addAll(_expandSearchSynonyms('shoulder'));
    }
    if (code.contains('upper back') ||
        code.contains('upper_back') ||
        code.contains('mid back') ||
        code.contains('thoracic')) {
      synonyms.addAll(_expandSearchSynonyms('upper back'));
    }
    if (code.contains('lower back') || code.contains('lower_back')) {
      synonyms.addAll(_expandSearchSynonyms('lower back'));
      synonyms.addAll(_expandSearchSynonyms('back'));
    }
    if (code.contains('wrist')) {
      synonyms.addAll(_expandSearchSynonyms('wrist'));
    }
    if (code.contains('forearm')) {
      synonyms.addAll(_expandSearchSynonyms('forearm'));
    }
    if (code.contains('hand')) {
      synonyms.addAll(_expandSearchSynonyms('hand'));
    }
  }

  return synonyms.toList(growable: false);
}

List<String> _tagSynonyms(SessionSummary session) {
  final synonyms = <String>{};

  for (final tag in session.tags) {
    synonyms.addAll(_expandSearchSynonyms(tag.code));
    synonyms.addAll(_expandSearchSynonyms(tag.labelFallback));
  }

  if (session.isSilentFriendly) {
    synonyms.addAll(_expandSearchSynonyms('silent'));
  }

  if (session.environmentCompatibility.deskFriendly) {
    synonyms.addAll(_expandSearchSynonyms('desk'));
  }

  if (session.environmentCompatibility.officeFriendly) {
    synonyms.addAll(_expandSearchSynonyms('office'));
  }

  return synonyms.toList(growable: false);
}

bool _matchesCategory(SessionSummary session, SessionLibraryCategory category) {
  switch (category) {
    case SessionLibraryCategory.all:
      return true;
    case SessionLibraryCategory.neckShoulders:
      return session.painTargets.any((target) {
        final code = _normalizeSearchText(target.code);
        return code.contains('neck') || code.contains('shoulder');
      });
    case SessionLibraryCategory.upperBack:
      return session.painTargets.any((target) {
        final code = _normalizeSearchText(target.code);
        return code.contains('upper back') ||
            code.contains('upper_back') ||
            code.contains('mid back') ||
            code.contains('thoracic');
      });
    case SessionLibraryCategory.lowerBack:
      return session.painTargets.any((target) {
        final code = _normalizeSearchText(target.code);
        return code.contains('lower back') || code.contains('lower_back');
      });
    case SessionLibraryCategory.wristsForearms:
      return session.painTargets.any((target) {
        final code = _normalizeSearchText(target.code);
        return code.contains('wrist') ||
            code.contains('forearm') ||
            code.contains('hand');
      });
    case SessionLibraryCategory.focus:
      return session.goals.contains(SessionGoal.focusPrep) ||
          session.modeCompatibility.focusMode;
    case SessionLibraryCategory.recovery:
      return session.goals.contains(SessionGoal.recovery) ||
          session.goals.contains(SessionGoal.decompression) ||
          session.goals.contains(SessionGoal.painRelief);
    case SessionLibraryCategory.quietDesk:
      return session.environmentCompatibility.deskFriendly ||
          session.environmentCompatibility.officeFriendly ||
          session.environmentCompatibility.quietFriendly ||
          session.isSilentFriendly;
  }
}

int _compareSessions(
  SessionSummary a,
  SessionSummary b,
  SessionLibrarySort sort,
) {
  switch (sort) {
    case SessionLibrarySort.recommended:
      final aScore = _recommendationScore(a);
      final bScore = _recommendationScore(b);
      if (aScore != bScore) {
        return bScore.compareTo(aScore);
      }
      return a.durationMinutes.compareTo(b.durationMinutes);
    case SessionLibrarySort.durationShortest:
      return a.durationMinutes.compareTo(b.durationMinutes);
    case SessionLibrarySort.durationLongest:
      return b.durationMinutes.compareTo(a.durationMinutes);
    case SessionLibrarySort.intensityLowest:
      return _intensityRank(a.intensity).compareTo(_intensityRank(b.intensity));
    case SessionLibrarySort.intensityHighest:
      return _intensityRank(b.intensity).compareTo(_intensityRank(a.intensity));
    case SessionLibrarySort.alphabetical:
      return a.titleFallback.toLowerCase().compareTo(
            b.titleFallback.toLowerCase(),
          );
  }
}

int _recommendationScore(SessionSummary session) {
  var score = 0;

  if (session.environmentCompatibility.deskFriendly) score += 3;
  if (session.environmentCompatibility.officeFriendly) score += 2;
  if (session.environmentCompatibility.quietFriendly) score += 2;
  if (session.environmentCompatibility.noMatRequired) score += 2;
  if (session.environmentCompatibility.lowSpaceFriendly) score += 2;
  if (session.isSilentFriendly) score += 2;
  if (session.isBeginnerFriendly) score += 2;
  if (session.modeCompatibility.focusMode) score += 1;
  if (session.modeCompatibility.dadMode) score += 1;
  if (session.durationMinutes <= 4) score += 3;
  if (session.durationMinutes <= 6) score += 1;

  score -= _intensityRank(session.intensity);

  return score;
}

int _intensityRank(SessionIntensity intensity) {
  switch (intensity) {
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

String _goalSearchToken(SessionGoal goal) {
  switch (goal) {
    case SessionGoal.painRelief:
      return 'pain relief schmerz linderung درد relief';
    case SessionGoal.postureReset:
      return 'posture reset haltung posture پوسچر وضعیت';
    case SessionGoal.focusPrep:
      return 'focus prep fokus vorbereitung تمرکز';
    case SessionGoal.recovery:
      return 'recovery erholung ریکاوری';
    case SessionGoal.mobility:
      return 'mobility beweglichkeit موبیلیتی تحرک';
    case SessionGoal.decompression:
      return 'decompression entspannung رفع فشار';
  }
}

List<String> _environmentSearchTokens(SessionSummary session) {
  final tokens = <String>[];

  if (session.environmentCompatibility.deskFriendly) {
    tokens.addAll([
      'desk',
      'desk safe',
      'desk friendly',
      'schreibtisch',
      'میز',
    ]);
  }
  if (session.environmentCompatibility.officeFriendly) {
    tokens.addAll([
      'office',
      'office friendly',
      'büro',
      'buero',
      'اداره',
      'محیط کار',
    ]);
  }
  if (session.environmentCompatibility.homeFriendly) {
    tokens.addAll(['home', 'home friendly', 'zuhause', 'خانه']);
  }
  if (session.environmentCompatibility.noMatRequired) {
    tokens.addAll([
      'no mat',
      'no mat required',
      'ohne matte',
      'بدون مت',
      'بدون زیرانداز',
    ]);
  }
  if (session.environmentCompatibility.lowSpaceFriendly) {
    tokens.addAll([
      'small space',
      'low space',
      'wenig platz',
      'فضای کم',
    ]);
  }
  if (session.environmentCompatibility.quietFriendly) {
    tokens.addAll([
      'quiet',
      'silent',
      'leise',
      'ruhig',
      'بی صدا',
      'بیصدا',
      'ساکت',
    ]);
  }

  return tokens;
}

List<String> _modeSearchTokens(SessionSummary session) {
  final tokens = <String>[];

  if (session.modeCompatibility.dadMode) {
    tokens.addAll(['dad mode', 'dad', 'vater', 'بابا', 'پدر']);
  }
  if (session.modeCompatibility.nightMode) {
    tokens.addAll(['night mode', 'night', 'nacht', 'شب']);
  }
  if (session.modeCompatibility.focusMode) {
    tokens.addAll(['focus mode', 'focus', 'fokus', 'تمرکز']);
  }
  if (session.modeCompatibility.painReliefMode) {
    tokens.addAll([
      'pain relief mode',
      'pain',
      'schmerz',
      'درد',
    ]);
  }

  return tokens;
}