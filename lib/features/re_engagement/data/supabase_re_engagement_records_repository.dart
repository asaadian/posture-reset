// lib/features/re_engagement/data/supabase_re_engagement_records_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/re_engagement_models.dart';
import '../domain/re_engagement_records_repository.dart';

class SupabaseReEngagementRecordsRepository
    implements ReEngagementRecordsRepository {
  SupabaseReEngagementRecordsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReEngagementRecord>> getRecentRecords({
    int limit = 40,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return const <ReEngagementRecord>[];

    final response = await _client
        .from('re_engagement_records')
        .select()
        .eq('user_id', user.id)
        .order('updated_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map(
          (row) => ReEngagementRecord.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertRecord({
    required ReEngagementType type,
    required String candidateKey,
    required ReEngagementStatus status,
    String? sessionId,
    String? painAreaCode,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('re_engagement_records').upsert(
      {
        'user_id': user.id,
        'candidate_type': _typeDbValue(type),
        'candidate_key': candidateKey,
        'status': status.dbValue,
        'session_id': sessionId,
        'pain_area_code': painAreaCode,
        'metadata': metadata,
      },
      onConflict: 'user_id,candidate_key',
    );
  }

  String _typeDbValue(ReEngagementType type) {
    switch (type) {
      case ReEngagementType.continueSession:
        return 'continue_session';
      case ReEngagementType.returnToSaved:
        return 'return_to_saved';
      case ReEngagementType.quickRelief:
        return 'quick_relief';
      case ReEngagementType.consistencyRecovery:
        return 'consistency_recovery';
    }
  }
}