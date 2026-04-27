// lib/features/re_engagement/application/re_engagement_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../player/application/session_continuity_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../data/re_engagement_repository_impl.dart';
import '../data/supabase_re_engagement_records_repository.dart';
import '../domain/re_engagement_models.dart';
import '../domain/re_engagement_records_repository.dart';
import '../domain/re_engagement_repository.dart';

final reEngagementRecordsRepositoryProvider =
    Provider<ReEngagementRecordsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseReEngagementRecordsRepository(client);
});

final reEngagementRepositoryProvider = Provider<ReEngagementRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final continuityRepository = ref.watch(sessionContinuityRepositoryProvider);
  final recordsRepository = ref.watch(reEngagementRecordsRepositoryProvider);

  final preferencesAsync = ref.watch(userPreferencesControllerProvider);
  final preferences = preferencesAsync.maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );

  return ReEngagementRepositoryImpl(
    client: client,
    continuityRepository: continuityRepository,
    recordsRepository: recordsRepository,
    preferences: preferences,
  );
});

final reEngagementSnapshotProvider =
    FutureProvider<ReEngagementSnapshot>((ref) async {
  final repository = ref.watch(reEngagementRepositoryProvider);
  return repository.getSnapshot();
});