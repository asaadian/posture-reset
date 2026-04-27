// lib/features/player/domain/session_runs_repository.dart

import 'session_feedback_models.dart';
import 'session_run_models.dart';

abstract class SessionRunsRepository {
  Future<String> startRun({
    required String sessionId,
    required int totalSteps,
    required String? firstStepId,
    required SessionEntrySource entrySource,
  });

  Future<void> completeRun({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
  });

  Future<void> abandonRun({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
    required String exitReason,
  });

  Future<SessionRun?> getRunById(String runId);

  Future<void> updateRunProgress({
    required String runId,
    required int completedSteps,
    required int totalElapsedSeconds,
    required String? lastStepId,
  });
  Future<List<SessionRun>> getRecentRuns({
    int limit = 12,
  });

  Future<SessionRun?> getLatestActiveRun();

  Future<List<SessionRun>> getRunsBySessionId(
    String sessionId, {
    int limit = 20,
  });
}