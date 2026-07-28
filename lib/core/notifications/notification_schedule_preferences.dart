// lib/core/notifications/notification_schedule_preferences.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationReminderTime {
  morning,
  afternoon,
  evening;

  String get code {
    switch (this) {
      case NotificationReminderTime.morning:
        return 'morning';
      case NotificationReminderTime.afternoon:
        return 'afternoon';
      case NotificationReminderTime.evening:
        return 'evening';
    }
  }

  int get hour {
    switch (this) {
      case NotificationReminderTime.morning:
        return 9;
      case NotificationReminderTime.afternoon:
        return 14;
      case NotificationReminderTime.evening:
        return 18;
    }
  }

  int get minute {
    switch (this) {
      case NotificationReminderTime.morning:
        return 30;
      case NotificationReminderTime.afternoon:
        return 30;
      case NotificationReminderTime.evening:
        return 30;
    }
  }

  String get fallbackLabel {
    switch (this) {
      case NotificationReminderTime.morning:
        return 'Morning';
      case NotificationReminderTime.afternoon:
        return 'Afternoon';
      case NotificationReminderTime.evening:
        return 'Evening';
    }
  }

  String get fallbackTimeLabel {
    switch (this) {
      case NotificationReminderTime.morning:
        return '09:30';
      case NotificationReminderTime.afternoon:
        return '14:30';
      case NotificationReminderTime.evening:
        return '18:30';
    }
  }

  static NotificationReminderTime fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'morning':
        return NotificationReminderTime.morning;
      case 'afternoon':
        return NotificationReminderTime.afternoon;
      case 'evening':
      default:
        return NotificationReminderTime.evening;
    }
  }
}

class NotificationSchedulePreferencesStore {
  const NotificationSchedulePreferencesStore();

  static const String _reminderTimeKey = 'notifications.reminder_time.v1';

  Future<NotificationReminderTime> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationReminderTime.fromCode(prefs.getString(_reminderTimeKey));
  }

  Future<void> setReminderTime(NotificationReminderTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, value.code);
  }
}

final notificationSchedulePreferencesStoreProvider =
    Provider<NotificationSchedulePreferencesStore>((ref) {
  return const NotificationSchedulePreferencesStore();
});

final notificationReminderTimeProvider =
    FutureProvider<NotificationReminderTime>((ref) async {
  final store = ref.watch(notificationSchedulePreferencesStoreProvider);
  return store.getReminderTime();
});
