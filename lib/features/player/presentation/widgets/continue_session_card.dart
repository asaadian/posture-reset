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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(context, candidate.action),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    icon: Icon(primaryIcon),
                    label: Text(primaryLabel),
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
                  icon: const Icon(Icons.info_outline_rounded),
                  label: Text(
                    AppText.get(
                      context,
                      key: 'continuity_open_detail',
                      fallback: 'Open',
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