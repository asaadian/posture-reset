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
        .map(
          (session) => _ScoredRecommendation(
            recommendation: _buildRecommendation(state, session),
          ),
        )
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
    final signals = _buildSignals(session);

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

    final problemScore = _scoreProblem(state.selectedProblemId, session);
    if (problemScore <= 0) {
      return 0;
    }

    if (!_hasRequiredEquipment(state, session)) {
      return 0;
    }

    score += problemScore;
    score += _scoreEquipment(state, session);
    score += _scoreEnergy(state.selectedEnergyId, session);
    score += _scoreModes(state.selectedModeIds, session);

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

  double _scoreProblem(String rawProblemId, SessionSummary session) {
    final problemId = _canonicalProblemId(rawProblemId);
    final painCodes =
        session.painTargets.map((e) => _canonicalBodyCode(e.code)).toSet();
    final tagCodes = session.tags.map((e) => e.code.toLowerCase()).toSet();
    final text =
        '${session.id} ${session.titleFallback} ${session.subtitleFallback} ${session.shortDescriptionFallback}'
            .toLowerCase();

    bool exactPain(List<String> codes) {
      final canonicalCodes = codes.map(_canonicalBodyCode).toSet();
      return painCodes.intersection(canonicalCodes).isNotEmpty;
    }

    bool hit(List<String> keywords) {
      for (final keyword in keywords) {
        final normalized = keyword.toLowerCase();
        if (painCodes.any((e) => e.contains(normalized))) return true;
        if (tagCodes.any((e) => e.contains(normalized))) return true;
        if (text.contains(normalized)) return true;
      }
      return false;
    }

    double base({
      required List<String> primaryCodes,
      required List<String> primaryKeywords,
      required List<String> secondaryKeywords,
      required List<SessionGoal> preferredGoals,
    }) {
      return _problemScore(
        exactPain(primaryCodes) || hit(primaryKeywords),
        hit(secondaryKeywords),
        session,
        preferredGoals: preferredGoals,
      );
    }

    switch (problemId) {
      case 'neck':
        final score = base(
          primaryCodes: const ['neck'],
          primaryKeywords: const ['neck', 'cervical'],
          secondaryKeywords: const ['shoulder', 'upper_back', 'upper back'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.postureReset,
            SessionGoal.mobility,
          ],
        );
        if (session.id == 'sess_towel_deep_neck_flexor_control_07') return score + 8;
        if (session.id == 'sess_cervical_isometric_stability_07') return score + 7;
        if (session.id == 'sess_ball_upper_trap_levator_reset_07') return score + 5;
        if (session.id == 'sess_flagship_laptop_neck_shoulder_chain_10') return score + 6;
        return score;

      case 'shoulders':
        final score = base(
          primaryCodes: const ['shoulders'],
          primaryKeywords: const ['shoulder', 'shoulders', 'scapula'],
          secondaryKeywords: const ['neck', 'upper_back', 'upper back'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.mobility,
            SessionGoal.recovery,
          ],
        );
        if (session.id == 'sess_band_rotator_cuff_scapular_control_08') return score + 8;
        if (session.id == 'sess_serratus_wall_slide_miniband_07') return score + 7;
        if (session.id == 'sess_dowel_shoulder_mobility_control_07') return score + 5;
        if (session.id == 'sess_flagship_laptop_neck_shoulder_chain_10') return score + 6;
        return score;

      case 'upper_back':
        final score = base(
          primaryCodes: const ['upper_back'],
          primaryKeywords: const [
            'upper_back',
            'upper back',
            'thoracic',
            'mid_back',
            'mid back',
          ],
          secondaryKeywords: const ['shoulder', 'neck', 'posture'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.mobility,
            SessionGoal.postureReset,
          ],
        );
        if (session.id == 'sess_foam_roller_thoracic_extension_rotation_08') return score + 8;
        if (session.id == 'sess_desk_thoracic_rotation_scapular_integration_07') return score + 6;
        if (session.id == 'sess_flagship_full_desk_worker_therapy_12') return score + 5;
        return score;

      case 'lower_back':
        final score = base(
          primaryCodes: const ['lower_back'],
          primaryKeywords: const ['lower_back', 'lower back', 'lumbar'],
          secondaryKeywords: const ['hips', 'glutes', 'hips_glutes', 'posture'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.postureReset,
            SessionGoal.decompression,
          ],
        );
        if (session.id == 'sess_chair_core_bracing_low_back_support_07') return score + 8;
        if (session.id == 'sess_standing_back_decompression_core_reset_07') return score + 6;
        if (session.id == 'sess_flagship_after_work_spine_hip_reset_10') return score + 5;
        return score;

      case 'wrists':
        final score = base(
          primaryCodes: const ['wrists'],
          primaryKeywords: const ['wrist', 'wrists'],
          secondaryKeywords: const ['forearm', 'forearms', 'hand', 'hands', 'typing'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.recovery,
            SessionGoal.mobility,
          ],
        );
        if (session.id == 'sess_eccentric_wrist_extensor_loading_07') return score + 8;
        if (session.id == 'sess_median_nerve_tendon_glide_06') return score + 6;
        if (session.id == 'sess_flagship_mouse_arm_clinical_reset_09') return score + 5;
        if (session.id == 'sess_free_typing_load_starter_04') return score + 3;
        return score;

      case 'forearms':
        final score = base(
          primaryCodes: const ['forearms'],
          primaryKeywords: const ['forearm', 'forearms', 'mouse arm'],
          secondaryKeywords: const ['wrist', 'wrists', 'typing', 'shoulder'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.recovery,
            SessionGoal.mobility,
          ],
        );
        if (session.id == 'sess_forearm_pronation_supination_control_07') return score + 8;
        if (session.id == 'sess_mouse_arm_shoulder_chain_07') return score + 7;
        if (session.id == 'sess_flagship_mouse_arm_clinical_reset_09') return score + 6;
        return score;

      case 'hands':
      case 'fingers':
        final score = base(
          primaryCodes: const ['hands', 'fingers'],
          primaryKeywords: const ['hand', 'hands', 'finger', 'fingers'],
          secondaryKeywords: const ['wrist', 'wrists', 'typing', 'forearm'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.recovery,
            SessionGoal.mobility,
          ],
        );
        if (session.id == 'sess_soft_ball_hand_strength_06') return score + 8;
        if (session.id == 'sess_median_nerve_tendon_glide_06') return score + 5;
        return score;

      case 'eyes':
        final score = base(
          primaryCodes: const ['eyes'],
          primaryKeywords: const [
            'eye',
            'eyes',
            'screen',
            'visual',
            'vision',
            'screen_break',
          ],
          secondaryKeywords: const ['neck', 'focus', 'breath'],
          preferredGoals: const [
            SessionGoal.focusPrep,
            SessionGoal.decompression,
            SessionGoal.recovery,
          ],
        );
        if (session.id == 'sess_free_desk_decompression_04') return score + 4;
        if (session.id == 'sess_towel_deep_neck_flexor_control_07') return score + 3;
        return score;

      case 'hips_glutes':
        final score = base(
          primaryCodes: const ['hips_glutes', 'hips', 'glutes'],
          primaryKeywords: const ['hips_glutes', 'hip', 'hips', 'glute', 'glutes'],
          secondaryKeywords: const ['lower_back', 'lower back', 'lumbar'],
          preferredGoals: const [
            SessionGoal.painRelief,
            SessionGoal.recovery,
            SessionGoal.mobility,
          ],
        );
        if (session.id == 'sess_miniband_glute_med_stability_08') return score + 8;
        if (session.id == 'sess_hip_flexor_release_glute_rebalance_07') return score + 7;
        if (session.id == 'sess_hamstring_slider_hip_hinge_control_07') return score + 5;
        if (session.id == 'sess_flagship_after_work_spine_hip_reset_10') return score + 5;
        return score;

      case 'stress':
        final score = _problemScore(
          hit(['stress', 'calm', 'downshift', 'nervous system', 'breath']),
          hit(['decompression', 'recovery', 'focus', 'low_energy', 'evening']),
          session,
          preferredGoals: const [
            SessionGoal.decompression,
            SessionGoal.recovery,
            SessionGoal.focusPrep,
          ],
        );
        if (session.id == 'sess_flagship_after_work_spine_hip_reset_10') return score + 7;
        if (session.id == 'sess_free_desk_decompression_04') return score + 4;
        if (session.id == 'sess_flagship_full_desk_worker_therapy_12') return score + 4;
        return score;

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
    if (primaryHit) score += 16;
    if (secondaryHit) score += 5;

    for (final goal in preferredGoals) {
      if (session.goals.contains(goal)) {
        score += 2.5;
      }
    }

    return score;
  }

  String _canonicalProblemId(String raw) {
    switch (raw.toLowerCase()) {
      case 'shoulder':
      case 'shoulders':
        return 'shoulders';
      case 'wrist':
      case 'wrists':
        return 'wrists';
      case 'back':
      case 'lower_back':
      case 'low_back':
      case 'lumbar':
        return 'lower_back';
      case 'eye':
      case 'eyes':
      case 'screen':
      case 'screen_strain':
      case 'eye_strain':
        return 'eyes';
      case 'hand':
      case 'hands':
        return 'hands';
      case 'finger':
      case 'fingers':
        return 'fingers';
      case 'forearm':
      case 'forearms':
      case 'mouse_arm':
        return 'forearms';
      case 'hip':
      case 'hips':
      case 'glute':
      case 'glutes':
      case 'hips_glutes':
        return 'hips_glutes';
      default:
        return raw.toLowerCase();
    }
  }

  String _canonicalBodyCode(String raw) {
    switch (raw.toLowerCase()) {
      case 'shoulder':
      case 'shoulders':
        return 'shoulders';
      case 'wrist':
      case 'wrists':
        return 'wrists';
      case 'back':
      case 'low_back':
      case 'lumbar':
      case 'lower_back':
        return 'lower_back';
      case 'eye':
      case 'eyes':
        return 'eyes';
      case 'hand':
      case 'hands':
        return 'hands';
      case 'finger':
      case 'fingers':
        return 'fingers';
      case 'forearm':
      case 'forearms':
        return 'forearms';
      case 'hip':
      case 'hips':
      case 'glute':
      case 'glutes':
      case 'hips_glutes':
        return 'hips_glutes';
      default:
        return raw.toLowerCase();
    }
  }

  bool _hasRequiredEquipment(QuickFixState state, SessionSummary session) {
    final selected = state.selectedEquipmentIds.toSet();
    if (selected.isEmpty) return false;

    final selectedSpecial = _selectedSpecialEquipment(selected);
    final requiredSpecial = _requiredSpecialEquipment(session);

    if (selectedSpecial.isNotEmpty) {
      return requiredSpecial.isNotEmpty &&
          requiredSpecial.any(selectedSpecial.contains) &&
          requiredSpecial.every(selected.contains);
    }

    if (requiredSpecial.isEmpty) return true;
    return requiredSpecial.every(selected.contains);
  }

  double _scoreEquipment(QuickFixState state, SessionSummary session) {
    final selected = state.selectedEquipmentIds.toSet();
    final selectedSpecial = _selectedSpecialEquipment(selected);
    final requiredSpecial = _requiredSpecialEquipment(session);

    if (selectedSpecial.isNotEmpty && requiredSpecial.isEmpty) return 0;
    if (requiredSpecial.isEmpty) return 2.5;
    if (!requiredSpecial.every(selected.contains)) return 0;

    if (requiredSpecial.any(
      (item) => item == 'long_band' || item == 'mini_band',
    )) {
      return 6;
    }

    if (requiredSpecial.any(
      (item) => item == 'foam_roller' || item == 'massage_ball',
    )) {
      return 5.5;
    }

    if (requiredSpecial.any(
      (item) => item == 'water_bottle' ||
          item == 'soft_ball' ||
          item == 'dowel' ||
          item == 'towel',
    )) {
      return 5;
    }

    return 3;
  }

  Set<String> _requiredSpecialEquipment(SessionSummary session) {
    return session.requiredEquipment
        .map(sessionStepEquipmentCodeToDb)
        .where(_isSpecialEquipment)
        .toSet();
  }

  Set<String> _selectedSpecialEquipment(Set<String> selected) {
    return selected.where(_isSpecialEquipment).toSet();
  }

  bool _isSpecialEquipment(String item) {
    return item != 'none' &&
        item != 'chair' &&
        item != 'desk' &&
        item != 'wall';
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

  List<QuickFixSignal> _buildSignals(SessionSummary session) {
    final signals = <QuickFixSignal>[];

    if (session.isBeginnerFriendly) {
      signals.add(const QuickFixSignal(
        iconName: 'star_outline_rounded',
        labelKey: 'sessions_tag_beginner',
        labelFallback: 'Beginner',
      ));
    }

    if (session.requiredEquipment.any((item) =>
        item != SessionStepEquipmentCode.none &&
        item != SessionStepEquipmentCode.chair &&
        item != SessionStepEquipmentCode.desk &&
        item != SessionStepEquipmentCode.wall)) {
      signals.add(const QuickFixSignal(
        iconName: 'fitness_center_outlined',
        labelKey: 'quick_fix_signal_equipment_based',
        labelFallback: 'Equipment-based',
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

    if (session.modeCompatibility.focusMode &&
        state.selectedModeIds.contains('focus')) {
      parts.add('focus-compatible');
    }

    if (session.modeCompatibility.painReliefMode &&
        state.selectedModeIds.contains('pain_relief')) {
      parts.add('pain-relief aligned');
    }

    final requiredEquipment = _requiredSpecialEquipment(session).toList(growable: false);

    if (requiredEquipment.isNotEmpty) {
      parts.add('available equipment');
    }

    if (parts.isEmpty) {
      parts.add('strong context match');
    }

    return 'Recommended because it matches your current target, time window, and ${parts.join(', ')} support.';
  }
}

class _ScoredRecommendation {
  const _ScoredRecommendation({
    required this.recommendation,
  });

  final QuickFixRecommendation recommendation;
}
