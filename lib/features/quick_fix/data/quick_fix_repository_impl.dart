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
          id: 'shoulders',
          labelKey: 'quick_fix_problem_shoulder',
          labelFallback: 'Shoulder Tightness',
          iconName: 'fitness_center_outlined',
        ),
        QuickFixOption(
          id: 'upper_back',
          labelKey: 'quick_fix_problem_upper_back',
          labelFallback: 'Upper Back',
          iconName: 'accessibility_outlined',
        ),
        QuickFixOption(
          id: 'lower_back',
          labelKey: 'quick_fix_problem_back',
          labelFallback: 'Lower Back',
          iconName: 'airline_seat_recline_normal_outlined',
        ),
        QuickFixOption(
          id: 'hips_glutes',
          labelKey: 'quick_fix_problem_hips_glutes',
          labelFallback: 'Hips & Glutes',
          iconName: 'accessibility_new_outlined',
        ),
        QuickFixOption(
          id: 'forearms',
          labelKey: 'quick_fix_problem_forearms',
          labelFallback: 'Forearms',
          iconName: 'fitness_center_outlined',
        ),
        QuickFixOption(
          id: 'wrists',
          labelKey: 'quick_fix_problem_wrist',
          labelFallback: 'Wrist Pain',
          iconName: 'back_hand_outlined',
        ),
        QuickFixOption(
          id: 'hands',
          labelKey: 'quick_fix_problem_hands',
          labelFallback: 'Hands & Fingers',
          iconName: 'back_hand_outlined',
        ),
      ],
      equipmentOptions: [
        QuickFixOption(
          id: 'none',
          labelKey: 'quick_fix_equipment_none',
          labelFallback: 'No extra equipment',
          iconName: 'check_circle_outline_rounded',
        ),
        QuickFixOption(
          id: 'towel',
          labelKey: 'quick_fix_equipment_towel',
          labelFallback: 'Towel',
          iconName: 'dry_cleaning_outlined',
        ),
        QuickFixOption(
          id: 'long_band',
          labelKey: 'quick_fix_equipment_long_band',
          labelFallback: 'Resistance band',
          iconName: 'fitness_center_outlined',
        ),
        QuickFixOption(
          id: 'mini_band',
          labelKey: 'quick_fix_equipment_mini_band',
          labelFallback: 'Mini band',
          iconName: 'fitness_center_outlined',
        ),
        QuickFixOption(
          id: 'foam_roller',
          labelKey: 'quick_fix_equipment_foam_roller',
          labelFallback: 'Foam roller',
          iconName: 'horizontal_rule_rounded',
        ),
        QuickFixOption(
          id: 'massage_ball',
          labelKey: 'quick_fix_equipment_massage_ball',
          labelFallback: 'Massage ball',
          iconName: 'sports_baseball_outlined',
        ),
        QuickFixOption(
          id: 'soft_ball',
          labelKey: 'quick_fix_equipment_soft_ball',
          labelFallback: 'Soft ball',
          iconName: 'sports_baseball_outlined',
        ),
        QuickFixOption(
          id: 'water_bottle',
          labelKey: 'quick_fix_equipment_water_bottle',
          labelFallback: 'Water bottle',
          iconName: 'water_bottle_outlined',
        ),
        QuickFixOption(
          id: 'dowel',
          labelKey: 'quick_fix_equipment_dowel',
          labelFallback: 'Dowel / broomstick',
          iconName: 'horizontal_rule_rounded',
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
      selectedEquipmentIds: ['none'],
      selectedEnergyId: 'medium',
      selectedModeIds: [],
      silentModeEnabled: false,
      primaryRecommendation: null,
      alternativeRecommendations: [],
      lastTrackedRecommendationId: null,
      hasUserInteracted: false,
      recommendationRevealCount: 0,
    );
  }
}
