// lib/features/sessions/domain/sessions_repository.dart
import 'session_models.dart';

abstract class SessionsRepository {
  Future<List<SessionSummary>> getSessionSummaries();

  Future<SessionDetail?> getSessionDetailById(String sessionId);

  Future<List<SessionSummary>> getSessionsByIds(List<String> sessionIds);
}