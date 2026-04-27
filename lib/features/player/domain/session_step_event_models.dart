// lib/features/player/domain/session_step_event_models.dart

class SessionStepEventInput {
  const SessionStepEventInput({
    required this.runId,
    required this.sessionId,
    required this.stepId,
    required this.stepIndex,
    required this.eventType,
    required this.stepElapsedSeconds,
    required this.totalElapsedSeconds,
    this.metadata = const <String, Object?>{},
  });

  final String runId;
  final String sessionId;
  final String stepId;
  final int stepIndex;
  final SessionStepEventType eventType;
  final int stepElapsedSeconds;
  final int totalElapsedSeconds;
  final Map<String, Object?> metadata;
}

enum SessionStepEventType {
  stepStarted,
  stepCompleted,
  stepSkipped,
  stepReplayed,
  stepPrevious,
  stepNext,
  playerPaused,
  playerResumed,
  sessionCompleted,
  sessionAbandoned;

  String get dbValue {
    switch (this) {
      case SessionStepEventType.stepStarted:
        return 'step_started';
      case SessionStepEventType.stepCompleted:
        return 'step_completed';
      case SessionStepEventType.stepSkipped:
        return 'step_skipped';
      case SessionStepEventType.stepReplayed:
        return 'step_replayed';
      case SessionStepEventType.stepPrevious:
        return 'step_previous';
      case SessionStepEventType.stepNext:
        return 'step_next';
      case SessionStepEventType.playerPaused:
        return 'player_paused';
      case SessionStepEventType.playerResumed:
        return 'player_resumed';
      case SessionStepEventType.sessionCompleted:
        return 'session_completed';
      case SessionStepEventType.sessionAbandoned:
        return 'session_abandoned';
    }
  }
}