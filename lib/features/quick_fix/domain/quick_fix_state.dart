import 'quick_fix_models.dart';

class QuickFixOption {
  const QuickFixOption({
    required this.id,
    required this.labelKey,
    required this.labelFallback,
    required this.iconName,
  });

  final String id;
  final String labelKey;
  final String labelFallback;
  final String iconName;
}

class QuickFixState {
  const QuickFixState({
    required this.problems,
    required this.timeOptions,
    required this.equipmentOptions,
    required this.energyOptions,
    required this.modes,
    required this.selectedProblemId,
    required this.selectedTimeId,
    required this.selectedEquipmentIds,
    required this.selectedEnergyId,
    required this.selectedModeIds,
    required this.silentModeEnabled,
    required this.primaryRecommendation,
    required this.alternativeRecommendations,
    required this.lastTrackedRecommendationId,
    required this.hasUserInteracted,
    required this.recommendationRevealCount,
  });

  final List<QuickFixOption> problems;
  final List<QuickFixOption> timeOptions;
  final List<QuickFixOption> equipmentOptions;
  final List<QuickFixOption> energyOptions;
  final List<QuickFixOption> modes;

  final String selectedProblemId;
  final String selectedTimeId;
  final List<String> selectedEquipmentIds;
  final String selectedEnergyId;
  final List<String> selectedModeIds;
  final bool silentModeEnabled;

  final QuickFixRecommendation? primaryRecommendation;
  final List<QuickFixRecommendation> alternativeRecommendations;
  final String? lastTrackedRecommendationId;
  final bool hasUserInteracted;
  final int recommendationRevealCount;

  QuickFixState copyWith({
    List<QuickFixOption>? problems,
    List<QuickFixOption>? timeOptions,
    List<QuickFixOption>? equipmentOptions,
    List<QuickFixOption>? energyOptions,
    List<QuickFixOption>? modes,
    String? selectedProblemId,
    String? selectedTimeId,
    List<String>? selectedEquipmentIds,
    String? selectedEnergyId,
    List<String>? selectedModeIds,
    bool? silentModeEnabled,
    QuickFixRecommendation? primaryRecommendation,
    List<QuickFixRecommendation>? alternativeRecommendations,
    String? lastTrackedRecommendationId,
    bool? hasUserInteracted,
    int? recommendationRevealCount,
    bool clearPrimaryRecommendation = false,
    bool clearTrackedRecommendationId = false,
  }) {
    return QuickFixState(
      problems: problems ?? this.problems,
      timeOptions: timeOptions ?? this.timeOptions,
      equipmentOptions: equipmentOptions ?? this.equipmentOptions,
      energyOptions: energyOptions ?? this.energyOptions,
      modes: modes ?? this.modes,
      selectedProblemId: selectedProblemId ?? this.selectedProblemId,
      selectedTimeId: selectedTimeId ?? this.selectedTimeId,
      selectedEquipmentIds: selectedEquipmentIds ?? this.selectedEquipmentIds,
      selectedEnergyId: selectedEnergyId ?? this.selectedEnergyId,
      selectedModeIds: selectedModeIds ?? this.selectedModeIds,
      silentModeEnabled: silentModeEnabled ?? this.silentModeEnabled,
      primaryRecommendation: clearPrimaryRecommendation
          ? null
          : (primaryRecommendation ?? this.primaryRecommendation),
      alternativeRecommendations:
          alternativeRecommendations ?? this.alternativeRecommendations,
      lastTrackedRecommendationId: clearTrackedRecommendationId
          ? null
          : (lastTrackedRecommendationId ?? this.lastTrackedRecommendationId),
      hasUserInteracted: hasUserInteracted ?? this.hasUserInteracted,
      recommendationRevealCount:
          recommendationRevealCount ?? this.recommendationRevealCount,
    );
  }
}
