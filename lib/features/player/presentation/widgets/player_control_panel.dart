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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _CompactIconAction(
                    icon: Icons.skip_previous_rounded,
                    onPressed: canGoPrevious ? onPreviousPressed : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: isCompleted ? null : onPauseResumePressed,
                    icon: Icon(
                      isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isPaused
                          ? t.get('player_resume_cta', fallback: 'Resume')
                          : t.get('player_pause_cta', fallback: 'Pause'),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactIconAction(
                    icon: Icons.skip_next_rounded,
                    onPressed:
                        canGoNext && !isCompleted ? onNextPressed : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SmallActionButton(
                  icon: Icons.replay_rounded,
                  label: t.get('player_replay_cta', fallback: 'Replay'),
                  onPressed: canReplay && !isCompleted ? onReplayPressed : null,
                ),
                _SmallActionButton(
                  icon: Icons.fast_forward_rounded,
                  label: t.get('player_skip_cta', fallback: 'Skip'),
                  onPressed: canSkip && !isCompleted ? onSkipPressed : null,
                ),
                _SmallActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: t.get('player_finish_cta', fallback: 'Finish'),
                  onPressed: !isCompleted ? onFinishPressed : null,
                  isPrimaryTint: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactIconAction extends StatelessWidget {
  const _CompactIconAction({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimaryTint = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimaryTint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        foregroundColor:
            isPrimaryTint ? theme.colorScheme.primary : null,
        textStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}