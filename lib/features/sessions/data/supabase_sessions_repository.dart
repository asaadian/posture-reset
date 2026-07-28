// lib/features/sessions/data/supabase_sessions_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../access/domain/access_models.dart';
import '../domain/session_models.dart';
import '../domain/sessions_repository.dart';

class SupabaseSessionsRepository implements SessionsRepository {
  SupabaseSessionsRepository(this._client);

  final SupabaseClient _client;

  static const String _templatesTable = 'session_templates';
  static const String _stepsTable = 'session_steps';
  static const String _sessionVisualsBucket = 'session-visuals';

  @override
  Future<List<SessionSummary>> getSessionSummaries() async {
    final response = await _client
        .from(_templatesTable)
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    final rows = (response as List)
        .map(
          (item) => _SessionTemplateRow.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    return rows.map(_mapSummary).toList(growable: false);
  }

  @override
  Future<SessionDetail?> getSessionDetailById(String sessionId) async {
    final templateResponse = await _client
        .from(_templatesTable)
        .select()
        .eq('id', sessionId)
        .eq('is_active', true)
        .maybeSingle();

    if (templateResponse == null) {
      return null;
    }

    final stepsResponse = await _client
        .from(_stepsTable)
        .select()
        .eq('session_id', sessionId)
        .order('step_order', ascending: true);

    final template = _SessionTemplateRow.fromJson(
      Map<String, dynamic>.from(templateResponse as Map),
    );

    final steps = (stepsResponse as List)
        .map(
          (item) => _SessionStepRow.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    return _mapDetail(template, steps);
  }

  @override
  Future<List<SessionSummary>> getSessionsByIds(List<String> sessionIds) async {
    if (sessionIds.isEmpty) {
      return const [];
    }

    final response = await _client
        .from(_templatesTable)
        .select()
        .inFilter('id', sessionIds)
        .eq('is_active', true);

    final rows = (response as List)
        .map(
          (item) => _SessionTemplateRow.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    final summaries = rows.map(_mapSummary).toList(growable: true);
    final orderMap = {
      for (var i = 0; i < sessionIds.length; i++) sessionIds[i]: i,
    };

    summaries.sort((a, b) {
      final aOrder = orderMap[a.id] ?? 999999;
      final bOrder = orderMap[b.id] ?? 999999;
      return aOrder.compareTo(bOrder);
    });

    return summaries;
  }

  SessionSummary _mapSummary(_SessionTemplateRow row) {
    return SessionSummary(
      id: row.id,
      titleKey: row.titleKey,
      titleFallback: row.titleFallback,
      subtitleKey: row.subtitleKey,
      subtitleFallback: row.subtitleFallback,
      shortDescriptionKey: row.shortDescriptionKey,
      shortDescriptionFallback: row.shortDescriptionFallback,
      durationMinutes: row.durationMinutes,
      intensity: _toIntensity(row.intensity),
      equipmentLevel: sessionEquipmentLevelFromDb(row.equipmentLevel),
      requiredEquipment: row.requiredEquipment
          .map((e) => sessionStepEquipmentCodeFromDb(e))
          .toList(growable: false),
      goals: row.goals.map((e) => _toGoal(e.toString())).toList(growable: false),
      painTargets: row.painTargets
          .map(_toPainTarget)
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
      tags: row.tags
          .map(_toTag)
          .where((item) => item.code.isNotEmpty)
          .toList(growable: false),
      isSilentFriendly: row.isSilentFriendly,
      isBeginnerFriendly: row.isBeginnerFriendly,
      coverVariant: row.coverVariant,
      modeCompatibility: _toModeCompatibility(row.modeCompatibility),
      environmentCompatibility:
          _toEnvironmentCompatibility(row.environmentCompatibility),
      accessTier: row.accessTier,
      sessionLevelTag: sessionLevelTagFromDb(row.sessionLevelTag),
    );
  }

  SessionDetail _mapDetail(
    _SessionTemplateRow row,
    List<_SessionStepRow> stepRows,
  ) {
    final steps = stepRows
        .map(_mapStep)
        .toList(growable: true)
      ..sort((a, b) => a.order.compareTo(b.order));

    return SessionDetail(
      summary: _mapSummary(row),
      longDescriptionKey: row.longDescriptionKey,
      longDescriptionFallback: row.longDescriptionFallback,
      whyItHelpsKey: row.whyItHelpsKey,
      whyItHelpsFallback: row.whyItHelpsFallback,
      preparationNotes: row.preparationNotes
          .map((e) => e.toString())
          .toList(growable: false),
      steps: steps,
      cautions: row.cautions
          .map(_toCaution)
          .where((item) => item.code.isNotEmpty || item.messageFallback.isNotEmpty)
          .toList(growable: false),
      contraindications: row.contraindications
          .map(_toCaution)
          .where((item) => item.code.isNotEmpty || item.messageFallback.isNotEmpty)
          .toList(growable: false),
      recommendedUseCases: row.recommendedUseCases
          .map((e) => e.toString())
          .toList(growable: false),
      equipment: row.equipment
          .map((e) => e.toString())
          .toList(growable: false),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SessionStep _mapStep(_SessionStepRow row) {
    final legacyStepType = _toStepType(row.stepType);

    return SessionStep(
      id: row.id,
      sessionId: row.sessionId,
      order: row.stepOrder,
      titleKey: row.titleKey,
      titleFallback: row.titleFallback,
      instructionKey: row.instructionKey,
      instructionFallback: row.instructionFallback,
      durationSeconds: row.durationSeconds,
      stepType: legacyStepType,
      bodyTargetCodes: row.bodyTargetCodes
          .map((e) => _canonicalBodyCode(e.toString()))
          .toList(growable: false),
      isSkippable: row.isSkippable,
      breathingCueKey: row.breathingCueKey,
      breathingCueFallback: row.breathingCueFallback,
      safetyNoteKey: row.safetyNoteKey,
      safetyNoteFallback: row.safetyNoteFallback,
      visualType: _toVisualType(row.visualType),
      visualUrl: row.visualUrl ?? _publicUrlFromStoragePath(row.visualStoragePath),
      visualStoragePath: row.visualStoragePath,
      visualThumbnailUrl: row.visualThumbnailUrl ??
          _publicUrlFromStoragePath(row.visualThumbnailStoragePath),
      visualThumbnailStoragePath: row.visualThumbnailStoragePath,
      visualDurationSeconds: row.visualDurationSeconds,
      movementPattern: sessionStepMovementPatternFromDb(
        row.movementPattern,
        legacyStepType: legacyStepType,
      ),
      repetitionCount: _positiveIntOrNull(row.repetitionCount),
      holdSeconds: _positiveIntOrNull(row.holdSeconds),
      sideMode: sessionStepSideModeFromDb(row.sideMode),
      equipmentCode: sessionStepEquipmentCodeFromDb(row.equipmentCode),
      intensityLevel: sessionStepIntensityLevelFromDb(
        row.intensityLevel,
        legacyStepType: legacyStepType,
      ),
      coachingCueKey: row.coachingCueKey,
      coachingCueFallback: row.coachingCueFallback,
      stepPurpose: sessionStepPurposeFromDb(row.stepPurposeCode),
      stepPurposeLabel: row.stepPurposeLabel,
      stepGoal: row.stepGoal,
      whatToNotice: row.whatToNotice,
      avoidMistakes: row.avoidMistakes,
      coachTip: row.coachTip,
      playerFocusNote: row.playerFocusNote,
      isAssessmentStep: row.isAssessmentStep,
      isRetestStep: row.isRetestStep,
    );
  }

  String? _publicUrlFromStoragePath(String? rawPath) {
    final trimmed = rawPath?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final normalized = trimmed.startsWith('$_sessionVisualsBucket/')
        ? trimmed.substring(_sessionVisualsBucket.length + 1)
        : trimmed;

    return _client.storage.from(_sessionVisualsBucket).getPublicUrl(normalized);
  }

  String _canonicalBodyCode(String raw) {
    switch (raw.toLowerCase()) {
      case 'shoulder':
      case 'shoulders':
        return 'shoulders';
      case 'wrist':
      case 'wrists':
        return 'wrists';
      case 'back':
      case 'low_back':
      case 'lumbar':
      case 'lower_back':
        return 'lower_back';
      case 'eye':
      case 'eyes':
        return 'eyes';
      case 'hand':
      case 'hands':
        return 'hands';
      case 'finger':
      case 'fingers':
        return 'fingers';
      case 'forearm':
      case 'forearms':
        return 'forearms';
      case 'hip':
      case 'hips':
      case 'glute':
      case 'glutes':
      case 'hips_glutes':
        return 'hips_glutes';
      default:
        return raw.toLowerCase();
    }
  }

  SessionIntensity _toIntensity(String raw) {
    switch (raw) {
      case 'gentle':
        return SessionIntensity.gentle;
      case 'light':
        return SessionIntensity.light;
      case 'moderate':
        return SessionIntensity.moderate;
      case 'strong':
        return SessionIntensity.strong;
      default:
        return SessionIntensity.light;
    }
  }

  SessionGoal _toGoal(String raw) {
    switch (raw) {
      case 'pain_relief':
        return SessionGoal.painRelief;
      case 'posture_reset':
        return SessionGoal.postureReset;
      case 'focus_prep':
        return SessionGoal.focusPrep;
      case 'recovery':
        return SessionGoal.recovery;
      case 'mobility':
        return SessionGoal.mobility;
      case 'decompression':
        return SessionGoal.decompression;
      default:
        return SessionGoal.recovery;
    }
  }

  SessionStepType _toStepType(String raw) {
    switch (raw) {
      case 'setup':
        return SessionStepType.setup;
      case 'movement':
        return SessionStepType.movement;
      case 'hold':
        return SessionStepType.hold;
      case 'breath':
        return SessionStepType.breath;
      case 'transition':
        return SessionStepType.transition;
      case 'cooldown':
        return SessionStepType.cooldown;
      default:
        return SessionStepType.movement;
    }
  }

  SessionStepVisualType _toVisualType(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'video_url':
        return SessionStepVisualType.videoUrl;
      case 'video_storage':
        return SessionStepVisualType.videoStorage;
      case 'image_url':
        return SessionStepVisualType.imageUrl;
      case 'image_asset':
        return SessionStepVisualType.imageAsset;
      case 'animated_placeholder':
        return SessionStepVisualType.animatedPlaceholder;
      case 'none':
      case '':
      default:
        return SessionStepVisualType.none;
    }
  }

  SessionPainTarget _toPainTarget(Object? raw) {
    if (raw is Map) {
      final json = raw.cast<String, dynamic>();
      final code = _canonicalBodyCode(json['code']?.toString() ?? '');
      return SessionPainTarget(
        code: code,
        labelKey: json['label_key'] as String? ?? '',
        labelFallback: json['label_fallback'] as String? ?? _labelForCode(code),
        priority: _intOrDefault(json['priority'], 0),
      );
    }

    final code = _canonicalBodyCode(raw?.toString() ?? '');
    return SessionPainTarget(
      code: code,
      labelKey: code.isEmpty ? '' : 'session_body_${code}_label',
      labelFallback: _labelForCode(code),
      priority: 0,
    );
  }

  SessionTag _toTag(Object? raw) {
    if (raw is Map) {
      final json = raw.cast<String, dynamic>();
      final code = json['code']?.toString() ?? '';
      return SessionTag(
        code: code,
        labelKey: json['label_key'] as String? ?? '',
        labelFallback: json['label_fallback'] as String? ?? _labelForCode(code),
      );
    }

    final code = raw?.toString().trim() ?? '';
    return SessionTag(
      code: code,
      labelKey: code.isEmpty ? '' : 'session_tag_${code}_label',
      labelFallback: _labelForCode(code),
    );
  }

  SessionCaution _toCaution(Object? raw) {
    if (raw is Map) {
      final json = raw.cast<String, dynamic>();
      return SessionCaution(
        code: json['code']?.toString() ?? '',
        messageKey: json['message_key'] as String? ?? '',
        messageFallback: json['message_fallback'] as String? ?? '',
        severity: json['severity'] as String? ?? 'info',
      );
    }

    final value = raw?.toString().trim() ?? '';
    return SessionCaution(
      code: value,
      messageKey: '',
      messageFallback: _labelForCode(value),
      severity: 'info',
    );
  }

  String _labelForCode(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return '';

    switch (_canonicalBodyCode(normalized)) {
      case 'neck':
        return 'Neck';
      case 'shoulders':
        return 'Shoulders';
      case 'upper_back':
        return 'Upper Back';
      case 'lower_back':
        return 'Lower Back';
      case 'wrists':
        return 'Wrists';
      case 'forearms':
        return 'Forearms';
      case 'hands':
        return 'Hands';
      case 'fingers':
        return 'Fingers';
      case 'eyes':
        return 'Eyes';
      case 'hips_glutes':
        return 'Hips & Glutes';
      default:
        return normalized
            .replaceAll('_', ' ')
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }

  SessionModeCompatibility _toModeCompatibility(Map<String, dynamic> json) {
    return SessionModeCompatibility(
      dadMode: json['dad_mode'] as bool? ?? false,
      nightMode: json['night_mode'] as bool? ?? false,
      focusMode: json['focus_mode'] as bool? ?? false,
      painReliefMode: json['pain_relief_mode'] as bool? ?? false,
    );
  }

  SessionEnvironmentCompatibility _toEnvironmentCompatibility(
    Map<String, dynamic> json,
  ) {
    return SessionEnvironmentCompatibility(
      deskFriendly: json['desk_friendly'] as bool? ?? false,
      officeFriendly: json['office_friendly'] as bool? ?? false,
      homeFriendly: json['home_friendly'] as bool? ?? true,
      noMatRequired: json['no_mat_required'] as bool? ?? false,
      lowSpaceFriendly: json['low_space_friendly'] as bool? ?? false,
      quietFriendly: json['quiet_friendly'] as bool? ?? false,
    );
  }

  int _intOrDefault(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  int? _positiveIntOrNull(Object? value) {
    final parsed = _intOrDefault(value, 0);
    return parsed > 0 ? parsed : null;
  }
}

class _SessionTemplateRow {
  const _SessionTemplateRow({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.shortDescriptionKey,
    required this.shortDescriptionFallback,
    required this.longDescriptionKey,
    required this.longDescriptionFallback,
    required this.whyItHelpsKey,
    required this.whyItHelpsFallback,
    required this.durationMinutes,
    required this.intensity,
    required this.equipmentLevel,
    required this.requiredEquipment,
    required this.goals,
    required this.painTargets,
    required this.tags,
    required this.isSilentFriendly,
    required this.isBeginnerFriendly,
    required this.coverVariant,
    required this.accessTier,
    required this.sessionLevelTag,
    required this.modeCompatibility,
    required this.environmentCompatibility,
    required this.preparationNotes,
    required this.cautions,
    required this.contraindications,
    required this.recommendedUseCases,
    required this.equipment,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String shortDescriptionKey;
  final String shortDescriptionFallback;
  final String longDescriptionKey;
  final String longDescriptionFallback;
  final String whyItHelpsKey;
  final String whyItHelpsFallback;
  final int durationMinutes;
  final String intensity;
  final String equipmentLevel;
  final List<dynamic> requiredEquipment;
  final List<dynamic> goals;
  final List<dynamic> painTargets;
  final List<dynamic> tags;
  final bool isSilentFriendly;
  final bool isBeginnerFriendly;
  final String coverVariant;
  final AccessTier accessTier;
  final String? sessionLevelTag;
  final Map<String, dynamic> modeCompatibility;
  final Map<String, dynamic> environmentCompatibility;
  final List<dynamic> preparationNotes;
  final List<dynamic> cautions;
  final List<dynamic> contraindications;
  final List<dynamic> recommendedUseCases;
  final List<dynamic> equipment;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory _SessionTemplateRow.fromJson(Map<String, dynamic> json) {
    return _SessionTemplateRow(
      id: json['id'] as String,
      titleKey: json['title_key'] as String,
      titleFallback: json['title_fallback'] as String,
      subtitleKey: json['subtitle_key'] as String,
      subtitleFallback: json['subtitle_fallback'] as String,
      shortDescriptionKey: json['short_description_key'] as String,
      shortDescriptionFallback: json['short_description_fallback'] as String,
      longDescriptionKey: json['long_description_key'] as String,
      longDescriptionFallback: json['long_description_fallback'] as String,
      whyItHelpsKey: json['why_it_helps_key'] as String,
      whyItHelpsFallback: json['why_it_helps_fallback'] as String,
      durationMinutes: _readInt(json['duration_minutes'], fallback: 0),
      intensity: json['intensity'] as String? ?? 'light',
      equipmentLevel: json['equipment_level'] as String? ?? 'none',
      requiredEquipment: (json['required_equipment'] as List?) ?? const [],
      goals: (json['goals'] as List?) ?? const [],
      painTargets: (json['pain_targets'] as List?) ?? const [],
      tags: (json['tags'] as List?) ?? const [],
      isSilentFriendly: json['is_silent_friendly'] as bool? ?? false,
      isBeginnerFriendly: json['is_beginner_friendly'] as bool? ?? false,
      coverVariant: json['cover_variant'] as String? ?? 'default',
      accessTier: AccessTier.fromCode(json['access_tier'] as String?),
      sessionLevelTag: json['session_level_tag'] as String?,
      modeCompatibility:
          (json['mode_compatibility'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{},
      environmentCompatibility:
          (json['environment_compatibility'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{},
      preparationNotes: (json['preparation_notes'] as List?) ?? const [],
      cautions: (json['cautions'] as List?) ?? const [],
      contraindications: (json['contraindications'] as List?) ?? const [],
      recommendedUseCases:
          (json['recommended_use_cases'] as List?) ?? const [],
      equipment: (json['equipment'] as List?) ?? const [],
      createdAt: _readDateTime(json['created_at']),
      updatedAt: _readDateTime(json['updated_at']),
    );
  }
}

class _SessionStepRow {
  const _SessionStepRow({
    required this.id,
    required this.sessionId,
    required this.stepOrder,
    required this.titleKey,
    required this.titleFallback,
    required this.instructionKey,
    required this.instructionFallback,
    required this.durationSeconds,
    required this.stepType,
    required this.bodyTargetCodes,
    required this.isSkippable,
    this.breathingCueKey,
    this.breathingCueFallback,
    this.safetyNoteKey,
    this.safetyNoteFallback,
    this.visualType,
    this.visualUrl,
    this.visualStoragePath,
    this.visualThumbnailUrl,
    this.visualThumbnailStoragePath,
    this.visualDurationSeconds,
    this.movementPattern,
    this.repetitionCount,
    this.holdSeconds,
    this.sideMode,
    this.equipmentCode,
    this.intensityLevel,
    this.coachingCueKey,
    this.coachingCueFallback,
    this.stepPurposeCode,
    this.stepPurposeLabel,
    this.stepGoal,
    this.whatToNotice,
    this.avoidMistakes = const <String>[],
    this.coachTip,
    this.playerFocusNote,
    this.isAssessmentStep = false,
    this.isRetestStep = false,
  });

  final String id;
  final String sessionId;
  final int stepOrder;
  final String titleKey;
  final String titleFallback;
  final String instructionKey;
  final String instructionFallback;
  final int durationSeconds;
  final String stepType;
  final List<dynamic> bodyTargetCodes;
  final bool isSkippable;
  final String? breathingCueKey;
  final String? breathingCueFallback;
  final String? safetyNoteKey;
  final String? safetyNoteFallback;
  final String? visualType;
  final String? visualUrl;
  final String? visualStoragePath;
  final String? visualThumbnailUrl;
  final String? visualThumbnailStoragePath;
  final int? visualDurationSeconds;

  /// Phase 16 therapeutic dose metadata.
  final String? movementPattern;
  final Object? repetitionCount;
  final Object? holdSeconds;
  final String? sideMode;
  final String? equipmentCode;
  final String? intensityLevel;
  final String? coachingCueKey;
  final String? coachingCueFallback;

  /// Player guidance metadata added after the Supabase step-purpose migration.
  final String? stepPurposeCode;
  final String? stepPurposeLabel;
  final String? stepGoal;
  final String? whatToNotice;
  final List<String> avoidMistakes;
  final String? coachTip;
  final String? playerFocusNote;
  final bool isAssessmentStep;
  final bool isRetestStep;

  factory _SessionStepRow.fromJson(Map<String, dynamic> json) {
    return _SessionStepRow(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      stepOrder: _readInt(json['step_order'], fallback: 0),
      titleKey: json['title_key'] as String,
      titleFallback: json['title_fallback'] as String,
      instructionKey: json['instruction_key'] as String,
      instructionFallback: json['instruction_fallback'] as String,
      durationSeconds: _readInt(json['duration_seconds'], fallback: 30),
      stepType: json['step_type'] as String? ?? 'movement',
      bodyTargetCodes: (json['body_target_codes'] as List?) ?? const [],
      isSkippable: json['is_skippable'] as bool? ?? true,
      breathingCueKey: json['breathing_cue_key'] as String?,
      breathingCueFallback: json['breathing_cue_fallback'] as String?,
      safetyNoteKey: json['safety_note_key'] as String?,
      safetyNoteFallback: json['safety_note_fallback'] as String?,
      visualType: json['visual_type'] as String?,
      visualUrl: json['visual_url'] as String?,
      visualStoragePath: json['visual_storage_path'] as String?,
      visualThumbnailUrl: json['visual_thumbnail_url'] as String?,
      visualThumbnailStoragePath:
          json['visual_thumbnail_storage_path'] as String?,
      visualDurationSeconds:
          _readNullableInt(json['visual_duration_seconds']),

      // New nullable columns added in Phase 16.1.
      movementPattern: json['movement_pattern'] as String?,
      repetitionCount: json['repetition_count'],
      holdSeconds: json['hold_seconds'],
      sideMode: json['side_mode'] as String?,
      equipmentCode: json['equipment_code'] as String?,
      intensityLevel: json['intensity_level'] as String?,
      coachingCueKey: json['coaching_cue_key'] as String?,
      coachingCueFallback: json['coaching_cue_fallback'] as String?,

      // Player guidance metadata. All fields are optional for backward
      // compatibility with rows that have not been enriched yet.
      stepPurposeCode: json['step_purpose_code'] as String?,
      stepPurposeLabel: json['step_purpose_label'] as String?,
      stepGoal: json['step_goal'] as String?,
      whatToNotice: json['what_to_notice'] as String?,
      avoidMistakes: _readStringList(json['avoid_mistakes']),
      coachTip: json['coach_tip'] as String?,
      playerFocusNote: json['player_focus_note'] as String?,
      isAssessmentStep: json['is_assessment_step'] as bool? ?? false,
      isRetestStep: json['is_retest_step'] as bool? ?? false,
    );
  }
}

List<String> _readStringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  if (value is String && value.trim().isNotEmpty) {
    return <String>[value.trim()];
  }

  return const <String>[];
}

int _readInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  final parsed = _readInt(value, fallback: 0);
  return parsed > 0 ? parsed : null;
}

DateTime _readDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.parse(value).toUtc();
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
