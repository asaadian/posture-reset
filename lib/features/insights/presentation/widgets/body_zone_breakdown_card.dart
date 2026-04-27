// lib/features/insights/presentation/widgets/body_zone_breakdown_card.dart

import 'package:flutter/material.dart';

import '../../domain/insights_snapshot.dart';

class BodyZoneBreakdownCard extends StatelessWidget {
  const BodyZoneBreakdownCard({
    super.key,
    required this.items,
  });

  final List<InsightsBodyZoneStat> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Complete a few sessions with after-state check-ins to populate body zone distribution.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.take(5).map((item) {
            final percent = (item.share * 100).round();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ZoneRow(
                label: _painAreaLabel(item.painAreaCode),
                percent: percent,
                relief: item.averageReliefScore.round(),
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }

  String _painAreaLabel(String code) {
    switch (code) {
      case 'neck':
        return 'Neck';
      case 'shoulders':
        return 'Shoulders';
      case 'upper_back':
        return 'Upper back';
      case 'lower_back':
        return 'Lower back';
      case 'wrists':
        return 'Wrists';
      default:
        return code.replaceAll('_', ' ');
    }
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.label,
    required this.percent,
    required this.relief,
  });

  final String label;
  final int percent;
  final int relief;

  @override
  Widget build(BuildContext context) {
    final progress = (percent / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 10),
            Text(
              'Relief $relief',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
          ),
        ),
      ],
    );
  }
}