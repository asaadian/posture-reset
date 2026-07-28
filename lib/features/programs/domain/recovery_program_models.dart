// lib/features/programs/domain/recovery_program_models.dart

import '../../access/domain/access_models.dart';

enum RecoveryProgramDifficulty {
  beginner,
  intermediate,
  advanced;

  static RecoveryProgramDifficulty fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'intermediate':
        return RecoveryProgramDifficulty.intermediate;
      case 'advanced':
        return RecoveryProgramDifficulty.advanced;
      case 'beginner':
      default:
        return RecoveryProgramDifficulty.beginner;
    }
  }

  String get code {
    switch (this) {
      case RecoveryProgramDifficulty.beginner:
        return 'beginner';
      case RecoveryProgramDifficulty.intermediate:
        return 'intermediate';
      case RecoveryProgramDifficulty.advanced:
        return 'advanced';
    }
  }
}

enum RecoveryProgramPhase {
  calm,
  release,
  activate,
  control,
  stability,
  integrate,
  maintain;

  static RecoveryProgramPhase fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'release':
        return RecoveryProgramPhase.release;
      case 'activate':
        return RecoveryProgramPhase.activate;
      case 'control':
        return RecoveryProgramPhase.control;
      case 'stability':
        return RecoveryProgramPhase.stability;
      case 'integrate':
        return RecoveryProgramPhase.integrate;
      case 'maintain':
        return RecoveryProgramPhase.maintain;
      case 'calm':
      default:
        return RecoveryProgramPhase.calm;
    }
  }

  String get code {
    switch (this) {
      case RecoveryProgramPhase.calm:
        return 'calm';
      case RecoveryProgramPhase.release:
        return 'release';
      case RecoveryProgramPhase.activate:
        return 'activate';
      case RecoveryProgramPhase.control:
        return 'control';
      case RecoveryProgramPhase.stability:
        return 'stability';
      case RecoveryProgramPhase.integrate:
        return 'integrate';
      case RecoveryProgramPhase.maintain:
        return 'maintain';
    }
  }
}

enum RecoveryProgramProgressStatus {
  active,
  completed,
  paused,
  abandoned;

  static RecoveryProgramProgressStatus fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'completed':
        return RecoveryProgramProgressStatus.completed;
      case 'paused':
        return RecoveryProgramProgressStatus.paused;
      case 'abandoned':
        return RecoveryProgramProgressStatus.abandoned;
      case 'active':
      default:
        return RecoveryProgramProgressStatus.active;
    }
  }

  String get code {
    switch (this) {
      case RecoveryProgramProgressStatus.active:
        return 'active';
      case RecoveryProgramProgressStatus.completed:
        return 'completed';
      case RecoveryProgramProgressStatus.paused:
        return 'paused';
      case RecoveryProgramProgressStatus.abandoned:
        return 'abandoned';
    }
  }
}

enum RecoveryProgramDayProgressStatus {
  notStarted,
  started,
  completed,
  skipped;

  static RecoveryProgramDayProgressStatus fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'started':
        return RecoveryProgramDayProgressStatus.started;
      case 'completed':
        return RecoveryProgramDayProgressStatus.completed;
      case 'skipped':
        return RecoveryProgramDayProgressStatus.skipped;
      case 'not_started':
      default:
        return RecoveryProgramDayProgressStatus.notStarted;
    }
  }

  String get code {
    switch (this) {
      case RecoveryProgramDayProgressStatus.notStarted:
        return 'not_started';
      case RecoveryProgramDayProgressStatus.started:
        return 'started';
      case RecoveryProgramDayProgressStatus.completed:
        return 'completed';
      case RecoveryProgramDayProgressStatus.skipped:
        return 'skipped';
    }
  }
}

