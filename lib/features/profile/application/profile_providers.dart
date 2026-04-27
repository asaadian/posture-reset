// lib/features/profile/application/profile_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/profile_models.dart';
import '../domain/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(client);
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.getOrCreateProfile(user);
  } catch (error, stackTrace) {
    debugPrint('currentUserProfileProvider failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
});

final userPreferencesControllerProvider =
    AsyncNotifierProvider<UserPreferencesController, UserPreferences?>(
  UserPreferencesController.new,
);

class UserPreferencesController extends AsyncNotifier<UserPreferences?> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<UserPreferences?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    try {
      final locale = ref.read(appLocaleControllerProvider).languageCode;

      return _repository.getOrCreatePreferences(
        user: user,
        fallbackLocale: locale,
      );
    } catch (error, stackTrace) {
      debugPrint('UserPreferencesController.build failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider);
      if (user == null) return null;

      final locale = ref.read(appLocaleControllerProvider).languageCode;

      return _repository.getOrCreatePreferences(
        user: user,
        fallbackLocale: locale,
      );
    });
  }

  Future<void> setPreferredLocale(String languageCode) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        preferredLocale: languageCode,
      );
    });
  }

  Future<void> setPreferredSilentMode(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        preferredSilentMode: value,
      );
    });
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        notificationsEnabled: value,
      );
    });
  }

  Future<void> setAudioEnabled(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        audioEnabled: value,
      );
    });
  }

  Future<void> setHapticsEnabled(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        hapticsEnabled: value,
      );
    });
  }

  Future<void> toggleDefaultMode(String modeCode) async {
    final current = state.value;
    if (current == null) return;

    final nextModes = [...current.defaultModeCodes];
    if (nextModes.contains(modeCode)) {
      nextModes.remove(modeCode);
    } else {
      nextModes.add(modeCode);
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.updatePreferences(
        userId: current.userId,
        defaultModeCodes: nextModes,
      );
    });
  }
}