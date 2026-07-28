// lib/features/player/presentation/widgets/player_media_zone.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/localization/app_text.dart';
import '../../../sessions/domain/session_models.dart';

class PlayerMediaZone extends StatefulWidget {
  const PlayerMediaZone({
    super.key,
    required this.stepTitle,
    required this.stepTypeLabel,
    this.mediaUrl,
    this.posterUrl,
    this.exerciseDurationSeconds,
    this.visualDurationSeconds,
    this.visualType,
    this.visualUrl,
    this.visualThumbnailUrl,
    this.bodyTargetCodes = const <String>[],
    this.progress = 0,
    this.isVideo = false,
    this.isPaused = false,
    this.isCompleted = false,
  });

  final String stepTitle;
  final String stepTypeLabel;

  /// Backward-compatible fields from the previous widget API.
  final String? mediaUrl;
  final String? posterUrl;
  final bool isVideo;

  /// Exercise duration is controlled by session_steps.duration_seconds.
  /// The video is only a short visual demo and may loop many times.
  final int? exerciseDurationSeconds;
  final int? visualDurationSeconds;

  /// New visual-aware fields for Supabase Storage / remote visuals.
  final SessionStepVisualType? visualType;
  final String? visualUrl;
  final String? visualThumbnailUrl;
  final List<String> bodyTargetCodes;
  final double progress;

  /// Mirrors the player pause/completed state so the video loop can pause visually.
  final bool isPaused;
  final bool isCompleted;

  @override
  State<PlayerMediaZone> createState() => _PlayerMediaZoneState();
}

class _PlayerMediaZoneState extends State<PlayerMediaZone> {
  bool _muted = false;
  bool _fullscreenOpen = false;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _firstNotBlank(widget.visualUrl, widget.mediaUrl);
    final resolvedPosterUrl =
        _firstNotBlank(widget.visualThumbnailUrl, widget.posterUrl);
    final resolvedType = widget.visualType ?? _legacyTypeFromIsVideo(widget.isVideo);

    final shouldRenderVideo =
        resolvedUrl != null &&
        (resolvedType == SessionStepVisualType.videoUrl ||
            resolvedType == SessionStepVisualType.videoStorage);


    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;
        final radius = isCompact ? 28.0 : 32.0;
        final colors = Theme.of(context).colorScheme;
        final accent = _zoneAccentColor(colors, widget.bodyTargetCodes);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius + 2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.62),
                colors.tertiary.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.18),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.14,
                ),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: DecoratedBox(
              decoration: _stageDecoration(context, radius),
              child: AspectRatio(
                aspectRatio: 16 / 8.2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PremiumStageBackground(
                      bodyTargetCodes: widget.bodyTargetCodes,
                    ),
                    if (shouldRenderVideo)
                      _LoopingStepVideo(
                        key: ValueKey(resolvedUrl),
                        videoUrl: resolvedUrl,
                        posterUrl: resolvedPosterUrl,
                        isPaused: widget.isPaused || widget.isCompleted || _fullscreenOpen,
                        muted: _muted,
                        fit: BoxFit.contain,
                      )
                    else if (resolvedPosterUrl != null)
                      _PosterImage(posterUrl: resolvedPosterUrl)
                    else
                      _CalmMotionFallback(
                        bodyTargetCodes: widget.bodyTargetCodes,
                      ),
                    _SubtleMediaScrim(
                      hasRealMedia: shouldRenderVideo || resolvedPosterUrl != null,
                    ),

                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _ExpandMediaButton(
                        stepTitle: widget.stepTitle,
                        stepTypeLabel: widget.stepTypeLabel,
                        videoUrl: shouldRenderVideo ? resolvedUrl : null,
                        posterUrl: resolvedPosterUrl,
                        exerciseDurationSeconds: widget.exerciseDurationSeconds,
                        visualDurationSeconds: widget.visualDurationSeconds,
                        muted: _muted,
                        onExpandStart: () => setState(() => _fullscreenOpen = true),
                        onExpandEnd: () {
                          if (mounted) {
                            setState(() => _fullscreenOpen = false);
                          }
                        },
                      ),
                    ),
                    if (shouldRenderVideo)
                      Positioned(
                        right: 56,
                        bottom: 10,
                        child: _SoundToggleButton(
                          muted: _muted,
                          onPressed: () => setState(() => _muted = !_muted),
                        ),
                      ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _ZoneGlowBadge(
                        bodyTargetCodes: widget.bodyTargetCodes,
                      ),
                    ),
                    if (widget.isPaused && !widget.isCompleted)
                      const _PausedOverlay(),
                    if (widget.isCompleted) const _CompletedBadge(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _stageDecoration(BuildContext context, double radius) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: isDark ? Colors.black : colors.surfaceContainerLowest,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.22),
      ),
    );
  }

  SessionStepVisualType _legacyTypeFromIsVideo(bool value) {
    return value
        ? SessionStepVisualType.videoUrl
        : SessionStepVisualType.animatedPlaceholder;
  }

  String? _firstNotBlank(String? first, String? second) {
    if (first != null && first.trim().isNotEmpty) return first.trim();
    if (second != null && second.trim().isNotEmpty) return second.trim();
    return null;
  }
}

