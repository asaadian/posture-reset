// lib/features/quick_fix/presentation/widgets/quick_fix_option_sheet.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/quick_fix_state.dart';
import '../utils/quick_fix_icon_resolver.dart';

Future<void> showQuickFixOptionSheet({
  required BuildContext context,
  required String title,
  required List<QuickFixOption> options,
  required Set<String> selectedIds,
  required bool multiSelect,
  required ValueChanged<Set<String>> onApply,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final t = AppText.of(context);
      final tempSelection = {...selectedIds};
      final mediaQuery = MediaQuery.of(context);
      final bottomInset = math.max(
        mediaQuery.viewInsets.bottom,
        mediaQuery.viewPadding.bottom,
      );

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset + 72),
          child: FractionallySizedBox(
            heightFactor: 0.72,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (multiSelect)
                              TextButton(
                                onPressed: () {
                                  setState(tempSelection.clear);
                                },
                                child: Text(
                                  t.get('common_clear', fallback: 'Clear'),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final selected = tempSelection.contains(option.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _SheetOptionTile(
                                  label: t.get(
                                    option.labelKey,
                                    fallback: option.labelFallback,
                                  ),
                                  icon: QuickFixIconResolver.resolve(option.iconName),
                                  selected: selected,
                                  multiSelect: multiSelect,
                                  onTap: () {
                                    setState(() {
                                      if (multiSelect) {
                                        if (selected) {
                                          tempSelection.remove(option.id);
                                        } else {
                                          tempSelection.add(option.id);
                                        }
                                      } else {
                                        tempSelection
                                          ..clear()
                                          ..add(option.id);
                                      }
                                    });

                                    if (!multiSelect) {
                                      onApply(tempSelection);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        if (multiSelect) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                onApply(tempSelection);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                t.get('common_apply', fallback: 'Apply'),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : colorScheme.surfaceContainerHigh,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                multiSelect
                    ? (selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded)
                    : (selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded),
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}