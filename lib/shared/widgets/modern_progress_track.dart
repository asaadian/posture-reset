import 'package:flutter/material.dart';

class ModernProgressTrack extends StatelessWidget {
  const ModernProgressTrack({
    super.key,
    required this.value,
    this.height = 10,
    this.light = false,
  });

  final double value;
  final double height;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeValue = value.clamp(0.0, 1.0);
    final foreground = light
        ? const [Colors.white, Color(0xFFDDEBFF)]
        : [colors.primary, colors.tertiary];
    final background = light
        ? Colors.white.withValues(alpha: 0.22)
        : colors.surfaceContainerHighest.withValues(alpha: 0.72);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: safeValue),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: light
                  ? Colors.white.withValues(alpha: 0.18)
                  : colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: animatedValue,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(colors: foreground),
                          boxShadow: [
                            BoxShadow(
                              color: foreground.last.withValues(alpha: 0.34),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
