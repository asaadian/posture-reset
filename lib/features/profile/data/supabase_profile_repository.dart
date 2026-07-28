// lib/features/profile/data/supabase_profile_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../domain/profile_models.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
Future<UserProfile> getOrCreateProfile(User user) async {
  final email = user.email?.trim();

  final existing = await _client
      .from('profiles')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();

  if (existing != null) {
    final row = Map<String, dynamic>.from(existing);
    final storedEmail = row['email']?.toString().trim();

    if ((email ?? '').isNotEmpty && storedEmail != email) {
      final updated = await _client
          .from('profiles')
          .update({
            'email': email,
          })
          .eq('user_id', user.id)
          .select()
          .single();

      return UserProfile.fromMap(Map<String, dynamic>.from(updated));
    }

    return UserProfile.fromMap(row);
  }

  final displayName = _defaultDisplayNameForUser(user);

  await _client.from('profiles').insert({
    'user_id': user.id,
    'email': email,
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
      'notifications_enabled': false,
    });

    final created = await _client
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .single();

    return UserPreferences.fromMap(Map<String, dynamic>.from(created));
  }

@override
Future<String> uploadAvatar({
  required String userId,
  required Uint8List bytes,
  required String extension,
  required String contentType,
}) async {
  final safeExtension = extension.toLowerCase().replaceAll('.', '').trim();
  final resolvedExtension = safeExtension.isEmpty ? 'jpg' : safeExtension;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final path = '$userId/avatar_$timestamp.$resolvedExtension';

  await _client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

  return _client.storage.from('avatars').getPublicUrl(path);
}
  @override
Future<UserProfile> updateProfile({
  required String userId,
  String? email,
  String? displayName,
  String? avatarUrl,
  bool? onboardingCompleted,
  bool clearDisplayName = false,
  bool clearAvatar = false,
}) async {
  final payload = <String, Object?>{};

  if (email != null) payload['email'] = email.trim();
  if (clearDisplayName) {
    payload['display_name'] = null;
  } else if (displayName != null) {
    payload['display_name'] = displayName.trim();
  }

  if (clearAvatar) {
    payload['avatar_url'] = null;
  } else if (avatarUrl != null) {
    payload['avatar_url'] = avatarUrl.trim();
  }

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
