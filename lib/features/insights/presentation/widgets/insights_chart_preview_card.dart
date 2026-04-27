// lib/features/insights/presentation/widgets/insights_chart_preview_card.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/insights_snapshot.dart';

class InsightsChartPreviewCard extends StatelessWidget {
  const InsightsChartPreviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.accent,
    required this.valueSuffix,
  });

  final String title;
  final String subtitle;
  final List<InsightsSeriesPoint> points;
  final Color accent;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _InsightsLinePainter(
                  points: points.map((e) => e.value).toList(growable: false),
                  accent: accent,
                  gridColor: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.30),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Column(
                    children: [
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: points
                            .map(
                              (point) => Expanded(
                                child: Text(
                                  point.label,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniStatPill(
                  label: 'Peak',
                  value:
                      '${_max(points).round()}$valueSuffix',
                  accent: accent,
                ),
                _MiniStatPill(
                  label: 'Average',
                  value:
                      '${_average(points).round()}$valueSuffix',
                  accent: accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _max(List<InsightsSeriesPoint> values) {
    if (values.isEmpty) return 0;
    return values.map((e) => e.value).reduce(math.max);
  }

  double _average(List<InsightsSeriesPoint> values) {
    if (values.isEmpty) return 0;
    return values.map((e) => e.value).reduce((a, b) => a + b) / values.length;
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.10),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '$label • $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
            ),
      ),
    );
  }
}

class _InsightsLinePainter extends CustomPainter {
  _InsightsLinePainter({
    required this.points,
    required this.accent,
    required this.gridColor,
  });

  final List<double> points;
  final Color accent;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (points.isEmpty) return;

    final safeMax = points.fold<double>(0, math.max);
    final maxY = safeMax <= 0 ? 1.0 : safeMax;
    final dx = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y = size.height - ((points[i] / maxY).clamp(0.0, 1.0) * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.20),
          accent.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = accent;

    final dotPaint = Paint()..color = accent;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);

    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y = size.height - ((points[i] / maxY).clamp(0.0, 1.0) * size.height);
      canvas.drawCircle(x == 0 && y.isNaN ? Offset.zero : Offset(x, y), 3.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InsightsLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor;
  }
}