// lib/features/quick_fix/data/quick_fix_repository_impl.dart

import '../domain/quick_fix_repository.dart';
import '../domain/quick_fix_state.dart';

class QuickFixRepositoryImpl implements QuickFixRepository {
  const QuickFixRepositoryImpl();

  @override
  Future<QuickFixState> getInitialState() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    return const QuickFixState(
      problems: [
        QuickFixOption(
          id: 'neck',
          labelKey: 'quick_fix_problem_neck',
          labelFallback: 'Neck Pain',
          iconName: 'accessibility_new_outlined',
        ),
        QuickFixOption(
          id: 'shoulder',
          labelKey: 'quick_fix_problem_shoulder',
          labelFallback: 'Shoulder Tightness',
          iconName: 'fitness_center_outlined',
        ),
        QuickFixOption(
          id: 'wrist',
          labelKey: 'quick_fix_problem_wrist',
          labelFallback: 'Wrist Pain',
          iconName: 'back_hand_outlined',
        ),
        QuickFixOption(
          id: 'back',
          labelKey: 'quick_fix_problem_back',
          labelFallback: 'Lower Back',
          iconName: 'airline_seat_recline_normal_outlined',
        ),
        QuickFixOption(
          id: 'eye',
          labelKey: 'quick_fix_problem_eye',
          labelFallback: 'Eye Strain',
          iconName: 'remove_red_eye_outlined',
        ),
        QuickFixOption(
          id: 'stress',
          labelKey: 'quick_fix_problem_stress',
          labelFallback: 'Stress Reset',
          iconName: 'self_improvement_outlined',
        ),
      ],
      timeOptions: [
        QuickFixOption(
          id: '2',
          labelKey: 'quick_fix_time_2',
          labelFallback: '2 min',
          iconName: 'timelapse_outlined',
        ),
        QuickFixOption(
          id: '4',
          labelKey: 'quick_fix_time_4',
          labelFallback: '4 min',
          iconName: 'timer_outlined',
        ),
        QuickFixOption(
          id: '6',
          labelKey: 'quick_fix_time_6',
          labelFallback: '6 min',
          iconName: 'more_time_outlined',
        ),
        QuickFixOption(
          id: '10',
          labelKey: 'quick_fix_time_10',
          labelFallback: '10 min',
          iconName: 'schedule_outlined',
        ),
      ],
      locations: [
        QuickFixOption(
          id: 'desk',
          labelKey: 'quick_fix_location_desk',
          labelFallback: 'Desk',
          iconName: 'desk_outlined',
        ),
        QuickFixOption(
          id: 'chair',
          labelKey: 'quick_fix_location_chair',
          labelFallback: 'Chair',
          iconName: 'chair_outlined',
        ),
        QuickFixOption(
          id: 'standing',
          labelKey: 'quick_fix_location_standing',
          labelFallback: 'Standing',
          iconName: 'accessibility_new_outlined',
        ),
        QuickFixOption(
          id: 'floor',
          labelKey: 'quick_fix_location_floor',
          labelFallback: 'Floor',
          iconName: 'crop_16_9_outlined',
        ),
        QuickFixOption(
          id: 'bedside',
          labelKey: 'quick_fix_location_bedside',
          labelFallback: 'Bedside',
          iconName: 'bed_outlined',
        ),
      ],
      energyOptions: [
        QuickFixOption(
          id: 'low',
          labelKey: 'quick_fix_energy_low',
          labelFallback: 'Low',
          iconName: 'battery_2_bar_rounded',
        ),
        QuickFixOption(
          id: 'medium',
          labelKey: 'quick_fix_energy_medium',
          labelFallback: 'Medium',
          iconName: 'battery_5_bar_rounded',
        ),
        QuickFixOption(
          id: 'high',
          labelKey: 'quick_fix_energy_high',
          labelFallback: 'High',
          iconName: 'battery_full_rounded',
        ),
      ],
      modes: [
        QuickFixOption(
          id: 'dad',
          labelKey: 'quick_fix_mode_dad',
          labelFallback: 'Dad Mode',
          iconName: 'family_restroom_outlined',
        ),
        QuickFixOption(
          id: 'night',
          labelKey: 'quick_fix_mode_night',
          labelFallback: 'Night Coder',
          iconName: 'dark_mode_outlined',
        ),
        QuickFixOption(
          id: 'focus',
          labelKey: 'quick_fix_mode_focus',
          labelFallback: 'Focus Mode',
          iconName: 'center_focus_strong_outlined',
        ),
        QuickFixOption(
          id: 'pain_relief',
          labelKey: 'quick_fix_mode_pain_relief',
          labelFallback: 'Pain Relief',
          iconName: 'healing_outlined',
        ),
      ],
      selectedProblemId: 'neck',
      selectedTimeId: '4',
      selectedLocationIds: ['desk'],
      selectedEnergyId: 'low',
      selectedModeIds: [],
      silentModeEnabled: true,
      primaryRecommendation: null,
      alternativeRecommendations: [],
      lastTrackedRecommendationId: null,
      hasUserInteracted: false,
    );
  }
}