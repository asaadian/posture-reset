// lib/features/insights/presentation/widgets/insights_heatmap_preview_card.dart

import 'package:flutter/material.dart';

import '../../domain/insights_snapshot.dart';

class InsightsHeatmapPreviewCard extends StatelessWidget {
  const InsightsHeatmapPreviewCard({
    super.key,
    required this.cells,
    this.compact = false,
  });

  final List<InsightsHeatmapCell> cells;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visibleCells = compact && cells.length > 28
        ? cells.sublist(cells.length - 28)
        : cells;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            const columns = 7;
            const spacing = 8.0;
            final tile =
                (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: visibleCells.map((cell) {
                    return Tooltip(
                      message:
                          '${cell.date.day}.${cell.date.month} • ${cell.minutes} min',
                      child: Container(
                        width: tile,
                        height: tile,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.primary.withValues(
                                alpha: 0.08 + (cell.intensity * 0.78),
                              ),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 12),
                Text(
                  'Darker cells indicate more recovery minutes on that day.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}