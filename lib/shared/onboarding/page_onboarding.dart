import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_text.dart';

typedef OnboardingTargetBuilder = Rect Function(
  Size overlaySize,
  EdgeInsets safePadding,
);

class OnboardingTip {
  const OnboardingTip({
    required this.icon,
    required this.title,
    required this.body,
    this.targetKey,
    this.targetBuilder,
    this.targetBorderRadius = 24,
  });

  final IconData icon;
  final String title;
  final String body;
  final GlobalKey? targetKey;
  final OnboardingTargetBuilder? targetBuilder;
  final double targetBorderRadius;
}

class PageOnboarding extends StatefulWidget {
  const PageOnboarding({
    super.key,
    required this.pageId,
    required this.tips,
    required this.child,
    this.delay = const Duration(milliseconds: 620),
  });

  final String pageId;
  final List<OnboardingTip> tips;
  final Widget child;
  final Duration delay;

  @override
  State<PageOnboarding> createState() => _PageOnboardingState();
}

class _PageOnboardingState extends State<PageOnboarding> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    unawaited(_showOnceIfNeeded());
  }

  Future<void> _showOnceIfNeeded() async {
    if (widget.tips.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'page_onboarding_seen_${widget.pageId}';
    if (prefs.getBool(key) == true) return;

    await Future<void>.delayed(widget.delay);
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _SpotlightGuideDialog(
          tips: widget.tips,
          onDone: () async {
            await prefs.setBool(key, true);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          onSkip: () async {
            await prefs.setBool(key, true);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - curved)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SpotlightGuideDialog extends StatefulWidget {
  const _SpotlightGuideDialog({
    required this.tips,
    required this.onDone,
    required this.onSkip,
  });

  final List<OnboardingTip> tips;
  final Future<void> Function() onDone;
  final Future<void> Function() onSkip;

  @override
  State<_SpotlightGuideDialog> createState() => _SpotlightGuideDialogState();
}

class _SpotlightGuideDialogState extends State<_SpotlightGuideDialog> {
  int _index = 0;
  bool _closing = false;

  Future<void> _next() async {
    if (_closing) return;
    if (_index >= widget.tips.length - 1) {
      setState(() => _closing = true);
      await widget.onDone();
      return;
    }

    setState(() => _index += 1);
  }

  Future<void> _skip() async {
    if (_closing) return;
    setState(() => _closing = true);
    await widget.onSkip();
  }

  Rect? _targetRectFor(
    OnboardingTip tip,
    Size overlaySize,
    EdgeInsets safePadding,
  ) {
    final virtualTarget = tip.targetBuilder?.call(overlaySize, safePadding);
    if (virtualTarget != null) {
      final inflated = virtualTarget.inflate(6);
      return Rect.fromLTRB(
        inflated.left.clamp(8.0, overlaySize.width - 8.0).toDouble(),
        inflated.top.clamp(8.0, overlaySize.height - 8.0).toDouble(),
        inflated.right.clamp(8.0, overlaySize.width - 8.0).toDouble(),
        inflated.bottom.clamp(8.0, overlaySize.height - 8.0).toDouble(),
      );
    }

    final key = tip.targetKey;
    final context = key?.currentContext;
    if (context == null) return null;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return null;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    if (size.isEmpty) return null;

    final rect = topLeft & size;
    final inflated = rect.inflate(8);
    return Rect.fromLTRB(
      inflated.left.clamp(8.0, overlaySize.width - 8.0).toDouble(),
      inflated.top.clamp(8.0, overlaySize.height - 8.0).toDouble(),
      inflated.right.clamp(8.0, overlaySize.width - 8.0).toDouble(),
      inflated.bottom.clamp(8.0, overlaySize.height - 8.0).toDouble(),
    );
  }

  Alignment _cardAlignment(Rect? target, Size overlaySize) {
    if (target == null) return Alignment.bottomCenter;
    final verticalCenter = target.center.dy / overlaySize.height;
    return verticalCenter > 0.54 ? Alignment.topCenter : Alignment.bottomCenter;
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tips[_index];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    final topSafe = MediaQuery.of(context).viewPadding.top;
    final isLast = _index == widget.tips.length - 1;

    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final overlaySize = Size(constraints.maxWidth, constraints.maxHeight);
          final safePadding = MediaQuery.of(context).padding;
          final target = _targetRectFor(tip, overlaySize, safePadding);
          final alignment = _cardAlignment(target, overlaySize);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpotlightScrimPainter(
                    target: target,
                    radius: tip.targetBorderRadius,
                    color: Colors.black.withValues(alpha: isDark ? 0.58 : 0.42),
                  ),
                ),
              ),
              if (target != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: target.left,
                  top: target.top,
                  width: target.width,
                  height: target.height,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tip.targetBorderRadius),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: isDark ? 0.88 : 0.78),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: isDark ? 0.42 : 0.26),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: SafeArea(
                  child: Align(
                    alignment: alignment,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        14,
                        14 + (alignment == Alignment.topCenter ? topSafe * 0.15 : 0),
                        14,
                        14 + bottomSafe,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _GuideCard(
                          tip: tip,
                          index: _index,
                          count: widget.tips.length,
                          isLast: isLast,
                          closing: _closing,
                          onNext: _next,
                          onSkip: _skip,
                        ),
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
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.tip,
    required this.index,
    required this.count,
    required this.isLast,
    required this.closing,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingTip tip;
  final int index;
  final int count;
  final bool isLast;
  final bool closing;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      colors.surfaceContainerHigh.withValues(alpha: 0.94),
                      colors.surface.withValues(alpha: 0.98),
                    ]
                  : [
                      colors.surfaceContainerLowest.withValues(alpha: 0.96),
                      colors.surfaceContainerLow.withValues(alpha: 0.94),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colors.primary.withValues(alpha: isDark ? 0.26 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.36)
                    : const Color(0xFF263B57).withValues(alpha: 0.16),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: isDark ? 0.26 : 0.18),
                        ),
                      ),
                      child: Icon(tip.icon, color: colors.primary, size: 23),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tip.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              height: 1.22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _GuideDots(count: count, activeIndex: index),
                    const Spacer(),
                    TextButton(
                      onPressed: closing ? null : onSkip,
                      child: Text(AppText.get(context, key: 'guide_skip_cta', fallback: 'Skip')),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.icon(
                      onPressed: closing ? null : onNext,
                      icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        isLast
                            ? AppText.get(context, key: 'guide_got_it_cta', fallback: 'Got it')
                            : AppText.get(context, key: 'guide_next_cta', fallback: 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightScrimPainter extends CustomPainter {
  const _SpotlightScrimPainter({
    required this.target,
    required this.radius,
    required this.color,
  });

  final Rect? target;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    if (target == null) {
      canvas.drawPath(full, Paint()..color = color);
      return;
    }

    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(target!.inflate(2), Radius.circular(radius)),
      );

    final path = Path.combine(PathOperation.difference, full, cutout);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SpotlightScrimPainter oldDelegate) {
    return oldDelegate.target != target ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color;
  }
}

class _GuideDots extends StatelessWidget {
  const _GuideDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: selected ? 22 : 7,
          height: 7,
          margin: const EdgeInsetsDirectional.only(end: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.80),
          ),
        );
      }),
    );
  }
}
