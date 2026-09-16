// lib/features/insights/application/insights_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_data/app_data_reset_signal.dart';
import '../../../core/localization/app_locale_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/application/auth_providers.dart';
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

final insightsRefreshSignalProvider =
    NotifierProvider<InsightsRefreshSignalController, int>(
  InsightsRefreshSignalController.new,
);

class InsightsRefreshSignalController extends Notifier<int> {
  @override
  int build() => 0;

  void markDirty() {
    state = state + 1;
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final languageCode = ref.watch(appLocaleControllerProvider).languageCode;
  return InsightsRepositoryImpl(client, languageCode: languageCode);
});

final insightsSnapshotProvider =
    FutureProvider.family<InsightsSnapshot, InsightsRange>((ref, range) async {
  // These dependencies make every cached range user-safe and self-refreshing.
  // A user switch, profile data reset, or completed/abandoned run produces a
  // new provider generation instead of leaving a stale snapshot on screen.
  ref.watch(currentUserProvider.select((user) => user?.id));
  ref.watch(appDataResetSignalProvider);
  ref.watch(insightsRefreshSignalProvider);

  final repository = ref.watch(insightsRepositoryProvider);
  return repository.getInsightsSnapshot(range: range);
});

final currentInsightsSnapshotProvider =
    FutureProvider<InsightsSnapshot>((ref) async {
  final range = ref.watch(insightsSelectedRangeProvider);
  return ref.watch(insightsSnapshotProvider(range).future);
});