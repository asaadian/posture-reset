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
}) async {
  final initial = {...selectedIds};

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.54),
    builder: (context) {
      return _QuickFixOptionSheet(
        title: title,
        options: options,
        selectedIds: initial,
        multiSelect: multiSelect,
        onApply: onApply,
      );
    },
  );
}

class _QuickFixOptionSheet extends StatefulWidget {
  const _QuickFixOptionSheet({
    required this.title,
    required this.options,
    required this.selectedIds,
    required this.multiSelect,
    required this.onApply,
  });

  final String title;
  final List<QuickFixOption> options;
  final Set<String> selectedIds;
  final bool multiSelect;
  final ValueChanged<Set<String>> onApply;

  @override
  State<_QuickFixOptionSheet> createState() => _QuickFixOptionSheetState();
}

class _QuickFixOptionSheetState extends State<_QuickFixOptionSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedIds};
  }

  void _toggle(String id) {
    if (!widget.multiSelect) {
      widget.onApply({id});
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _apply() {
    widget.onApply(_selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);

    final maxHeight = media.size.height * 0.72;
    final selectedCount = _selected.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: media.viewInsets.bottom + 12,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              maxWidth: 620,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: isDark ? 0.82 : 0.68),
                ),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          colors.primary.withValues(alpha: 0.10),
                          colors.surfaceContainerHigh.withValues(alpha: 0.96),
                          colors.surface.withValues(alpha: 0.98),
                        ]
                      : [
                          colors.primary.withValues(alpha: 0.06),
                          colors.surface.withValues(alpha: 0.98),
                          colors.surfaceContainerLow.withValues(alpha: 0.96),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.34)
                        : colors.primary.withValues(alpha: 0.10),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: colors.outlineVariant,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.10),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: isDark ? 0.24 : 0.18),
                            ),
                          ),
                          child: Icon(
                            widget.multiSelect
                                ? Icons.checklist_rounded
                                : Icons.radio_button_checked_rounded,
                            size: 19,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              if (widget.multiSelect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  selectedCount == 0
                                      ? t.get(
                                          'quick_fix_none_selected',
                                          fallback: 'None selected',
                                        )
                                      : '$selectedCount ${t.get('quick_fix_selected_count_suffix', fallback: 'selected')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: t.get('common_close', fallback: 'Close'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final useGrid = constraints.maxWidth >= 430;
                          final width = useGrid
                              ? (constraints.maxWidth - 8) / 2
                              : constraints.maxWidth;

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.options.map((option) {
                              final selected = _selected.contains(option.id);

                              return SizedBox(
                                width: width,
                                child: _OptionTile(
                                  label: t.get(
                                    option.labelKey,
                                    fallback: option.labelFallback,
                                  ),
                                  icon: QuickFixIconResolver.resolve(
                                    option.iconName,
                                  ),
                                  selected: selected,
                                  multiSelect: widget.multiSelect,
                                  onTap: () => _toggle(option.id),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  if (widget.multiSelect)
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colors.outlineVariant.withValues(
                              alpha: isDark ? 0.76 : 0.62,
                            ),
                          ),
                        ),
                        color: isDark
                            ? colors.surface.withValues(alpha: 0.48)
                            : colors.surface.withValues(alpha: 0.68),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                              ),
                              child: Text(
                                t.get('common_cancel', fallback: 'Cancel'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: _apply,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                              ),
                              child: Text(
                                t.get('common_apply', fallback: 'Apply'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = selected ? colors.primary : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: isDark ? 0.66 : 0.52)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.82 : 0.66),
              width: selected ? 1.25 : 1,
            ),
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? [
                            colors.primary.withValues(alpha: 0.16),
                            colors.tertiary.withValues(alpha: 0.10),
                            colors.surfaceContainerHigh.withValues(alpha: 0.72),
                          ]
                        : [
                            colors.primary.withValues(alpha: 0.12),
                            colors.tertiary.withValues(alpha: 0.08),
                            colors.surface.withValues(alpha: 0.80),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected
                ? null
                : isDark
                    ? colors.surfaceContainerHigh.withValues(alpha: 0.66)
                    : colors.surface.withValues(alpha: 0.76),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: isDark ? 0.13 : 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: selected
                      ? colors.primary.withValues(alpha: isDark ? 0.16 : 0.13)
                      : colors.surfaceContainerHighest.withValues(
                          alpha: isDark ? 0.76 : 0.86,
                        ),
                ),
                child: Icon(
                  selected ? Icons.check_rounded : icon,
                  size: 18,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? colors.primary.withValues(alpha: isDark ? 0.18 : 0.16)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outlineVariant,
                    width: selected ? 1.6 : 1.2,
                  ),
                ),
                child: selected
                    ? Icon(
                        multiSelect
                            ? Icons.check_rounded
                            : Icons.circle_rounded,
                        size: multiSelect ? 15 : 9,
                        color: colors.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
