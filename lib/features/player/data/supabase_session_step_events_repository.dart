// lib/features/player/data/supabase_session_step_events_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/session_step_event_models.dart';
import '../domain/session_step_events_repository.dart';

class SupabaseSessionStepEventsRepository
    implements SessionStepEventsRepository {
  SupabaseSessionStepEventsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> trackEvent({
    required SessionStepEventInput input,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'Authenticated user required to track session step events.',
      );
    }

    await _client.from('session_step_events').insert({
      'user_id': user.id,
      'run_id': input.runId,
      'session_id': input.sessionId,
      'step_id': input.stepId,
      'step_index': input.stepIndex,
      'event_type': input.eventType.dbValue,
      'step_elapsed_seconds': input.stepElapsedSeconds,
      'total_elapsed_seconds': input.totalElapsedSeconds,
      'metadata': input.metadata,
    });
  }
}