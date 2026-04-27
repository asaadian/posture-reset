import 'package:flutter/material.dart';

import '../../domain/body_map_models.dart';

class BodyMapCanvasCard extends StatelessWidget {
  const BodyMapCanvasCard({
    super.key,
    required this.side,
    required this.snapshot,
    required this.selectedZoneCode,
    required this.onZoneTap,
  });

  final BodyMapSide side;
  final BodyMapSnapshot snapshot;
  final String? selectedZoneCode;
  final ValueChanged<String> onZoneTap;

  static const double _imageAspectRatio = 654 / 1350;

  @override
  Widget build(BuildContext context) {
    final sideZones = snapshot.zonesForSide(side);
    final colorScheme = Theme.of(context).colorScheme;
    final imagePath = side == BodyMapSide.front
        ? 'assets/images/body_map/front.png'
        : 'assets/images/body_map/back.png';

    return Container(
      width: double.infinity,
      height: 560,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            double artboardWidth = availableWidth;
            double artboardHeight = artboardWidth / _imageAspectRatio;

            if (artboardHeight > availableHeight) {
              artboardHeight = availableHeight;
              artboardWidth = artboardHeight * _imageAspectRatio;
            }

            return Center(
              child: SizedBox(
                width: artboardWidth,
                height: artboardHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    ...sideZones.map((zone) {
                      final placement = _hotspotForZone(zone.code, side);
                      return _ZoneHotspotLayer(
                        dotAlignment: _alignmentFromNormalized(
                          placement.dotX,
                          placement.dotY,
                        ),
                        labelAlignment: _alignmentFromNormalized(
                          placement.labelX,
                          placement.labelY,
                        ),
                        label: _zoneLabel(zone.code),
                        severity: zone.severity,
                        isSelected: selectedZoneCode == zone.code,
                        onTap: () => onZoneTap(zone.code),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _HotspotPlacement _hotspotForZone(String code, BodyMapSide side) {
  if (side == BodyMapSide.front) {
    switch (code) {
      case 'neck':
        return const _HotspotPlacement(
          dotX: 0.50,
          dotY: 0.135,
          labelX: 0.60,
          labelY: 0.135,
        );
      case 'shoulders':
        return const _HotspotPlacement(
          dotX: 0.50,
          dotY: 0.265,
          labelX: 0.62,
          labelY: 0.265,
        );
      case 'wrists':
        return const _HotspotPlacement(
          dotX: 0.79,
          dotY: 0.505,
          labelX: 0.90,
          labelY: 0.505,
        );
      default:
        return const _HotspotPlacement(
          dotX: 0.50,
          dotY: 0.50,
          labelX: 0.62,
          labelY: 0.50,
        );
    }
  }

  switch (code) {
    case 'upper_back':
      return const _HotspotPlacement(
        dotX: 0.50,
        dotY: 0.305,
        labelX: 0.62,
        labelY: 0.305,
      );
    case 'lower_back':
      return const _HotspotPlacement(
        dotX: 0.50,
        dotY: 0.465,
        labelX: 0.63,
        labelY: 0.465,
      );
    default:
      return const _HotspotPlacement(
        dotX: 0.50,
        dotY: 0.50,
        labelX: 0.62,
        labelY: 0.50,
      );
  }
}
}

class _ZoneHotspotLayer extends StatelessWidget {
  const _ZoneHotspotLayer({
    required this.dotAlignment,
    required this.labelAlignment,
    required this.label,
    required this.severity,
    required this.isSelected,
    required this.onTap,
  });

  final Alignment dotAlignment;
  final Alignment labelAlignment;
  final String label;
  final BodyZoneSeverity severity;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (severity) {
      BodyZoneSeverity.low => Theme.of(context).colorScheme.secondary,
      BodyZoneSeverity.medium => const Color(0xFF62E6D9),
      BodyZoneSeverity.high => Theme.of(context).colorScheme.primary,
    };

    return Stack(
      children: [
        Align(
          alignment: dotAlignment,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: isSelected ? 26 : 22,
              height: isSelected ? 26 : 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.38),
                    blurRadius: isSelected ? 24 : 14,
                    spreadRadius: isSelected ? 3 : 1,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.82),
                  width: 2.5,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: labelAlignment,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: 0.92,
                    ),
                border: Border.all(
                  color: isSelected
                      ? accent.withValues(alpha: 0.35)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotspotPlacement {
  const _HotspotPlacement({
    required this.dotX,
    required this.dotY,
    required this.labelX,
    required this.labelY,
  });

  final double dotX;
  final double dotY;
  final double labelX;
  final double labelY;
}

Alignment _alignmentFromNormalized(double x, double y) {
  return Alignment((x * 2) - 1, (y * 2) - 1);
}

String _zoneLabel(String? code) {
  switch (code) {
    case 'neck':
      return 'Neck';
    case 'shoulders':
      return 'Shoulders';
    case 'upper_back':
      return 'Upper back';
    case 'lower_back':
      return 'Lower back';
    case 'wrists':
      return 'Wrists';
    default:
      return 'Zone';
  }
}