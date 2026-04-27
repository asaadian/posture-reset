// lib/features/player/domain/session_feedback_repository.dart

import 'session_feedback_models.dart';

abstract class SessionFeedbackRepository {
  Future<void> saveBeforeStateSnapshot({
    required String runId,
    required String sessionId,
    required SessionStateSnapshotInput input,
  });

  Future<void> saveAfterStateSnapshot({
    required String runId,
    required String sessionId,
    required SessionStateSnapshotInput input,
  });

  Future<void> saveFeedback({
    required String runId,
    required String sessionId,
    required SessionFeedbackInput input,
  });
}