// lib/features/insights/domain/insights_snapshot.dart

enum InsightsRange {
  last7Days(7),
  last14Days(14),
  last28Days(28);

  const InsightsRange(this.days);

  final int days;
}

enum InsightLogTone {
  positive,
  neutral,
  warning,
}

class InsightsSnapshot {
  const InsightsSnapshot({
    required this.range,
    required this.consistencyScore,
    required this.recoveryMinutes,
    required this.dominantPainAreaCode,
    required this.quickFixStarts,
    required this.completedSessions,
    required this.totalRuns,
    required this.helpRate,
    required this.averageReliefScore,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.recoveryMinutesSeries,
    required this.reliefSeries,
    required this.heatmapCells,
    required this.bodyZones,
    required this.logs,
  });

  final InsightsRange range;
  final double consistencyScore;
  final int recoveryMinutes;
  final String? dominantPainAreaCode;
  final int quickFixStarts;
  final int completedSessions;
  final int totalRuns;
  final double helpRate;
  final double averageReliefScore;
  final int currentStreakDays;
  final int longestStreakDays;
  final List<InsightsSeriesPoint> recoveryMinutesSeries;
  final List<InsightsSeriesPoint> reliefSeries;
  final List<InsightsHeatmapCell> heatmapCells;
  final List<InsightsBodyZoneStat> bodyZones;
  final List<InsightLogItem> logs;

  bool get hasContent {
    return recoveryMinutes > 0 ||
        quickFixStarts > 0 ||
        totalRuns > 0 ||
        bodyZones.isNotEmpty ||
        logs.isNotEmpty ||
        recoveryMinutesSeries.any((point) => point.value > 0) ||
        heatmapCells.any((cell) => cell.minutes > 0);
  }

  double get completionRate {
    if (totalRuns <= 0) return 0.0;
    return completedSessions / totalRuns;
  }
}

class InsightsSeriesPoint {
  const InsightsSeriesPoint({
    required this.date,
    required this.label,
    required this.value,
  });

  final DateTime date;
  final String label;
  final double value;
}

class InsightsHeatmapCell {
  const InsightsHeatmapCell({
    required this.date,
    required this.minutes,
    required this.intensity,
  });

  final DateTime date;
  final int minutes;
  final double intensity;
}

class InsightsBodyZoneStat {
  const InsightsBodyZoneStat({
    required this.painAreaCode,
    required this.hits,
    required this.share,
    required this.averageReliefScore,
  });

  final String painAreaCode;
  final int hits;
  final double share;
  final double averageReliefScore;
}

class InsightLogItem {
  const InsightLogItem({
    required this.id,
    required this.title,
    required this.body,
    required this.tone,
  });

  final String id;
  final String title;
  final String body;
  final InsightLogTone tone;
}