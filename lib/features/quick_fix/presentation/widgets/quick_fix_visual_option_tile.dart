// lib/features/quick_fix/presentation/widgets/quick_fix_visual_option_tile.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/quick_fix_state.dart';
import '../utils/quick_fix_icon_resolver.dart';

class QuickFixVisualOptionTile extends StatelessWidget {
  const QuickFixVisualOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final QuickFixOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? colorScheme.primary : AppTheme.border,
          width: selected ? 1.3 : 1,
        ),
        gradient: selected
            ? LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.16),
                  AppTheme.surfaceElevated,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppTheme.surface,
                  AppTheme.surfaceAlt,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 8 : 10,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: compact ? 30 : 34,
                  height: compact ? 30 : 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selected
                        ? colorScheme.primary.withValues(alpha: 0.14)
                        : colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    QuickFixIconResolver.resolve(option.iconName),
                    size: compact ? 16 : 18,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.get(option.labelKey, fallback: option.labelFallback),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: compact
                        ? theme.textTheme.labelLarge
                        : theme.textTheme.titleSmall,
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