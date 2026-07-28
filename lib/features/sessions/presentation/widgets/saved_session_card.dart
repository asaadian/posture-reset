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
                      colors.surfaceContainerHigh.withValues(alpha: 0.78),
                      colors.surface.withValues(alpha: 0.96),
                    ]
                  : [
                      colors.surface.withValues(alpha: 0.98),
                      colors.surfaceContainerLow.withValues(alpha: 0.90),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.56),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.14)
                    : colors.primary.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _SavedSessionVisual(sessionId: item.session.id),
              const SizedBox(width: 12),
              Expanded(
                child: _SavedSessionCopy(
                  title: title,
                  subtitle: subtitle,
                  item: item,
                ),
              ),
              const SizedBox(width: 10),
              _QuickStartButton(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedSessionVisual extends StatelessWidget {
  const _SavedSessionVisual({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return SessionVisualStage(
      sessionId: sessionId,
      width: 82,
      height: 94,
      compact: true,
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 4),
      borderRadius: 22,
    );
  }
}

class _SavedSessionCopy extends StatelessWidget {
  const _SavedSessionCopy({
    required this.title,
    required this.subtitle,
    required this.item,
  });

  final String title;
  final String subtitle;
  final SavedSessionContinuityItem item;

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
            _Tag(label: '${item.session.durationMinutes} min'),
            _Tag(label: _intensityLabel(context, item.session.intensity)),
            if (item.latestRun != null)
              _Tag(label: _actionLabel(context, item.action), emphasized: true),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.18,
          ),
        ),
      ],
    );
  }
}

class _QuickStartButton extends StatelessWidget {
  const _QuickStartButton({required this.item});

  final SavedSessionContinuityItem item;

  @override
  Widget build(BuildContext context) {
    final label = _cta(context, item.action);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.pushNamed(
            'session-player',
            pathParameters: {'id': item.session.id},
            queryParameters: const {'source': 'profile'},
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.emphasized = false,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = emphasized ? colors.secondary : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: emphasized ? 0.14 : 0.09),
        border: Border.all(
          color: color.withValues(alpha: emphasized ? 0.22 : 0.14),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
      ),
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

String _actionLabel(BuildContext context, ContinuityActionType action) {
  switch (action) {
    case ContinuityActionType.continueSession:
      return AppText.get(
        context,
        key: 'continuity_label_active',
        fallback: 'Active run',
      );
    case ContinuityActionType.resumeSession:
      return AppText.get(
        context,
        key: 'continuity_label_resumable',
        fallback: 'Unfinished',
      );
    case ContinuityActionType.repeatSession:
      return AppText.get(
        context,
        key: 'continuity_label_repeatable',
        fallback: 'Played before',
      );
    case ContinuityActionType.startSession:
      return AppText.get(
        context,
        key: 'continuity_label_saved',
        fallback: 'Saved',
      );
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
