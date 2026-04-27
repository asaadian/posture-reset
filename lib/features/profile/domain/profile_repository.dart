// lib/features/profile/domain/profile_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_models.dart';

abstract class ProfileRepository {
  Future<UserProfile> getOrCreateProfile(User user);

  Future<UserPreferences> getOrCreatePreferences({
    required User user,
    required String fallbackLocale,
  });

  Future<UserProfile> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    bool? onboardingCompleted,
  });

  Future<UserPreferences> updatePreferences({
    required String userId,
    String? preferredLocale,
    int? preferredTimeMinutes,
    String? preferredEnergyCode,
    bool? preferredSilentMode,
    bool? notificationsEnabled,
    bool? audioEnabled,
    bool? hapticsEnabled,
    List<String>? defaultModeCodes,
  });
}