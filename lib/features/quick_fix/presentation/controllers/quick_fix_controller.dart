// lib/features/quick_fix/presentation/controllers/quick_fix_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/quick_fix_recommendation_engine.dart';
import '../../data/quick_fix_repository_impl.dart';
import '../../data/supabase_quick_fix_events_repository.dart';
import '../../domain/quick_fix_events_repository.dart';
import '../../domain/quick_fix_models.dart';
import '../../domain/quick_fix_repository.dart';
import '../../domain/quick_fix_state.dart';
import '../../../profile/application/profile_providers.dart';
import '../../../profile/domain/profile_models.dart';
import '../../../sessions/application/sessions_providers.dart';
import '../../../sessions/domain/session_models.dart';

final quickFixRepositoryProvider = Provider<QuickFixRepository>((ref) {
  return const QuickFixRepositoryImpl();
});

final quickFixRecommendationEngineProvider =
    Provider<QuickFixRecommendationEngine>((ref) {
  return const QuickFixRecommendationEngine();
});

final quickFixEventsRepositoryProvider =
    Provider<QuickFixEventsRepository>((ref) {
  return SupabaseQuickFixEventsRepository(Supabase.instance.client);
});

final quickFixControllerProvider =
    AsyncNotifierProvider<QuickFixController, QuickFixState>(
  QuickFixController.new,
);

class QuickFixController extends AsyncNotifier<QuickFixState> {
  QuickFixRepository get _repository => ref.read(quickFixRepositoryProvider);
  QuickFixRecommendationEngine get _engine =>
      ref.read(quickFixRecommendationEngineProvider);
  QuickFixEventsRepository get _eventsRepository =>
      ref.read(quickFixEventsRepositoryProvider);

  @override
  Future<QuickFixState> build() async {
    final initial = await _repository.getInitialState();
    final preferences = await ref.watch(userPreferencesControllerProvider.future);
    final seeded = _applyPreferenceBaseline(initial, preferences);
    return _recompute(seeded, trackRecommendation: true);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final initial = await _repository.getInitialState();
      final preferences = await ref.read(userPreferencesControllerProvider.future);
      final seeded = _applyPreferenceBaseline(initial, preferences);
      return _recompute(seeded, trackRecommendation: true);
    });
  }

  QuickFixState? _current() => state.value;

  Future<List<SessionSummary>> _sessions() async {
    return ref.read(sessionSummariesProvider.future);
  }

  QuickFixState _applyPreferenceBaseline(
    QuickFixState initial,
    UserPreferences? preferences,
  ) {
    if (preferences == null) {
      return initial;
    }

    final validModeIds = initial.modes.map((e) => e.id).toSet();
    final seededModes = preferences.defaultModeCodes
        .where(validModeIds.contains)
        .toSet()
        .toList()
      ..sort();

    return initial.copyWith(
      selectedModeIds: seededModes,
      silentModeEnabled: preferences.preferredSilentMode,
    );
  }

  Future<QuickFixState> _recompute(
    QuickFixState current, {
    bool trackRecommendation = false,
  }) async {
    final sessions = await _sessions();
    final result = _engine.recommend(state: current, sessions: sessions);

    var next = current.copyWith(
      primaryRecommendation: result.primary,
      alternativeRecommendations: result.alternatives,
    );

    if (trackRecommendation &&
        result.primary != null &&
        next.lastTrackedRecommendationId != result.primary!.session.id) {
      await _eventsRepository.trackEvent(
        actionType: QuickFixActionType.recommendationShown,
        state: next,
        recommendedSessionId: result.primary!.session.id,
        metadata: {
          'score': result.primary!.score,
          'has_user_interacted': next.hasUserInteracted,
        },
      );

      next = next.copyWith(
        lastTrackedRecommendationId: result.primary!.session.id,
      );
    }

    return next;
  }

  Future<void> _apply(QuickFixState next) async {
    final recomputed = await _recompute(next, trackRecommendation: true);
    state = AsyncData(recomputed);
  }

  Future<void> setSilentMode(bool value) async {
    final current = _current();
    if (current == null) return;

    await _apply(
      current.copyWith(
        silentModeEnabled: value,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> selectProblem(String id) async {
    final current = _current();
    if (current == null || current.selectedProblemId == id) return;

    await _apply(
      current.copyWith(
        selectedProblemId: id,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> selectTime(String id) async {
    final current = _current();
    if (current == null || current.selectedTimeId == id) return;

    await _apply(
      current.copyWith(
        selectedTimeId: id,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> toggleLocation(String id) async {
    final current = _current();
    if (current == null) return;

    final selected = [...current.selectedLocationIds];
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }

    final safeSelected = selected.isEmpty ? <String>['desk'] : selected;

    await _apply(
      current.copyWith(
        selectedLocationIds: safeSelected,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> selectEnergy(String id) async {
    final current = _current();
    if (current == null || current.selectedEnergyId == id) return;

    await _apply(
      current.copyWith(
        selectedEnergyId: id,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> toggleMode(String id) async {
    final current = _current();
    if (current == null) return;

    final selected = [...current.selectedModeIds];
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }

    await _apply(
      current.copyWith(
        selectedModeIds: selected,
        hasUserInteracted: true,
      ),
    );
  }

  Future<void> setAlternativeRecommendation(String sessionId) async {
    final current = _current();
    if (current == null) return;

    final alternatives = [...current.alternativeRecommendations];
    final matchIndex =
        alternatives.indexWhere((item) => item.session.id == sessionId);
    if (matchIndex == -1) return;

    final promoted = alternatives.removeAt(matchIndex);
    final demotedPrimary = current.primaryRecommendation;

    final updatedAlternatives = [
      if (demotedPrimary != null) demotedPrimary,
      ...alternatives,
    ];

    state = AsyncData(
      current.copyWith(
        primaryRecommendation: promoted,
        alternativeRecommendations: updatedAlternatives.take(3).toList(),
        clearTrackedRecommendationId: true,
        hasUserInteracted: true,
      ),
    );

    final refreshed = await _recompute(state.value!, trackRecommendation: true);
    state = AsyncData(refreshed);
  }

  Future<void> trackAction(QuickFixActionType actionType) async {
    final current = _current();
    final recommendation = current?.primaryRecommendation;
    if (current == null || recommendation == null) return;

    await _eventsRepository.trackEvent(
      actionType: actionType,
      state: current,
      recommendedSessionId: recommendation.session.id,
      metadata: {
        'score': recommendation.score,
        'has_user_interacted': current.hasUserInteracted,
      },
    );
  }
}