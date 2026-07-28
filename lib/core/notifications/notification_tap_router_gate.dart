// lib/core/notifications/notification_tap_router_gate.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import 'notification_history_repository.dart';
import 'notification_payload_router.dart';
import 'notification_providers.dart';

class NotificationTapRouterGate extends ConsumerStatefulWidget {
  const NotificationTapRouterGate({
    super.key,
    required this.router,
    required this.navigatorKey,
    required this.child,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<NotificationTapRouterGate> createState() =>
      _NotificationTapRouterGateState();
}

class _NotificationTapRouterGateState
    extends ConsumerState<NotificationTapRouterGate> {
  StreamSubscription<String>? _subscription;
  String? _lastHandledPayload;
  DateTime? _lastHandledAt;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_attachNotificationTapHandling());
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _attachNotificationTapHandling() async {
    if (!mounted) return;

    final service = ref.read(localNotificationServiceProvider);
    await service.initialize();

    _subscription ??= service.tapPayloadStream.listen((payload) {
      unawaited(_handlePayload(payload, source: 'tap-stream'));
    });

    final launchPayload = await service.consumeInitialLaunchPayload();
    if (launchPayload != null && launchPayload.trim().isNotEmpty) {
      await _handlePayload(launchPayload, source: 'launch');
    }
  }

  Future<void> _handlePayload(String payload, {required String source}) async {
    final trimmed = payload.trim();
    if (trimmed.isEmpty || !mounted) return;

    final now = DateTime.now();
    final lastAt = _lastHandledAt;
    if (_lastHandledPayload == trimmed &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      return;
    }

    _lastHandledPayload = trimmed;
    _lastHandledAt = now;

    final target = NotificationPayloadRouteMapper.toAppRoute(trimmed);
    if (target == null) {
      debugPrint('[Notifications] unsupported payload from $source: $trimmed');
      return;
    }

    final userId = ref.read(currentUserProvider)?.id;
    ref.invalidate(notificationHistoryItemsProvider(userId));
    ref.invalidate(notificationHistoryUnreadCountProvider(userId));

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final navigatorReady = widget.navigatorKey.currentContext != null;
    if (!navigatorReady) {
      debugPrint('[Notifications] navigator not ready for payload: $trimmed');
      return;
    }

    debugPrint('[Notifications] routing from $source: $trimmed -> $target');
    widget.router.go(target);
  }
}
