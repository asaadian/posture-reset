// lib/features/body_map/presentation/widgets/body_zone_trend_card.dart

import 'package:flutter/material.dart';

import '../../domain/body_map_models.dart';

class BodyZoneTrendCard extends StatelessWidget {
  const BodyZoneTrendCard({
    super.key,
    required this.zone,
  });

  final BodyMapZoneSnapshot zone;

  @override
  Widget build(BuildContext context) {
    final trendIcon = switch (zone.trend) {
      BodyZoneTrend.rising => Icons.north_east_rounded,
      BodyZoneTrend.stable => Icons.east_rounded,
      BodyZoneTrend.improving => Icons.south_east_rounded,
    };

    final accent = switch (zone.severity) {
      BodyZoneSeverity.low => Theme.of(context).colorScheme.secondary,
      BodyZoneSeverity.medium => const Color(0xFF62E6D9),
      BodyZoneSeverity.high => Theme.of(context).colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
            ),
            child: Icon(trendIcon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _zoneLabel(zone.code),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 10),
          _MiniTag(label: _severityLabel(zone.severity)),
          const SizedBox(width: 8),
          _MiniTag(label: _trendLabel(zone.trend)),
        ],
      ),
    );
  }

  String _zoneLabel(String code) {
    switch (code) {
      case 'neck':
        return 'Neck';
      case 'shoulders':
        return 'Shoulders';
      case 'upper_back':
        return 'Upper Back';
      case 'lower_back':
        return 'Lower Back';
      case 'wrists':
        return 'Wrists';
      default:
        return code;
    }
  }

  String _severityLabel(BodyZoneSeverity value) {
    switch (value) {
      case BodyZoneSeverity.low:
        return 'Low';
      case BodyZoneSeverity.medium:
        return 'Medium';
      case BodyZoneSeverity.high:
        return 'High';
    }
  }

  String _trendLabel(BodyZoneTrend value) {
    switch (value) {
      case BodyZoneTrend.rising:
        return 'Rising';
      case BodyZoneTrend.stable:
        return 'Stable';
      case BodyZoneTrend.improving:
        return 'Improving';
    }
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}