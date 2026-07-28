// lib/features/player/presentation/widgets/continue_session_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_continuity_models.dart';

class ContinueSessionCard extends StatelessWidget {
  const ContinueSessionCard({
    super.key,
    required this.candidate,
  });

  final ContinueSessionCandidate candidate;

  bool get _canOpenPlayerDirectly {
    return candidate.reason == ContinuityReason.activeRun ||
        candidate.reason == ContinuityReason.resumableRun ||
        candidate.action == ContinuityActionType.continueSession ||
        candidate.action == ContinuityActionType.resumeSession;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final title = AppText.get(
      context,
      key: candidate.session.titleKey,
      fallback: candidate.session.titleFallback,
    );

    final primaryLabel = _canOpenPlayerDirectly
        ? _cta(context, candidate.action)
        : AppText.get(
            context,
            key: 'continuity_preview_cta',
            fallback: 'Preview',
          );

    final primaryIcon = _canOpenPlayerDirectly
        ? Icons.play_arrow_rounded
        : Icons.open_in_new_rounded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.12),
                  colors.surfaceContainerHigh.withValues(alpha: 0.78),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.primary.withValues(alpha: 0.06),
                  colors.surface.withValues(alpha: 0.94),
                  colors.surfaceContainerLow.withValues(alpha: 0.88),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: isDark ? 0.76 : 0.64,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : colors.primary.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderIconLabel(
              icon: _headerIcon(candidate.action),
              label: _title(context, candidate.action),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 7),
            Text(
              _subtitle(context),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.32,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (_canOpenPlayerDirectly) {
                        context.pushNamed(
                          'session-player',
                          pathParameters: {'id': candidate.sessionId},
                          queryParameters: const {'source': 'dashboard'},
                        );
                        return;
                      }

                      context.pushNamed(
                        'session-detail',
                        pathParameters: {'id': candidate.sessionId},
                      );
                    },
                    icon: Icon(primaryIcon, size: 19),
                    label: Text(primaryLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      'session-detail',
                      pathParameters: {'id': candidate.sessionId},
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: Text(
                    AppText.get(
                      context,
                      key: 'continuity_open_detail',
                      fallback: 'Open',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(
                        alpha: isDark ? 0.78 : 0.64,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _headerIcon(ContinuityActionType action) {
    switch (action) {
      case ContinuityActionType.continueSession:
        return Icons.play_circle_outline_rounded;
      case ContinuityActionType.resumeSession:
        return Icons.restore_rounded;
      case ContinuityActionType.repeatSession:
        return Icons.replay_rounded;
      case ContinuityActionType.startSession:
        return Icons.flash_on_rounded;
    }
  }

  String _title(BuildContext context, ContinuityActionType action) {
    switch (action) {
      case ContinuityActionType.continueSession:
        return AppText.get(
          context,
          key: 'continuity_continue_title',
          fallback: 'Continue Session',
        );
      case ContinuityActionType.resumeSession:
        return AppText.get(
          context,
          key: 'continuity_resume_title',
          fallback: 'Resume Session',
        );
      case ContinuityActionType.repeatSession:
        return AppText.get(
          context,
          key: 'continuity_repeat_title',
          fallback: 'Do It Again',
        );
      case ContinuityActionType.startSession:
        return AppText.get(
          context,
          key: 'continuity_start_title',
          fallback: 'Start Session',
        );
    }
  }

  String _cta(BuildContext context, ContinuityActionType action) {
    switch (action) {
      case ContinuityActionType.continueSession:
        return AppText.get(
          context,
          key: 'continuity_continue_cta',
          fallback: 'Continue',
        );
      case ContinuityActionType.resumeSession:
        return AppText.get(
          context,
          key: 'continuity_resume_cta',
          fallback: 'Resume',
        );
      case ContinuityActionType.repeatSession:
        return AppText.get(
          context,
          key: 'continuity_repeat_cta',
          fallback: 'Do Again',
        );
      case ContinuityActionType.startSession:
        return AppText.get(
          context,
          key: 'continuity_start_cta',
          fallback: 'Start',
        );
    }
  }

  String _subtitle(BuildContext context) {
    switch (candidate.reason) {
      case ContinuityReason.activeRun:
        return AppText.get(
          context,
          key: 'continuity_reason_active',
          fallback: 'You still have an active recovery run.',
        );
      case ContinuityReason.resumableRun:
        return AppText.get(
          context,
          key: 'continuity_reason_resumable',
          fallback: 'You left this session unfinished and can pick it up again.',
        );
      case ContinuityReason.recentSaved:
        return AppText.get(
          context,
          key: 'continuity_reason_saved',
          fallback: 'This saved session is your best next continuity pick.',
        );
      case ContinuityReason.recentCompleted:
        return AppText.get(
          context,
          key: 'continuity_reason_repeat',
          fallback: 'This is the most recent session worth repeating.',
        );
    }
  }
}

class _HeaderIconLabel extends StatelessWidget {
  const _HeaderIconLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.10),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.24 : 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}