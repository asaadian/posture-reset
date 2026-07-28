// lib/core/notifications/notification_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/profile/application/profile_providers.dart';
import '../supabase/supabase_providers.dart';
import 'local_notification_service.dart';
import 'notification_context_repository.dart';
import 'notification_history_repository.dart';
import 'notification_schedule_preferences.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService.instance;
});

final notificationContextRepositoryProvider =
    Provider<NotificationContextRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotificationContextRepository(client);
});

final notificationReminderSyncControllerProvider =
    Provider<NotificationReminderSyncController>((ref) {
  return NotificationReminderSyncController(ref);
});

class NotificationReminderSyncController {
  NotificationReminderSyncController(this._ref);

  final Ref _ref;

  Future<void> syncForCurrentUser() async {
    final user = _ref.read(currentUserProvider);
    final service = _ref.read(localNotificationServiceProvider);

    if (user == null) {
      debugPrint('[Notifications] sync skipped: no current user.');
      await service.cancelRecoveryReminders();
      return;
    }

    final prefs = await _ref.read(userPreferencesControllerProvider.future);
    if (prefs == null || !prefs.notificationsEnabled) {
      debugPrint('[Notifications] sync skipped: reminders disabled or prefs missing. user=${user.id}');
      await service.cancelRecoveryReminders();
      return;
    }

    try {
      final repository = _ref.read(notificationContextRepositoryProvider);
      final plan = await repository.buildPlanForUser(user.id);
      final reminderTime = await _ref.read(notificationReminderTimeProvider.future);

      final scheduledPlan = plan.copyWith(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        userId: user.id,
      );

      debugPrint('[Notifications] scheduling kind=${scheduledPlan.kind.name} time=${scheduledPlan.hour}:${scheduledPlan.minute.toString().padLeft(2, '0')} payload=${scheduledPlan.payload} user=${user.id}');

      await service.scheduleRecoveryReminder(scheduledPlan);

      _ref.invalidate(notificationHistoryItemsProvider(user.id));
      _ref.invalidate(notificationHistoryUnreadCountProvider(user.id));
    } catch (error, stackTrace) {
      debugPrint('[Notifications] sync failed, scheduling safe default: $error');
      debugPrintStack(stackTrace: stackTrace);
      await service.scheduleDailyRecoveryReminder(userId: user.id);
      _ref.invalidate(notificationHistoryItemsProvider(user.id));
      _ref.invalidate(notificationHistoryUnreadCountProvider(user.id));
    }
  }

  Future<void> cancelForCurrentUser() async {
    await _ref.read(localNotificationServiceProvider).cancelRecoveryReminders();
  }
}
