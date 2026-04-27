// lib/features/player/presentation/widgets/session_history_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_continuity_models.dart';
import '../../domain/session_run_models.dart';

class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    super.key,
    required this.item,
  });

  final SessionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final title = AppText.get(
      context,
      key: item.session.titleKey,
      fallback: item.session.titleFallback,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed(
            'session-detail',
            pathParameters: {'id': item.session.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _statusColor(context).withValues(alpha: 0.12),
                foregroundColor: _statusColor(context),
                child: Icon(_statusIcon()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _meta(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                          label: _statusLabel(context),
                          color: _statusColor(context),
                        ),
                        if (item.isResumable)
                          _Tag(
                            label: AppText.get(
                              context,
                              key: 'continuity_resume_available',
                              fallback: 'Resume available',
                            ),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.isResumable)
                OutlinedButton(
                  onPressed: () {
                    context.pushNamed(
                      'session-player',
                      pathParameters: {'id': item.session.id},
                      queryParameters: const {'source': 'dashboard'},
                    );
                  },
                  child: Text(
                    AppText.get(
                      context,
                      key: 'continuity_resume_cta',
                      fallback: 'Resume',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _meta(BuildContext context) {
    final minutes = (item.run.totalElapsedSeconds / 60).ceil();
    return '${minutes}m • ${item.run.completedSteps}/${item.run.totalSteps}';
  }

  String _statusLabel(BuildContext context) {
    switch (item.run.status) {
      case SessionRunStatus.started:
        return AppText.get(
          context,
          key: 'continuity_status_started',
          fallback: 'Started',
        );
      case SessionRunStatus.completed:
        return AppText.get(
          context,
          key: 'continuity_status_completed',
          fallback: 'Completed',
        );
      case SessionRunStatus.abandoned:
        return AppText.get(
          context,
          key: 'continuity_status_abandoned',
          fallback: 'Ended early',
        );
    }
  }

  IconData _statusIcon() {
    switch (item.run.status) {
      case SessionRunStatus.started:
        return Icons.play_circle_outline_rounded;
      case SessionRunStatus.completed:
        return Icons.check_circle_outline_rounded;
      case SessionRunStatus.abandoned:
        return Icons.exit_to_app_rounded;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (item.run.status) {
      case SessionRunStatus.started:
        return Theme.of(context).colorScheme.secondary;
      case SessionRunStatus.completed:
        return Theme.of(context).colorScheme.primary;
      case SessionRunStatus.abandoned:
        return Theme.of(context).colorScheme.error;
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
            ),
      ),
    );
  }
}