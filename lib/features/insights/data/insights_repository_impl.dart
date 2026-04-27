// lib/features/insights/data/insights_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/insights_repository.dart';
import '../domain/insights_snapshot.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  InsightsRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> _safeSelectList(
    String label,
    Future<dynamic> Function() query,
  ) async {
    try {
      final response = await query();
      return (response as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
    } catch (error, stackTrace) {
      debugPrint('InsightsRepository.$label failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const <Map<String, dynamic>>[];
    }
  }

  @override
  Future<InsightsSnapshot> getInsightsSnapshot({
    required InsightsRange range,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return InsightsSnapshot(
        range: range,
        consistencyScore: 0,
        recoveryMinutes: 0,
        dominantPainAreaCode: null,
        quickFixStarts: 0,
        completedSessions: 0,
        totalRuns: 0,
        helpRate: 0,
        averageReliefScore: 0,
        currentStreakDays: 0,
        longestStreakDays: 0,
        recoveryMinutesSeries: _emptySeries(range.days),
        reliefSeries: _emptySeries(range.days),
        heatmapCells: _emptyHeatmap(),
        bodyZones: const [],
        logs: const [],
      );
    }

    final now = DateTime.now().toUtc();
    final rangeStart = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: range.days - 1));

    final heatmapStart = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 34));

    final runsRows = await _safeSelectList(
      'session_runs',
      () => _client
          .from('session_runs')
          .select(
            'id, user_id, session_id, status, total_elapsed_seconds, created_at, completed_at, abandoned_at, entry_source',
          )
          .eq('user_id', user.id)
          .gte('created_at', heatmapStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final feedbackRows = await _safeSelectList(
      'session_feedback',
      () => _client
          .from('session_feedback')
          .select(
            'run_id, user_id, session_id, helped, tension_delta, pain_delta, energy_delta, perceived_fit, would_repeat, completion_status, entry_source, created_at',
          )
          .eq('user_id', user.id)
          .gte('created_at', heatmapStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final snapshotRows = await _safeSelectList(
      'session_state_snapshots',
      () => _client
          .from('session_state_snapshots')
          .select(
            'run_id, user_id, session_id, snapshot_kind, energy_level, stress_level, focus_level, pain_area_codes, intent_code, entry_source, created_at',
          )
          .eq('user_id', user.id)
          .gte('created_at', heatmapStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final quickFixRows = await _safeSelectList(
      'quick_fix_events',
      () => _client
          .from('quick_fix_events')
          .select(
            'user_id, recommended_session_id, action_type, created_at',
          )
          .eq('user_id', user.id)
          .gte('created_at', heatmapStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final stepEventRows = await _safeSelectList(
      'session_step_events',
      () => _client
          .from('session_step_events')
          .select(
            'user_id, run_id, session_id, step_id, event_type, step_index, total_elapsed_seconds, created_at',
          )
          .eq('user_id', user.id)
          .gte('created_at', heatmapStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final templatesRows = await _safeSelectList(
      'session_templates',
      () => _client.from('session_templates').select(
            'id, title_key, title_fallback, duration_minutes',
          ),
    );

    final templateById = <String, Map<String, dynamic>>{
      for (final row in templatesRows)
        if (row['id'] is String) row['id'] as String: row,
    };

    final runsInRange = runsRows.where((row) {
      final createdAt = _parseDate(row['created_at']);
      return createdAt != null && !createdAt.isBefore(rangeStart);
    }).toList(growable: false);

    final feedbackInRange = feedbackRows.where((row) {
      final createdAt = _parseDate(row['created_at']);
      return createdAt != null && !createdAt.isBefore(rangeStart);
    }).toList(growable: false);

    final snapshotsInRange = snapshotRows.where((row) {
      final createdAt = _parseDate(row['created_at']);
      return createdAt != null && !createdAt.isBefore(rangeStart);
    }).toList(growable: false);

    final quickFixInRange = quickFixRows.where((row) {
      final createdAt = _parseDate(row['created_at']);
      return createdAt != null && !createdAt.isBefore(rangeStart);
    }).toList(growable: false);

    final stepEventsInRange = stepEventRows.where((row) {
      final createdAt = _parseDate(row['created_at']);
      return createdAt != null && !createdAt.isBefore(rangeStart);
    }).toList(growable: false);

    final feedbackByRun = <String, Map<String, dynamic>>{};
    for (final row in feedbackRows) {
      final runId = row['run_id'] as String?;
      if (runId != null) {
        feedbackByRun[runId] = row;
      }
    }

    final consistencyScore = _computeConsistencyScore(
      runsRows: runsInRange,
      range: range,
      rangeStart: rangeStart,
    );

    final recoveryMinutes = runsInRange.fold<int>(
      0,
      (sum, row) => sum + (_asInt(row['total_elapsed_seconds']) ~/ 60),
    );

    final quickFixStarts = quickFixInRange.where((row) {
      return (row['action_type'] as String?) == 'startSession';
    }).length;

    final completedSessions = runsInRange.where((row) {
      return (row['status'] as String?) == 'completed';
    }).length;

    final totalRuns = runsInRange.length;

    final helpRate = _computeHelpRate(feedbackInRange);
    final averageReliefScore = _computeAverageRelief(feedbackInRange);

    final bodyZones = _buildBodyZoneStats(
      snapshotRows: snapshotsInRange,
      feedbackByRun: feedbackByRun,
    );

    final dominantPainAreaCode =
        bodyZones.isEmpty ? null : bodyZones.first.painAreaCode;

    final recoveryMinutesSeries = _buildRecoveryMinutesSeries(
      runsRows: runsInRange,
      range: range,
      rangeStart: rangeStart,
    );

    final reliefSeries = _buildReliefSeries(
      feedbackRows: feedbackInRange,
      range: range,
      rangeStart: rangeStart,
    );

    final heatmapCells = _buildHeatmapCells(
      runsRows: runsRows,
      heatmapStart: heatmapStart,
    );

    final activeDays = recoveryMinutesSeries
        .where((point) => point.value > 0)
        .map((point) => DateTime.utc(point.date.year, point.date.month, point.date.day))
        .toSet()
        .toList()
      ..sort();

    final currentStreakDays = _computeCurrentStreak(activeDays, now);
    final longestStreakDays = _computeLongestStreak(activeDays);

    final logs = _buildLogs(
      range: range,
      templateById: templateById,
      runsInRange: runsInRange,
      feedbackInRange: feedbackInRange,
      quickFixInRange: quickFixInRange,
      stepEventsInRange: stepEventsInRange,
      bodyZones: bodyZones,
      consistencyScore: consistencyScore,
      helpRate: helpRate,
      currentStreakDays: currentStreakDays,
      averageReliefScore: averageReliefScore,
    );

    return InsightsSnapshot(
      range: range,
      consistencyScore: consistencyScore,
      recoveryMinutes: recoveryMinutes,
      dominantPainAreaCode: dominantPainAreaCode,
      quickFixStarts: quickFixStarts,
      completedSessions: completedSessions,
      totalRuns: totalRuns,
      helpRate: helpRate,
      averageReliefScore: averageReliefScore,
      currentStreakDays: currentStreakDays,
      longestStreakDays: longestStreakDays,
      recoveryMinutesSeries: recoveryMinutesSeries,
      reliefSeries: reliefSeries,
      heatmapCells: heatmapCells,
      bodyZones: bodyZones,
      logs: logs,
    );
  }

  List<InsightsSeriesPoint> _emptySeries(int days) {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    return List.generate(days, (index) {
      final date = DateTime.utc(start.year, start.month, start.day + index);
      return InsightsSeriesPoint(
        date: date,
        label: _weekdayLabel(date.weekday),
        value: 0,
      );
    });
  }

  List<InsightsHeatmapCell> _emptyHeatmap() {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day)
        .subtract(const Duration(days: 34));

    return List.generate(35, (index) {
      final date = DateTime.utc(start.year, start.month, start.day + index);
      return InsightsHeatmapCell(
        date: date,
        minutes: 0,
        intensity: 0,
      );
    });
  }

  List<InsightsSeriesPoint> _buildRecoveryMinutesSeries({
    required List<Map<String, dynamic>> runsRows,
    required InsightsRange range,
    required DateTime rangeStart,
  }) {
    final buckets = <DateTime, int>{};

    for (var i = 0; i < range.days; i++) {
      final day = DateTime.utc(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day + i,
      );
      buckets[day] = 0;
    }

    for (final row in runsRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(rangeStart)) continue;

      final day = DateTime.utc(createdAt.year, createdAt.month, createdAt.day);
      buckets.update(
        day,
        (value) => value + (_asInt(row['total_elapsed_seconds']) ~/ 60),
        ifAbsent: () => (_asInt(row['total_elapsed_seconds']) ~/ 60),
      );
    }

    return buckets.entries.map((entry) {
      return InsightsSeriesPoint(
        date: entry.key,
        label: _weekdayLabel(entry.key.weekday),
        value: entry.value.toDouble(),
      );
    }).toList(growable: false);
  }

  List<InsightsSeriesPoint> _buildReliefSeries({
    required List<Map<String, dynamic>> feedbackRows,
    required InsightsRange range,
    required DateTime rangeStart,
  }) {
    final buckets = <DateTime, List<double>>{};

    for (var i = 0; i < range.days; i++) {
      final day = DateTime.utc(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day + i,
      );
      buckets[day] = <double>[];
    }

    for (final row in feedbackRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(rangeStart)) continue;

      final day = DateTime.utc(createdAt.year, createdAt.month, createdAt.day);
      buckets.putIfAbsent(day, () => <double>[]).add(_feedbackScore(row));
    }

    return buckets.entries.map((entry) {
      final values = entry.value;
      final average = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;

      return InsightsSeriesPoint(
        date: entry.key,
        label: _weekdayLabel(entry.key.weekday),
        value: average,
      );
    }).toList(growable: false);
  }

  List<InsightsHeatmapCell> _buildHeatmapCells({
    required List<Map<String, dynamic>> runsRows,
    required DateTime heatmapStart,
  }) {
    final dailyMinutes = <DateTime, int>{};

    for (var i = 0; i < 35; i++) {
      final day = DateTime.utc(
        heatmapStart.year,
        heatmapStart.month,
        heatmapStart.day + i,
      );
      dailyMinutes[day] = 0;
    }

    for (final row in runsRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(heatmapStart)) continue;

      final day = DateTime.utc(createdAt.year, createdAt.month, createdAt.day);
      dailyMinutes.update(
        day,
        (value) => value + (_asInt(row['total_elapsed_seconds']) ~/ 60),
        ifAbsent: () => (_asInt(row['total_elapsed_seconds']) ~/ 60),
      );
    }

    final maxValue = dailyMinutes.values.fold<int>(0, (a, b) => a > b ? a : b);

    return dailyMinutes.entries.map((entry) {
      final intensity = maxValue <= 0 ? 0.0 : (entry.value / maxValue);
      return InsightsHeatmapCell(
        date: entry.key,
        minutes: entry.value,
        intensity: intensity.clamp(0.0, 1.0),
      );
    }).toList(growable: false);
  }

  List<InsightsBodyZoneStat> _buildBodyZoneStats({
    required List<Map<String, dynamic>> snapshotRows,
    required Map<String, Map<String, dynamic>> feedbackByRun,
  }) {
    final counts = <String, int>{};
    final reliefBuckets = <String, List<double>>{};
    var totalHits = 0;

    for (final row in snapshotRows) {
      final kind = row['snapshot_kind'] as String?;
      if (kind != 'after') continue;

      final runId = row['run_id'] as String?;
      final painAreas =
          (row['pain_area_codes'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(growable: false);

      final feedback = runId == null ? null : feedbackByRun[runId];
      final reliefScore = feedback == null ? null : _feedbackScore(feedback);

      for (final code in painAreas) {
        counts.update(code, (value) => value + 1, ifAbsent: () => 1);
        totalHits += 1;

        if (reliefScore != null) {
          reliefBuckets.putIfAbsent(code, () => <double>[]).add(reliefScore);
        }
      }
    }

    if (totalHits <= 0) return const <InsightsBodyZoneStat>[];

    final items = counts.entries.map((entry) {
      final scores = reliefBuckets[entry.key] ?? const <double>[];
      final averageRelief = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;

      return InsightsBodyZoneStat(
        painAreaCode: entry.key,
        hits: entry.value,
        share: entry.value / totalHits,
        averageReliefScore: averageRelief,
      );
    }).toList();

    items.sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      if (byHits != 0) return byHits;
      return b.averageReliefScore.compareTo(a.averageReliefScore);
    });

    return items;
  }

  List<InsightLogItem> _buildLogs({
    required InsightsRange range,
    required Map<String, Map<String, dynamic>> templateById,
    required List<Map<String, dynamic>> runsInRange,
    required List<Map<String, dynamic>> feedbackInRange,
    required List<Map<String, dynamic>> quickFixInRange,
    required List<Map<String, dynamic>> stepEventsInRange,
    required List<InsightsBodyZoneStat> bodyZones,
    required double consistencyScore,
    required double helpRate,
    required int currentStreakDays,
    required double averageReliefScore,
  }) {
    final logs = <InsightLogItem>[];

    final completedRuns = runsInRange.where(
      (row) => (row['status'] as String?) == 'completed',
    ).length;
    final abandonedRuns = runsInRange.where(
      (row) => (row['status'] as String?) == 'abandoned',
    ).length;

    final quickFixStarts = quickFixInRange.where(
      (row) => (row['action_type'] as String?) == 'startSession',
    ).length;

    final skippedCount = stepEventsInRange.where(
      (row) => (row['event_type'] as String?) == 'step_skipped',
    ).length;

    final pausedCount = stepEventsInRange.where(
      (row) => (row['event_type'] as String?) == 'player_paused',
    ).length;

    if (currentStreakDays >= 3) {
      logs.add(
        InsightLogItem(
          id: 'streak',
          title: 'Recovery rhythm is holding',
          body:
              'You have been active for $currentStreakDays days in a row across the last ${range.days}-day window.',
          tone: InsightLogTone.positive,
        ),
      );
    }

    if (bodyZones.isNotEmpty) {
      final topZone = bodyZones.first;
      logs.add(
        InsightLogItem(
          id: 'dominant_zone',
          title: 'Most attention is landing on ${_painAreaLabel(topZone.painAreaCode)}',
          body:
              '${(topZone.share * 100).round()}% of recent after-session pain tagging was concentrated in this zone.',
          tone: InsightLogTone.neutral,
        ),
      );
    }

    if (quickFixStarts > completedRuns) {
      logs.add(
        InsightLogItem(
          id: 'quick_fix_bias',
          title: 'Quick Fix use is outpacing full sessions',
          body:
              'You launched Quick Fix $quickFixStarts times, while completed sessions landed at $completedRuns. That usually signals speed-first behavior.',
          tone: InsightLogTone.neutral,
        ),
      );
    }

    if (abandonedRuns > 0 && abandonedRuns >= completedRuns) {
      logs.add(
        InsightLogItem(
          id: 'abandon_pattern',
          title: 'A notable share of runs end early',
          body:
              '$abandonedRuns runs were abandoned in this window. This may indicate session length mismatch or friction inside the player flow.',
          tone: InsightLogTone.warning,
        ),
      );
    }

    if (skippedCount >= 3) {
      logs.add(
        InsightLogItem(
          id: 'skip_pattern',
          title: 'Step skipping shows friction',
          body:
              '$skippedCount step-skip events were recorded recently. Consider reviewing which session flows are being skipped most often.',
          tone: InsightLogTone.warning,
        ),
      );
    }

    if (pausedCount >= 4) {
      logs.add(
        InsightLogItem(
          id: 'pause_pattern',
          title: 'Pause frequency is elevated',
          body:
              '$pausedCount pause events were detected. This often suggests interruption-heavy recovery sessions or low-flow timing.',
          tone: InsightLogTone.neutral,
        ),
      );
    }

    if (feedbackInRange.isNotEmpty && helpRate >= 0.70) {
      logs.add(
        InsightLogItem(
          id: 'help_rate',
          title: 'Recent feedback trend is positive',
          body:
              '${(helpRate * 100).round()}% of recent feedback marked sessions as helpful, with an average relief score of ${averageReliefScore.round()}.',
          tone: InsightLogTone.positive,
        ),
      );
    }

    if (logs.isEmpty && runsInRange.isNotEmpty) {
      logs.add(
        const InsightLogItem(
          id: 'baseline',
          title: 'Recovery data is accumulating',
          body:
              'More insights will appear as more runs, snapshots, feedback, and step events are collected.',
          tone: InsightLogTone.neutral,
        ),
      );
    }

    return logs.take(6).toList(growable: false);
  }

  double _computeConsistencyScore({
    required List<Map<String, dynamic>> runsRows,
    required InsightsRange range,
    required DateTime rangeStart,
  }) {
    if (runsRows.isEmpty) return 0.0;

    final activeDays = <DateTime>{};
    for (final row in runsRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(rangeStart)) continue;

      activeDays.add(
        DateTime.utc(createdAt.year, createdAt.month, createdAt.day),
      );
    }

    return activeDays.length / range.days;
  }

  double _computeHelpRate(List<Map<String, dynamic>> feedbackRows) {
    if (feedbackRows.isEmpty) return 0.0;

    final helpedCount = feedbackRows.where((row) => row['helped'] == true).length;
    return helpedCount / feedbackRows.length;
  }

  double _computeAverageRelief(List<Map<String, dynamic>> feedbackRows) {
    if (feedbackRows.isEmpty) return 0.0;

    final scores = feedbackRows.map(_feedbackScore).toList(growable: false);
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int _computeCurrentStreak(List<DateTime> activeDays, DateTime now) {
    if (activeDays.isEmpty) return 0;

    final activeSet = activeDays.toSet();
    var streak = 0;
    var cursor = DateTime.utc(now.year, now.month, now.day);

    while (activeSet.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _computeLongestStreak(List<DateTime> activeDays) {
    if (activeDays.isEmpty) return 0;

    var longest = 1;
    var current = 1;

    for (var i = 1; i < activeDays.length; i++) {
      final previous = activeDays[i - 1];
      final currentDay = activeDays[i];
      final difference = currentDay.difference(previous).inDays;

      if (difference == 1) {
        current += 1;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }

    return longest;
  }

  double _feedbackScore(Map<String, dynamic> row) {
    double score = 0.0;

    if (row['helped'] == true) score += 0.30;
    score += _deltaScore(row['tension_delta'] as String?) * 0.20;
    score += _deltaScore(row['pain_delta'] as String?) * 0.20;
    score += _deltaScore(row['energy_delta'] as String?) * 0.15;
    score += _fitScore(row['perceived_fit'] as String?) * 0.10;
    score += (row['would_repeat'] == true ? 1.0 : 0.0) * 0.05;

    return (score * 100).clamp(0, 100);
  }

  double _deltaScore(String? raw) {
    switch (raw) {
      case 'better':
        return 1.0;
      case 'same':
        return 0.55;
      case 'worse':
        return 0.10;
      default:
        return 0.0;
    }
  }

  double _fitScore(String? raw) {
    switch (raw) {
      case 'great':
        return 1.0;
      case 'okay':
        return 0.6;
      case 'poor':
        return 0.15;
      default:
        return 0.0;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }

  String _painAreaLabel(String raw) {
    switch (raw) {
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
        return raw.replaceAll('_', ' ');
    }
  }
}