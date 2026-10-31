// lib/features/sessions/presentation/widgets/saved_session_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../player/domain/session_continuity_models.dart';
import '../../domain/session_models.dart';
import 'session_visual_asset.dart';

class SavedSessionCard extends StatelessWidget {
  const SavedSessionCard({
    super.key,
    required this.item,
  });

  final SavedSessionContinuityItem item;

  @override
  Widget build(BuildContext context) {
    final title = AppText.get(
      context,
      key: item.session.titleKey,
      fallback: item.session.titleFallback,
    );
    final subtitle = AppText.get(
      context,
      key: item.session.shortDescriptionKey,
      fallback: item.session.shortDescriptionFallback,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': item.session.id},
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: isDark ? 0.42 : 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SessionVisualStage(
                      sessionId: item.session.id,
                      width: 94,
                      height: 96,
                      imageFit: BoxFit.cover,
                      compact: true,
                      padding: EdgeInsets.zero,
                      borderRadius: 19,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              _actionLabel(context, item.action),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          if (subtitle.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 7, 7, 7),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: colors.onSurfaceVariant),
                      const SizedBox(width: 5),
                      _MetaText(label: '${item.session.durationMinutes} min'),
                      const SizedBox(width: 6),
                      Flexible(
                        child: _MetaText(label: _intensityLabel(context, item.session.intensity)),
                      ),
                      const Spacer(),
                      _QuickStartButton(item: item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: (emphasized ? colors.secondary : colors.primary)
            .withValues(alpha: 0.075),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: emphasized ? colors.secondary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
      ),
    );
  }
}

class _QuickStartButton extends StatelessWidget {
  const _QuickStartButton({required this.item});

  final SavedSessionContinuityItem item;

  @override
  Widget build(BuildContext context) {
    final label = _cta(context, item.action);
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(
          'session-player',
          pathParameters: {'id': item.session.id},
          queryParameters: const {'source': 'profile'},
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colors.primary,
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

String _cta(BuildContext context, ContinuityActionType action) {
  switch (action) {
    case ContinuityActionType.continueSession:
      return AppText.get(context, key: 'continuity_continue_cta', fallback: 'Continue');
    case ContinuityActionType.resumeSession:
      return AppText.get(context, key: 'continuity_resume_cta', fallback: 'Resume');
    case ContinuityActionType.repeatSession:
      return AppText.get(context, key: 'continuity_repeat_cta', fallback: 'Do Again');
    case ContinuityActionType.startSession:
      return AppText.get(context, key: 'continuity_start_cta', fallback: 'Start');
  }
}

String _actionLabel(BuildContext context, ContinuityActionType action) {
  switch (action) {
    case ContinuityActionType.continueSession:
      return AppText.get(context, key: 'continuity_label_active', fallback: 'Active run');
    case ContinuityActionType.resumeSession:
      return AppText.get(context, key: 'continuity_label_resumable', fallback: 'Unfinished');
    case ContinuityActionType.repeatSession:
      return AppText.get(context, key: 'continuity_label_repeatable', fallback: 'Played before');
    case ContinuityActionType.startSession:
      return AppText.get(context, key: 'continuity_label_saved', fallback: 'Saved');
  }
}

String _intensityLabel(BuildContext context, SessionIntensity intensity) {
  final t = AppText.of(context);
  switch (intensity) {
    case SessionIntensity.gentle:
      return t.get('session_intensity_gentle', fallback: 'Gentle');
    case SessionIntensity.light:
      return t.get('session_intensity_light', fallback: 'Light');
    case SessionIntensity.moderate:
      return t.get('session_intensity_moderate', fallback: 'Moderate');
    case SessionIntensity.strong:
      return t.get('session_intensity_strong', fallback: 'Strong');
  }
}
