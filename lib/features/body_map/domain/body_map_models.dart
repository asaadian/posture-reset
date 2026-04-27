// lib/features/body_map/domain/body_map_models.dart

enum BodyMapSide {
  front,
  back,
}

enum BodyZoneSeverity {
  low,
  medium,
  high,
}

enum BodyZoneTrend {
  rising,
  stable,
  improving,
}

class BodyMapZoneSnapshot {
  const BodyMapZoneSnapshot({
    required this.code,
    required this.side,
    required this.recentHits,
    required this.previousHits,
    required this.reliefScore,
    required this.severity,
    required this.trend,
  });

  final String code;
  final BodyMapSide side;
  final int recentHits;
  final int previousHits;
  final double reliefScore;
  final BodyZoneSeverity severity;
  final BodyZoneTrend trend;

  bool get isActive => recentHits > 0;
}

class BodyMapRecommendationItem {
  const BodyMapRecommendationItem({
    required this.sessionId,
    required this.titleKey,
    required this.titleFallback,
    required this.durationMinutes,
    required this.reason,
  });

  final String sessionId;
  final String titleKey;
  final String titleFallback;
  final int durationMinutes;
  final String reason;
}

class BodyMapSnapshot {
  const BodyMapSnapshot({
    required this.zones,
    required this.recommendationsByZone,
  });

  final List<BodyMapZoneSnapshot> zones;
  final Map<String, List<BodyMapRecommendationItem>> recommendationsByZone;

  List<BodyMapZoneSnapshot> zonesForSide(BodyMapSide side) {
    final items = zones.where((zone) => zone.side == side).toList();
    items.sort((a, b) {
      final byHits = b.recentHits.compareTo(a.recentHits);
      if (byHits != 0) return byHits;
      return b.reliefScore.compareTo(a.reliefScore);
    });
    return items;
  }

  BodyMapZoneSnapshot? zoneByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final zone in zones) {
      if (zone.code == code) return zone;
    }
    return null;
  }

  String? dominantZoneCodeForSide(BodyMapSide side) {
    final sideZones = zonesForSide(side);
    if (sideZones.isEmpty) return null;
    return sideZones.first.code;
  }

  int activeZoneCountForSide(BodyMapSide side) {
    return zonesForSide(side).where((zone) => zone.isActive).length;
  }

  List<BodyMapRecommendationItem> recommendationsForZone(String? code) {
    if (code == null || code.isEmpty) return const [];
    return recommendationsByZone[code] ?? const [];
  }
}