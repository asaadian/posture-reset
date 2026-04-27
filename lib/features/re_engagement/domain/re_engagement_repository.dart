// lib/features/re_engagement/domain/re_engagement_repository.dart

import 're_engagement_models.dart';

abstract class ReEngagementRepository {
  Future<ReEngagementSnapshot> getSnapshot();
  Future<void> markShown(ReEngagementCandidate candidate);
  Future<void> markActed(ReEngagementCandidate candidate);
  Future<void> markDismissed(ReEngagementCandidate candidate);
}