// lib/features/profile/domain/profile_models.dart

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      onboardingCompleted: (map['onboarding_completed'] as bool?) ?? false,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }
}

class UserPreferences {
  const UserPreferences({
    required this.userId,
    required this.preferredLocale,
    required this.preferredTimeMinutes,
    required this.preferredEnergyCode,
    required this.preferredSilentMode,
    required this.notificationsEnabled,
    required this.audioEnabled,
    required this.hapticsEnabled,
    required this.defaultModeCodes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String preferredLocale;
  final int? preferredTimeMinutes;
  final String? preferredEnergyCode;
  final bool preferredSilentMode;
  final bool notificationsEnabled;
  final bool audioEnabled;
  final bool hapticsEnabled;
  final List<String> defaultModeCodes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['user_id'] as String,
      preferredLocale: (map['preferred_locale'] as String?) ?? 'en',
      preferredTimeMinutes: map['preferred_time_minutes'] as int?,
      preferredEnergyCode: map['preferred_energy_code'] as String?,
      preferredSilentMode: (map['preferred_silent_mode'] as bool?) ?? true,
      notificationsEnabled: (map['notifications_enabled'] as bool?) ?? true,
      audioEnabled: (map['audio_enabled'] as bool?) ?? true,
      hapticsEnabled: (map['haptics_enabled'] as bool?) ?? true,
      defaultModeCodes: ((map['default_mode_codes'] as List?) ?? const [])
          .map((item) => item.toString())
          .toList(),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  UserPreferences copyWith({
    String? preferredLocale,
    int? preferredTimeMinutes,
    String? preferredEnergyCode,
    bool? preferredSilentMode,
    bool? notificationsEnabled,
    bool? audioEnabled,
    bool? hapticsEnabled,
    List<String>? defaultModeCodes,
  }) {
    return UserPreferences(
      userId: userId,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      preferredTimeMinutes: preferredTimeMinutes ?? this.preferredTimeMinutes,
      preferredEnergyCode: preferredEnergyCode ?? this.preferredEnergyCode,
      preferredSilentMode: preferredSilentMode ?? this.preferredSilentMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      defaultModeCodes: defaultModeCodes ?? this.defaultModeCodes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value.toUtc();
  if (value is String) {
    return DateTime.tryParse(value)?.toUtc() ?? DateTime.now().toUtc();
  }
  return DateTime.now().toUtc();
}