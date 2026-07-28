// lib/core/notifications/local_notification_service.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_context_repository.dart';
import 'notification_history_repository.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Required entry point for Android background notification responses.
  // Navigation is handled from the foreground isolate through
  // getNotificationAppLaunchDetails() and onDidReceiveNotificationResponse.
}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapPayloadController =
      StreamController<String>.broadcast();

  bool _initialized = false;
  bool _timeZoneReady = false;
  String? _initialLaunchPayload;

  static const int dailyRecoveryReminderId = 2001;
  static const int smartRecoveryReminderId = 2101;
  static const int testNotificationId = 2999;
  static const int scheduledTestNotificationId = 3001;

  static const String recoveryChannelId = 'recovery_reminders';
  static const String recoveryChannelName = 'Recovery reminders';
  static const String recoveryChannelDescription =
      'Personalized posture, program, and desk recovery reminders.';

  Stream<String> get tapPayloadStream => _tapPayloadController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _captureInitialLaunchPayload();

    _initialized = true;
  }

  Future<String?> consumeInitialLaunchPayload() async {
    await initialize();
    final payload = _initialLaunchPayload;
    _initialLaunchPayload = null;
    return payload;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final notificationGranted =
          await android?.requestNotificationsPermission() ?? true;

      if (!notificationGranted) {
        return false;
      }

      try {
        await android?.requestExactAlarmsPermission();
      } catch (error) {
        debugPrint('[Notifications] exact alarm permission request skipped: $error');
      }

      return true;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final darwin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await darwin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      final mac = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final macGranted = await mac?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return iosGranted ?? macGranted ?? false;
    }

    return true;
  }

  Future<void> scheduleRecoveryReminder(RecoveryNotificationPlan plan) async {
    await initialize();
    await _configureTimeZone();

    await _plugin.cancel(dailyRecoveryReminderId);
    await _plugin.cancel(smartRecoveryReminderId);

    final when = _nextInstanceOfTime(
      hour: plan.hour,
      minute: plan.minute,
      deferToday: plan.deferToday,
    );

    try {
      await _plugin.zonedSchedule(
        smartRecoveryReminderId,
        plan.title,
        plan.body,
        when,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: plan.payload,
      );
    } catch (error, stackTrace) {
      debugPrint('[Notifications] exact schedule failed, using inexact fallback: $error');
      debugPrintStack(stackTrace: stackTrace);

      await _plugin.zonedSchedule(
        smartRecoveryReminderId,
        plan.title,
        plan.body,
        when,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: plan.payload,
      );
    }

    await const NotificationHistoryRepository().recordScheduled(
      notificationId: smartRecoveryReminderId,
      plan: plan,
      scheduledFor: when,
    );

    await debugPrintPendingNotifications(source: 'scheduleRecoveryReminder');
  }

  Future<void> scheduleDailyRecoveryReminder({
    int hour = 18,
    int minute = 30,
    String? userId,
  }) async {
    await scheduleRecoveryReminder(
      RecoveryNotificationPlan(
        kind: RecoveryNotificationKind.dailyReset,
        title: 'Time for a quick reset',
        body: 'Take two minutes for your neck, back, or wrists.',
        hour: hour,
        minute: minute,
        payload: 'posture_reset://quick_fix',
        userId: userId,
      ),
    );
  }

  Future<void> cancelDailyRecoveryReminder() async {
    await cancelRecoveryReminders();
  }

  Future<void> cancelRecoveryReminders() async {
    await initialize();
    await _plugin.cancel(dailyRecoveryReminderId);
    await _plugin.cancel(smartRecoveryReminderId);
  }

  Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      testNotificationId,
      'Desk Workout reminder',
      'Notifications are active. Your next reminder will use your current recovery state.',
      _notificationDetails(),
      payload: 'posture_reset://settings/notifications/test',
    );
  }

  Future<void> scheduleTestNotificationInTwoMinutes() async {
    await initialize();
    await _configureTimeZone();

    await _plugin.cancel(scheduledTestNotificationId);

    final scheduledAt = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2));

    try {
      await _plugin.zonedSchedule(
        scheduledTestNotificationId,
        'Scheduled reminder test',
        'This notification was scheduled two minutes ago.',
        scheduledAt,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'posture_reset://settings/notifications/test',
      );
    } catch (error, stackTrace) {
      debugPrint('[Notifications] exact scheduled test failed, using inexact fallback: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _plugin.zonedSchedule(
        scheduledTestNotificationId,
        'Scheduled reminder test',
        'This notification was scheduled two minutes ago.',
        scheduledAt,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'posture_reset://settings/notifications/test',
      );
    }

    await debugPrintPendingNotifications(source: 'scheduleTestNotificationInTwoMinutes');
  }

  Future<void> scheduleTestInTwoMinutes() => scheduleTestNotificationInTwoMinutes();

  Future<void> scheduleDebugNotificationInTwoMinutes() =>
      scheduleTestNotificationInTwoMinutes();

  // Compatibility method used by SettingsPage from the schedule-diagnostic build.
  Future<void> scheduleDiagnosticTestNotification({
    Duration delay = const Duration(minutes: 2),
  }) async {
    await initialize();
    await _configureTimeZone();

    await _plugin.cancel(scheduledTestNotificationId);

    final scheduledAt = tz.TZDateTime.now(tz.local).add(delay);

    try {
      await _plugin.zonedSchedule(
        scheduledTestNotificationId,
        'Scheduled reminder test',
        'This was scheduled ${delay.inMinutes} minute(s) ago.',
        scheduledAt,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'posture_reset://settings/notifications/test',
      );
    } on PlatformException catch (error, stackTrace) {
      debugPrint('[Notifications] exact diagnostic test failed: ${error.code} ${error.message}');
      debugPrintStack(stackTrace: stackTrace);

      await _plugin.zonedSchedule(
        scheduledTestNotificationId,
        'Scheduled reminder test',
        'This was scheduled ${delay.inMinutes} minute(s) ago.',
        scheduledAt,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'posture_reset://settings/notifications/test',
      );
    }

    await debugPrintPendingNotifications(source: 'scheduleDiagnosticTestNotification');
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    await initialize();
    return _plugin.pendingNotificationRequests();
  }

  Future<List<String>> pendingNotificationDebugLines() async {
    final pending = await pendingNotificationRequests();
    if (pending.isEmpty) {
      return const ['No pending notifications.'];
    }

    return pending
        .map(
          (item) =>
              'id=${item.id} | title=${item.title ?? ''} | body=${item.body ?? ''} | payload=${item.payload ?? ''}',
        )
        .toList(growable: false);
  }

  Future<String> pendingNotificationDebugSummary() async {
    final lines = await pendingNotificationDebugLines();
    return lines.join('\n');
  }

  Future<void> debugPrintPendingNotifications({String source = 'debug'}) async {
    final lines = await pendingNotificationDebugLines();
    debugPrint('[Notifications] Pending from $source:');
    for (final line in lines) {
      debugPrint(line);
    }
  }

  Future<void> printPendingNotificationsFromSettings() =>
      debugPrintPendingNotifications(source: 'settings');

  Future<void> printPendingFromSettings() =>
      debugPrintPendingNotifications(source: 'settings');

  Future<void> debugPrintPendingFromSettings() =>
      debugPrintPendingNotifications(source: 'settings');

  Future<void> _captureInitialLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final didLaunch = details?.didNotificationLaunchApp ?? false;
      final payload = details?.notificationResponse?.payload?.trim();

      if (didLaunch && payload != null && payload.isNotEmpty) {
        _initialLaunchPayload = payload;
        await const NotificationHistoryRepository().markPayloadOpened(payload);
        debugPrint('[Notifications] captured initial launch payload: $payload');
      }
    } catch (error, stackTrace) {
      debugPrint('[Notifications] initial launch payload read failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload?.trim();
    if (payload == null || payload.isEmpty) return;

    debugPrint('[Notifications] tap payload: $payload');
    unawaited(const NotificationHistoryRepository().markPayloadOpened(payload));
    _tapPayloadController.add(payload);
  }

  Future<void> _configureTimeZone() async {
    if (_timeZoneReady) return;

    tz_data.initializeTimeZones();

    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    _timeZoneReady = true;
  }

  tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
    bool deferToday = false,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (deferToday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      recoveryChannelId,
      recoveryChannelName,
      channelDescription: recoveryChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );

    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
  }
}
