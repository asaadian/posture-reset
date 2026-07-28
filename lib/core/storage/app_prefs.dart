// lib/core/storage/app_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  const AppPrefs._();

  static const String localeCodeKey = 'app.locale_code';
  static const String themeModeKey = 'app.theme_mode';

  static Future<SharedPreferences> get instance async {
    return SharedPreferences.getInstance();
  }

  static Future<String?> getSavedLocaleCode() async {
    final prefs = await instance;
    return prefs.getString(localeCodeKey);
  }

  static Future<void> setSavedLocaleCode(String languageCode) async {
    final prefs = await instance;
    await prefs.setString(localeCodeKey, languageCode);
  }

  static Future<String?> getSavedThemeModeCode() async {
    final prefs = await instance;
    return prefs.getString(themeModeKey);
  }

  static Future<void> setSavedThemeModeCode(String code) async {
    final prefs = await instance;
    await prefs.setString(themeModeKey, code);
  }
}