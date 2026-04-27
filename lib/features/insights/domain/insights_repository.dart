// lib/features/insights/domain/insights_repository.dart

import 'insights_snapshot.dart';

abstract class InsightsRepository {
  Future<InsightsSnapshot> getInsightsSnapshot({
    required InsightsRange range,
  });
}