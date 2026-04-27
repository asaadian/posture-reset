// lib/app/startup/app_startup_state.dart
enum AppStartupStatus { loading, ready, failure }

class AppStartupState {
  const AppStartupState({required this.status, this.message});

  final AppStartupStatus status;
  final String? message;

  const AppStartupState.loading()
    : status = AppStartupStatus.loading,
      message = null;

  const AppStartupState.ready()
    : status = AppStartupStatus.ready,
      message = null;

  const AppStartupState.failure(String this.message)
    : status = AppStartupStatus.failure;
}
