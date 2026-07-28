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
            'id, title_key, title_fallback, duration_minutes, pain_targets, session_level_tag, access_tier, session_quality',
          ),
    );

    final stepTargetRows = await _safeSelectList(
      'session_steps_targets',
      () => _client.from('session_steps').select(
            'session_id, body_target_codes',
          ),
    );

    final sessionBodyZones = _buildSessionBodyZoneIndex(
      templatesRows: templatesRows,
      stepTargetRows: stepTargetRows,
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
      runsRows: runsInRange,
      snapshotRows: snapshotsInRange,
      feedbackByRun: feedbackByRun,
      sessionBodyZones: sessionBodyZones,
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
    final activeDaysCount = activeDays.length;

    final abandonedRuns = runsInRange.where(
      (row) => (row['status'] as String?) == 'abandoned',
    ).length;

    final skippedStepEvents = stepEventsInRange.where(
      (row) => (row['event_type'] as String?) == 'step_skipped',
    ).length;

    final pausedEvents = stepEventsInRange.where(
      (row) => (row['event_type'] as String?) == 'player_paused',
    ).length;

    final bestDay = _bestRecoveryDay(recoveryMinutesSeries);
    final undertrainedBodyZoneCodes = _undertrainedBodyZones(bodyZones);
    final sessionEffectiveness = _buildSessionEffectiveness(
      templateById: templateById,
      runsInRange: runsInRange,
      feedbackInRange: feedbackInRange,
    );
    final recoveryScore = _computeRecoveryScore(
      consistencyScore: consistencyScore,
      completionRate: totalRuns <= 0 ? 0.0 : completedSessions / totalRuns,
      helpRate: helpRate,
      averageReliefScore: averageReliefScore,
      currentStreakDays: currentStreakDays,
      abandonedRuns: abandonedRuns,
      totalRuns: totalRuns,
    );
    final nextBestAction = _buildNextBestAction(
      bodyZones: bodyZones,
      undertrainedBodyZoneCodes: undertrainedBodyZoneCodes,
      sessionEffectiveness: sessionEffectiveness,
      abandonedRuns: abandonedRuns,
      completedSessions: completedSessions,
      quickFixStarts: quickFixStarts,
      skippedStepEvents: skippedStepEvents,
    );

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
      recoveryScore: recoveryScore,
      recoveryScoreTitle: _scoreTitle(recoveryScore),
      recoveryScoreBody: _scoreBody(
        score: recoveryScore,
        dominantPainAreaCode: dominantPainAreaCode,
        abandonedRuns: abandonedRuns,
        pausedEvents: pausedEvents,
      ),
      activeDaysCount: activeDaysCount,
      abandonedRuns: abandonedRuns,
      skippedStepEvents: skippedStepEvents,
      pausedEvents: pausedEvents,
      bestDayLabel: bestDay?.label,
      bestDayMinutes: bestDay?.value.round() ?? 0,
      undertrainedBodyZoneCodes: undertrainedBodyZoneCodes,
      sessionEffectiveness: sessionEffectiveness,
      nextBestAction: nextBestAction,
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

  Map<String, List<String>> _buildSessionBodyZoneIndex({
    required List<Map<String, dynamic>> templatesRows,
    required List<Map<String, dynamic>> stepTargetRows,
  }) {
    final zonesBySession = <String, Set<String>>{};

    for (final row in templatesRows) {
      final sessionId = row['id'] as String?;
      if (sessionId == null || sessionId.trim().isEmpty) continue;

      final targets = _normalizeBodyAreaCodes(
        _asStringList(row['pain_targets']),
      );

      if (targets.isNotEmpty) {
        zonesBySession.putIfAbsent(sessionId, () => <String>{}).addAll(targets);
      }
    }

    for (final row in stepTargetRows) {
      final sessionId = row['session_id'] as String?;
      if (sessionId == null || sessionId.trim().isEmpty) continue;

      final targets = _normalizeBodyAreaCodes(
        _asStringList(row['body_target_codes']),
      );

      if (targets.isNotEmpty) {
        zonesBySession.putIfAbsent(sessionId, () => <String>{}).addAll(targets);
      }
    }

    return zonesBySession.map(
      (sessionId, targets) {
        final sorted = targets.toList(growable: false)..sort();
        return MapEntry(sessionId, sorted);
      },
    );
  }

  List<InsightsBodyZoneStat> _buildBodyZoneStats({
    required List<Map<String, dynamic>> runsRows,
    required List<Map<String, dynamic>> snapshotRows,
    required Map<String, Map<String, dynamic>> feedbackByRun,
    required Map<String, List<String>> sessionBodyZones,
  }) {
    final snapshotZonesByRun = _buildSnapshotBodyZoneIndex(snapshotRows);
    final counts = <String, int>{};
    final reliefBuckets = <String, List<double>>{};
    var totalHits = 0;

    for (final row in runsRows) {
      final runId = row['id'] as String?;
      final sessionId = row['session_id'] as String?;

      final zones = runId == null
          ? sessionBodyZones[sessionId] ?? const <String>[]
          : snapshotZonesByRun[runId] ??
              sessionBodyZones[sessionId] ??
              const <String>[];

      if (zones.isEmpty) continue;

      final feedback = runId == null ? null : feedbackByRun[runId];
      final reliefScore = feedback == null ? null : _feedbackScore(feedback);

      for (final code in zones) {
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

  Map<String, List<String>> _buildSnapshotBodyZoneIndex(
    List<Map<String, dynamic>> snapshotRows,
  ) {
    final afterByRun = <String, Set<String>>{};
    final beforeByRun = <String, Set<String>>{};

    for (final row in snapshotRows) {
      final runId = row['run_id'] as String?;
      if (runId == null || runId.trim().isEmpty) continue;

      final targets = _normalizeBodyAreaCodes(
        _asStringList(row['pain_area_codes']),
      );
      if (targets.isEmpty) continue;

      final kind = row['snapshot_kind'] as String?;
      final bucket = kind == 'after' ? afterByRun : beforeByRun;
      bucket.putIfAbsent(runId, () => <String>{}).addAll(targets);
    }

    final merged = <String, List<String>>{};
    for (final entry in beforeByRun.entries) {
      merged[entry.key] = entry.value.toList(growable: false)..sort();
    }
    for (final entry in afterByRun.entries) {
      merged[entry.key] = entry.value.toList(growable: false)..sort();
    }

    return merged;
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    if (value is String && value.trim().isNotEmpty) {
      return <String>[value.trim()];
    }

    return const <String>[];
  }

  List<String> _normalizeBodyAreaCodes(List<String> rawCodes) {
    final normalized = <String>{};

    for (final raw in rawCodes) {
      final code = raw.trim().toLowerCase();
      if (code.isEmpty) continue;

      switch (code) {
        case 'neck':
        case 'cervical':
          normalized.add('neck');
          break;
        case 'shoulder':
        case 'shoulders':
        case 'scapula':
        case 'scapular':
          normalized.add('shoulders');
          break;
        case 'upper_back':
        case 'upper back':
        case 'mid_back':
        case 'mid back':
        case 'thoracic':
        case 'chest':
          normalized.add('upper_back');
          break;
        case 'lower_back':
        case 'low_back':
        case 'lower back':
        case 'lumbar':
        case 'back':
        case 'core':
          normalized.add('lower_back');
          break;
        case 'hip':
        case 'hips':
        case 'glute':
        case 'glutes':
        case 'hips_glutes':
        case 'hamstring':
        case 'hamstrings':
          normalized.add('hips_glutes');
          break;
        case 'forearm':
        case 'forearms':
        case 'mouse_arm':
        case 'mouse arm':
          normalized.add('forearms');
          break;
        case 'wrist':
        case 'wrists':
          normalized.add('wrists');
          break;
        case 'hand':
        case 'hands':
        case 'finger':
        case 'fingers':
          normalized.add('hands');
          break;
        case 'eye':
        case 'eyes':
        case 'screen':
        case 'screen_strain':
        case 'eye_strain':
          normalized.add('eyes');
          break;
      }
    }

    return normalized.toList(growable: false);
  }


  int _computeRecoveryScore({
    required double consistencyScore,
    required double completionRate,
    required double helpRate,
    required double averageReliefScore,
    required int currentStreakDays,
    required int abandonedRuns,
    required int totalRuns,
  }) {
    if (totalRuns <= 0) return 0;

    final reliefNormalized = (averageReliefScore / 100).clamp(0.0, 1.0);
    var score = 0.0;
    score += consistencyScore.clamp(0.0, 1.0) * 28;
    score += completionRate.clamp(0.0, 1.0) * 24;
    score += helpRate.clamp(0.0, 1.0) * 22;
    score += reliefNormalized * 18;
    score += (currentStreakDays.clamp(0, 7) / 7) * 8;

    if (abandonedRuns > 0) {
      score -= (abandonedRuns * 4).clamp(0, 16);
    }

    return score.round().clamp(0, 100);
  }

  String _scoreTitle(int score) {
    if (score >= 82) return 'Strong recovery rhythm';
    if (score >= 64) return 'Recovery rhythm is building';
    if (score >= 42) return 'Recovery signal needs consistency';
    if (score > 0) return 'Early recovery signal';
    return 'No recovery score yet';
  }

  String _scoreBody({
    required int score,
    required String? dominantPainAreaCode,
    required int abandonedRuns,
    required int pausedEvents,
  }) {
    if (score <= 0) {
      return 'Complete a few sessions to unlock a useful personal recovery score.';
    }

    final zone = dominantPainAreaCode == null
        ? 'your main working zone'
        : _painAreaLabel(dominantPainAreaCode).toLowerCase();

    if (abandonedRuns >= 2) {
      return 'Your recent rhythm is being limited by unfinished runs. Try shorter sessions and keep the next run simple.';
    }

    if (pausedEvents >= 4) {
      return 'You are getting recovery work done, but pause frequency suggests interruptions. A shorter quiet block may fit better.';
    }

    if (score >= 82) {
      return 'Your consistency, completion, and feedback are aligned. Keep rotating support around $zone.';
    }

    if (score >= 64) {
      return 'Your recovery pattern is moving in the right direction. Add one focused session for $zone to keep the signal improving.';
    }

    return 'You have enough activity to see patterns, but consistency and completion still need work.';
  }

  InsightsSeriesPoint? _bestRecoveryDay(List<InsightsSeriesPoint> series) {
    InsightsSeriesPoint? best;
    for (final point in series) {
      if (point.value <= 0) continue;
      if (best == null || point.value > best.value) best = point;
    }
    return best;
  }

  List<String> _undertrainedBodyZones(List<InsightsBodyZoneStat> bodyZones) {
    const coreZones = <String>[
      'neck',
      'shoulders',
      'upper_back',
      'lower_back',
      'hips_glutes',
      'forearms',
      'wrists',
      'hands',
      'eyes',
    ];

    if (bodyZones.isEmpty) return const <String>[];

    final trained = bodyZones.map((item) => item.painAreaCode).toSet();
    return coreZones
        .where((code) => !trained.contains(code))
        .take(3)
        .toList(growable: false);
  }

  List<InsightsSessionEffectiveness> _buildSessionEffectiveness({
    required Map<String, Map<String, dynamic>> templateById,
    required List<Map<String, dynamic>> runsInRange,
    required List<Map<String, dynamic>> feedbackInRange,
  }) {
    final completedBySession = <String, int>{};
    for (final row in runsInRange) {
      if ((row['status'] as String?) != 'completed') continue;
      final sessionId = row['session_id'] as String?;
      if (sessionId == null || sessionId.trim().isEmpty) continue;
      completedBySession.update(sessionId, (value) => value + 1, ifAbsent: () => 1);
    }

    final feedbackBySession = <String, List<Map<String, dynamic>>>{};
    for (final row in feedbackInRange) {
      final sessionId = row['session_id'] as String?;
      if (sessionId == null || sessionId.trim().isEmpty) continue;
      feedbackBySession.putIfAbsent(sessionId, () => <Map<String, dynamic>>[]).add(row);
    }

    final items = <InsightsSessionEffectiveness>[];
    for (final entry in completedBySession.entries) {
      final feedback = feedbackBySession[entry.key] ?? const <Map<String, dynamic>>[];
      final helped = feedback.where((row) => row['helped'] == true).length;
      final helpRate = feedback.isEmpty ? 0.0 : helped / feedback.length;
      final relief = feedback.isEmpty
          ? 0.0
          : feedback.map(_feedbackScore).reduce((a, b) => a + b) / feedback.length;
      final template = templateById[entry.key];
      final title = template?['title_fallback']?.toString().trim();

      items.add(
        InsightsSessionEffectiveness(
          sessionId: entry.key,
          title: title == null || title.isEmpty ? entry.key : title,
          completedRuns: entry.value,
          helpRate: helpRate,
          averageReliefScore: relief,
        ),
      );
    }

    items.sort((a, b) {
      final aScore = (a.helpRate * 100) + a.averageReliefScore + (a.completedRuns * 4);
      final bScore = (b.helpRate * 100) + b.averageReliefScore + (b.completedRuns * 4);
      return bScore.compareTo(aScore);
    });

    return items.take(4).toList(growable: false);
  }

  InsightsNextBestAction _buildNextBestAction({
    required List<InsightsBodyZoneStat> bodyZones,
    required List<String> undertrainedBodyZoneCodes,
    required List<InsightsSessionEffectiveness> sessionEffectiveness,
    required int abandonedRuns,
    required int completedSessions,
    required int quickFixStarts,
    required int skippedStepEvents,
  }) {
    if (completedSessions <= 0) {
      return const InsightsNextBestAction(
        title: 'Start with one short reset',
        body: 'Complete one guided session today so your insights can move from preview to personal signal.',
        reason: 'No completed sessions in this range.',
      );
    }

    if (abandonedRuns >= 2) {
      return const InsightsNextBestAction(
        title: 'Choose a shorter session next',
        body: 'Pick a 6–7 minute recovery block before starting another longer flow.',
        reason: 'Recent abandoned runs suggest session length or timing friction.',
      );
    }

    if (skippedStepEvents >= 3) {
      return const InsightsNextBestAction(
        title: 'Use a gentler flow next',
        body: 'Choose a lower-intensity session and avoid skipping unless a movement feels wrong.',
        reason: 'Step skipping is elevated in this range.',
      );
    }

    if (undertrainedBodyZoneCodes.isNotEmpty) {
      final zone = _painAreaLabel(undertrainedBodyZoneCodes.first);
      return InsightsNextBestAction(
        title: 'Balance your next recovery block',
        body: 'Add a session that supports $zone so your recovery work is not concentrated in one area.',
        reason: '$zone has little or no recent coverage.',
      );
    }

    if (sessionEffectiveness.isNotEmpty) {
      final best = sessionEffectiveness.first;
      return InsightsNextBestAction(
        title: 'Repeat what works',
        body: 'Repeat ${best.title} or choose a related session with the same body focus.',
        reason: '${(best.helpRate * 100).round()}% helpful feedback from recent runs.',
        sessionId: best.sessionId,
      );
    }

    if (quickFixStarts > completedSessions) {
      return const InsightsNextBestAction(
        title: 'Convert one Quick Fix into a full session',
        body: 'Keep Quick Fix for emergencies, but complete one full guided recovery session today.',
        reason: 'Quick Fix usage is higher than completed sessions.',
      );
    }

    return const InsightsNextBestAction(
      title: 'Keep the current rhythm',
      body: 'Your recent activity is balanced enough. Keep one short recovery session in the next 24 hours.',
      reason: 'No major friction signal detected.',
    );
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
              '${(topZone.share * 100).round()}% of recent recovery work was concentrated in this zone. Action: rotate one supporting session for a secondary zone.',
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
    switch (raw.trim().toLowerCase()) {
      case 'neck':
      case 'cervical':
        return 'Neck';
      case 'shoulder':
      case 'shoulders':
      case 'scapula':
      case 'scapular':
        return 'Shoulders';
      case 'upper_back':
      case 'upper back':
      case 'mid_back':
      case 'mid back':
      case 'thoracic':
      case 'chest':
        return 'Upper back';
      case 'lower_back':
      case 'low_back':
      case 'lower back':
      case 'lumbar':
      case 'back':
      case 'core':
        return 'Lower back';
      case 'wrist':
      case 'wrists':
        return 'Wrists';
      case 'forearm':
      case 'forearms':
      case 'mouse_arm':
      case 'mouse arm':
        return 'Forearms';
      case 'hand':
      case 'hands':
      case 'finger':
      case 'fingers':
        return 'Hands';
      case 'hips':
      case 'glutes':
      case 'hip':
      case 'glute':
      case 'hips_glutes':
      case 'hamstrings':
      case 'hamstring':
        return 'Hips & glutes';
      case 'eye':
      case 'eyes':
      case 'screen':
      case 'screen_strain':
      case 'eye_strain':
        return 'Eyes';
      default:
        return raw.replaceAll('_', ' ');
    }
  }
}