// lib/app/startup/initial_route_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../shared/widgets/states/app_fullscreen_loading.dart';

class InitialRoutePage extends ConsumerStatefulWidget {
  const InitialRoutePage({super.key});

  @override
  ConsumerState<InitialRoutePage> createState() => _InitialRoutePageState();
}

class _InitialRoutePageState extends ConsumerState<InitialRoutePage> {
  bool _navigationQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _queueInitialRouting());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateChangesProvider);

    ref.listen(currentUserProvider, (previous, next) {
      _queueInitialRouting();
    });

    return const AppFullscreenLoading();
  }

  void _queueInitialRouting() {
    if (_navigationQueued || !mounted) return;
    _navigationQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      _navigationQueued = false;
      _routeNow();
    });
  }

  void _routeNow() {
    if (!mounted) return;

    final riverpodUser = ref.read(currentUserProvider);
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final user = riverpodUser ?? supabaseUser;

    if (user == null) {
      context.go('/auth?mode=signin&redirect=/app/dashboard');
      return;
    }

    context.go('/app/dashboard');
  }
}
