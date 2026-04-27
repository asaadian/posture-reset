// lib/core/localization/app_locale_controller.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_prefs.dart';
import '../supabase/supabase_providers.dart';

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends Notifier<Locale> {
  static const supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fa'),
  ];

  @override
  Locale build() {
    return _normalizeLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  Future<void> loadSavedLocale() async {
    final savedCode = await AppPrefs.getSavedLocaleCode();

    if (savedCode != null && savedCode.trim().isNotEmpty) {
      final savedLocale = _normalizeLocale(Locale(savedCode));
      if (savedLocale.languageCode != state.languageCode) {
        state = savedLocale;
      }
    }

    await _loadRemoteLocaleIfAvailable();
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalizeLocale(locale);
    state = normalized;

    await AppPrefs.setSavedLocaleCode(normalized.languageCode);
    await _saveRemoteLocaleIfAvailable(normalized.languageCode);
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  Future<void> _loadRemoteLocaleIfAvailable() async {
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) return;

      final row = await client
          .from('user_preferences')
          .select('preferred_locale')
          .eq('user_id', user.id)
          .maybeSingle();

      final remoteCode = row?['preferred_locale'] as String?;
      if (remoteCode == null || remoteCode.trim().isEmpty) return;

      final remoteLocale = _normalizeLocale(Locale(remoteCode));
      if (remoteLocale.languageCode != state.languageCode) {
        state = remoteLocale;
        await AppPrefs.setSavedLocaleCode(remoteLocale.languageCode);
      }
    } catch (_) {
      // non-blocking
    }
  }

  Future<void> _saveRemoteLocaleIfAvailable(String languageCode) async {
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) return;

      await client.from('user_preferences').upsert(
        {
          'user_id': user.id,
          'preferred_locale': languageCode,
        },
        onConflict: 'user_id',
      );
    } catch (_) {
      // non-blocking
    }
  }

  Locale _normalizeLocale(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }
}