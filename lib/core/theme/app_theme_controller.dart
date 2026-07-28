// lib/core/theme/app_theme_controller.dart


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_prefs.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  String get code {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  ThemeMode get materialThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromCode(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

final appThemeModeControllerProvider =
    NotifierProvider<AppThemeModeController, AppThemeMode>(
  AppThemeModeController.new,
);

class AppThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    Future<void>.microtask(_loadSavedThemeMode);
    return AppThemeMode.system;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state == mode) return;

    state = mode;
    await AppPrefs.setSavedThemeModeCode(mode.code);
  }

  Future<void> _loadSavedThemeMode() async {
    final savedCode = await AppPrefs.getSavedThemeModeCode();
    final savedMode = AppThemeMode.fromCode(savedCode);

    if (state != savedMode) {
      state = savedMode;
    }
  }
}