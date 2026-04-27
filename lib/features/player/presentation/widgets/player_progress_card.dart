// lib/features/player/presentation/widgets/player_progress_card.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class PlayerProgressCard extends StatelessWidget {
  const PlayerProgressCard({
    super.key,
    required this.progress,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.totalElapsedSeconds,
    required this.totalRemainingSeconds,
    this.currentStepRemainingSeconds,
  });

  final double progress;
  final int currentStepIndex;
  final int totalSteps;
  final int totalElapsedSeconds;
  final int totalRemainingSeconds;
  final int? currentStepRemainingSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);
    final percent = (progress.clamp(0.0, 1.0) * 100).round();

    final stepLabel = totalSteps <= 0
        ? t.get('player_step_label_empty', fallback: 'No steps')
        : '${t.get('player_step_label_prefix', fallback: 'Step')} ${currentStepIndex + 1}/$totalSteps';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: t.get(
                      'player_runtime_step_remaining',
                      fallback: 'Step Left',
                    ),
                    value: _formatDuration(currentStepRemainingSeconds ?? 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: t.get(
                      'player_runtime_remaining',
                      fallback: 'Remaining',
                    ),
                    value: _formatDuration(totalRemainingSeconds),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: t.get(
                      'player_runtime_elapsed',
                      fallback: 'Elapsed',
                    ),
                    value: _formatDuration(totalElapsedSeconds),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    stepLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              borderRadius: BorderRadius.circular(999),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}