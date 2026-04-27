// lib/features/player/data/supabase_session_runs_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/session_feedback_models.dart';
import '../domain/session_run_models.dart';
import '../domain/session_runs_repository.dart';

class SupabaseSessionRunsRepository implements SessionRunsRepository {
  SupabaseSessionRunsRepository(this._client);

  final SupabaseClient _client;

  static const _baseSelect = '''
id,
user_id,
session_id,
status,
started_at,
completed_at,
abandoned_at,
total_steps,
completed_steps,
total_elapsed_seconds,
last_step_id,
exit_reason,
created_at,
updated_at,
entry_source
''';

  @override
  Future<String> startRun({
    required String sessionId,
    required int totalSteps,
    required String? firstStepId,
    required SessionEntrySource entrySource,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to start a session run.');
    }

    final inserted = await _client
        .from('session_runs')
        .insert({
          'user_id': user.id,
          'session_id': sessionId,
          'status': 'started',
          'total_steps': totalSteps,
          'completed_steps': 0,
          'total_elapsed_seconds': 0,
          'last_step_id': firstStepId,
          'entry_source': entrySource.dbValue,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  @override
  Future<void> completeRun({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to complete a session run.');
    }

    await _client
        .from('session_runs')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
          'completed_steps': completedSteps,
          'total_elapsed_seconds': totalElapsedSeconds,
          'last_step_id': lastStepId,
        })
        .eq('id', runId)
        .eq('user_id', user.id);
  }

  @override
  Future<SessionRun?> getRunById(String runId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('session_runs')
        .select(_baseSelect)
        .eq('id', runId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return SessionRun.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> updateRunProgress({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to update session run.');
    }

    await _client
        .from('session_runs')
        .update({
          'completed_steps': completedSteps,
          'total_elapsed_seconds': totalElapsedSeconds,
          'last_step_id': lastStepId,
        })
        .eq('id', runId)
        .eq('user_id', user.id);
  }
  @override
  Future<void> abandonRun({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
    required String exitReason,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to abandon a session run.');
    }

    await _client
        .from('session_runs')
        .update({
          'status': 'abandoned',
          'abandoned_at': DateTime.now().toUtc().toIso8601String(),
          'completed_steps': completedSteps,
          'total_elapsed_seconds': totalElapsedSeconds,
          'last_step_id': lastStepId,
          'exit_reason': exitReason,
        })
        .eq('id', runId)
        .eq('user_id', user.id);
  }

  @override
  Future<List<SessionRun>> getRecentRuns({
    int limit = 12,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return const <SessionRun>[];

    final response = await _client
        .from('session_runs')
        .select(_baseSelect)
        .eq('user_id', user.id)
        .order('started_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((row) => SessionRun.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  @override
  Future<SessionRun?> getLatestActiveRun() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('session_runs')
        .select(_baseSelect)
        .eq('user_id', user.id)
        .eq('status', 'started')
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SessionRun.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<List<SessionRun>> getRunsBySessionId(
    String sessionId, {
    int limit = 20,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return const <SessionRun>[];

    final response = await _client
        .from('session_runs')
        .select(_baseSelect)
        .eq('user_id', user.id)
        .eq('session_id', sessionId)
        .order('started_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((row) => SessionRun.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }
}