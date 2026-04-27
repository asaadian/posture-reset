// lib/features/sessions/data/supabase_sessions_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/session_models.dart';
import '../domain/sessions_repository.dart';
import '../../access/domain/access_models.dart';

class SupabaseSessionsRepository implements SessionsRepository {
  SupabaseSessionsRepository(this._client);

  final SupabaseClient _client;

  static const String _templatesTable = 'session_templates';
  static const String _stepsTable = 'session_steps';

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
      goals: row.goals.map((e) => _toGoal(e.toString())).toList(growable: false),
      painTargets: row.painTargets
          .map((e) => _toPainTarget((e as Map).cast<String, dynamic>()))
          .toList(growable: false),
      tags: row.tags
          .map((e) => _toTag((e as Map).cast<String, dynamic>()))
          .toList(growable: false),
      isSilentFriendly: row.isSilentFriendly,
      isBeginnerFriendly: row.isBeginnerFriendly,
      coverVariant: row.coverVariant,
      modeCompatibility: _toModeCompatibility(row.modeCompatibility),
      environmentCompatibility:
          _toEnvironmentCompatibility(row.environmentCompatibility),
      accessTier: row.accessTier,
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
          .map((e) => _toCaution((e as Map).cast<String, dynamic>()))
          .toList(growable: false),
      contraindications: row.contraindications
          .map((e) => _toCaution((e as Map).cast<String, dynamic>()))
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
    return SessionStep(
      id: row.id,
      sessionId: row.sessionId,
      order: row.stepOrder,
      titleKey: row.titleKey,
      titleFallback: row.titleFallback,
      instructionKey: row.instructionKey,
      instructionFallback: row.instructionFallback,
      durationSeconds: row.durationSeconds,
      stepType: _toStepType(row.stepType),
      bodyTargetCodes:
          row.bodyTargetCodes.map((e) => e.toString()).toList(growable: false),
      isSkippable: row.isSkippable,
      breathingCueKey: row.breathingCueKey,
      breathingCueFallback: row.breathingCueFallback,
      safetyNoteKey: row.safetyNoteKey,
      safetyNoteFallback: row.safetyNoteFallback,
    );
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

  SessionPainTarget _toPainTarget(Map<String, dynamic> json) {
    return SessionPainTarget(
      code: json['code'] as String? ?? '',
      labelKey: json['label_key'] as String? ?? '',
      labelFallback: json['label_fallback'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
    );
  }

  SessionTag _toTag(Map<String, dynamic> json) {
    return SessionTag(
      code: json['code'] as String? ?? '',
      labelKey: json['label_key'] as String? ?? '',
      labelFallback: json['label_fallback'] as String? ?? '',
    );
  }

  SessionCaution _toCaution(Map<String, dynamic> json) {
    return SessionCaution(
      code: json['code'] as String? ?? '',
      messageKey: json['message_key'] as String? ?? '',
      messageFallback: json['message_fallback'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
    );
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
    required this.goals,
    required this.painTargets,
    required this.tags,
    required this.isSilentFriendly,
    required this.isBeginnerFriendly,
    required this.coverVariant,
    required this.accessTier,
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
  final List<dynamic> goals;
  final List<dynamic> painTargets;
  final List<dynamic> tags;
  final bool isSilentFriendly;
  final bool isBeginnerFriendly;
  final String coverVariant;
  final AccessTier accessTier;
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
      durationMinutes: json['duration_minutes'] as int,
      intensity: json['intensity'] as String,
      goals: (json['goals'] as List?) ?? const [],
      painTargets: (json['pain_targets'] as List?) ?? const [],
      tags: (json['tags'] as List?) ?? const [],
      isSilentFriendly: json['is_silent_friendly'] as bool? ?? false,
      isBeginnerFriendly: json['is_beginner_friendly'] as bool? ?? false,
      coverVariant: json['cover_variant'] as String? ?? 'default',
      accessTier: AccessTier.fromCode(json['access_tier'] as String?),
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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

  factory _SessionStepRow.fromJson(Map<String, dynamic> json) {
    return _SessionStepRow(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      stepOrder: json['step_order'] as int,
      titleKey: json['title_key'] as String,
      titleFallback: json['title_fallback'] as String,
      instructionKey: json['instruction_key'] as String,
      instructionFallback: json['instruction_fallback'] as String,
      durationSeconds: json['duration_seconds'] as int,
      stepType: json['step_type'] as String,
      bodyTargetCodes: (json['body_target_codes'] as List?) ?? const [],
      isSkippable: json['is_skippable'] as bool? ?? true,
      breathingCueKey: json['breathing_cue_key'] as String?,
      breathingCueFallback: json['breathing_cue_fallback'] as String?,
      safetyNoteKey: json['safety_note_key'] as String?,
      safetyNoteFallback: json['safety_note_fallback'] as String?,
    );
  }
}