class RecoveryProgramSummary {
  const RecoveryProgramSummary({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.shortDescriptionKey,
    required this.shortDescriptionFallback,
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
    required this.expectedOutcomes,
    required this.modeCompatibility,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String shortDescriptionKey;
  final String shortDescriptionFallback;
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
  final RecoveryProgramDifficulty difficulty;
  final AccessTier accessTier;
  final int freeDayCount;
  final List<String> primaryBodyZones;
  final List<String> secondaryBodyZones;
  final List<String> recommendedFor;
  final List<String> expectedOutcomes;
  final Map<String, bool> modeCompatibility;
  final bool isActive;
  final int sortOrder;

  int get lockedDayCount {
    final locked = durationDays - freeDayCount;
    return locked < 0 ? 0 : locked;
  }

  bool get hasFreePreview => freeDayCount > 0;
  bool get hasCoverImage =>
    coverImage != null && coverImage!.trim().isNotEmpty;

bool get isMedicalReviewed => medicalReviewed;
}

class RecoveryProgramDetail {
  const RecoveryProgramDetail({
    required this.summary,
    required this.longDescriptionKey,
    required this.longDescriptionFallback,
    required this.notRecommendedFor,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  final RecoveryProgramSummary summary;
  final String longDescriptionKey;
  final String longDescriptionFallback;
  final List<String> notRecommendedFor;
  final List<RecoveryProgramDay> days;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get seededDayCount => days.length;

  bool get isFullySeeded => seededDayCount == summary.durationDays;
}

class RecoveryProgramDay {
  const RecoveryProgramDay({
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
  required this.session,
});

  final String id;
  final String programId;
  final int dayNumber;
  final String titleKey;
  final String titleFallback;
  final String focusKey;
  final String focusFallback;
  final RecoveryProgramPhase phaseCode;
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
  final RecoveryProgramSessionRef? session;

  bool isLockedFor({
    required AccessSnapshot accessSnapshot,
    required AccessTier programAccessTier,
  }) {
    if (isFreePreview) return false;
    if (programAccessTier == AccessTier.free) return false;
    if (programAccessTier == AccessTier.coreAccess) {
      return !accessSnapshot.hasCoreAccess;
    }
    return true;
  }
  bool get hasObjective =>
    objective != null && objective!.trim().isNotEmpty;

  bool get hasWhyToday =>
      whyToday != null && whyToday!.trim().isNotEmpty;

  bool get hasExpectedResult =>
      expectedResult != null && expectedResult!.trim().isNotEmpty;

  bool get hasTherapistNote =>
      therapistNote != null && therapistNote!.trim().isNotEmpty;

  bool get hasTomorrowPreview =>
      tomorrowPreview != null && tomorrowPreview!.trim().isNotEmpty;

  bool get hasCompletionMessage =>
      completionMessage != null &&
      completionMessage!.trim().isNotEmpty;

  bool get isRepeatable =>
      allowRepeat && maxRepeatCount > 1;
}

class RecoveryProgramSessionRef {
  const RecoveryProgramSessionRef({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.durationMinutes,
    required this.intensity,
    required this.accessTier,
  });

  final String id;
  final String titleKey;
  final String titleFallback;
  final int durationMinutes;
  final String intensity;
  final AccessTier accessTier;
}

class RecoveryProgramProgress {
  const RecoveryProgramProgress({
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

  final String id;
  final String userId;
  final String programId;
  final RecoveryProgramProgressStatus status;
  final int currentDay;
  final int completedDayCount;
  final DateTime? startedAt;
  final DateTime? lastStartedDayAt;
  final DateTime? lastCompletedDayAt;
  final DateTime? completedAt;
  final int streakCount;
  final int bestStreakCount;

  bool get isActive => status == RecoveryProgramProgressStatus.active;

  bool get isCompleted => status == RecoveryProgramProgressStatus.completed;
}

class RecoveryProgramDayProgress {
  const RecoveryProgramDayProgress({
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

  final String id;
  final String userId;
  final String programId;
  final String programDayId;
  final int dayNumber;
  final String sessionId;
  final RecoveryProgramDayProgressStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? skippedAt;
  final int minutesCompleted;
  final bool? helped;
  final int? difficultyRating;

  bool get isStarted => status == RecoveryProgramDayProgressStatus.started;

  bool get isCompleted => status == RecoveryProgramDayProgressStatus.completed;

  bool get isSkipped => status == RecoveryProgramDayProgressStatus.skipped;

}

class RecoveryProgramDashboardProgress {
  const RecoveryProgramDashboardProgress({
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

  final String userId;
  final String programId;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final int durationDays;
  final int estimatedMinutesPerDay;
  final AccessTier accessTier;
  final RecoveryProgramProgressStatus status;
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

  bool get hasCurrentSession =>
      currentSessionId != null && currentSessionId!.trim().isNotEmpty;

  bool get isCompleted => status == RecoveryProgramProgressStatus.completed;

  double get progressFraction {
    if (durationDays <= 0) return 0;
    return (completedDayCount / durationDays).clamp(0.0, 1.0);
  }
}

abstract class RecoveryProgramsRepository {
  Future<List<RecoveryProgramSummary>> getProgramSummaries();

  Future<RecoveryProgramDetail?> getProgramDetailById(String programId);

  Future<RecoveryProgramProgress?> getProgramProgress(String programId);

  Future<Map<int, RecoveryProgramDayProgress>> getProgramDayProgressMap(
    String programId,
  );

  Future<RecoveryProgramDashboardProgress?> getActiveDashboardProgress();

  Future<RecoveryProgramProgress> startProgram(String programId);

  Future<RecoveryProgramDayProgress> startProgramDay({
    required String programId,
    required int dayNumber,
  });

  Future<RecoveryProgramProgress> completeProgramDay({
    required String programId,
    required int dayNumber,
    String? sessionRunId,
    int minutesCompleted = 0,
    bool? helped,
    int? difficultyRating,
  });
}
