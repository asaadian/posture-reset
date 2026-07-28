// lib/features/auth/presentation/pages/auth_callback_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../application/auth_providers.dart';

class AuthCallbackPage extends ConsumerStatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  ConsumerState<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<AuthCallbackPage> {
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _fallbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _goToSafeDestination();
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _goToSafeDestination() {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    context.go(isAuthenticated ? '/app/dashboard' : '/auth');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    ref.listen(currentUserProvider, (previous, next) {
      if (next == null) return;
      if (!mounted) return;
      _fallbackTimer?.cancel();
      context.go('/app/dashboard');
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.get(
                      'auth_callback_title',
                      fallback: 'Finishing sign in...',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.get(
                      'auth_callback_subtitle',
                      fallback:
                          'Please wait while your account session is prepared.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
