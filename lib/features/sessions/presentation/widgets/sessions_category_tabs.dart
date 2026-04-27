// lib/features/sessions/presentation/widgets/sessions_category_tabs.dart
import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../session_library_models.dart';

class SessionsCategoryTabs extends StatelessWidget {
  const SessionsCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final SessionLibraryCategory selectedCategory;
  final ValueChanged<SessionLibraryCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final items = <({SessionLibraryCategory value, String label})>[
      (
        value: SessionLibraryCategory.all,
        label: t.get('sessions_category_all', fallback: 'All'),
      ),
      (
        value: SessionLibraryCategory.neckShoulders,
        label: t.get(
          'sessions_category_neck_shoulders',
          fallback: 'Neck & Shoulders',
        ),
      ),
      (
        value: SessionLibraryCategory.upperBack,
        label: t.get('sessions_category_upper_back', fallback: 'Upper Back'),
      ),
      (
        value: SessionLibraryCategory.lowerBack,
        label: t.get('sessions_category_lower_back', fallback: 'Lower Back'),
      ),
      (
        value: SessionLibraryCategory.wristsForearms,
        label: t.get(
          'sessions_category_wrists_forearms',
          fallback: 'Wrists & Forearms',
        ),
      ),
      (
        value: SessionLibraryCategory.focus,
        label: t.get('sessions_category_focus', fallback: 'Focus'),
      ),
      (
        value: SessionLibraryCategory.recovery,
        label: t.get('sessions_category_recovery', fallback: 'Recovery'),
      ),
      (
        value: SessionLibraryCategory.quietDesk,
        label: t.get('sessions_category_quiet_desk', fallback: 'Quiet & Desk'),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(item.label),
                  selected: item.value == selectedCategory,
                  onSelected: (_) => onCategorySelected(item.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}