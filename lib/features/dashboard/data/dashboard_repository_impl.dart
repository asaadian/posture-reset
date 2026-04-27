// lib/features/dashboard/data/dashboard_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../player/domain/session_feedback_models.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_snapshot.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._client);

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
      debugPrint('DashboardRepository.$label failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const <Map<String, dynamic>>[];
    }
  }

  DashboardSnapshot _emptySnapshot() {
    return const DashboardSnapshot(
      readinessScore: 0,
      weeklyMinutes: 0,
      completedSessionsThisWeek: 0,
      quickFixStartsThisWeek: 0,
      helpRate: 0,
      consistencyScore: 0,
      currentEnergyLevel: null,
      currentStressLevel: null,
      currentFocusLevel: null,
      dominantPainAreaCode: null,
      nextSession: null,
      recoveryMinutesSeries: <DashboardSeriesPoint>[],
      reliefSeries: <DashboardSeriesPoint>[],
      heatmapCells: <DashboardHeatmapCell>[],
      bodyZones: <DashboardBodyZoneStat>[],
      recentRuns: <DashboardRecentRun>[],
    );
  }

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    try {
      final now = DateTime.now().toUtc();
      final start7 = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      final start21 = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 20));
      final start28 = DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 27));

      final runsRows = await _safeSelectList(
        'session_runs',
        () => _client
            .from('session_runs')
            .select(
              'id, session_id, status, total_elapsed_seconds, completed_at, started_at, created_at, entry_source, last_step_id',
            )
            .gte('created_at', start28.toIso8601String())
            .order('created_at', ascending: true),
      );

      final feedbackRows = await _safeSelectList(
        'session_feedback',
        () => _client
            .from('session_feedback')
            .select(
              'run_id, helped, tension_delta, pain_delta, energy_delta, perceived_fit, would_repeat, completion_status, entry_source, created_at',
            )
            .gte('created_at', start28.toIso8601String())
            .order('created_at', ascending: true),
      );

      final snapshotRows = await _safeSelectList(
        'session_state_snapshots',
        () => _client
            .from('session_state_snapshots')
            .select(
              'run_id, snapshot_kind, energy_level, stress_level, focus_level, pain_area_codes, intent_code, entry_source, created_at',
            )
            .gte('created_at', start28.toIso8601String())
            .order('created_at', ascending: true),
      );

      final quickFixRows = await _safeSelectList(
        'quick_fix_events',
        () => _client
            .from('quick_fix_events')
            .select('recommended_session_id, action_type, created_at')
            .gte('created_at', start28.toIso8601String())
            .order('created_at', ascending: true),
      );

      final templatesRows = await _safeSelectList(
        'session_templates',
        () => _client.from('session_templates').select(
              'id, title_key, title_fallback, duration_minutes, access_tier',
            ),
      );  

      final templateById = <String, Map<String, dynamic>>{};
      for (final row in templatesRows) {
        final rawId = row['id'];
        if (rawId is String && rawId.trim().isNotEmpty) {
          templateById[rawId] = row;
        }
      }

      final feedbackByRun = <String, Map<String, dynamic>>{};
      for (final row in feedbackRows) {
        final runId = row['run_id'] as String?;
        if (runId != null && runId.isNotEmpty) {
          feedbackByRun[runId] = row;
        }
      }

      final snapshotsByRun = <String, List<Map<String, dynamic>>>{};
      for (final row in snapshotRows) {
        final runId = row['run_id'] as String?;
        if (runId == null || runId.isEmpty) continue;
        snapshotsByRun.putIfAbsent(runId, () => <Map<String, dynamic>>[]).add(row);
      }

      final runsLast7 = runsRows.where((row) {
        final createdAt = _parseDate(row['created_at']);
        return createdAt != null && !createdAt.isBefore(start7);
      }).toList();

      final quickFixLast7 = quickFixRows.where((row) {
        final createdAt = _parseDate(row['created_at']);
        return createdAt != null && !createdAt.isBefore(start7);
      }).toList();

      final weeklyMinutes = runsLast7.fold<int>(
        0,
        (sum, row) => sum + (_asInt(row['total_elapsed_seconds']) ~/ 60),
      );

      final completedSessionsThisWeek = runsLast7.where((row) {
        return (row['status'] as String?) == 'completed';
      }).length;

      final quickFixStartsThisWeek = quickFixLast7.where((row) {
        return (row['action_type'] as String?) == 'startSession';
      }).length;

      final latestSnapshot = _pickLatestSnapshot(snapshotRows);
      final latestEnergy =
          _parseStateLevel(latestSnapshot?['energy_level'] as String?);
      final latestStress =
          _parseStateLevel(latestSnapshot?['stress_level'] as String?);
      final latestFocus =
          _parseStateLevel(latestSnapshot?['focus_level'] as String?);

      final bodyZoneStats = _buildBodyZoneStats(
        snapshotRows: snapshotRows,
        feedbackByRun: feedbackByRun,
      );

      final dominantPainAreaCode =
          bodyZoneStats.isEmpty ? null : bodyZoneStats.first.painAreaCode;

      final recoveryMinutesSeries = _buildRecoveryMinutesSeries(
        runsRows: runsRows,
        start7: start7,
      );

      final reliefSeries = _buildReliefSeries(
        feedbackRows: feedbackRows,
        start7: start7,
      );

      final heatmapCells = _buildHeatmapCells(
        runsRows: runsRows,
        start21: start21,
      );

      final helpRate = _computeHelpRate(feedbackRows);
      final consistencyScore = _computeConsistencyScore(heatmapCells);

      final readinessScore = _computeReadinessScore(
        energy: latestEnergy,
        stress: latestStress,
        focus: latestFocus,
        helpRate: helpRate,
        consistencyScore: consistencyScore,
      );

      final recentRuns = _buildRecentRuns(
        runsRows: runsRows,
        feedbackByRun: feedbackByRun,
        snapshotsByRun: snapshotsByRun,
        templateById: templateById,
      );

      final nextSession = _buildNextSession(
        quickFixRows: quickFixRows,
        runsRows: runsRows,
        templateById: templateById,
      );

      return DashboardSnapshot(
        readinessScore: readinessScore,
        weeklyMinutes: weeklyMinutes,
        completedSessionsThisWeek: completedSessionsThisWeek,
        quickFixStartsThisWeek: quickFixStartsThisWeek,
        helpRate: helpRate,
        consistencyScore: consistencyScore,
        currentEnergyLevel: latestEnergy,
        currentStressLevel: latestStress,
        currentFocusLevel: latestFocus,
        dominantPainAreaCode: dominantPainAreaCode,
        nextSession: nextSession,
        recoveryMinutesSeries: recoveryMinutesSeries,
        reliefSeries: reliefSeries,
        heatmapCells: heatmapCells,
        bodyZones: bodyZoneStats,
        recentRuns: recentRuns,
      );
    } catch (error, stackTrace) {
      debugPrint('DashboardRepository.getDashboardSnapshot failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return _emptySnapshot();
    }
  }

  List<DashboardRecentRun> _buildRecentRuns({
    required List<Map<String, dynamic>> runsRows,
    required Map<String, Map<String, dynamic>> feedbackByRun,
    required Map<String, List<Map<String, dynamic>>> snapshotsByRun,
    required Map<String, Map<String, dynamic>> templateById,
  }) {
    final recent = runsRows.reversed.take(5).toList();

    return recent.map((row) {
      final runId = row['id'] as String? ?? '';
      final sessionId = row['session_id'] as String? ?? '';
      final template = templateById[sessionId];

      final feedback = feedbackByRun[runId];
      final snapshots = snapshotsByRun[runId] ?? const <Map<String, dynamic>>[];
      final latestSnapshot = snapshots.isEmpty ? null : snapshots.last;

      final painAreasRaw =
          (latestSnapshot?['pain_area_codes'] as List<dynamic>? ?? const [])
              .cast<dynamic>();
      final primaryPainAreaCode =
          painAreasRaw.isEmpty ? null : painAreasRaw.first.toString();

      return DashboardRecentRun(
        runId: runId,
        sessionId: sessionId,
        titleKey: template?['title_key'] as String? ?? '',
        titleFallback:
            template?['title_fallback'] as String? ?? _humanizeSessionId(sessionId),
        status: _parseRunStatus(row['status'] as String?),
        elapsedMinutes: (_asInt(row['total_elapsed_seconds']) / 60).round(),
        createdAt: _parseDate(row['created_at']) ?? DateTime.now().toUtc(),
        completedAt: _parseDate(row['completed_at']),
        entrySource: SessionEntrySource.fromRaw(
          row['entry_source'] as String? ??
              feedback?['entry_source'] as String? ??
              latestSnapshot?['entry_source'] as String?,
        ),
        helped: feedback?['helped'] as bool?,
        primaryPainAreaCode: primaryPainAreaCode,
      );
    }).toList(growable: false);
  }

  DashboardNextSession? _buildNextSession({
    required List<Map<String, dynamic>> quickFixRows,
    required List<Map<String, dynamic>> runsRows,
    required Map<String, Map<String, dynamic>> templateById,
  }) {
    Map<String, dynamic>? activeRun;
    for (final row in runsRows.reversed) {
      if ((row['status'] as String?) == 'started') {
        activeRun = row;
        break;
      }
    }

    if (activeRun != null) {
      final sessionId = activeRun['session_id'] as String?;
      if (sessionId != null && sessionId.isNotEmpty) {
        final template = templateById[sessionId];
        if (template != null) {
          return DashboardNextSession(
            sessionId: sessionId,
            titleKey: template['title_key'] as String? ?? '',
            titleFallback:
                template['title_fallback'] as String? ?? _humanizeSessionId(sessionId),
            durationMinutes: _asInt(template['duration_minutes']),
            entrySource: SessionEntrySource.fromRaw(
              activeRun['entry_source'] as String?,
            ),
            accessTier: _accessTierRaw(template['access_tier']),
            isActiveRun: true,
          );
        }
      }
    }

    for (final row in quickFixRows.reversed) {
      final recommendedSessionId = row['recommended_session_id'] as String?;
      if (recommendedSessionId == null || recommendedSessionId.isEmpty) continue;

      final template = templateById[recommendedSessionId];
      if (template == null) continue;

      return DashboardNextSession(
        sessionId: recommendedSessionId,
        titleKey: template['title_key'] as String? ?? '',
        titleFallback: template['title_fallback'] as String? ??
            _humanizeSessionId(recommendedSessionId),
        durationMinutes: _asInt(template['duration_minutes']),
        entrySource: SessionEntrySource.quickFix,
        accessTier: _accessTierRaw(template['access_tier']),
        isActiveRun: false,
      );
    }

    for (final row in runsRows.reversed) {
      final sessionId = row['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) continue;

      final template = templateById[sessionId];
      if (template == null) continue;

      return DashboardNextSession(
        sessionId: sessionId,
        titleKey: template['title_key'] as String? ?? '',
        titleFallback:
            template['title_fallback'] as String? ?? _humanizeSessionId(sessionId),
        durationMinutes: _asInt(template['duration_minutes']),
        entrySource: SessionEntrySource.fromRaw(
          row['entry_source'] as String?,
        ),
        accessTier: _accessTierRaw(template['access_tier']),
        isActiveRun: false,
      );
    }

    return null;
  }

  List<DashboardBodyZoneStat> _buildBodyZoneStats({
    required List<Map<String, dynamic>> snapshotRows,
    required Map<String, Map<String, dynamic>> feedbackByRun,
  }) {
    final counts = <String, int>{};
    final reliefBuckets = <String, List<double>>{};

    for (final row in snapshotRows) {
      final kind = row['snapshot_kind'] as String?;
      if (kind != 'after') continue;

      final runId = row['run_id'] as String?;
      final painAreas =
          (row['pain_area_codes'] as List<dynamic>? ?? const <dynamic>[])
              .map((e) => e.toString())
              .toList(growable: false);

      final feedback = runId == null ? null : feedbackByRun[runId];
      final reliefScore = feedback == null ? null : _feedbackScore(feedback);

      for (final code in painAreas) {
        counts.update(code, (value) => value + 1, ifAbsent: () => 1);
        if (reliefScore != null) {
          reliefBuckets.putIfAbsent(code, () => <double>[]).add(reliefScore);
        }
      }
    }

    final items = counts.entries.map((entry) {
      final scores = reliefBuckets[entry.key] ?? const <double>[];
      final avgRelief = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;

      return DashboardBodyZoneStat(
        painAreaCode: entry.key,
        hits: entry.value,
        reliefScore: avgRelief,
      );
    }).toList();

    items.sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      if (byHits != 0) return byHits;
      return b.reliefScore.compareTo(a.reliefScore);
    });

    return items.take(4).toList(growable: false);
  }

  List<DashboardSeriesPoint> _buildRecoveryMinutesSeries({
    required List<Map<String, dynamic>> runsRows,
    required DateTime start7,
  }) {
    final buckets = <DateTime, int>{};

    for (var i = 0; i < 7; i++) {
      final day = DateTime.utc(start7.year, start7.month, start7.day + i);
      buckets[day] = 0;
    }

    for (final row in runsRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(start7)) continue;

      final day = DateTime.utc(createdAt.year, createdAt.month, createdAt.day);
      buckets.update(
        day,
        (value) => value + (_asInt(row['total_elapsed_seconds']) ~/ 60),
        ifAbsent: () => (_asInt(row['total_elapsed_seconds']) ~/ 60),
      );
    }

    return buckets.entries.map((entry) {
      return DashboardSeriesPoint(
        label: _weekdayLabel(entry.key.weekday),
        value: entry.value.toDouble(),
      );
    }).toList(growable: false);
  }

  List<DashboardSeriesPoint> _buildReliefSeries({
    required List<Map<String, dynamic>> feedbackRows,
    required DateTime start7,
  }) {
    final buckets = <DateTime, List<double>>{};

    for (var i = 0; i < 7; i++) {
      final day = DateTime.utc(start7.year, start7.month, start7.day + i);
      buckets[day] = <double>[];
    }

    for (final row in feedbackRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(start7)) continue;

      final day = DateTime.utc(createdAt.year, createdAt.month, createdAt.day);
      buckets.putIfAbsent(day, () => <double>[]).add(_feedbackScore(row));
    }

    return buckets.entries.map((entry) {
      final values = entry.value;
      final avg = values.isEmpty
          ? 0.0
          : values.reduce((a, b) => a + b) / values.length;

      return DashboardSeriesPoint(
        label: _weekdayLabel(entry.key.weekday),
        value: avg,
      );
    }).toList(growable: false);
  }

  List<DashboardHeatmapCell> _buildHeatmapCells({
    required List<Map<String, dynamic>> runsRows,
    required DateTime start21,
  }) {
    final dailyMinutes = <DateTime, int>{};

    for (var i = 0; i < 21; i++) {
      final day = DateTime.utc(start21.year, start21.month, start21.day + i);
      dailyMinutes[day] = 0;
    }

    for (final row in runsRows) {
      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null || createdAt.isBefore(start21)) continue;

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
      return DashboardHeatmapCell(
        date: entry.key,
        intensity: intensity.clamp(0.0, 1.0),
      );
    }).toList(growable: false);
  }

  double _computeHelpRate(List<Map<String, dynamic>> feedbackRows) {
    if (feedbackRows.isEmpty) return 0.0;

    final helpedCount = feedbackRows.where((row) => row['helped'] == true).length;
    return helpedCount / feedbackRows.length;
  }

  double _computeConsistencyScore(List<DashboardHeatmapCell> cells) {
    if (cells.isEmpty) return 0.0;
    final activeDays = cells.where((cell) => cell.intensity > 0.0).length;
    return activeDays / cells.length;
  }

  int _computeReadinessScore({
    required SessionStateLevel? energy,
    required SessionStateLevel? stress,
    required SessionStateLevel? focus,
    required double helpRate,
    required double consistencyScore,
  }) {
    final energyScore = _stateLevelScore(energy);
    final focusScore = _stateLevelScore(focus);
    final stressScore = 1.0 - _stateLevelScore(stress);

    final bodyState = (energyScore + focusScore + stressScore) / 3.0;
    final score = (bodyState * 50) + (helpRate * 30) + (consistencyScore * 20);

    return score.round().clamp(0, 100);
  }

  DashboardRunStatus _parseRunStatus(String? raw) {
    switch (raw) {
      case 'completed':
        return DashboardRunStatus.completed;
      case 'abandoned':
        return DashboardRunStatus.abandoned;
      default:
        return DashboardRunStatus.started;
    }
  }

  SessionStateLevel? _parseStateLevel(String? raw) {
    switch (raw) {
      case 'low':
        return SessionStateLevel.low;
      case 'medium':
        return SessionStateLevel.medium;
      case 'high':
        return SessionStateLevel.high;
      default:
        return null;
    }
  }

  Map<String, dynamic>? _pickLatestSnapshot(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;

    final afterRows =
        rows.where((row) => (row['snapshot_kind'] as String?) == 'after').toList();

    if (afterRows.isNotEmpty) return afterRows.last;
    return rows.last;
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

  double _stateLevelScore(SessionStateLevel? level) {
    switch (level) {
      case SessionStateLevel.low:
        return 0.2;
      case SessionStateLevel.medium:
        return 0.6;
      case SessionStateLevel.high:
        return 1.0;
      case null:
        return 0.5;
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

  String _accessTierRaw(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == 'core_access' || raw == 'premium_later' || raw == 'free') {
      return raw!;
    }
    return 'free';
  }
  String _humanizeSessionId(String raw) {
    return raw
        .replaceAll('sess_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty && int.tryParse(part) == null)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}