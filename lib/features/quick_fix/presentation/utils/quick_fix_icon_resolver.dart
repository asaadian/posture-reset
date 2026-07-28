import 'package:flutter/material.dart';

class QuickFixIconResolver {
  const QuickFixIconResolver._();

  static IconData resolve(String? iconName) {
    switch (iconName) {
      case 'accessibility_new_outlined':
        return Icons.accessibility_new_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'back_hand_outlined':
        return Icons.back_hand_outlined;
      case 'airline_seat_recline_normal_outlined':
        return Icons.airline_seat_recline_normal_outlined;
      case 'remove_red_eye_outlined':
        return Icons.remove_red_eye_outlined;
      case 'self_improvement_outlined':
        return Icons.self_improvement_outlined;
      case 'timelapse_outlined':
        return Icons.timelapse_outlined;
      case 'timer_outlined':
        return Icons.timer_outlined;
      case 'more_time_outlined':
        return Icons.more_time_outlined;
      case 'schedule_outlined':
        return Icons.schedule_outlined;
      case 'desk_outlined':
        return Icons.desk_outlined;
      case 'chair_outlined':
        return Icons.chair_outlined;
      case 'bed_outlined':
        return Icons.bed_outlined;
      case 'battery_2_bar_rounded':
        return Icons.battery_2_bar_rounded;
      case 'battery_5_bar_rounded':
        return Icons.battery_5_bar_rounded;
      case 'battery_full_rounded':
        return Icons.battery_full_rounded;
      case 'family_restroom_outlined':
        return Icons.family_restroom_outlined;
      case 'dark_mode_outlined':
        return Icons.dark_mode_outlined;
      case 'center_focus_strong_outlined':
        return Icons.center_focus_strong_outlined;
      case 'healing_outlined':
        return Icons.healing_outlined;
      case 'volume_off_outlined':
        return Icons.volume_off_outlined;
      case 'crop_square_outlined':
        return Icons.crop_square_outlined;
      case 'dry_cleaning_outlined':
        return Icons.dry_cleaning_outlined;
      case 'horizontal_rule_rounded':
        return Icons.horizontal_rule_rounded;
      case 'construction_rounded':
        return Icons.construction_rounded;
      case 'sports_baseball_outlined':
        return Icons.sports_baseball_outlined;
      case 'water_bottle_outlined':
        return Icons.water_drop_outlined;
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'accessibility_outlined':
        return Icons.accessibility_outlined;
      case 'crop_16_9_outlined':
        return Icons.crop_16_9_outlined;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'star_outline_rounded':
        return Icons.star_outline_rounded;
      case 'local_fire_department_outlined':
        return Icons.local_fire_department_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
