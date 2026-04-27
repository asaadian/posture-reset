// lib/app/startup/app_startup_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/states/app_fullscreen_loading.dart';
import '../../shared/widgets/states/app_startup_error_view.dart';
import 'app_startup_provider.dart';

class AppStartupGate extends ConsumerWidget {
  const AppStartupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupState = ref.watch(appStartupProvider);

    return startupState.when(
      loading: () => const AppFullscreenLoading(),
      error: (error, stackTrace) {
        return AppStartupErrorView(
          message: error.toString(),
          onRetry: () => ref.read(appStartupProvider.notifier).retry(),
        );
      },
      data: (data) => child,
    );
  }
}
