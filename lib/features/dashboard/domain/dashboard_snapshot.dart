// lib/features/dashboard/domain/dashboard_snapshot.dart

import '../../../features/player/domain/session_feedback_models.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.readinessScore,
    required this.weeklyMinutes,
    required this.completedSessionsThisWeek,
    required this.quickFixStartsThisWeek,
    required this.helpRate,
    required this.consistencyScore,
    required this.currentEnergyLevel,
    required this.currentStressLevel,
    required this.currentFocusLevel,
    required this.dominantPainAreaCode,
    required this.nextSession,
    required this.recoveryMinutesSeries,
    required this.reliefSeries,
    required this.heatmapCells,
    required this.bodyZones,
    required this.recentRuns,
  });

  final int readinessScore;
  final int weeklyMinutes;
  final int completedSessionsThisWeek;
  final int quickFixStartsThisWeek;
  final double helpRate;
  final double consistencyScore;

  final SessionStateLevel? currentEnergyLevel;
  final SessionStateLevel? currentStressLevel;
  final SessionStateLevel? currentFocusLevel;

  final String? dominantPainAreaCode;
  final DashboardNextSession? nextSession;

  final List<DashboardSeriesPoint> recoveryMinutesSeries;
  final List<DashboardSeriesPoint> reliefSeries;
  final List<DashboardHeatmapCell> heatmapCells;
  final List<DashboardBodyZoneStat> bodyZones;
  final List<DashboardRecentRun> recentRuns;

  bool get hasContent {
    return weeklyMinutes > 0 ||
        completedSessionsThisWeek > 0 ||
        quickFixStartsThisWeek > 0 ||
        bodyZones.isNotEmpty ||
        recentRuns.isNotEmpty ||
        recoveryMinutesSeries.isNotEmpty ||
        heatmapCells.isNotEmpty;
  }
}

class DashboardNextSession {
  const DashboardNextSession({
    required this.sessionId,
    required this.titleKey,
    required this.titleFallback,
    required this.durationMinutes,
    required this.entrySource,
    required this.accessTier,
    required this.isActiveRun,
  });

  final String sessionId;
  final String titleKey;
  final String titleFallback;
  final int durationMinutes;
  final SessionEntrySource entrySource;
  final String accessTier;
  final bool isActiveRun;

  bool get requiresCoreAccess => accessTier == 'core_access';
}

class DashboardSeriesPoint {
  const DashboardSeriesPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class DashboardHeatmapCell {
  const DashboardHeatmapCell({
    required this.date,
    required this.intensity,
  });

  final DateTime date;
  final double intensity;
}

class DashboardBodyZoneStat {
  const DashboardBodyZoneStat({
    required this.painAreaCode,
    required this.hits,
    required this.reliefScore,
  });

  final String painAreaCode;
  final int hits;
  final double reliefScore;
}

enum DashboardRunStatus {
  completed,
  abandoned,
  started,
}

class DashboardRecentRun {
  const DashboardRecentRun({
    required this.runId,
    required this.sessionId,
    required this.titleKey,
    required this.titleFallback,
    required this.status,
    required this.elapsedMinutes,
    required this.createdAt,
    required this.entrySource,
    this.completedAt,
    this.helped,
    this.primaryPainAreaCode,
  });

  final String runId;
  final String sessionId;
  final String titleKey;
  final String titleFallback;
  final DashboardRunStatus status;
  final int elapsedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final SessionEntrySource entrySource;
  final bool? helped;
  final String? primaryPainAreaCode;
}