import 'package:flutter/material.dart';

class AppFullscreenLoading extends StatefulWidget {
  const AppFullscreenLoading({super.key});

  static const String loadingImagePath = 'assets/images/app_loading.webp';

  @override
  State<AppFullscreenLoading> createState() => _AppFullscreenLoadingState();
}

class _AppFullscreenLoadingState extends State<AppFullscreenLoading>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _imageController;
  late final Animation<double> _imageScale;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _imageScale = Tween<double>(begin: 1, end: 1.025).animate(
      CurvedAnimation(
        parent: _imageController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E5D5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _imageScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _imageScale.value,
                child: child,
              );
            },
            child: Image.asset(
              AppFullscreenLoading.loadingImagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF5E8D8),
                      colorScheme.primaryContainer,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Soft overlays preserve the photo while keeping the loading UI readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.48, 0.72, 1],
                colors: [
                  Color(0x12000000),
                  Color(0x00000000),
                  Color(0x420D0906),
                  Color(0xCC0D0906),
                ],
              ),
            ),
          ),

          SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                _LoadingPanel(
                  progressAnimation: _progressController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.progressAnimation});

  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xB81B1511),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Getting your sessions ready…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Preparing your personalized Desk Workout experience',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ModernIndeterminateProgress(animation: progressAnimation),
        ],
      ),
    );
  }
}

class _ModernIndeterminateProgress extends StatelessWidget {
  const _ModernIndeterminateProgress({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const segmentFraction = 0.34;
        final trackWidth = constraints.maxWidth;
        final segmentWidth = trackWidth * segmentFraction;
        final travelDistance = trackWidth + segmentWidth;

        return Container(
          height: 7,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(99),
          ),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final easedValue = Curves.easeInOutCubic.transform(animation.value);
              final offset = (travelDistance * easedValue) - segmentWidth;

              return Stack(
                children: [
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      width: segmentWidth,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD6A0),
                            Color(0xFFFFA94D),
                            Color(0xFFFFE3BD),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66FFB35C),
                            blurRadius: 9,
                          ),
                        ],
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
