// lib/features/quick_fix/application/quick_fix_recommendation_engine.dart

import '../domain/quick_fix_models.dart';
import '../domain/quick_fix_state.dart';
import '../../sessions/domain/session_models.dart';

class QuickFixRecommendationResult {
  const QuickFixRecommendationResult({
    required this.primary,
    required this.alternatives,
  });

  final QuickFixRecommendation? primary;
  final List<QuickFixRecommendation> alternatives;
}

class QuickFixRecommendationEngine {
  const QuickFixRecommendationEngine();

  QuickFixRecommendationResult recommend({
    required QuickFixState state,
    required List<SessionSummary> sessions,
  }) {
    if (sessions.isEmpty) {
      return const QuickFixRecommendationResult(
        primary: null,
        alternatives: <QuickFixRecommendation>[],
      );
    }

    final ranked = sessions
        .map((session) => _ScoredRecommendation(
              recommendation: _buildRecommendation(state, session),
            ))
        .where((item) => item.recommendation.score > 0)
        .toList(growable: true)
      ..sort((a, b) {
        final byScore =
            b.recommendation.score.compareTo(a.recommendation.score);
        if (byScore != 0) return byScore;

        final durationDeltaA =
            (a.recommendation.session.durationMinutes -
                    (int.tryParse(state.selectedTimeId) ?? 0))
                .abs();
        final durationDeltaB =
            (b.recommendation.session.durationMinutes -
                    (int.tryParse(state.selectedTimeId) ?? 0))
                .abs();

        final byDuration = durationDeltaA.compareTo(durationDeltaB);
        if (byDuration != 0) return byDuration;

        return a.recommendation.session.titleFallback
            .compareTo(b.recommendation.session.titleFallback);
      });

    if (ranked.isEmpty) {
      return const QuickFixRecommendationResult(
        primary: null,
        alternatives: <QuickFixRecommendation>[],
      );
    }

    return QuickFixRecommendationResult(
      primary: ranked.first.recommendation,
      alternatives: ranked.skip(1).take(3).map((e) => e.recommendation).toList(),
    );
  }

  QuickFixRecommendation _buildRecommendation(
    QuickFixState state,
    SessionSummary session,
  ) {
    final score = _scoreSession(state, session);
    final signals = _buildSignals(state, session);

    return QuickFixRecommendation(
      session: session,
      score: score,
      reasoningTitleKey: 'quick_fix_primary_match_label',
      reasoningTitleFallback: 'Best Match Right Now',
      reasoningBodyKey: 'quick_fix_reasoning_default',
      reasoningBodyFallback: _buildReasoningFallback(state, session),
      signals: signals,
    );
  }

  double _scoreSession(QuickFixState state, SessionSummary session) {
    double score = 0;

    final desiredMinutes = int.tryParse(state.selectedTimeId) ?? 0;
    final durationDelta = (session.durationMinutes - desiredMinutes).abs();

    score += _scoreProblem(state.selectedProblemId, session);
    score += _scoreEnergy(state.selectedEnergyId, session);
    score += _scoreModes(state.selectedModeIds, session);
    score += _scoreLocations(state.selectedLocationIds, session);

    if (state.silentModeEnabled && session.isSilentFriendly) {
      score += 5;
    } else if (!state.silentModeEnabled && session.isSilentFriendly) {
      score += 1.5;
    }

    if (session.isBeginnerFriendly) {
      score += 1.25;
    }

    if (durationDelta == 0) {
      score += 8;
    } else if (durationDelta == 1) {
      score += 6;
    } else if (durationDelta == 2) {
      score += 4;
    } else if (durationDelta <= 4) {
      score += 2;
    } else {
      score -= 2;
    }

    return score;
  }

