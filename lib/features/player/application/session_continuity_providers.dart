// lib/features/player/application/session_continuity_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../sessions/application/sessions_providers.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/session_continuity_repository_impl.dart';
import '../domain/session_continuity_models.dart';
import '../domain/session_continuity_repository.dart';
import '../domain/session_run_models.dart';
import 'player_providers.dart';

final sessionContinuityRepositoryProvider =
    Provider<SessionContinuityRepository>((ref) {
  return SessionContinuityRepositoryImpl(
    sessionRunsRepository: ref.watch(sessionRunsRepositoryProvider),
    savedSessionsRepository: ref.watch(savedSessionsRepositoryProvider),
    sessionsRepository: ref.watch(sessionsRepositoryProvider),
  );
});

final completedSessionCountProvider = FutureProvider<int>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return 0;

  final response = await client
      .from('session_runs')
      .select('id', const FetchOptions(count: CountOption.exact))
      .eq('user_id', user.id)
      .eq('status', 'completed');
  return response.count ?? 0;
});

final recentSessionRunsProvider = FutureProvider<List<SessionRun>>((ref) async {
  final repository = ref.watch(sessionRunsRepositoryProvider);
  return repository.getRecentRuns();
});

final sessionContinuitySnapshotProvider =
    FutureProvider<SessionContinuitySnapshot>((ref) async {
  final repository = ref.watch(sessionContinuityRepositoryProvider);
  return repository.getSnapshot();
});

final continueSessionCandidateProvider =
    FutureProvider<ContinueSessionCandidate?>((ref) async {
  final repository = ref.watch(sessionContinuityRepositoryProvider);
  return repository.getContinueCandidate();
});

final sessionHistoryItemsProvider =
    FutureProvider<List<SessionHistoryItem>>((ref) async {
  final repository = ref.watch(sessionContinuityRepositoryProvider);
  return repository.getHistory(limit: 24);
});

final savedSessionContinuityItemsProvider =
    FutureProvider<List<SavedSessionContinuityItem>>((ref) async {
  final repository = ref.watch(sessionContinuityRepositoryProvider);
  return repository.getSavedSessions(limit: 24);
});

final recentlySavedSessionsProvider =
    FutureProvider<List<SavedSessionContinuityItem>>((ref) async {
  final repository = ref.watch(sessionContinuityRepositoryProvider);
  return repository.getSavedSessions(limit: 8);
});
