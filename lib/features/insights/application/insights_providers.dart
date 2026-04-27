// lib/features/insights/application/insights_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/insights_repository_impl.dart';
import '../domain/insights_repository.dart';
import '../domain/insights_snapshot.dart';

final insightsSelectedRangeProvider =
    NotifierProvider<InsightsSelectedRangeController, InsightsRange>(
  InsightsSelectedRangeController.new,
);

class InsightsSelectedRangeController extends Notifier<InsightsRange> {
  @override
  InsightsRange build() {
    return InsightsRange.last14Days;
  }

  void setRange(InsightsRange range) {
    if (state == range) return;
    state = range;
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InsightsRepositoryImpl(client);
});

final insightsSnapshotProvider =
    FutureProvider.family<InsightsSnapshot, InsightsRange>((ref, range) async {
  final repository = ref.watch(insightsRepositoryProvider);
  return repository.getInsightsSnapshot(range: range);
});

final currentInsightsSnapshotProvider =
    FutureProvider<InsightsSnapshot>((ref) async {
  final range = ref.watch(insightsSelectedRangeProvider);
  return ref.watch(insightsSnapshotProvider(range).future);
});