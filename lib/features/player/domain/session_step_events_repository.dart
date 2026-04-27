// lib/features/player/domain/session_step_events_repository.dart

import 'session_step_event_models.dart';

abstract class SessionStepEventsRepository {
  Future<void> trackEvent({
    required SessionStepEventInput input,
  });
}