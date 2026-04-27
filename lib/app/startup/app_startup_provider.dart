// lib/app/startup/app_startup_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_env.dart';
import '../../core/localization/app_locale_controller.dart';
import 'app_startup_state.dart';

final appStartupProvider =
    AsyncNotifierProvider<AppStartupController, AppStartupState>(
  AppStartupController.new,
);

class AppStartupController extends AsyncNotifier<AppStartupState> {
  static bool _supabaseInitialized = false;

  @override
  Future<AppStartupState> build() async {
    await _initializeApp();
    return const AppStartupState.ready();
  }

  Future<void> _initializeApp() async {
    await _initializeSupabaseIfNeeded();
    await ref.read(appLocaleControllerProvider.notifier).loadSavedLocale();
  }

  Future<void> _initializeSupabaseIfNeeded() async {
    if (_supabaseInitialized) {
      _debugPrintSupabaseConfig('already_initialized');
      return;
    }

    if (!AppEnv.hasSupabaseConfig) {
      throw Exception(
        'Supabase config is missing. Run the app with SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    _debugPrintSupabaseConfig('before_initialize');

    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );

    _supabaseInitialized = true;

    _debugPrintSupabaseConfig('after_initialize');
  }

  void _debugPrintSupabaseConfig(String phase) {
    final host = AppEnv.supabaseUrl.trim().isEmpty
        ? 'EMPTY_URL'
        : Uri.tryParse(AppEnv.supabaseUrl)?.host ?? AppEnv.supabaseUrl;

    final anonPreview = AppEnv.supabaseAnonKey.trim().isEmpty
        ? 'EMPTY_KEY'
        : AppEnv.supabaseAnonKey.length >= 8
            ? '${AppEnv.supabaseAnonKey.substring(0, 8)}...'
            : '${AppEnv.supabaseAnonKey}...';

    debugPrint(
      '[Startup][$phase] SUPABASE_URL_HOST=$host | SUPABASE_ANON_KEY=$anonPreview',
    );
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _initializeApp();
      return const AppStartupState.ready();
    });
  }
}