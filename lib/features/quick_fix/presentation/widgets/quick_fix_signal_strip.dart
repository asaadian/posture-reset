// lib/features/quick_fix/presentation/widgets/quick_fix_signal_strip.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/quick_fix_models.dart';
import '../utils/quick_fix_icon_resolver.dart';

class QuickFixSignalStrip extends StatelessWidget {
  const QuickFixSignalStrip({
    super.key,
    required this.signals,
  });

  final List<QuickFixSignal> signals;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: signals
          .map(
            (signal) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.border),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      QuickFixIconResolver.resolve(signal.iconName),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.get(signal.labelKey, fallback: signal.labelFallback),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}