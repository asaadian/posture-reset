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
    this.recoveryScore = 0,
    this.recoveryScoreTitle = 'Recovery score',
    this.recoveryScoreBody = 'Complete a few sessions to build a reliable recovery signal.',
    this.activeDaysCount = 0,
    this.abandonedRuns = 0,
    this.skippedStepEvents = 0,
    this.pausedEvents = 0,
    this.bestDayLabel,
    this.bestDayMinutes = 0,
    this.undertrainedBodyZoneCodes = const <String>[],
    this.sessionEffectiveness = const <InsightsSessionEffectiveness>[],
    this.nextBestAction = const InsightsNextBestAction.empty(),
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

  /// Premium intelligence fields derived from runs, feedback, body-zone data,
  /// step events, and Quick Fix behavior. These are intentionally lightweight
  /// rule-based signals, not medical claims.
  final int recoveryScore;
  final String recoveryScoreTitle;
  final String recoveryScoreBody;
  final int activeDaysCount;
  final int abandonedRuns;
  final int skippedStepEvents;
  final int pausedEvents;
  final String? bestDayLabel;
  final int bestDayMinutes;
  final List<String> undertrainedBodyZoneCodes;
  final List<InsightsSessionEffectiveness> sessionEffectiveness;
  final InsightsNextBestAction nextBestAction;

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

class InsightsSessionEffectiveness {
  const InsightsSessionEffectiveness({
    required this.sessionId,
    required this.title,
    required this.completedRuns,
    required this.helpRate,
    required this.averageReliefScore,
  });

  final String sessionId;
  final String title;
  final int completedRuns;
  final double helpRate;
  final double averageReliefScore;
}

class InsightsNextBestAction {
  const InsightsNextBestAction({
    required this.title,
    required this.body,
    required this.reason,
    this.sessionId,
  });

  const InsightsNextBestAction.empty()
      : title = 'Build your recovery signal',
        body = 'Complete a few sessions so Posture Reset can recommend the next best action.',
        reason = 'Not enough recent data yet.',
        sessionId = null;

  final String title;
  final String body;
  final String reason;
  final String? sessionId;
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
