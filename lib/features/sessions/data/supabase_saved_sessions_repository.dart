// lib/features/sessions/data/supabase_saved_sessions_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/saved_sessions_repository.dart';

class SupabaseSavedSessionsRepository implements SavedSessionsRepository {
  SupabaseSavedSessionsRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'saved_sessions';

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const _UnauthenticatedSaveException();
    }
    return user;
  }

  @override
  Future<Set<String>> getSavedSessionIds() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return <String>{};
    }

    final response = await _client
        .from(_table)
        .select('session_id')
        .eq('user_id', user.id);

    return (response as List)
        .map((row) => (row as Map<String, dynamic>)['session_id'] as String)
        .toSet();
  }

  @override
  Future<List<String>> getRecentlySavedSessionIds({
    int limit = 12,
  }) async {
    final records = await getRecentlySavedSessionRecords(limit: limit);
    return records.map((e) => e.sessionId).toList(growable: false);
  }

  @override
  Future<List<SavedSessionRecord>> getRecentlySavedSessionRecords({
    int limit = 12,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const <SavedSessionRecord>[];
    }

    final response = await _client
        .from(_table)
        .select('session_id, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          return SavedSessionRecord(
            sessionId: map['session_id'] as String,
            createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<bool> isSaved(String sessionId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    final response = await _client
        .from(_table)
        .select('session_id')
        .eq('user_id', user.id)
        .eq('session_id', sessionId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<void> saveSession(String sessionId) async {
    final user = _requireUser();

    await _client.from(_table).upsert({
      'user_id': user.id,
      'session_id': sessionId,
    });
  }

  @override
  Future<void> unsaveSession(String sessionId) async {
    final user = _requireUser();

    await _client
        .from(_table)
        .delete()
        .eq('user_id', user.id)
        .eq('session_id', sessionId);
  }
}

class _UnauthenticatedSaveException implements Exception {
  const _UnauthenticatedSaveException();

  @override
  String toString() => 'UnauthenticatedSaveException';
}