class _LoopingStepVideo extends StatefulWidget {
  const _LoopingStepVideo({
    super.key,
    required this.videoUrl,
    required this.posterUrl,
    required this.isPaused,
    required this.muted,
    required this.fit,
  });

  final String videoUrl;
  final String? posterUrl;
  final bool isPaused;
  final bool muted;
  final BoxFit fit;

  @override
  State<_LoopingStepVideo> createState() => _LoopingStepVideoState();
}

class _LoopingStepVideoState extends State<_LoopingStepVideo> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant _LoopingStepVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _hasError = false;
      _initializeController();
      return;
    }

    _syncVolume();
    _syncPlayback();
  }

  Future<void> _initializeController() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    controller.addListener(_loopGuard);
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);

      if (!mounted) return;
      setState(() {});
      await _syncPlayback();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _syncVolume() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _hasError) {
      return;
    }
    await controller.setVolume(widget.muted ? 0 : 1);
  }

  void _loopGuard() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _hasError) {
      return;
    }
    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration.inMilliseconds <= 0 || widget.isPaused) return;
    final remaining = duration - position;
    if (remaining.inMilliseconds <= 180 && !controller.value.isBuffering) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _hasError) {
      return;
    }

    if (widget.isPaused) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_loopGuard);
    controller?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady =
        controller != null && controller.value.isInitialized && !_hasError;

    if (isReady) {
      return ColoredBox(
        color: Colors.black,
        child: FittedBox(
          fit: widget.fit,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    if (widget.posterUrl != null && widget.posterUrl!.trim().isNotEmpty) {
      return _PosterImage(posterUrl: widget.posterUrl!.trim());
    }

    return const _VideoLoadingFallback();
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.posterUrl});

  final String posterUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _CalmMotionFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _VideoLoadingFallback();
      },
    );
  }
}

class _ExpandMediaButton extends StatelessWidget {
  const _ExpandMediaButton({
    required this.stepTitle,
    required this.stepTypeLabel,
    required this.videoUrl,
    required this.posterUrl,
    required this.exerciseDurationSeconds,
    required this.visualDurationSeconds,
    required this.muted,
    required this.onExpandStart,
    required this.onExpandEnd,
  });

  final String stepTitle;
  final String stepTypeLabel;
  final String? videoUrl;
  final String? posterUrl;
  final int? exerciseDurationSeconds;
  final int? visualDurationSeconds;
  final bool muted;
  final VoidCallback onExpandStart;
  final VoidCallback onExpandEnd;

  @override
  Widget build(BuildContext context) {
    final tooltip = AppText.get(
      context,
      key: 'player_media_expand_tooltip',
      fallback: 'View larger',
    );

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.40),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            onExpandStart();
            try {
              await _showExpandedMedia(context);
            } finally {
              onExpandEnd();
            }
          },
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.open_in_full_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExpandedMedia(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: videoUrl != null
                            ? _LoopingStepVideo(
                                key: ValueKey('expanded_$videoUrl'),
                                videoUrl: videoUrl!,
                                posterUrl: posterUrl,
                                isPaused: false,
                                muted: muted,
                                fit: BoxFit.contain,
                              )
                            : const _CalmMotionFallback(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 72,
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepTypeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SoundToggleButton extends StatelessWidget {
  const _SoundToggleButton({
    required this.muted,
    required this.onPressed,
  });

  final bool muted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: muted
          ? AppText.get(
              context,
              key: 'player_media_unmute_tooltip',
              fallback: 'Turn sound on',
            )
          : AppText.get(
              context,
              key: 'player_media_mute_tooltip',
              fallback: 'Turn sound off',
            ),
      child: Material(
        color: Colors.black.withValues(alpha: 0.40),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoLoadingFallback extends StatelessWidget {
  const _VideoLoadingFallback();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        _CalmMotionFallback(),
        Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      ],
    );
  }
}

class _PremiumStageBackground extends StatelessWidget {
  const _PremiumStageBackground({this.bodyTargetCodes = const <String>[]});

  final List<String> bodyTargetCodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.08, -0.20),
          radius: 1.1,
          colors: isDark
              ? [
                  accent.withValues(alpha: 0.22),
                  colors.tertiary.withValues(alpha: 0.09),
                  Colors.black.withValues(alpha: 0.98),
                ]
              : [
                  accent.withValues(alpha: 0.15),
                  colors.tertiaryContainer.withValues(alpha: 0.15),
                  colors.surfaceContainerLowest.withValues(alpha: 0.98),
                ],
        ),
      ),
      child: CustomPaint(
        painter: _StageGridPainter(
          color: accent.withValues(alpha: isDark ? 0.055 : 0.040),
        ),
      ),
    );
  }
}

