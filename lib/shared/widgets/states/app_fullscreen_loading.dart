import 'package:flutter/material.dart';

/// Lightweight full-screen loading state used while app-level data is prepared.
///
/// It intentionally avoids photography and heavy copy so it feels calm during
/// startup, authentication callbacks, and account switching.
class AppFullscreenLoading extends StatefulWidget {
  const AppFullscreenLoading({super.key});

  static const String logoAssetPath =
      'assets/branding/desk_workout_icon.png';

  @override
  State<AppFullscreenLoading> createState() => _AppFullscreenLoadingState();
}

class _AppFullscreenLoadingState extends State<AppFullscreenLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final pulseA = 1.0 + (0.12 * t);
              final pulseB = 0.94 + (0.10 * ((t + 0.5) % 1.0));
              final fadeA = 0.22 * (1.0 - t) + 0.08;
              final fadeB = 0.18 * (1.0 - ((t + 0.5) % 1.0)) + 0.06;
              final shimmer = 0.96 + (0.04 * (0.5 - (t - 0.5).abs()) * 2);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 182,
                    height: 182,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: pulseA,
                          child: Container(
                            width: 168,
                            height: 168,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: fadeA),
                                width: 2.2,
                              ),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: pulseB,
                          child: Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.tertiary.withValues(alpha: fadeB),
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                colors.primary.withValues(alpha: isDark ? 0.18 : 0.15),
                                colors.primary.withValues(alpha: 0.02),
                              ],
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: shimmer,
                          child: Container(
                            width: 92,
                            height: 92,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: isDark
                                  ? colors.surfaceContainerHigh
                                  : colors.surface,
                              border: Border.all(
                                color: colors.outlineVariant.withValues(alpha: 0.44),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: isDark ? 0.18 : 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppFullscreenLoading.logoAssetPath,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.self_improvement_rounded,
                                size: 44,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Desk Workout',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preparing your recovery space',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LoadingDots(progress: t),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final phase = (progress + (index * 0.18)) % 1.0;
        final scale = 0.72 + (0.36 * (1.0 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
        final opacity = 0.28 + (0.72 * (1.0 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: opacity),
              ),
            ),
          ),
        );
      }),
    );
  }
}
