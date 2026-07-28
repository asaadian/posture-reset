// lib/app/startup/auth_route_gate.dart

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/application/auth_providers.dart';

class AuthRouteGate extends ConsumerStatefulWidget {
  const AuthRouteGate({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AuthRouteGate> createState() => _AuthRouteGateState();
}

class _AuthRouteGateState extends ConsumerState<AuthRouteGate> {
  bool _redirectQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _queueRouteSync());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateChangesProvider);

    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      _queueRouteSync();
    });

    return widget.child;
  }

  void _queueRouteSync() {
    if (_redirectQueued || !mounted) return;
    _redirectQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      _redirectQueued = false;
      _syncRoute();
    });
  }

  void _syncRoute() {
    if (!mounted) return;

    final riverpodUser = ref.read(currentUserProvider);
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final user = riverpodUser ?? supabaseUser;

    final router = widget.router;
    final uri = router.routerDelegate.currentConfiguration.uri;
    final path = uri.path;

    debugPrint('[AuthRouteGate] path=$path user=${user?.id ?? 'null'}');

    final isStartup = path == '/startup';
    final isAuthFlow = path == '/auth' || path == '/auth/callback' || path == '/callback';
    final isAppRoute = path.startsWith('/app/');

    if (isStartup) return;

    if (user == null && isAppRoute) {
      final redirect = Uri.encodeComponent(uri.toString());
      router.go('/auth?mode=signin&redirect=$redirect');
      return;
    }

    if (user != null && isAuthFlow) {
      router.go('/app/dashboard');
    }
  }
}
