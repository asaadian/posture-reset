// lib/features/player/presentation/widgets/player_control_panel.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class PlayerControlPanel extends StatelessWidget {
  const PlayerControlPanel({
    super.key,
    required this.isPaused,
    required this.isCompleted,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.canSkip,
    required this.canReplay,
    required this.isLastStep,
    required this.onPreviousPressed,
    required this.onPauseResumePressed,
    required this.onNextPressed,
    required this.onSkipPressed,
    required this.onReplayPressed,
    required this.onFinishPressed,
  });

  final bool isPaused;
  final bool isCompleted;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool canSkip;
  final bool canReplay;
  final bool isLastStep;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onPauseResumePressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onSkipPressed;
  final VoidCallback? onReplayPressed;
  final VoidCallback? onFinishPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final nextLabel = isLastStep
        ? t.get('player_finish_cta', fallback: 'Finish')
        : t.get('player_next_cta', fallback: 'Next');

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerHigh.withValues(alpha: 0.86),
                ]
              : [
                  Colors.white.withValues(alpha: 0.98),
                  colors.surfaceContainerLowest.withValues(alpha: 0.94),
                ],
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.40 : 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _IconActionButton(
              icon: Icons.skip_previous_rounded,
              tooltip: t.get('player_previous_cta', fallback: 'Previous'),
              onPressed: canGoPrevious ? onPreviousPressed : null,
            ),
            const SizedBox(width: 8),
            _IconActionButton(
              icon: Icons.replay_rounded,
              tooltip: t.get('player_replay_cta', fallback: 'Replay'),
              onPressed: canReplay && !isCompleted ? onReplayPressed : null,
            ),
            const SizedBox(width: 10),
            _PrimaryPauseButton(
              isPaused: isPaused,
              isCompleted: isCompleted,
              onPressed: onPauseResumePressed,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NextHeroButton(
                label: nextLabel,
                icon: isLastStep ? Icons.check_rounded : Icons.play_arrow_rounded,
                onPressed: isCompleted
                    ? null
                    : isLastStep
                        ? onFinishPressed
                        : canGoNext
                            ? onNextPressed
                            : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 52,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: enabled
                ? colors.surfaceContainerHighest.withValues(alpha: 0.58)
                : colors.surfaceContainerHighest.withValues(alpha: 0.28),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: enabled ? 0.34 : 0.16),
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPauseButton extends StatelessWidget {
  const _PrimaryPauseButton({
    required this.isPaused,
    required this.isCompleted,
    required this.onPressed,
  });

  final bool isPaused;
  final bool isCompleted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Tooltip(
      message: isPaused
          ? t.get('player_resume_cta', fallback: 'Resume')
          : t.get('player_pause_cta', fallback: 'Pause'),
      child: SizedBox(
        width: 72,
        height: 52,
        child: FilledButton(
          onPressed: isCompleted ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _NextHeroButton extends StatelessWidget {
  const _NextHeroButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
