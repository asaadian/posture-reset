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

final profileActionsControllerProvider = Provider<ProfileActionsController>((ref) {
  return ProfileActionsController(ref);
});

class ProfileActionsController {
  ProfileActionsController(this.ref);

  final Ref ref;

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  Future<UserProfile?> updateDisplayName(String value) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final trimmed = value.trim();

    final updated = await _repository.updateProfile(
      userId: user.id,
      displayName: trimmed.isEmpty ? null : trimmed,
      clearDisplayName: trimmed.isEmpty,
      email: user.email?.trim(),
    );

    ref.invalidate(currentUserProfileProvider);
    return updated;
  }

  Future<UserProfile?> uploadAvatar({
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final avatarUrl = await _repository.uploadAvatar(
      userId: user.id,
      bytes: bytes,
      extension: extension,
      contentType: contentType,
    );

    final updated = await _repository.updateProfile(
      userId: user.id,
      email: user.email?.trim(),
      avatarUrl: avatarUrl,
    );

    ref.invalidate(currentUserProfileProvider);
    return updated;
  }

  Future<UserProfile?> removeAvatar() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final updated = await _repository.updateProfile(
      userId: user.id,
      email: user.email?.trim(),
      clearAvatar: true,
    );

    ref.invalidate(currentUserProfileProvider);
    return updated;
  }
}

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
