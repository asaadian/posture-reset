// lib/features/body_map/data/body_map_repository_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/body_map_models.dart';
import '../domain/body_map_repository.dart';

class BodyMapRepositoryImpl implements BodyMapRepository {
  BodyMapRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _trackedZones = <String, BodyMapSide>{
    'neck': BodyMapSide.front,
    'shoulders': BodyMapSide.front,
    'wrists': BodyMapSide.front,
    'upper_back': BodyMapSide.back,
    'lower_back': BodyMapSide.back,
  };

  static const _recommendationMatrix = <String, List<String>>{
    'neck': [
      'sess_neck_reset_02',
      'sess_shoulder_release_04',
      'sess_silent_desk_reset_03',
    ],
    'shoulders': [
      'sess_shoulder_release_04',
      'sess_upper_back_mobility_06',
      'sess_full_posture_recovery_10',
    ],
    'wrists': [
      'sess_wrist_relief_02',
      'sess_typing_recovery_04',
      'sess_silent_desk_reset_03',
    ],
    'upper_back': [
      'sess_upper_back_mobility_06',
      'sess_seated_posture_reset_06',
      'sess_full_posture_recovery_10',
    ],
    'lower_back': [
      'sess_lower_back_unload_04',
      'sess_seated_posture_reset_06',
      'sess_full_posture_recovery_10',
    ],
  };

  @override
  Future<BodyMapSnapshot> getBodyMapSnapshot() async {
    final now = DateTime.now().toUtc();
    final recentStart =
        DateTime.utc(now.year, now.month, now.day).subtract(const Duration(days: 13));
    final previousStart = recentStart.subtract(const Duration(days: 14));

    final snapshotRows = await _safeSelectList(
      () => _client
          .from('session_state_snapshots')
          .select('run_id, snapshot_kind, pain_area_codes, created_at')
          .gte('created_at', previousStart.toIso8601String())
          .order('created_at', ascending: true),
    );

    final feedbackRows = await _safeSelectList(
      () => _client
          .from('session_feedback')
          .select('run_id, helped, tension_delta, pain_delta, energy_delta, perceived_fit')
          .gte('created_at', previousStart.toIso8601String()),
    );

    final allSessionIds = _recommendationMatrix.values.expand((e) => e).toSet().toList();
    final templateRows = await _safeSelectList(
      () => _client
          .from('session_templates')
          .select('id, title_key, title_fallback, duration_minutes')
          .inFilter('id', allSessionIds),
    );

    final feedbackByRun = <String, Map<String, dynamic>>{};
    for (final row in feedbackRows) {
      final runId = row['run_id'] as String?;
      if (runId != null && runId.isNotEmpty) {
        feedbackByRun[runId] = row;
      }
    }

    final recentCounts = <String, int>{};
    final previousCounts = <String, int>{};
    final reliefBuckets = <String, List<double>>{};

    for (final row in snapshotRows) {
      if ((row['snapshot_kind'] as String?) != 'after') continue;

      final createdAt = _parseDate(row['created_at']);
      if (createdAt == null) continue;

      final runId = row['run_id'] as String?;
      final painAreas = ((row['pain_area_codes'] as List?) ?? const [])
          .map((e) => e.toString())
          .where(_trackedZones.containsKey)
          .toSet()
          .toList(growable: false);

      final isRecent = !createdAt.isBefore(recentStart);
      final isPrevious = createdAt.isBefore(recentStart);

      final feedback = runId == null ? null : feedbackByRun[runId];
      final relief = feedback == null ? null : _feedbackScore(feedback);

      for (final code in painAreas) {
        if (isRecent) {
          recentCounts.update(code, (value) => value + 1, ifAbsent: () => 1);
        } else if (isPrevious) {
          previousCounts.update(code, (value) => value + 1, ifAbsent: () => 1);
        }

        if (isRecent && relief != null) {
          reliefBuckets.putIfAbsent(code, () => <double>[]).add(relief);
        }
      }
    }

    final zones = _trackedZones.entries.map((entry) {
      final code = entry.key;
      final recentHits = recentCounts[code] ?? 0;
      final previousHits = previousCounts[code] ?? 0;
      final reliefValues = reliefBuckets[code] ?? const <double>[];
      final reliefScore = reliefValues.isEmpty
          ? 0.0
          : reliefValues.reduce((a, b) => a + b) / reliefValues.length;

      return BodyMapZoneSnapshot(
        code: code,
        side: entry.value,
        recentHits: recentHits,
        previousHits: previousHits,
        reliefScore: reliefScore,
        severity: _severityForHits(recentHits),
        trend: _trendForCounts(recentHits: recentHits, previousHits: previousHits),
      );
    }).toList(growable: false);

    final templateById = <String, Map<String, dynamic>>{
      for (final row in templateRows) (row['id'] as String): row,
    };

    final recommendationsByZone = <String, List<BodyMapRecommendationItem>>{};
    for (final entry in _recommendationMatrix.entries) {
      recommendationsByZone[entry.key] = entry.value.map((sessionId) {
        final template = templateById[sessionId];
        return BodyMapRecommendationItem(
          sessionId: sessionId,
          titleKey: template?['title_key'] as String? ?? '',
          titleFallback: template?['title_fallback'] as String? ?? _humanizeSessionId(sessionId),
          durationMinutes: _asInt(template?['duration_minutes']),
          reason: _reasonForZone(entry.key),
        );
      }).toList(growable: false);
    }

    return BodyMapSnapshot(
      zones: zones,
      recommendationsByZone: recommendationsByZone,
    );
  }

  Future<List<Map<String, dynamic>>> _safeSelectList(
    Future<dynamic> Function() query,
  ) async {
    try {
      final result = await query();
      return (result as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  BodyZoneSeverity _severityForHits(int hits) {
    if (hits >= 4) return BodyZoneSeverity.high;
    if (hits >= 2) return BodyZoneSeverity.medium;
    return BodyZoneSeverity.low;
  }

  BodyZoneTrend _trendForCounts({
    required int recentHits,
    required int previousHits,
  }) {
    if (recentHits >= previousHits + 2) return BodyZoneTrend.rising;
    if (previousHits >= recentHits + 2) return BodyZoneTrend.improving;
    return BodyZoneTrend.stable;
  }

  double _feedbackScore(Map<String, dynamic> row) {
    double score = 0.0;

    if (row['helped'] == true) score += 0.30;
    score += _deltaScore(row['tension_delta'] as String?) * 0.20;
    score += _deltaScore(row['pain_delta'] as String?) * 0.20;
    score += _deltaScore(row['energy_delta'] as String?) * 0.15;
    score += _fitScore(row['perceived_fit'] as String?) * 0.15;

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

  String _reasonForZone(String zoneCode) {
    switch (zoneCode) {
      case 'neck':
        return 'Desk strain';
      case 'shoulders':
        return 'Upper tension';
      case 'wrists':
        return 'Typing load';
      case 'upper_back':
        return 'Posture reset';
      case 'lower_back':
        return 'Sitting pressure';
      default:
        return 'Recovery fit';
    }
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