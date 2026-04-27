// lib/features/quick_fix/presentation/widgets/quick_fix_selector_section.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/theme/app_theme.dart';

class QuickFixSelectorSection extends StatelessWidget {
  const QuickFixSelectorSection({
    super.key,
    required this.titleKey,
    required this.titleFallback,
    required this.child,
    this.trailing,
  });

  final String titleKey;
  final String titleFallback;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        gradient: LinearGradient(
          colors: [
            AppTheme.surface,
            AppTheme.surfaceAlt,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.get(titleKey, fallback: titleFallback),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}