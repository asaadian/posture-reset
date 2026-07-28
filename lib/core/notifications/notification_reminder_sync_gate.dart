// lib/core/notifications/notification_reminder_sync_gate.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/profile/application/profile_providers.dart';
import 'notification_providers.dart';

class NotificationReminderSyncGate extends ConsumerStatefulWidget {
  const NotificationReminderSyncGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationReminderSyncGate> createState() =>
      _NotificationReminderSyncGateState();
}

class _NotificationReminderSyncGateState
    extends ConsumerState<NotificationReminderSyncGate>
    with WidgetsBindingObserver {
  bool _syncQueued = false;
  DateTime? _lastSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueSync(force: true);
      _queueDelayedSync(const Duration(seconds: 4));
      _queueDelayedSync(const Duration(seconds: 14));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _queueSync(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      _queueSync(force: true);
    });

    ref.listen(userPreferencesControllerProvider, (previous, next) {
      final before = previous?.maybeWhen(
        data: (value) => value?.notificationsEnabled,
        orElse: () => null,
      );
      final after = next.maybeWhen(
        data: (value) => value?.notificationsEnabled,
        orElse: () => null,
      );

      if (before == after && next.hasValue) return;
      _queueSync(force: true);
    });

    return widget.child;
  }

  void _queueDelayedSync(Duration delay) {
    unawaited(() async {
      await Future<void>.delayed(delay);
      if (!mounted) return;
      _queueSync(force: true);
    }());
  }

  void _queueSync({bool force = false}) {
    if (!mounted || _syncQueued) return;

    final now = DateTime.now();
    final last = _lastSyncAt;
    if (!force && last != null && now.difference(last) < const Duration(minutes: 5)) {
      return;
    }

    _syncQueued = true;

    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      try {
        await ref.read(notificationReminderSyncControllerProvider).syncForCurrentUser();
        _lastSyncAt = DateTime.now();
      } catch (error, stackTrace) {
        debugPrint('[Notifications] sync gate failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      } finally {
        _syncQueued = false;
      }
    }());
  }
}
