// lib/features/re_engagement/presentation/widgets/re_engagement_card.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../player/domain/session_continuity_models.dart';
import '../../domain/re_engagement_models.dart';

class ReEngagementCard extends StatelessWidget {
  const ReEngagementCard({
    super.key,
    required this.candidate,
    required this.onPrimaryTap,
    required this.onDismissTap,
    this.compact = false,
  });

  final ReEngagementCandidate candidate;
  final VoidCallback onPrimaryTap;
  final VoidCallback onDismissTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypePill(candidate: candidate),
            const SizedBox(height: 10),
            Text(
              t.get(candidate.titleKey, fallback: candidate.titleFallback),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.get(candidate.bodyKey, fallback: candidate.bodyFallback),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPrimaryTap,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(_primaryLabel(context, candidate)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: onDismissTap,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: t.get(
                    're_engagement_dismiss',
                    fallback: 'Dismiss',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _primaryLabel(BuildContext context, ReEngagementCandidate candidate) {
    final t = AppText.of(context);

    switch (candidate.continuityAction) {
      case ContinuityActionType.continueSession:
        return t.get('continuity_continue_cta', fallback: 'Continue');
      case ContinuityActionType.resumeSession:
        return t.get('continuity_resume_cta', fallback: 'Resume');
      case ContinuityActionType.repeatSession:
        return t.get('continuity_repeat_cta', fallback: 'Repeat');
      case ContinuityActionType.startSession:
        return t.get('continuity_start_cta', fallback: 'Start');
      case null:
        switch (candidate.type) {
          case ReEngagementType.quickRelief:
            return t.get('nav_quick_fix', fallback: 'Quick Fix');
          case ReEngagementType.consistencyRecovery:
            return t.get('nav_sessions', fallback: 'Sessions');
          case ReEngagementType.returnToSaved:
            return t.get('saved_sessions_title', fallback: 'Saved Sessions');
          case ReEngagementType.continueSession:
            return t.get('continuity_continue_cta', fallback: 'Continue');
        }
    }
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.candidate});

  final ReEngagementCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    final label = switch (candidate.type) {
      ReEngagementType.continueSession =>
        t.get('re_engagement_type_continue', fallback: 'Continue'),
      ReEngagementType.returnToSaved =>
        t.get('re_engagement_type_saved', fallback: 'Saved'),
      ReEngagementType.quickRelief =>
        t.get('re_engagement_type_relief', fallback: 'Relief'),
      ReEngagementType.consistencyRecovery =>
        t.get('re_engagement_type_recovery', fallback: 'Recovery'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}