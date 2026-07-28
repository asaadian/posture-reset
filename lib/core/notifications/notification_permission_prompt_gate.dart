// lib/core/notifications/notification_permission_prompt_gate.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/profile/application/profile_providers.dart';
import '../localization/app_text.dart';
import 'notification_providers.dart';

class NotificationPermissionPromptGate extends ConsumerStatefulWidget {
  const NotificationPermissionPromptGate({
    super.key,
    required this.router,
    required this.navigatorKey,
    required this.child,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<NotificationPermissionPromptGate> createState() =>
      _NotificationPermissionPromptGateState();
}

class _NotificationPermissionPromptGateState
    extends ConsumerState<NotificationPermissionPromptGate> {
  static const String _askedKeyPrefix = 'notifications.permission_prompt_asked_v4.';
  bool _dialogOpen = false;
  String? _lastPromptedUserId;

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next == null) return;
      if (previous?.id == next.id && _lastPromptedUserId == next.id) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_maybeAskForNotifications(userId: next.id));
      });
    });

    return widget.child;
  }

  Future<void> _maybeAskForNotifications({required String userId}) async {
    if (_dialogOpen || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.id != userId) return;

    var path = widget.router.routerDelegate.currentConfiguration.uri.path;
    if (path == '/auth' || path == '/auth/callback' || path == '/callback' || path == '/startup') {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      path = widget.router.routerDelegate.currentConfiguration.uri.path;
    }

    final localPrefs = await SharedPreferences.getInstance();
    final askedKey = '$_askedKeyPrefix$userId';
    final alreadyAsked = localPrefs.getBool(askedKey) ?? false;
    if (alreadyAsked) return;

    final userPrefs = await ref.read(userPreferencesControllerProvider.future);
    if (!mounted) return;
    if (userPrefs == null) return;

    if (userPrefs.notificationsEnabled) {
      await ref
          .read(userPreferencesControllerProvider.notifier)
          .setNotificationsEnabled(false);
      await ref.read(notificationReminderSyncControllerProvider).cancelForCurrentUser();
    }

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    _lastPromptedUserId = userId;
    await _showPrompt(localPrefs: localPrefs, askedKey: askedKey);
  }

  Future<void> _showPrompt({
    required SharedPreferences localPrefs,
    required String askedKey,
  }) async {
    if (_dialogOpen || !mounted) return;

    final dialogContext = widget.navigatorKey.currentContext;
    if (dialogContext == null) {
      debugPrint('[NotificationPrompt] Navigator context not ready.');
      return;
    }

    _dialogOpen = true;

    final enable = await showDialog<bool>(
      context: dialogContext,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final t = AppText.of(context);

        return AlertDialog(
          icon: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
            ),
            child: Icon(Icons.notifications_active_rounded, color: colors.onPrimary),
          ),
          title: Text(
            t.get(
              'notification_permission_prompt_title',
              fallback: 'Enable recovery reminders?',
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            t.get(
              'notification_permission_prompt_body',
              fallback: 'Get one gentle daily reminder for a quick posture reset.',
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.get('common_not_now', fallback: 'Not now')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.notifications_rounded),
              label: Text(t.get('notification_enable_cta', fallback: 'Enable')),
            ),
          ],
        );
      },
    );

    await localPrefs.setBool(askedKey, true);

    if (enable == true && mounted) {
      final service = ref.read(localNotificationServiceProvider);
      final granted = await service.requestPermissions();
      if (granted) {
        await ref
            .read(userPreferencesControllerProvider.notifier)
            .setNotificationsEnabled(true);
        await ref
            .read(notificationReminderSyncControllerProvider)
            .syncForCurrentUser();
      } else {
        await ref
            .read(userPreferencesControllerProvider.notifier)
            .setNotificationsEnabled(false);
      }
    }

    _dialogOpen = false;
  }
}
