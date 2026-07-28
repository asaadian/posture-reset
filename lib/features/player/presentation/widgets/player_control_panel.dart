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
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? colors.surface.withValues(alpha: 0.92)
            : colors.surfaceContainerLowest.withValues(alpha: 0.96),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.62 : 0.50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Row(
          children: [
            _RoundControlButton(
              icon: Icons.skip_previous_rounded,
              tooltip: t.get('player_previous_cta', fallback: 'Previous'),
              onPressed: canGoPrevious ? onPreviousPressed : null,
            ),
            const SizedBox(width: 4),
            _RoundControlButton(
              icon: Icons.replay_rounded,
              tooltip: t.get('player_replay_cta', fallback: 'Replay'),
              onPressed: canReplay && !isCompleted ? onReplayPressed : null,
            ),
            const SizedBox(width: 4),
            _PrimaryPauseButton(
              isPaused: isPaused,
              isCompleted: isCompleted,
              onPressed: onPauseResumePressed,
            ),
            const SizedBox(width: 4),
            _RoundControlButton(
              icon: Icons.fast_forward_rounded,
              tooltip: t.get('player_skip_cta', fallback: 'Skip'),
              onPressed: canSkip && !isCompleted ? onSkipPressed : null,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _NextControlButton(
                label: nextLabel,
                icon: isLastStep ? Icons.check_rounded : Icons.skip_next_rounded,
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

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 40,
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: Icon(icon, size: 20),
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
        width: 54,
        height: 44,
        child: FilledButton(
          onPressed: isCompleted ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _NextControlButton extends StatelessWidget {
  const _NextControlButton({
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

    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
