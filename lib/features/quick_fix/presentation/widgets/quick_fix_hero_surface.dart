// lib/features/quick_fix/presentation/widgets/quick_fix_hero_surface.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/theme/app_theme.dart';

class QuickFixHeroSurface extends StatelessWidget {
  const QuickFixHeroSurface({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.border),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: compact ? 0.14 : 0.20),
            AppTheme.surfaceElevated,
            AppTheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (!compact)
            const Positioned(
              right: -20,
              top: -40,
              child: _Orb(size: 180, opacity: 0.16),
            ),
          if (!compact)
            const Positioned(
              right: 90,
              bottom: -30,
              child: _Orb(size: 120, opacity: 0.10),
            ),
          const Positioned(
            left: -30,
            bottom: -24,
            child: _GridGlow(),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 18 : 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760 && !compact;

                if (wide) {
                  return Row(
                    children: [
                      const Expanded(flex: 12, child: _HeroCopy(compact: false)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 8,
                        child: _HeroStatsPanel(
                          compact: false,
                          t: t,
                          theme: theme,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCopy(compact: compact),
                    if (!compact) ...[
                      const SizedBox(height: 18),
                      _HeroStatsPanel(
                        compact: true,
                        t: t,
                        theme: theme,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 6 : 8,
            ),
            child: Text(
              t.get(
                'quick_fix_hero_eyebrow',
                fallback: 'Adaptive Recovery Launcher',
              ),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          t.get(
            'quick_fix_hero_title',
            fallback: 'Find the right session for your body state in seconds.',
          ),
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: compact
              ? theme.textTheme.headlineSmall
              : theme.textTheme.displaySmall,
        ),
        SizedBox(height: compact ? 8 : 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            t.get(
              'quick_fix_hero_body',
              fallback:
                  'Quick Fix turns your current pain point, time window, energy, and environment into a real session recommendation from the live catalog.',
            ),
            maxLines: compact ? 2 : 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStatsPanel extends StatelessWidget {
  const _HeroStatsPanel({
    required this.compact,
    required this.t,
    required this.theme,
  });

  final bool compact;
  final AppTextReader t;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final children = [
      _StatCard(
        title: t.get('quick_fix_hero_stat_fast', fallback: 'Fast Match'),
        value: '2–10',
        suffix: 'min',
      ),
      _StatCard(
        title: t.get('quick_fix_hero_stat_silent', fallback: 'Quiet Context'),
        value: 'Desk',
        suffix: '+',
      ),
      _StatCard(
        title: t.get(
          'quick_fix_hero_stat_personalized',
          fallback: 'Live Personalization',
        ),
        value: 'Real',
        suffix: '',
      ),
    ];

    return Column(
      children: [
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.suffix,
  });

  final String title;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge,
          ),
          if (suffix.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              suffix,
              style: theme.textTheme.labelLarge,
            ),
          ],
          const Spacer(),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.secondary.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _GridGlow extends StatelessWidget {
  const _GridGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 180,
        height: 110,
        child: CustomPaint(
          painter: _GridGlowPainter(),
        ),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.28)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primary.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}