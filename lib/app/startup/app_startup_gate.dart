import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/access/application/access_providers.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/profile/application/profile_providers.dart';
import '../../features/programs/application/recovery_program_providers.dart';
import '../../features/sessions/application/sessions_providers.dart';
import '../../shared/widgets/states/app_fullscreen_loading.dart';
import '../../shared/widgets/states/app_startup_error_view.dart';
import 'app_startup_provider.dart';

class AppStartupGate extends ConsumerStatefulWidget {
  const AppStartupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends ConsumerState<AppStartupGate> {
  Future<void>? _warmupFuture;
  String? _warmupUserId;

  @override
  Widget build(BuildContext context) {
    final startupState = ref.watch(appStartupProvider);

    return startupState.when(
      loading: () => const AppFullscreenLoading(),
      error: (error, stackTrace) => AppStartupErrorView(
        message: error.toString(),
        onRetry: () {
          _warmupFuture = null;
          ref.read(appStartupProvider.notifier).retry();
        },
      ),
      data: (_) {
        final authState = ref.watch(authStateChangesProvider);
        if (authState.isLoading) {
          return const AppFullscreenLoading();
        }

        final userId = ref.watch(currentUserProvider)?.id;
        if (_warmupFuture == null || _warmupUserId != userId) {
          _warmupUserId = userId;
          _warmupFuture = _warmup(context);
        }

        return FutureBuilder<void>(
          future: _warmupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const AppFullscreenLoading();
            }
            if (snapshot.hasError) {
              return AppStartupErrorView(
                message: snapshot.error.toString(),
                onRetry: () => setState(() => _warmupFuture = _warmup(context)),
              );
            }
            return widget.child;
          },
        );
      },
    );
  }

  Future<void> _warmup(BuildContext context) async {
    final minimumVisibleTime = Future<void>.delayed(
      const Duration(milliseconds: 550),
    );
    final user = ref.read(currentUserProvider);

    final programsFuture = ref.read(recoveryProgramSummariesProvider.future);
    final sessionsFuture = ref.read(sessionSummariesProvider.future);

    final futures = <Future<Object?>>[
      programsFuture,
      sessionsFuture,
    ];

    if (user != null) {
      futures.addAll([
        ref.read(currentUserProfileProvider.future),
        ref.read(accessSnapshotProvider.future),
        ref.read(activeRecoveryProgramDashboardProgressProvider.future),
        ref.read(savedSessionIdsProvider.future),
        ref.read(dashboardControllerProvider.future),
      ]);
    }

    // Each screen owns its data loading and retry state. Do not make global
    // navigation depend on a network request or on downloading cover images.
    unawaited(Future.wait(futures.map((future) async {
      try {
        await future.timeout(const Duration(seconds: 10));
      } catch (error) {
        debugPrint('[Startup] Optional warmup failed: $error');
      }
    })).then((_) {}));

    await minimumVisibleTime;
  }
}