  double _scoreProblem(String problemId, SessionSummary session) {
    final painCodes = session.painTargets.map((e) => e.code.toLowerCase()).toSet();
    final tagCodes = session.tags.map((e) => e.code.toLowerCase()).toSet();
    final text =
        '${session.titleFallback} ${session.subtitleFallback} ${session.shortDescriptionFallback}'
            .toLowerCase();

    bool hit(List<String> keywords) {
      for (final keyword in keywords) {
        if (painCodes.any((e) => e.contains(keyword))) return true;
        if (tagCodes.any((e) => e.contains(keyword))) return true;
        if (text.contains(keyword)) return true;
      }
      return false;
    }

    switch (problemId) {
      case 'neck':
        return _problemScore(
          hit(['neck']),
          hit(['shoulder', 'upper_back', 'posture']),
          session,
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.postureReset,
            SessionGoal.mobility,
          ],
        );
      case 'shoulder':
        return _problemScore(
          hit(['shoulder']),
          hit(['neck', 'upper_back']),
          session,
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.mobility,
            SessionGoal.recovery,
          ],
        );
      case 'wrist':
        return _problemScore(
          hit(['wrist', 'forearm', 'hand', 'typing']),
          false,
          session,
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.recovery,
            SessionGoal.mobility,
          ],
        );
      case 'back':
        return _problemScore(
          hit(['lower_back', 'back', 'spine', 'lumbar']),
          hit(['posture']),
          session,
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.postureReset,
            SessionGoal.decompression,
          ],
        );
      case 'eye':
        return _problemScore(
          hit(['eye', 'screen', 'visual']),
          hit(['focus', 'breath', 'decompression']),
          session,
          preferredGoals: const [
            SessionGoal.focusPrep,
            SessionGoal.decompression,
            SessionGoal.recovery,
          ],
        );
      case 'stress':
        return _problemScore(
          hit(['breath', 'calm', 'decompression']),
          hit(['focus', 'recovery']),
          session,
          preferredGoals: const [
            SessionGoal.decompression,
            SessionGoal.recovery,
            SessionGoal.focusPrep,
          ],
        );
      default:
        return 0;
    }
  }

  double _problemScore(
    bool primaryHit,
    bool secondaryHit,
    SessionSummary session, {
    required List<SessionGoal> preferredGoals,
  }) {
    double score = 0;
    if (primaryHit) score += 12;
    if (secondaryHit) score += 5;

    for (final goal in preferredGoals) {
      if (session.goals.contains(goal)) {
        score += 2.5;
      }
    }

    return score;
  }

  double _scoreEnergy(String energyId, SessionSummary session) {
    switch (energyId) {
      case 'low':
        switch (session.intensity) {
          case SessionIntensity.gentle:
            return 5;
          case SessionIntensity.light:
            return 4;
          case SessionIntensity.moderate:
            return 1;
          case SessionIntensity.strong:
            return -4;
        }
      case 'medium':
        switch (session.intensity) {
          case SessionIntensity.gentle:
            return 2;
          case SessionIntensity.light:
            return 5;
          case SessionIntensity.moderate:
            return 4;
          case SessionIntensity.strong:
            return -1;
        }
      case 'high':
        switch (session.intensity) {
          case SessionIntensity.gentle:
            return 1;
          case SessionIntensity.light:
            return 3;
          case SessionIntensity.moderate:
            return 5;
          case SessionIntensity.strong:
            return 4;
        }
      default:
        return 0;
    }
  }

  double _scoreModes(List<String> modeIds, SessionSummary session) {
    double score = 0;

    for (final id in modeIds) {
      switch (id) {
        case 'dad':
          if (session.modeCompatibility.dadMode) score += 3;
          break;
        case 'night':
          if (session.modeCompatibility.nightMode) score += 3;
          break;
        case 'focus':
          if (session.modeCompatibility.focusMode) score += 3;
          break;
        case 'pain_relief':
          if (session.modeCompatibility.painReliefMode) score += 3;
          break;
      }
    }

    return score;
  }

  double _scoreLocations(List<String> locationIds, SessionSummary session) {
    double score = 0;

    for (final id in locationIds) {
      switch (id) {
        case 'desk':
          if (session.environmentCompatibility.deskFriendly) score += 4;
          if (session.environmentCompatibility.officeFriendly) score += 2;
          if (session.environmentCompatibility.lowSpaceFriendly) score += 1.5;
          if (session.environmentCompatibility.noMatRequired) score += 1.5;
          break;
        case 'chair':
          if (session.environmentCompatibility.deskFriendly) score += 3;
          if (session.environmentCompatibility.officeFriendly) score += 2;
          if (session.environmentCompatibility.lowSpaceFriendly) score += 2;
          break;
        case 'standing':
          if (session.environmentCompatibility.lowSpaceFriendly) score += 2.5;
          if (session.environmentCompatibility.officeFriendly) score += 1.5;
          if (session.environmentCompatibility.homeFriendly) score += 1;
          break;
        case 'floor':
          if (session.environmentCompatibility.homeFriendly) score += 3;
          break;
        case 'bedside':
          if (session.environmentCompatibility.homeFriendly) score += 3;
          if (session.environmentCompatibility.quietFriendly) score += 1.5;
          break;
      }
    }

    if (session.environmentCompatibility.quietFriendly) score += 1;

    return score;
  }

  List<QuickFixSignal> _buildSignals(
    QuickFixState state,
    SessionSummary session,
  ) {
    final signals = <QuickFixSignal>[];

    if (session.environmentCompatibility.deskFriendly) {
      signals.add(const QuickFixSignal(
        iconName: 'desk_outlined',
        labelKey: 'session_env_desk_friendly',
        labelFallback: 'Desk-friendly',
      ));
    }

    if (session.isSilentFriendly) {
      signals.add(const QuickFixSignal(
        iconName: 'volume_off_outlined',
        labelKey: 'session_env_quiet',
        labelFallback: 'Quiet-friendly',
      ));
    }

    if (session.environmentCompatibility.noMatRequired) {
      signals.add(const QuickFixSignal(
        iconName: 'checkroom_outlined',
        labelKey: 'session_env_no_mat',
        labelFallback: 'No mat required',
      ));
    }

    if (session.isBeginnerFriendly) {
      signals.add(const QuickFixSignal(
        iconName: 'star_outline_rounded',
        labelKey: 'sessions_tag_beginner',
        labelFallback: 'Beginner',
      ));
    }

    switch (session.intensity) {
      case SessionIntensity.gentle:
        signals.add(const QuickFixSignal(
          iconName: 'battery_2_bar_rounded',
          labelKey: 'session_intensity_gentle',
          labelFallback: 'Gentle',
        ));
        break;
      case SessionIntensity.light:
        signals.add(const QuickFixSignal(
          iconName: 'battery_5_bar_rounded',
          labelKey: 'session_intensity_light',
          labelFallback: 'Light',
        ));
        break;
      case SessionIntensity.moderate:
        signals.add(const QuickFixSignal(
          iconName: 'battery_full_rounded',
          labelKey: 'session_intensity_moderate',
          labelFallback: 'Moderate',
        ));
        break;
      case SessionIntensity.strong:
        signals.add(const QuickFixSignal(
          iconName: 'local_fire_department_outlined',
          labelKey: 'session_intensity_strong',
          labelFallback: 'Strong',
        ));
        break;
    }

    return signals.take(4).toList(growable: false);
  }

  String _buildReasoningFallback(
    QuickFixState state,
    SessionSummary session,
  ) {
    final parts = <String>[];

    if (state.silentModeEnabled && session.isSilentFriendly) {
      parts.add('quiet-friendly');
    }

    if (session.environmentCompatibility.deskFriendly &&
        state.selectedLocationIds.contains('desk')) {
      parts.add('desk-ready');
    }

    if (session.modeCompatibility.focusMode &&
        state.selectedModeIds.contains('focus')) {
      parts.add('focus-compatible');
    }

    if (session.modeCompatibility.painReliefMode &&
        state.selectedModeIds.contains('pain_relief')) {
      parts.add('pain-relief aligned');
    }

    if (parts.isEmpty) {
      parts.add('strong context match');
    }

    return 'Recommended because it matches your current problem, time window, and context with ${parts.join(', ')} support.';
  }
}

class _ScoredRecommendation {
  const _ScoredRecommendation({
    required this.recommendation,
  });

  final QuickFixRecommendation recommendation;
}