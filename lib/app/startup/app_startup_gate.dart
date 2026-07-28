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

    await Future.wait(futures);

    if (!mounted) return;

    final programs = await programsFuture;
    final sessions = await sessionsFuture;
    final images = <ImageProvider>[
      for (final program in programs.take(8))
        NetworkImage(
          'https://weglabs.com/data/desk-workout/covers/programs/${program.id}.webp',
        ),
      for (final session in sessions.take(16))
        NetworkImage(
          'https://weglabs.com/data/desk-workout/covers/sessions/${session.id}.webp',
        ),
    ];

    await Future.wait(
      images.map((image) async {
        try {
          await precacheImage(image, context);
        } catch (_) {
          // A missing remote image must not block the app indefinitely.
        }
      }),
    );
  }
}