class _CalmMotionFallback extends StatefulWidget {
  const _CalmMotionFallback({this.bodyTargetCodes = const <String>[]});

  final List<String> bodyTargetCodes;

  @override
  State<_CalmMotionFallback> createState() => _CalmMotionFallbackState();
}

class _CalmMotionFallbackState extends State<_CalmMotionFallback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _zoneAccentColor(colors, widget.bodyTargetCodes);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final value = _pulse.value;
        final scale = 0.94 + (value * 0.08);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.12 + (value * 0.22), -0.18),
                    radius: 0.72 + (value * 0.10),
                    colors: [
                      accent.withValues(alpha: 0.24),
                      colors.tertiary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.10),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.20),
                        blurRadius: 42,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _zoneIcon(widget.bodyTargetCodes),
                    size: 54,
                    color: accent,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SubtleMediaScrim extends StatelessWidget {
  const _SubtleMediaScrim({required this.hasRealMedia});

  final bool hasRealMedia;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: hasRealMedia ? 0.05 : 0.00),
              Colors.transparent,
              Colors.black.withValues(alpha: hasRealMedia ? 0.08 : 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.34),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: const Icon(
            Icons.pause_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      top: 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ZoneGlowBadge extends StatelessWidget {
  const _ZoneGlowBadge({required this.bodyTargetCodes});

  final List<String> bodyTargetCodes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_zoneIcon(bodyTargetCodes), color: accent, size: 16),
            const SizedBox(width: 6),
            Text(
              _bodyZoneLabel(bodyTargetCodes),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _StageGridPainter extends CustomPainter {
  const _StageGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 28.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StageGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

Color _zoneAccentColor(ColorScheme colors, List<String> codes) {
  final primary = _primaryBodyZone(codes);
  switch (primary) {
    case 'neck':
      return colors.primary;
    case 'shoulders':
    case 'upper_back':
      return colors.tertiary;
    case 'wrists':
    case 'hands':
    case 'forearms':
      return colors.secondary;
    case 'lower_back':
    case 'hips_glutes':
      return colors.primary;
    case 'eyes':
      return colors.secondary;
    default:
      return colors.primary;
  }
}

IconData _zoneIcon(List<String> codes) {
  final primary = _primaryBodyZone(codes);
  switch (primary) {
    case 'neck':
      return Icons.self_improvement_rounded;
    case 'shoulders':
    case 'upper_back':
      return Icons.accessibility_new_rounded;
    case 'wrists':
    case 'hands':
    case 'forearms':
      return Icons.pan_tool_alt_rounded;
    case 'lower_back':
    case 'hips_glutes':
      return Icons.airline_seat_recline_normal_rounded;
    case 'eyes':
      return Icons.visibility_outlined;
    default:
      return Icons.spa_rounded;
  }
}

String _bodyZoneLabel(List<String> codes) {
  final primary = _primaryBodyZone(codes);
  switch (primary) {
    case 'neck':
      return 'Neck';
    case 'shoulders':
      return 'Shoulders';
    case 'upper_back':
      return 'Upper back';
    case 'wrists':
      return 'Wrists';
    case 'hands':
      return 'Hands';
    case 'forearms':
      return 'Forearms';
    case 'lower_back':
      return 'Lower back';
    case 'hips_glutes':
      return 'Hips';
    case 'eyes':
      return 'Eyes';
    default:
      return 'Focus';
  }
}

String _primaryBodyZone(List<String> codes) {
  if (codes.isEmpty) return 'general';
  const priority = <String>[
    'neck',
    'shoulders',
    'upper_back',
    'wrists',
    'hands',
    'forearms',
    'lower_back',
    'hips_glutes',
    'eyes',
  ];

  for (final item in priority) {
    if (codes.contains(item)) return item;
  }

  return codes.first;
}
