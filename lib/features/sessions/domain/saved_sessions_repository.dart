// lib/features/sessions/domain/saved_sessions_repository.dart

class SavedSessionRecord {
  const SavedSessionRecord({
    required this.sessionId,
    required this.createdAt,
  });

  final String sessionId;
  final DateTime createdAt;
}

abstract class SavedSessionsRepository {
  Future<Set<String>> getSavedSessionIds();

  Future<List<String>> getRecentlySavedSessionIds({
    int limit = 12,
  });

  Future<List<SavedSessionRecord>> getRecentlySavedSessionRecords({
    int limit = 12,
  });

  Future<bool> isSaved(String sessionId);
  Future<void> saveSession(String sessionId);
  Future<void> unsaveSession(String sessionId);
}