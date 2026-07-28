// lib/features/player/presentation/widgets/session_history_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../sessions/presentation/widgets/session_visual_asset.dart';
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

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          context.pushNamed(
            'session-detail',
            pathParameters: {'id': item.session.id},
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      statusColor.withValues(alpha: 0.08),
                      colors.surfaceContainerHigh.withValues(alpha: 0.78),
                      colors.surface.withValues(alpha: 0.96),
                    ]
                  : [
                      statusColor.withValues(alpha: 0.04),
                      colors.surface.withValues(alpha: 0.98),
                      colors.surfaceContainerLow.withValues(alpha: 0.90),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: isDark ? 0.74 : 0.58,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.14)
                    : statusColor.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _HistoryVisual(sessionId: item.session.id),
              const SizedBox(width: 12),
              Expanded(
                child: _HistoryCopy(
                  title: title,
                  meta: _meta(context),
                  statusLabel: _statusLabel(context),
                  statusColor: statusColor,
                  statusIcon: _statusIcon(),
                  resumable: item.isResumable,
                ),
              ),
              if (item.isResumable) ...[
                const SizedBox(width: 10),
                _ResumeIconButton(item: item),
              ],
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

class _HistoryVisual extends StatelessWidget {
  const _HistoryVisual({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return SessionVisualStage(
      sessionId: sessionId,
      width: 78,
      height: 90,
      compact: true,
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 4),
      borderRadius: 21,
    );
  }
}

class _HistoryCopy extends StatelessWidget {
  const _HistoryCopy({
    required this.title,
    required this.meta,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.resumable,
  });

  final String title;
  final String meta;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final bool resumable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag(label: statusLabel, color: statusColor),
            if (resumable)
              _Tag(
                label: AppText.get(
                  context,
                  key: 'continuity_resume_available',
                  fallback: 'Resume',
                ),
                color: colors.primary,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                meta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResumeIconButton extends StatelessWidget {
  const _ResumeIconButton({required this.item});

  final SessionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppText.get(
        context,
        key: 'continuity_resume_cta',
        fallback: 'Resume',
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.pushNamed(
            'session-player',
            pathParameters: {'id': item.session.id},
            queryParameters: const {'source': 'dashboard'},
          );
        },
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
      ),
    );
  }
}
