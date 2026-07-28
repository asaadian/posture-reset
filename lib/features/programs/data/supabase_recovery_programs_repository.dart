// lib/features/programs/data/supabase_recovery_programs_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../access/domain/access_models.dart';
import '../domain/recovery_program_models.dart';

class SupabaseRecoveryProgramsRepository implements RecoveryProgramsRepository {
  SupabaseRecoveryProgramsRepository(this._client);

  final SupabaseClient _client;

  static const String _programsTable = 'recovery_programs';
  static const String _programDaysTable = 'recovery_program_days';
  static const String _sessionTemplatesTable = 'session_templates';
  static const String _programProgressTable = 'user_recovery_program_progress';
  static const String _programDayProgressTable =
      'user_recovery_program_day_progress';
  static const String _dashboardProgressView =
      'user_recovery_program_dashboard_view';

  @override
  Future<List<RecoveryProgramSummary>> getProgramSummaries() async {
    final response = await _client
        .from(_programsTable)
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);


    final rows = (response as List)
        .map(
          (item) => _RecoveryProgramRow.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    return rows.map(_mapSummary).toList(growable: false);
  }

  @override
  Future<RecoveryProgramDetail?> getProgramDetailById(String programId) async {
    final programResponse = await _client
        .from(_programsTable)
        .select()
        .eq('id', programId)
        .eq('is_active', true)
        .maybeSingle();

    if (programResponse == null) {
      return null;
    }

    final daysResponse = await _client
        .from(_programDaysTable)
        .select()
        .eq('program_id', programId)
        .order('day_number', ascending: true);

    final dayRows = (daysResponse as List)
        .map(
          (item) => _RecoveryProgramDayRow.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

    final sessionIds = dayRows.map((day) => day.sessionId).toSet().toList();
    final sessionMap = await _loadSessionRefs(sessionIds);

    final program = _RecoveryProgramRow.fromJson(
      Map<String, dynamic>.from(programResponse as Map),
    );

    final days = dayRows
        .map((day) => _mapDay(day, sessionMap[day.sessionId]))
        .toList(growable: true)
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    return RecoveryProgramDetail(
      summary: _mapSummary(program),
      longDescriptionKey: program.longDescriptionKey,
      longDescriptionFallback: program.longDescriptionFallback,
      notRecommendedFor: program.notRecommendedFor,
      days: days,
      createdAt: program.createdAt,
      updatedAt: program.updatedAt,
    );
  }

  @override
  Future<RecoveryProgramProgress?> getProgramProgress(String programId) async {
    final response = await _client
        .from(_programProgressTable)
        .select()
        .eq('program_id', programId)
        .maybeSingle();

    if (response == null) return null;

    return _RecoveryProgramProgressRow.fromJson(
      Map<String, dynamic>.from(response as Map),
    ).toModel();
  }

  @override
  Future<Map<int, RecoveryProgramDayProgress>> getProgramDayProgressMap(
    String programId,
  ) async {
    final response = await _client
        .from(_programDayProgressTable)
        .select()
        .eq('program_id', programId)
        .order('day_number', ascending: true);

    final result = <int, RecoveryProgramDayProgress>{};

    for (final item in response as List) {
      final row = _RecoveryProgramDayProgressRow.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
      result[row.dayNumber] = row.toModel();
    }

    return result;
  }

  @override
  Future<RecoveryProgramDashboardProgress?> getActiveDashboardProgress() async {
    final response = await _client
        .from(_dashboardProgressView)
        .select()
        .inFilter('status', const ['active', 'paused'])
        .order('last_started_day_at', ascending: false)
        .limit(1);

    final rows = response as List;
    if (rows.isEmpty) return null;

    return _RecoveryProgramDashboardProgressRow.fromJson(
      Map<String, dynamic>.from(rows.first as Map),
    ).toModel();
  }

  @override
  Future<RecoveryProgramProgress> startProgram(String programId) async {
    final response = await _client.rpc(
      'start_recovery_program',
      params: {'p_program_id': programId},
    );

    return _RecoveryProgramProgressRow.fromJson(
      Map<String, dynamic>.from(response as Map),
    ).toModel();
  }

  @override
  Future<RecoveryProgramDayProgress> startProgramDay({
    required String programId,
    required int dayNumber,
  }) async {
    final response = await _client.rpc(
      'start_recovery_program_day',
      params: {
        'p_program_id': programId,
        'p_day_number': dayNumber,
      },
    );

    return _RecoveryProgramDayProgressRow.fromJson(
      Map<String, dynamic>.from(response as Map),
    ).toModel();
  }

  @override
  Future<RecoveryProgramProgress> completeProgramDay({
    required String programId,
    required int dayNumber,
    String? sessionRunId,
    int minutesCompleted = 0,
    bool? helped,
    int? difficultyRating,
  }) async {
    final response = await _client.rpc(
      'complete_recovery_program_day',
      params: {
        'p_program_id': programId,
        'p_day_number': dayNumber,
        'p_session_run_id': sessionRunId,
        'p_minutes_completed': minutesCompleted,
        'p_helped': helped,
        'p_difficulty_rating': difficultyRating,
      },
    );

    return _RecoveryProgramProgressRow.fromJson(
      Map<String, dynamic>.from(response as Map),
    ).toModel();
  }

  Future<Map<String, RecoveryProgramSessionRef>> _loadSessionRefs(
    List<String> sessionIds,
  ) async {
    if (sessionIds.isEmpty) return const {};

    final response = await _client
        .from(_sessionTemplatesTable)
        .select('id,title_key,title_fallback,duration_minutes,intensity,access_tier')
        .inFilter('id', sessionIds);

    final refs = <String, RecoveryProgramSessionRef>{};

    for (final item in response as List) {
      final json = Map<String, dynamic>.from(item as Map);
      final ref = RecoveryProgramSessionRef(
        id: json['id'] as String? ?? '',
        titleKey: json['title_key'] as String? ?? '',
        titleFallback: json['title_fallback'] as String? ?? '',
        durationMinutes: _intOrDefault(json['duration_minutes'], 0),
        intensity: json['intensity'] as String? ?? 'light',
        accessTier: AccessTier.fromCode(json['access_tier'] as String?),
      );
      if (ref.id.isNotEmpty) {
        refs[ref.id] = ref;
      }
    }

    return refs;
  }

  RecoveryProgramSummary _mapSummary(_RecoveryProgramRow row) {
  return RecoveryProgramSummary(
    id: row.id,
    titleKey: row.titleKey,
    titleFallback: row.titleFallback,
    subtitleKey: row.subtitleKey,
    subtitleFallback: row.subtitleFallback,
    shortDescriptionKey: row.shortDescriptionKey,
    shortDescriptionFallback: row.shortDescriptionFallback,
    programGoalKey: row.programGoalKey,
    programGoalFallback: row.programGoalFallback,

    coverImage: row.coverImage,
    estimatedWeeks: row.estimatedWeeks,
    programVersion: row.programVersion,
    medicalReviewed: row.medicalReviewed,
    reviewedBy: row.reviewedBy,
    reviewedAt: row.reviewedAt,
    programType: row.programType,

    durationDays: row.durationDays,
    estimatedMinutesPerDay: row.estimatedMinutesPerDay,
    difficulty: RecoveryProgramDifficulty.fromCode(row.difficulty),
    accessTier: row.accessTier,
    freeDayCount: row.freeDayCount,
    primaryBodyZones: row.primaryBodyZones,
    secondaryBodyZones: row.secondaryBodyZones,
    recommendedFor: row.recommendedFor,
    expectedOutcomes: row.expectedOutcomes,
    modeCompatibility: row.modeCompatibility,
    isActive: row.isActive,
    sortOrder: row.sortOrder,
  );
}

  RecoveryProgramDay _mapDay(
  _RecoveryProgramDayRow row,
  RecoveryProgramSessionRef? session,
) {
  return RecoveryProgramDay(
    id: row.id,
    programId: row.programId,
    dayNumber: row.dayNumber,

    titleKey: row.titleKey,
    titleFallback: row.titleFallback,
    focusKey: row.focusKey,
    focusFallback: row.focusFallback,

    phaseCode: RecoveryProgramPhase.fromCode(row.phaseCode),
    phaseTitle: row.phaseTitle,
    phaseOrder: row.phaseOrder,

    objective: row.objective,
    whyToday: row.whyToday,
    expectedResult: row.expectedResult,
    therapistNote: row.therapistNote,
    tomorrowPreview: row.tomorrowPreview,
    completionMessage: row.completionMessage,

    difficultyScore: row.difficultyScore,
    loadLevel: row.loadLevel,
    estimatedPainAfter: row.estimatedPainAfter,
    estimatedEnergy: row.estimatedEnergy,

    phaseIcon: row.phaseIcon,
    badgeColor: row.badgeColor,
    illustrationName: row.illustrationName,

    isPhaseStart: row.isPhaseStart,
    isPhaseEnd: row.isPhaseEnd,
    isAssessmentDay: row.isAssessmentDay,
    isRecoveryDay: row.isRecoveryDay,

    allowRepeat: row.allowRepeat,
    maxRepeatCount: row.maxRepeatCount,
    adaptiveRule: row.adaptiveRule,

    sessionId: row.sessionId,
    isFreePreview: row.isFreePreview,
    isRestDay: row.isRestDay,
    dayTheme: row.dayTheme,
    sortOrder: row.sortOrder,
    session: session,
  );
}
}

class _RecoveryProgramRow {
  const _RecoveryProgramRow({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.shortDescriptionKey,
    required this.shortDescriptionFallback,
    required this.longDescriptionKey,
    required this.longDescriptionFallback,
    required this.programGoalKey,
    required this.programGoalFallback,
    required this.coverImage,
    required this.estimatedWeeks,
    required this.programVersion,
    required this.medicalReviewed,
    required this.reviewedBy,
    required this.reviewedAt,
    required this.programType,
    required this.durationDays,
    required this.estimatedMinutesPerDay,
    required this.difficulty,
    required this.accessTier,
    required this.freeDayCount,
    required this.primaryBodyZones,
    required this.secondaryBodyZones,
    required this.recommendedFor,
    required this.notRecommendedFor,
    required this.expectedOutcomes,
    required this.modeCompatibility,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _RecoveryProgramRow.fromJson(Map<String, dynamic> json) {
  return _RecoveryProgramRow(
    id: _stringOrEmpty(json['id']),
    titleKey: _stringOrEmpty(json['title_key']),
    titleFallback: _stringOrEmpty(json['title_fallback']),
    subtitleKey: _stringOrEmpty(json['subtitle_key']),
    subtitleFallback: _stringOrEmpty(json['subtitle_fallback']),
    shortDescriptionKey: _stringOrEmpty(json['short_description_key']),
    shortDescriptionFallback:
        _stringOrEmpty(json['short_description_fallback']),
    longDescriptionKey: _stringOrEmpty(json['long_description_key']),
    longDescriptionFallback:
        _stringOrEmpty(json['long_description_fallback']),
    programGoalKey: _stringOrEmpty(json['program_goal_key']),
    programGoalFallback:
        _stringOrEmpty(json['program_goal_fallback']),
    coverImage: _nullableString(json['cover_image']),
    estimatedWeeks: _intOrDefault(json['estimated_weeks'], 0),
    programVersion: _stringOrEmpty(json['program_version'], '1.0'),
    medicalReviewed: json['medical_reviewed'] as bool? ?? false,
    reviewedBy: _nullableString(json['reviewed_by']),
    reviewedAt: _dateTimeOrNull(json['reviewed_at']),
    programType: _stringOrEmpty(json['program_type'], 'standard'),
    durationDays: _intOrDefault(json['duration_days'], 0),
    estimatedMinutesPerDay:
        _intOrDefault(json['estimated_minutes_per_day'], 0),
    difficulty: _stringOrEmpty(json['difficulty'], 'beginner'),
    accessTier: AccessTier.fromCode(
      _nullableString(json['access_tier']),
    ),
    freeDayCount: _intOrDefault(json['free_day_count'], 0),
    primaryBodyZones: _stringListFromJson(json['primary_body_zones']),
    secondaryBodyZones: _stringListFromJson(json['secondary_body_zones']),
    recommendedFor: _stringListFromJson(json['recommended_for']),
    notRecommendedFor: _stringListFromJson(json['not_recommended_for']),
    expectedOutcomes: _stringListFromJson(json['expected_outcomes']),
    modeCompatibility: _boolMapFromJson(json['mode_compatibility']),
    isActive: json['is_active'] as bool? ?? true,
    sortOrder: _intOrDefault(json['sort_order'], 0),
    createdAt: _dateTimeOrNull(json['created_at']),
    updatedAt: _dateTimeOrNull(json['updated_at']),
  );
}

  final String id;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String shortDescriptionKey;
  final String shortDescriptionFallback;
  final String longDescriptionKey;
  final String longDescriptionFallback;
  final String programGoalKey;
  final String programGoalFallback;
  final String? coverImage;
  final int estimatedWeeks;
  final String programVersion;
  final bool medicalReviewed;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String programType;
  final int durationDays;
  final int estimatedMinutesPerDay;
  final String difficulty;
  final AccessTier accessTier;
  final int freeDayCount;
  final List<String> primaryBodyZones;
  final List<String> secondaryBodyZones;
  final List<String> recommendedFor;
  final List<String> notRecommendedFor;
  final List<String> expectedOutcomes;
  final Map<String, bool> modeCompatibility;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class _RecoveryProgramDayRow {
  const _RecoveryProgramDayRow({
    required this.id,
    required this.programId,
    required this.dayNumber,
    required this.titleKey,
    required this.titleFallback,
    required this.focusKey,
    required this.focusFallback,
    required this.phaseCode,
    required this.phaseTitle,
    required this.phaseOrder,

    required this.objective,
    required this.whyToday,
    required this.expectedResult,
    required this.therapistNote,
    required this.tomorrowPreview,
    required this.completionMessage,

    required this.difficultyScore,
    required this.loadLevel,
    required this.estimatedPainAfter,
    required this.estimatedEnergy,

    required this.phaseIcon,
    required this.badgeColor,
    required this.illustrationName,

    required this.isPhaseStart,
    required this.isPhaseEnd,
    required this.isAssessmentDay,
    required this.isRecoveryDay,

    required this.allowRepeat,
    required this.maxRepeatCount,
    required this.adaptiveRule,
    required this.sessionId,
    required this.isFreePreview,
    required this.isRestDay,
    required this.dayTheme,
    required this.sortOrder,
  });

  factory _RecoveryProgramDayRow.fromJson(Map<String, dynamic> json) {
    return _RecoveryProgramDayRow(
      id: json['id'] as String? ?? '',
      programId: json['program_id'] as String? ?? '',
      dayNumber: _intOrDefault(json['day_number'], 0),
      titleKey: json['title_key'] as String? ?? '',
      titleFallback: json['title_fallback'] as String? ?? '',
      focusKey: json['focus_key'] as String? ?? '',
      focusFallback: json['focus_fallback'] as String? ?? '',
      phaseCode: json['phase_code'] as String? ?? 'calm',
      phaseTitle: json['phase_title'] as String? ?? '',
      phaseOrder: _intOrDefault(json['phase_order'], 0),

      objective: json['objective'] as String?,
      whyToday: json['why_today'] as String?,
      expectedResult: json['expected_result'] as String?,
      therapistNote: json['therapist_note'] as String?,
      tomorrowPreview: json['tomorrow_preview'] as String?,
      completionMessage: json['completion_message'] as String?,

      difficultyScore: _intOrDefault(json['difficulty_score'], 1),
      loadLevel: _intOrDefault(json['load_level'], 1),
      estimatedPainAfter: _intOrDefault(json['estimated_pain_after'], 0),
      estimatedEnergy: _intOrDefault(json['estimated_energy'], 0),

      phaseIcon: json['phase_icon'] as String?,
      badgeColor: json['badge_color'] as String?,
      illustrationName: json['illustration_name'] as String?,

      isPhaseStart: json['is_phase_start'] as bool? ?? false,
      isPhaseEnd: json['is_phase_end'] as bool? ?? false,
      isAssessmentDay: json['is_assessment_day'] as bool? ?? false,
      isRecoveryDay: json['is_recovery_day'] as bool? ?? false,

      allowRepeat: json['allow_repeat'] as bool? ?? false,
      maxRepeatCount: _intOrDefault(json['max_repeat_count'], 1),

      adaptiveRule: json['adaptive_rule'] as String?,
      sessionId: json['session_id'] as String? ?? '',
      isFreePreview: json['is_free_preview'] as bool? ?? false,
      isRestDay: json['is_rest_day'] as bool? ?? false,
      dayTheme: json['day_theme'] as String? ?? 'practice',
      sortOrder: _intOrDefault(json['sort_order'], 0),
    );
  }

  final String id;
  final String programId;
  final int dayNumber;
  final String titleKey;
  final String titleFallback;
  final String focusKey;
  final String focusFallback;
  final String phaseCode;
  final String phaseTitle;
  final int phaseOrder;

  final String? objective;
  final String? whyToday;
  final String? expectedResult;
  final String? therapistNote;
  final String? tomorrowPreview;
  final String? completionMessage;

  final int difficultyScore;
  final int loadLevel;
  final int estimatedPainAfter;
  final int estimatedEnergy;

  final String? phaseIcon;
  final String? badgeColor;
  final String? illustrationName;

  final bool isPhaseStart;
  final bool isPhaseEnd;
  final bool isAssessmentDay;
  final bool isRecoveryDay;

  final bool allowRepeat;
  final int maxRepeatCount;

  final String? adaptiveRule;
  final String sessionId;
  final bool isFreePreview;
  final bool isRestDay;
  final String dayTheme;
  final int sortOrder;
}

class _RecoveryProgramProgressRow {
  const _RecoveryProgramProgressRow({
    required this.id,
    required this.userId,
    required this.programId,
    required this.status,
    required this.currentDay,
    required this.completedDayCount,
    required this.startedAt,
    required this.lastStartedDayAt,
    required this.lastCompletedDayAt,
    required this.completedAt,
    required this.streakCount,
    required this.bestStreakCount,
  });

  factory _RecoveryProgramProgressRow.fromJson(Map<String, dynamic> json) {
    return _RecoveryProgramProgressRow(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      programId: json['program_id'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      currentDay: _intOrDefault(json['current_day'], 1),
      completedDayCount: _intOrDefault(json['completed_day_count'], 0),
      startedAt: _dateTimeOrNull(json['started_at']),
      lastStartedDayAt: _dateTimeOrNull(json['last_started_day_at']),
      lastCompletedDayAt: _dateTimeOrNull(json['last_completed_day_at']),
      completedAt: _dateTimeOrNull(json['completed_at']),
      streakCount: _intOrDefault(json['streak_count'], 0),
      bestStreakCount: _intOrDefault(json['best_streak_count'], 0),
    );
  }

  final String id;
  final String userId;
  final String programId;
  final String status;
  final int currentDay;
  final int completedDayCount;
  final DateTime? startedAt;
  final DateTime? lastStartedDayAt;
  final DateTime? lastCompletedDayAt;
  final DateTime? completedAt;
  final int streakCount;
  final int bestStreakCount;

  RecoveryProgramProgress toModel() {
    return RecoveryProgramProgress(
      id: id,
      userId: userId,
      programId: programId,
      status: RecoveryProgramProgressStatus.fromCode(status),
      currentDay: currentDay,
      completedDayCount: completedDayCount,
      startedAt: startedAt,
      lastStartedDayAt: lastStartedDayAt,
      lastCompletedDayAt: lastCompletedDayAt,
      completedAt: completedAt,
      streakCount: streakCount,
      bestStreakCount: bestStreakCount,
    );
  }
}

class _RecoveryProgramDayProgressRow {
  const _RecoveryProgramDayProgressRow({
    required this.id,
    required this.userId,
    required this.programId,
    required this.programDayId,
    required this.dayNumber,
    required this.sessionId,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.skippedAt,
    required this.minutesCompleted,
    required this.helped,
    required this.difficultyRating,
  });

  factory _RecoveryProgramDayProgressRow.fromJson(Map<String, dynamic> json) {
    return _RecoveryProgramDayProgressRow(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      programId: json['program_id'] as String? ?? '',
      programDayId: json['program_day_id'] as String? ?? '',
      dayNumber: _intOrDefault(json['day_number'], 0),
      sessionId: json['session_id'] as String? ?? '',
      status: json['status'] as String? ?? 'not_started',
      startedAt: _dateTimeOrNull(json['started_at']),
      completedAt: _dateTimeOrNull(json['completed_at']),
      skippedAt: _dateTimeOrNull(json['skipped_at']),
      minutesCompleted: _intOrDefault(json['minutes_completed'], 0),
      helped: json['helped'] as bool?,
      difficultyRating: _nullableInt(json['difficulty_rating']),
    );
  }

  final String id;
  final String userId;
  final String programId;
  final String programDayId;
  final int dayNumber;
  final String sessionId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? skippedAt;
  final int minutesCompleted;
  final bool? helped;
  final int? difficultyRating;

  RecoveryProgramDayProgress toModel() {
    return RecoveryProgramDayProgress(
      id: id,
      userId: userId,
      programId: programId,
      programDayId: programDayId,
      dayNumber: dayNumber,
      sessionId: sessionId,
      status: RecoveryProgramDayProgressStatus.fromCode(status),
      startedAt: startedAt,
      completedAt: completedAt,
      skippedAt: skippedAt,
      minutesCompleted: minutesCompleted,
      helped: helped,
      difficultyRating: difficultyRating,
    );
  }
}

class _RecoveryProgramDashboardProgressRow {
  const _RecoveryProgramDashboardProgressRow({
    required this.userId,
    required this.programId,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.durationDays,
    required this.estimatedMinutesPerDay,
    required this.accessTier,
    required this.status,
    required this.currentDay,
    required this.completedDayCount,
    required this.remainingDayCount,
    required this.streakCount,
    required this.bestStreakCount,
    required this.currentProgramDayId,
    required this.currentDayTitleKey,
    required this.currentDayTitleFallback,
    required this.currentDayFocusKey,
    required this.currentDayFocusFallback,
    required this.currentSessionId,
    required this.currentSessionTitleKey,
    required this.currentSessionTitleFallback,
    required this.currentSessionDurationMinutes,
  });

  factory _RecoveryProgramDashboardProgressRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return _RecoveryProgramDashboardProgressRow(
      userId: json['user_id'] as String? ?? '',
      programId: json['program_id'] as String? ?? '',
      titleKey: json['title_key'] as String? ?? '',
      titleFallback: json['title_fallback'] as String? ?? '',
      subtitleKey: json['subtitle_key'] as String? ?? '',
      subtitleFallback: json['subtitle_fallback'] as String? ?? '',
      durationDays: _intOrDefault(json['duration_days'], 0),
      estimatedMinutesPerDay:
          _intOrDefault(json['estimated_minutes_per_day'], 0),
      accessTier: AccessTier.fromCode(json['access_tier'] as String?),
      status: json['status'] as String? ?? 'active',
      currentDay: _intOrDefault(json['current_day'], 1),
      completedDayCount: _intOrDefault(json['completed_day_count'], 0),
      remainingDayCount: _intOrDefault(json['remaining_day_count'], 0),
      streakCount: _intOrDefault(json['streak_count'], 0),
      bestStreakCount: _intOrDefault(json['best_streak_count'], 0),
      currentProgramDayId: json['current_program_day_id'] as String?,
      currentDayTitleKey: json['current_day_title_key'] as String?,
      currentDayTitleFallback: json['current_day_title_fallback'] as String?,
      currentDayFocusKey: json['current_day_focus_key'] as String?,
      currentDayFocusFallback: json['current_day_focus_fallback'] as String?,
      currentSessionId: json['current_session_id'] as String?,
      currentSessionTitleKey: json['current_session_title_key'] as String?,
      currentSessionTitleFallback:
          json['current_session_title_fallback'] as String?,
      currentSessionDurationMinutes:
          _nullableInt(json['current_session_duration_minutes']),
    );
  }

  final String userId;
  final String programId;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final int durationDays;
  final int estimatedMinutesPerDay;
  final AccessTier accessTier;
  final String status;
  final int currentDay;
  final int completedDayCount;
  final int remainingDayCount;
  final int streakCount;
  final int bestStreakCount;
  final String? currentProgramDayId;
  final String? currentDayTitleKey;
  final String? currentDayTitleFallback;
  final String? currentDayFocusKey;
  final String? currentDayFocusFallback;
  final String? currentSessionId;
  final String? currentSessionTitleKey;
  final String? currentSessionTitleFallback;
  final int? currentSessionDurationMinutes;

  RecoveryProgramDashboardProgress toModel() {
    return RecoveryProgramDashboardProgress(
      userId: userId,
      programId: programId,
      titleKey: titleKey,
      titleFallback: titleFallback,
      subtitleKey: subtitleKey,
      subtitleFallback: subtitleFallback,
      durationDays: durationDays,
      estimatedMinutesPerDay: estimatedMinutesPerDay,
      accessTier: accessTier,
      status: RecoveryProgramProgressStatus.fromCode(status),
      currentDay: currentDay,
      completedDayCount: completedDayCount,
      remainingDayCount: remainingDayCount,
      streakCount: streakCount,
      bestStreakCount: bestStreakCount,
      currentProgramDayId: currentProgramDayId,
      currentDayTitleKey: currentDayTitleKey,
      currentDayTitleFallback: currentDayTitleFallback,
      currentDayFocusKey: currentDayFocusKey,
      currentDayFocusFallback: currentDayFocusFallback,
      currentSessionId: currentSessionId,
      currentSessionTitleKey: currentSessionTitleKey,
      currentSessionTitleFallback: currentSessionTitleFallback,
      currentSessionDurationMinutes: currentSessionDurationMinutes,
    );
  }
}

List<String> _stringListFromJson(dynamic raw) {
  if (raw is List) {
    return raw.map((item) => item.toString()).toList(growable: false);
  }
  return const [];
}

Map<String, bool> _boolMapFromJson(dynamic raw) {
  if (raw is Map) {
    return raw.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );
  }
  return const {};
}

int _intOrDefault(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}


String _stringOrEmpty(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}