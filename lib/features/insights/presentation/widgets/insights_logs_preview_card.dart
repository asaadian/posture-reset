// lib/features/insights/presentation/widgets/insights_logs_preview_card.dart

import 'package:flutter/material.dart';

import '../../domain/insights_snapshot.dart';

class InsightsLogsPreviewCard extends StatelessWidget {
  const InsightsLogsPreviewCard({
    super.key,
    required this.logs,
    this.limit,
  });

  final List<InsightLogItem> logs;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final visibleLogs = limit == null ? logs : logs.take(limit!).toList();

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
        child: visibleLogs.isEmpty
            ? Text(
                'No significant patterns have been generated yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            : Column(
                children: [
                  for (var i = 0; i < visibleLogs.length; i++) ...[
                    _InsightLogTile(log: visibleLogs[i]),
                    if (i != visibleLogs.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }
}

class _InsightLogTile extends StatelessWidget {
  const _InsightLogTile({required this.log});

  final InsightLogItem log;

  @override
  Widget build(BuildContext context) {
    final accent = switch (log.tone) {
      InsightLogTone.positive => const Color(0xFF62E6D9),
      InsightLogTone.warning => Theme.of(context).colorScheme.error,
      InsightLogTone.neutral => Theme.of(context).colorScheme.primary,
    };

    final icon = switch (log.tone) {
      InsightLogTone.positive => Icons.trending_up_rounded,
      InsightLogTone.warning => Icons.warning_amber_rounded,
      InsightLogTone.neutral => Icons.insights_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(
          color: accent.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  log.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}