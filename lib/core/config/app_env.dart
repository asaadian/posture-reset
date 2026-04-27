// lib/core/config/app_env.dart

class AppEnv {
  const AppEnv._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String androidPackageName = String.fromEnvironment(
    'ANDROID_PACKAGE_NAME',
    defaultValue: 'com.weglabs.posturereset',
  );

  static const String coreAccessProductId = String.fromEnvironment(
    'CORE_ACCESS_PRODUCT_ID',
    defaultValue: 'core_access_lifetime',
  );

  static bool get hasSupabaseConfig {
    return supabaseUrl.trim().isNotEmpty &&
        supabaseAnonKey.trim().isNotEmpty;
  }

  static bool get hasBillingConfig {
    return androidPackageName.trim().isNotEmpty &&
        coreAccessProductId.trim().isNotEmpty;
  }
}