import 'package:flutter/material.dart';

class SessionVisualAsset {
  const SessionVisualAsset._();

  static String pathForSessionId(String sessionId) {
    return 'assets/images/sessions/$sessionId.png';
  }
}

class SessionVisualStage extends StatelessWidget {
  const SessionVisualStage({
    super.key,
    required this.sessionId,
    required this.height,
    this.width,
    this.isLocked = false,
    this.compact = false,
    this.showLockBadge = false,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 24,
    this.imageScale = 1.0,
    this.imageAlignment = Alignment.center,
  });

  final String sessionId;
  final double height;
  final double? width;
  final bool isLocked;
  final bool compact;
  final bool showLockBadge;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double imageScale;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final assetPath = SessionVisualAsset.pathForSessionId(sessionId);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                          Color(0xFF121A2A),
                          Color(0xFF101827),
                          Color(0xFF0D1422),
                        ]
                      : const [
                          Color(0xFFF2F6FE),
                          Color(0xFFFFFFFF),
                          Color(0xFFEAF1FA),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -52,
              bottom: -58,
              child: Container(
                width: compact ? 140 : 190,
                height: compact ? 140 : 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.secondary.withValues(alpha: isDark ? 0.10 : 0.12),
                      colors.secondary.withValues(alpha: 0.00),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -56,
              top: -56,
              child: Container(
                width: compact ? 128 : 172,
                height: compact ? 128 : 172,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.primary.withValues(alpha: isDark ? 0.08 : 0.12),
                      colors.primary.withValues(alpha: 0.00),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: Transform.scale(
                scale: imageScale,
                alignment: imageAlignment,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  alignment: imageAlignment,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) {
                    return _SessionVisualFallback(
                      compact: compact,
                      isLocked: isLocked,
                    );
                  },
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.10),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                            const Color(0xFF0F172A).withValues(alpha: 0.035),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            if (isLocked)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.34),
                  ),
                ),
              ),
            if (showLockBadge)
              Positioned(
                right: 10,
                top: 10,
                child: _VisualLockBadge(isLocked: isLocked),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionVisualFallback extends StatelessWidget {
  const _SessionVisualFallback({
    required this.compact,
    required this.isLocked,
  });

  final bool compact;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.accessibility_new_rounded,
        size: compact ? 30 : 42,
        color: colors.onSurfaceVariant.withValues(alpha: 0.72),
      ),
    );
  }
}

class _VisualLockBadge extends StatelessWidget {
  const _VisualLockBadge({required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.black.withValues(alpha: 0.46)
            : Colors.white.withValues(alpha: 0.86),
        border: Border.all(
          color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : const Color(0xFF1E293B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
        size: isLocked ? 16 : 19,
        color: isDark ? colors.onSurface : const Color(0xFF334155),
      ),
    );
  }
}
