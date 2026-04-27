// lib/features/player/data/supabase_session_feedback_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/session_feedback_models.dart';
import '../domain/session_feedback_repository.dart';

class SupabaseSessionFeedbackRepository implements SessionFeedbackRepository {
  SupabaseSessionFeedbackRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> saveBeforeStateSnapshot({
    required String runId,
    required String sessionId,
    required SessionStateSnapshotInput input,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to save state snapshot.');
    }

    await _client.from('session_state_snapshots').upsert(
      {
        'user_id': user.id,
        'run_id': runId,
        'session_id': sessionId,
        'snapshot_kind': 'before',
        'energy_level': input.energyLevel.name,
        'stress_level': input.stressLevel.name,
        'focus_level': input.focusLevel.name,
        'pain_area_codes': input.painAreaCodes,
        'intent_code': input.intentCode.name,
        'entry_source': input.entrySource.dbValue,
      },
      onConflict: 'run_id,snapshot_kind',
    );
  }

  @override
  Future<void> saveAfterStateSnapshot({
    required String runId,
    required String sessionId,
    required SessionStateSnapshotInput input,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to save state snapshot.');
    }

    await _client.from('session_state_snapshots').upsert(
      {
        'user_id': user.id,
        'run_id': runId,
        'session_id': sessionId,
        'snapshot_kind': 'after',
        'energy_level': input.energyLevel.name,
        'stress_level': input.stressLevel.name,
        'focus_level': input.focusLevel.name,
        'pain_area_codes': input.painAreaCodes,
        'intent_code': input.intentCode.name,
        'entry_source': input.entrySource.dbValue,
      },
      onConflict: 'run_id,snapshot_kind',
    );
  }

  @override
  Future<void> saveFeedback({
    required String runId,
    required String sessionId,
    required SessionFeedbackInput input,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Authenticated user required to save feedback.');
    }

    await _client.from('session_feedback').upsert(
      {
        'user_id': user.id,
        'run_id': runId,
        'session_id': sessionId,
        'completion_status': input.completionStatus.name,
        'helped': input.helped,
        'tension_delta': input.tensionDelta.name,
        'pain_delta': input.painDelta.name,
        'energy_delta': input.energyDelta.name,
        'perceived_fit': input.perceivedFit.name,
        'would_repeat': input.wouldRepeat,
        'entry_source': input.entrySource.dbValue,
      },
      onConflict: 'run_id',
    );
  }
}