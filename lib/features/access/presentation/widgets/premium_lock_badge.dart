// lib/features/access/presentation/widgets/premium_lock_badge.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class PremiumLockBadge extends StatelessWidget {
  const PremiumLockBadge({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: compact ? 13 : 15,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            t.get('access_core_badge', fallback: 'Core'),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}