// lib/features/quick_fix/domain/quick_fix_state.dart

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
    required this.locations,
    required this.energyOptions,
    required this.modes,
    required this.selectedProblemId,
    required this.selectedTimeId,
    required this.selectedLocationIds,
    required this.selectedEnergyId,
    required this.selectedModeIds,
    required this.silentModeEnabled,
    required this.primaryRecommendation,
    required this.alternativeRecommendations,
    required this.lastTrackedRecommendationId,
    required this.hasUserInteracted,
  });

  final List<QuickFixOption> problems;
  final List<QuickFixOption> timeOptions;
  final List<QuickFixOption> locations;
  final List<QuickFixOption> energyOptions;
  final List<QuickFixOption> modes;

  final String selectedProblemId;
  final String selectedTimeId;
  final List<String> selectedLocationIds;
  final String selectedEnergyId;
  final List<String> selectedModeIds;
  final bool silentModeEnabled;

  final QuickFixRecommendation? primaryRecommendation;
  final List<QuickFixRecommendation> alternativeRecommendations;
  final String? lastTrackedRecommendationId;
  final bool hasUserInteracted;

  QuickFixState copyWith({
    List<QuickFixOption>? problems,
    List<QuickFixOption>? timeOptions,
    List<QuickFixOption>? locations,
    List<QuickFixOption>? energyOptions,
    List<QuickFixOption>? modes,
    String? selectedProblemId,
    String? selectedTimeId,
    List<String>? selectedLocationIds,
    String? selectedEnergyId,
    List<String>? selectedModeIds,
    bool? silentModeEnabled,
    QuickFixRecommendation? primaryRecommendation,
    List<QuickFixRecommendation>? alternativeRecommendations,
    String? lastTrackedRecommendationId,
    bool? hasUserInteracted,
    bool clearPrimaryRecommendation = false,
    bool clearTrackedRecommendationId = false,
  }) {
    return QuickFixState(
      problems: problems ?? this.problems,
      timeOptions: timeOptions ?? this.timeOptions,
      locations: locations ?? this.locations,
      energyOptions: energyOptions ?? this.energyOptions,
      modes: modes ?? this.modes,
      selectedProblemId: selectedProblemId ?? this.selectedProblemId,
      selectedTimeId: selectedTimeId ?? this.selectedTimeId,
      selectedLocationIds: selectedLocationIds ?? this.selectedLocationIds,
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
    );
  }
}