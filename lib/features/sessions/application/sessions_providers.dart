// lib/features/sessions/application/sessions_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/supabase_saved_sessions_repository.dart';
import '../data/supabase_sessions_repository.dart';
import '../domain/saved_sessions_repository.dart';
import '../domain/session_models.dart';
import '../domain/sessions_repository.dart';


final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSessionsRepository(client);
});

final savedSessionsRepositoryProvider = Provider<SavedSessionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSavedSessionsRepository(client);
});

final sessionSummariesProvider =
    FutureProvider<List<SessionSummary>>((ref) async {
  final repository = ref.watch(sessionsRepositoryProvider);
  return repository.getSessionSummaries();
});

final sessionDetailProvider =
    FutureProvider.family<SessionDetail?, String>((ref, sessionId) async {
  final repository = ref.watch(sessionsRepositoryProvider);
  return repository.getSessionDetailById(sessionId);
});

final sessionsByIdsProvider =
    FutureProvider.family<List<SessionSummary>, List<String>>(
  (ref, sessionIds) async {
    final repository = ref.watch(sessionsRepositoryProvider);
    return repository.getSessionsByIds(sessionIds);
  },
);


final savedSessionIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(savedSessionsRepositoryProvider);
  return repository.getSavedSessionIds();
});

final isSessionSavedProvider =
    Provider.family<AsyncValue<bool>, String>((ref, sessionId) {
  final savedIdsAsync = ref.watch(savedSessionIdsProvider);
  return savedIdsAsync.whenData((savedIds) => savedIds.contains(sessionId));
});

final relatedSessionsProvider =
    FutureProvider.family<List<SessionSummary>, String>((ref, sessionId) async {
  final currentDetail = await ref.watch(sessionDetailProvider(sessionId).future);
  if (currentDetail == null) {
    return const <SessionSummary>[];
  }

  final current = currentDetail.summary;
  final summaries = await ref.watch(sessionSummariesProvider.future);

  final ranked = summaries
      .where((item) => item.id != sessionId)
      .map(
        (item) => _RankedSession(
          session: item,
          score: _scoreRelatedSession(current, item),
        ),
      )
      .where((item) => item.score > 0)
      .toList(growable: true)
    ..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      final aDurationDelta =
          (a.session.durationMinutes - current.durationMinutes).abs();
      final bDurationDelta =
          (b.session.durationMinutes - current.durationMinutes).abs();

      final byDuration = aDurationDelta.compareTo(bDurationDelta);
      if (byDuration != 0) return byDuration;

      return a.session.titleFallback.compareTo(b.session.titleFallback);
    });

  return ranked.take(4).map((item) => item.session).toList(growable: false);
});

class _RankedSession {
  const _RankedSession({
    required this.session,
    required this.score,
  });

  final SessionSummary session;
  final double score;
}

double _scoreRelatedSession(SessionSummary current, SessionSummary other) {
  double score = 0;

  final currentPainCodes = current.painTargets.map((e) => e.code).toSet();
  final otherPainCodes = other.painTargets.map((e) => e.code).toSet();
  score += currentPainCodes.intersection(otherPainCodes).length * 5.0;

  final currentGoals = current.goals.toSet();
  final otherGoals = other.goals.toSet();
  score += currentGoals.intersection(otherGoals).length * 4.0;

  final currentTags = current.tags.map((e) => e.code).toSet();
  final otherTags = other.tags.map((e) => e.code).toSet();
  score += currentTags.intersection(otherTags).length * 2.0;

  if (current.intensity == other.intensity) score += 2.0;
  if (current.isSilentFriendly == other.isSilentFriendly) score += 1.0;
  if (current.isBeginnerFriendly == other.isBeginnerFriendly) score += 1.0;

  if (current.modeCompatibility.dadMode && other.modeCompatibility.dadMode) {
    score += 1.0;
  }
  if (current.modeCompatibility.nightMode && other.modeCompatibility.nightMode) {
    score += 1.0;
  }
  if (current.modeCompatibility.focusMode && other.modeCompatibility.focusMode) {
    score += 1.0;
  }
  if (current.modeCompatibility.painReliefMode &&
      other.modeCompatibility.painReliefMode) {
    score += 1.0;
  }

  if (current.environmentCompatibility.deskFriendly &&
      other.environmentCompatibility.deskFriendly) {
    score += 1.0;
  }
  if (current.environmentCompatibility.officeFriendly &&
      other.environmentCompatibility.officeFriendly) {
    score += 1.0;
  }
  if (current.environmentCompatibility.homeFriendly &&
      other.environmentCompatibility.homeFriendly) {
    score += 1.0;
  }
  if (current.environmentCompatibility.noMatRequired &&
      other.environmentCompatibility.noMatRequired) {
    score += 1.0;
  }
  if (current.environmentCompatibility.lowSpaceFriendly &&
      other.environmentCompatibility.lowSpaceFriendly) {
    score += 1.0;
  }
  if (current.environmentCompatibility.quietFriendly &&
      other.environmentCompatibility.quietFriendly) {
    score += 1.0;
  }

  final durationDelta =
      (current.durationMinutes - other.durationMinutes).abs();
  if (durationDelta == 0) {
    score += 2.0;
  } else if (durationDelta <= 2) {
    score += 1.5;
  } else if (durationDelta <= 5) {
    score += 1.0;
  }

  return score;
}