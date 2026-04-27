// lib/features/profile/data/supabase_profile_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile_models.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfile> getOrCreateProfile(User user) async {
    final existing = await _client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return UserProfile.fromMap(Map<String, dynamic>.from(existing));
    }

    final displayName = _defaultDisplayNameForUser(user);

    await _client.from('profiles').insert({
      'user_id': user.id,
      'display_name': displayName,
    });

    final created = await _client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .single();

    return UserProfile.fromMap(Map<String, dynamic>.from(created));
  }

  @override
  Future<UserPreferences> getOrCreatePreferences({
    required User user,
    required String fallbackLocale,
  }) async {
    final existing = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return UserPreferences.fromMap(Map<String, dynamic>.from(existing));
    }

    await _client.from('user_preferences').insert({
      'user_id': user.id,
      'preferred_locale': fallbackLocale,
    });

    final created = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .single();

    return UserPreferences.fromMap(Map<String, dynamic>.from(created));
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    bool? onboardingCompleted,
  }) async {
    final payload = <String, Object?>{};
    if (displayName != null) payload['display_name'] = displayName;
    if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
    if (onboardingCompleted != null) {
      payload['onboarding_completed'] = onboardingCompleted;
    }

    if (payload.isEmpty) {
      final row = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();
      return UserProfile.fromMap(Map<String, dynamic>.from(row));
    }

    final row = await _client
        .from('profiles')
        .update(payload)
        .eq('user_id', userId)
        .select()
        .single();

    return UserProfile.fromMap(Map<String, dynamic>.from(row));
  }

  @override
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
  }) async {
    final payload = <String, Object?>{};
    if (preferredLocale != null) payload['preferred_locale'] = preferredLocale;
    if (preferredTimeMinutes != null) {
      payload['preferred_time_minutes'] = preferredTimeMinutes;
    }
    if (preferredEnergyCode != null) {
      payload['preferred_energy_code'] = preferredEnergyCode;
    }
    if (preferredSilentMode != null) {
      payload['preferred_silent_mode'] = preferredSilentMode;
    }
    if (notificationsEnabled != null) {
      payload['notifications_enabled'] = notificationsEnabled;
    }
    if (audioEnabled != null) payload['audio_enabled'] = audioEnabled;
    if (hapticsEnabled != null) {
      payload['haptics_enabled'] = hapticsEnabled;
    }
    if (defaultModeCodes != null) {
      payload['default_mode_codes'] = _normalizedCodes(defaultModeCodes);
    }

    if (payload.isEmpty) {
      final row = await _client
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();
      return UserPreferences.fromMap(Map<String, dynamic>.from(row));
    }

    final row = await _client
        .from('user_preferences')
        .update(payload)
        .eq('user_id', userId)
        .select()
        .single();

    return UserPreferences.fromMap(Map<String, dynamic>.from(row));
  }

  String? _defaultDisplayNameForUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    final candidates = <String?>[
      metadata['full_name']?.toString(),
      metadata['name']?.toString(),
      metadata['display_name']?.toString(),
      _emailLocalPart(user.email),
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  String? _emailLocalPart(String? email) {
    if (email == null || !email.contains('@')) return null;
    return email.split('@').first.trim();
  }

  List<String> _normalizedCodes(List<String> values) {
    final result = values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return result;
  }
}