// lib/app/shell/main_shell.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_text.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _GlassConcaveBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        dashboardLabel: t.navDashboard,
        sessionsLabel: t.navSessions,
        quickFixLabel: t.navQuickFix,
        insightsLabel: t.navInsights,
        profileLabel: t.navProfile,
      ),
    );
  }
}

class _GlassConcaveBottomBar extends StatelessWidget {
  const _GlassConcaveBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.dashboardLabel,
    required this.sessionsLabel,
    required this.quickFixLabel,
    required this.insightsLabel,
    required this.profileLabel,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String dashboardLabel;
  final String sessionsLabel;
  final String quickFixLabel;
  final String insightsLabel;
  final String profileLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 98,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: const _ConcaveBarClipper(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: CustomPaint(
                    painter: _GlassConcaveBarPainter(
                      fillColor: colorScheme.surface.withValues(alpha: 0.72),
                      borderColor:
                          colorScheme.outlineVariant.withValues(alpha: 0.28),
                      shadowColor: Colors.black.withValues(alpha: 0.16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MinimalNavItem(
                              icon: Icons.space_dashboard_outlined,
                              selectedIcon: Icons.space_dashboard_rounded,
                              label: dashboardLabel,
                              selected: currentIndex == 0,
                              onTap: () => onTap(0),
                            ),
                          ),
                          Expanded(
                            child: _MinimalNavItem(
                              icon: Icons.grid_view_rounded,
                              selectedIcon: Icons.grid_view_rounded,
                              label: sessionsLabel,
                              selected: currentIndex == 1,
                              onTap: () => onTap(1),
                            ),
                          ),
                          const SizedBox(width: 94),
                          Expanded(
                            child: _MinimalNavItem(
                              icon: Icons.insights_outlined,
                              selectedIcon: Icons.insights_rounded,
                              label: insightsLabel,
                              selected: currentIndex == 3,
                              onTap: () => onTap(3),
                            ),
                          ),
                          Expanded(
                            child: _MinimalNavItem(
                              icon: Icons.person_outline_rounded,
                              selectedIcon: Icons.person_rounded,
                              label: profileLabel,
                              selected: currentIndex == 4,
                              onTap: () => onTap(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -10,
              child: _QuickFixOrbButton(
                label: quickFixLabel,
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalNavItem extends StatelessWidget {
  const _MinimalNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: selected ? 30 : 0,
                height: 4,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primaryContainer.withValues(alpha: 0.82)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 21,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFixOrbButton extends StatelessWidget {
  const _QuickFixOrbButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    width: 5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.34),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: colorScheme.tertiary.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  selected ? Icons.flash_on_rounded : Icons.bolt_rounded,
                  color: colorScheme.onPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcaveBarClipper extends CustomClipper<Path> {
  const _ConcaveBarClipper();

  @override
  Path getClip(Size size) {
    const radius = 30.0;
    const notchRadius = 41.0;
    const notchDepth = 24.0;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );
    path.addRRect(rrect);

    final notchPath = Path()
      ..moveTo(size.width / 2 - notchRadius - 18, 0)
      ..quadraticBezierTo(
        size.width / 2 - notchRadius,
        0,
        size.width / 2 - notchRadius + 4,
        8,
      )
      ..cubicTo(
        size.width / 2 - notchRadius / 2,
        notchDepth,
        size.width / 2 + notchRadius / 2,
        notchDepth,
        size.width / 2 + notchRadius - 4,
        8,
      )
      ..quadraticBezierTo(
        size.width / 2 + notchRadius,
        0,
        size.width / 2 + notchRadius + 18,
        0,
      )
      ..lineTo(size.width / 2 + notchRadius + 18, -1)
      ..lineTo(size.width / 2 - notchRadius - 18, -1)
      ..close();

    return Path.combine(PathOperation.difference, path, notchPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GlassConcaveBarPainter extends CustomPainter {
  const _GlassConcaveBarPainter({
    required this.fillColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 30.0;
    const notchRadius = 41.0;
    const notchDepth = 24.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(radius),
        ),
      );

    final notchPath = Path()
      ..moveTo(size.width / 2 - notchRadius - 18, 0)
      ..quadraticBezierTo(
        size.width / 2 - notchRadius,
        0,
        size.width / 2 - notchRadius + 4,
        8,
      )
      ..cubicTo(
        size.width / 2 - notchRadius / 2,
        notchDepth,
        size.width / 2 + notchRadius / 2,
        notchDepth,
        size.width / 2 + notchRadius - 4,
        8,
      )
      ..quadraticBezierTo(
        size.width / 2 + notchRadius,
        0,
        size.width / 2 + notchRadius + 18,
        0,
      )
      ..lineTo(size.width / 2 + notchRadius + 18, -1)
      ..lineTo(size.width / 2 - notchRadius - 18, -1)
      ..close();

    final finalPath = Path.combine(
      PathOperation.difference,
      path,
      notchPath,
    );

    canvas.drawShadow(finalPath, shadowColor, 22, false);

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(finalPath, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(finalPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassConcaveBarPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}