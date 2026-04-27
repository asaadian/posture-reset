// lib/features/sessions/presentation/widgets/sessions_filter_row.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../session_library_models.dart';

class SessionsFilterRow extends StatelessWidget {
  const SessionsFilterRow({
    super.key,
    required this.selectedSort,
    required this.silentOnly,
    required this.beginnerOnly,
    required this.hasActiveFilters,
    required this.showSilentFilter,
    required this.showBeginnerFilter,
    required this.onSortSelected,
    required this.onSilentOnlyChanged,
    required this.onBeginnerOnlyChanged,
    required this.onClearFilters,
  });

  final SessionLibrarySort selectedSort;
  final bool silentOnly;
  final bool beginnerOnly;
  final bool hasActiveFilters;
  final bool showSilentFilter;
  final bool showBeginnerFilter;
  final ValueChanged<SessionLibrarySort> onSortSelected;
  final VoidCallback onSilentOnlyChanged;
  final VoidCallback onBeginnerOnlyChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PopupMenuButton<SessionLibrarySort>(
          initialValue: selectedSort,
          onSelected: onSortSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: SessionLibrarySort.recommended,
              child: Text(_sortLabel(SessionLibrarySort.recommended, t)),
            ),
            PopupMenuItem(
              value: SessionLibrarySort.durationShortest,
              child: Text(_sortLabel(SessionLibrarySort.durationShortest, t)),
            ),
            PopupMenuItem(
              value: SessionLibrarySort.durationLongest,
              child: Text(_sortLabel(SessionLibrarySort.durationLongest, t)),
            ),
            PopupMenuItem(
              value: SessionLibrarySort.intensityLowest,
              child: Text(_sortLabel(SessionLibrarySort.intensityLowest, t)),
            ),
            PopupMenuItem(
              value: SessionLibrarySort.intensityHighest,
              child: Text(_sortLabel(SessionLibrarySort.intensityHighest, t)),
            ),
            PopupMenuItem(
              value: SessionLibrarySort.alphabetical,
              child: Text(_sortLabel(SessionLibrarySort.alphabetical, t)),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_vert, size: 18),
                const SizedBox(width: 8),
                Text(_sortLabel(selectedSort, t)),
              ],
            ),
          ),
        ),
        if (showSilentFilter)
          FilterChip(
            label: Text(
              t.get(
                'sessions_filter_silent_only',
                fallback: 'Silent only',
              ),
            ),
            selected: silentOnly,
            onSelected: (_) => onSilentOnlyChanged(),
          ),
        if (showBeginnerFilter)
          FilterChip(
            label: Text(
              t.get(
                'sessions_filter_beginner_only',
                fallback: 'Beginner only',
              ),
            ),
            selected: beginnerOnly,
            onSelected: (_) => onBeginnerOnlyChanged(),
          ),
        if (hasActiveFilters)
          OutlinedButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.restart_alt),
            label: Text(
              t.get(
                'sessions_clear_filters_cta',
                fallback: 'Clear filters',
              ),
            ),
          ),
      ],
    );
  }

  String _sortLabel(SessionLibrarySort sort, dynamic t) {
    switch (sort) {
      case SessionLibrarySort.recommended:
        return t.get(
          'sessions_sort_recommended',
          fallback: 'Recommended',
        );
      case SessionLibrarySort.durationShortest:
        return t.get(
          'sessions_sort_duration_shortest',
          fallback: 'Duration: Shortest',
        );
      case SessionLibrarySort.durationLongest:
        return t.get(
          'sessions_sort_duration_longest',
          fallback: 'Duration: Longest',
        );
      case SessionLibrarySort.intensityLowest:
        return t.get(
          'sessions_sort_intensity_lowest',
          fallback: 'Intensity: Lowest',
        );
      case SessionLibrarySort.intensityHighest:
        return t.get(
          'sessions_sort_intensity_highest',
          fallback: 'Intensity: Highest',
        );
      case SessionLibrarySort.alphabetical:
        return t.get(
          'sessions_sort_alphabetical',
          fallback: 'Alphabetical',
        );
    }
  }
}