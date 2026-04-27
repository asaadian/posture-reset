// lib/features/re_engagement/domain/re_engagement_records_repository.dart

import 're_engagement_models.dart';

abstract class ReEngagementRecordsRepository {
  Future<List<ReEngagementRecord>> getRecentRecords({
    int limit = 40,
  });

  Future<void> upsertRecord({
    required ReEngagementType type,
    required String candidateKey,
    required ReEngagementStatus status,
    String? sessionId,
    String? painAreaCode,
    Map<String, Object?> metadata,
  });
}