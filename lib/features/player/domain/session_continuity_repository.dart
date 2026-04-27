// lib/features/player/domain/session_continuity_repository.dart

import 'session_continuity_models.dart';

abstract class SessionContinuityRepository {
  Future<SessionContinuitySnapshot> getSnapshot({
    int recentRunsLimit = 12,
    int savedLimit = 12,
  });

  Future<List<SessionHistoryItem>> getHistory({
    int limit = 24,
  });

  Future<List<SavedSessionContinuityItem>> getSavedSessions({
    int limit = 24,
  });

  Future<ContinueSessionCandidate?> getContinueCandidate();
}