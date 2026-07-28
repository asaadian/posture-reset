// lib/features/sessions/domain/session_models.dart

import '../../access/domain/access_models.dart';

enum SessionIntensity {
  gentle,
  light,
  moderate,
  strong,
}

enum SessionLevelTag {
  freeStarter,
  therapy,
  advancedTherapy,
  flagship,
}

enum SessionStepType {
  setup,
  movement,
  hold,
  breath,
  transition,
  cooldown,
}

enum SessionStepMovementPattern {
  setup,
  assessment,
  mobility,
  stretch,
  release,
  activation,
  strength,
  endurance,
  posture,
  breathing,
  cooldown,
  habit,
}

enum SessionStepSideMode {
  none,
  left,
  right,
  leftRight,
  bothSides,
  singleSide,
}

enum SessionStepEquipmentCode {
  none,
  chair,
  desk,
  wall,
  towel,
  smallCushion,
  lumbarRoll,
  miniBand,
  longBand,
  massageBall,
  softBall,
  waterBottle,
  dowel,
  yogaMat,
  foamRoller,
}

enum SessionEquipmentLevel {
  none,
  simple,
  expanded,
}

enum SessionStepIntensityLevel {
  veryLight,
  light,
  moderate,
  strong,
}

enum SessionStepVisualType {
  none,
  videoUrl,
  videoStorage,
  imageUrl,
  imageAsset,
  animatedPlaceholder,
}

enum SessionStepPurpose {
  check,
  control,
  activate,
  release,
  retest,
}

enum SessionGoal {
  painRelief,
  postureReset,
  focusPrep,
  recovery,
  mobility,
  decompression,
}

class SessionTag {
  const SessionTag({
    required this.code,
    required this.labelKey,
    required this.labelFallback,
  });

  final String code;
  final String labelKey;
  final String labelFallback;
}

class SessionPainTarget {
  const SessionPainTarget({
    required this.code,
    required this.labelKey,
    required this.labelFallback,
    required this.priority,
  });

  final String code;
  final String labelKey;
  final String labelFallback;
  final int priority;
}

class SessionCaution {
  const SessionCaution({
    required this.code,
    required this.messageKey,
    required this.messageFallback,
    required this.severity,
  });

  final String code;
  final String messageKey;
  final String messageFallback;
  final String severity;
}

class SessionModeCompatibility {
  const SessionModeCompatibility({
    required this.dadMode,
    required this.nightMode,
    required this.focusMode,
    required this.painReliefMode,
  });

  final bool dadMode;
  final bool nightMode;
  final bool focusMode;
  final bool painReliefMode;
}

class SessionEnvironmentCompatibility {
  const SessionEnvironmentCompatibility({
    required this.deskFriendly,
    required this.officeFriendly,
    required this.homeFriendly,
    required this.noMatRequired,
    required this.lowSpaceFriendly,
    required this.quietFriendly,
  });

  final bool deskFriendly;
  final bool officeFriendly;
  final bool homeFriendly;
  final bool noMatRequired;
  final bool lowSpaceFriendly;
  final bool quietFriendly;
}

class SessionStep {
  const SessionStep({
    required this.id,
    required this.sessionId,
    required this.order,
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
    this.visualType = SessionStepVisualType.none,
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
    this.stepPurpose,
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
  final int order;
  final String titleKey;
  final String titleFallback;
  final String instructionKey;
  final String instructionFallback;
  final int durationSeconds;
  final SessionStepType stepType;
  final List<String> bodyTargetCodes;
  final bool isSkippable;
  final String? breathingCueKey;
  final String? breathingCueFallback;
  final String? safetyNoteKey;
  final String? safetyNoteFallback;
  final SessionStepVisualType visualType;
  final String? visualUrl;
  final String? visualStoragePath;
  final String? visualThumbnailUrl;
  final String? visualThumbnailStoragePath;
  final int? visualDurationSeconds;

  /// Phase 16 therapeutic dose metadata.
  ///
  /// These fields are nullable to keep the Flutter app backward-compatible with
  /// older local/cache data and any Supabase row that has not been backfilled yet.
  final SessionStepMovementPattern? movementPattern;
  final int? repetitionCount;
  final int? holdSeconds;
  final SessionStepSideMode? sideMode;
  final SessionStepEquipmentCode? equipmentCode;
  final SessionStepIntensityLevel? intensityLevel;
  final String? coachingCueKey;
  final String? coachingCueFallback;

  /// Player guidance metadata.
  ///
  /// These fields are nullable/defaulted so older Supabase rows that have not
  /// been enriched yet still render safely in the Player.
  final SessionStepPurpose? stepPurpose;
  final String? stepPurposeLabel;
  final String? stepGoal;
  final String? whatToNotice;
  final List<String> avoidMistakes;
  final String? coachTip;
  final String? playerFocusNote;
  final bool isAssessmentStep;
  final bool isRetestStep;

  SessionStepMovementPattern get effectiveMovementPattern {
    return movementPattern ?? _legacyMovementPatternForStepType(stepType);
  }

  SessionStepSideMode get effectiveSideMode {
    return sideMode ?? SessionStepSideMode.none;
  }

  SessionStepEquipmentCode get effectiveEquipmentCode {
    return equipmentCode ?? SessionStepEquipmentCode.none;
  }

  SessionStepIntensityLevel get effectiveIntensityLevel {
    return intensityLevel ?? _legacyIntensityForStepType(stepType);
  }

  SessionStepPurpose get effectiveStepPurpose {
    if (stepPurpose != null) return stepPurpose!;
    if (isRetestStep) return SessionStepPurpose.retest;
    if (isAssessmentStep ||
        effectiveMovementPattern == SessionStepMovementPattern.assessment) {
      return SessionStepPurpose.check;
    }
    if (effectiveMovementPattern == SessionStepMovementPattern.release) {
      return SessionStepPurpose.release;
    }
    if (effectiveMovementPattern == SessionStepMovementPattern.activation ||
        effectiveMovementPattern == SessionStepMovementPattern.strength ||
        effectiveMovementPattern == SessionStepMovementPattern.endurance) {
      return SessionStepPurpose.activate;
    }
    return SessionStepPurpose.control;
  }

  String get effectiveStepPurposeLabel {
    final raw = stepPurposeLabel?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return sessionStepPurposeLabel(effectiveStepPurpose);
  }

  bool get hasPlayerFocusNote =>
      playerFocusNote != null && playerFocusNote!.trim().isNotEmpty;

  bool get hasStepGoal => stepGoal != null && stepGoal!.trim().isNotEmpty;

  bool get hasWhatToNotice =>
      whatToNotice != null && whatToNotice!.trim().isNotEmpty;

  bool get hasAvoidMistakes => avoidMistakes.any((item) => item.trim().isNotEmpty);

  bool get hasCoachTip => coachTip != null && coachTip!.trim().isNotEmpty;

  bool get hasRemoteVisual => visualUrl != null && visualUrl!.trim().isNotEmpty;

  bool get hasStorageVisual =>
      visualStoragePath != null && visualStoragePath!.trim().isNotEmpty;

  bool get hasAnyVisual => hasRemoteVisual || hasStorageVisual;

  bool get hasThumbnail =>
      visualThumbnailUrl != null && visualThumbnailUrl!.trim().isNotEmpty ||
      visualThumbnailStoragePath != null &&
          visualThumbnailStoragePath!.trim().isNotEmpty;

  bool get usesVideo =>
      visualType == SessionStepVisualType.videoUrl ||
      visualType == SessionStepVisualType.videoStorage;

  bool get usesImage =>
      visualType == SessionStepVisualType.imageUrl ||
      visualType == SessionStepVisualType.imageAsset;

  bool get hasCoachingCue =>
      coachingCueKey != null && coachingCueKey!.trim().isNotEmpty ||
      coachingCueFallback != null && coachingCueFallback!.trim().isNotEmpty;

  bool get hasBreathingCue =>
      breathingCueKey != null && breathingCueKey!.trim().isNotEmpty ||
      breathingCueFallback != null && breathingCueFallback!.trim().isNotEmpty;

  bool get hasSafetyNote =>
      safetyNoteKey != null && safetyNoteKey!.trim().isNotEmpty ||
      safetyNoteFallback != null && safetyNoteFallback!.trim().isNotEmpty;

  bool get hasRepetitionDose => repetitionCount != null && repetitionCount! > 0;

  bool get hasHoldDose => holdSeconds != null && holdSeconds! > 0;

  bool get hasSideDose => effectiveSideMode != SessionStepSideMode.none;

  bool get hasEquipmentRequirement =>
      effectiveEquipmentCode != SessionStepEquipmentCode.none;

  bool get hasTrainingDose =>
      hasRepetitionDose ||
      hasHoldDose ||
      hasSideDose ||
      hasEquipmentRequirement ||
      effectiveIntensityLevel != SessionStepIntensityLevel.light;

  bool get shouldLoopVisualAsDemo {
    if (!usesVideo) return false;
    if (visualDurationSeconds == null || visualDurationSeconds! <= 0) {
      return true;
    }
    return durationSeconds > visualDurationSeconds!;
  }

  SessionStep copyWith({
    String? id,
    String? sessionId,
    int? order,
    String? titleKey,
    String? titleFallback,
    String? instructionKey,
    String? instructionFallback,
    int? durationSeconds,
    SessionStepType? stepType,
    List<String>? bodyTargetCodes,
    bool? isSkippable,
    String? breathingCueKey,
    String? breathingCueFallback,
    String? safetyNoteKey,
    String? safetyNoteFallback,
    SessionStepVisualType? visualType,
    String? visualUrl,
    String? visualStoragePath,
    String? visualThumbnailUrl,
    String? visualThumbnailStoragePath,
    int? visualDurationSeconds,
    SessionStepMovementPattern? movementPattern,
    int? repetitionCount,
    int? holdSeconds,
    SessionStepSideMode? sideMode,
    SessionStepEquipmentCode? equipmentCode,
    SessionStepIntensityLevel? intensityLevel,
    String? coachingCueKey,
    String? coachingCueFallback,
    SessionStepPurpose? stepPurpose,
    String? stepPurposeLabel,
    String? stepGoal,
    String? whatToNotice,
    List<String>? avoidMistakes,
    String? coachTip,
    String? playerFocusNote,
    bool? isAssessmentStep,
    bool? isRetestStep,
  }) {
    return SessionStep(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      order: order ?? this.order,
      titleKey: titleKey ?? this.titleKey,
      titleFallback: titleFallback ?? this.titleFallback,
      instructionKey: instructionKey ?? this.instructionKey,
      instructionFallback: instructionFallback ?? this.instructionFallback,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      stepType: stepType ?? this.stepType,
      bodyTargetCodes: bodyTargetCodes ?? this.bodyTargetCodes,
      isSkippable: isSkippable ?? this.isSkippable,
      breathingCueKey: breathingCueKey ?? this.breathingCueKey,
      breathingCueFallback: breathingCueFallback ?? this.breathingCueFallback,
      safetyNoteKey: safetyNoteKey ?? this.safetyNoteKey,
      safetyNoteFallback: safetyNoteFallback ?? this.safetyNoteFallback,
      visualType: visualType ?? this.visualType,
      visualUrl: visualUrl ?? this.visualUrl,
      visualStoragePath: visualStoragePath ?? this.visualStoragePath,
      visualThumbnailUrl: visualThumbnailUrl ?? this.visualThumbnailUrl,
      visualThumbnailStoragePath:
          visualThumbnailStoragePath ?? this.visualThumbnailStoragePath,
      visualDurationSeconds:
          visualDurationSeconds ?? this.visualDurationSeconds,
      movementPattern: movementPattern ?? this.movementPattern,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      sideMode: sideMode ?? this.sideMode,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      intensityLevel: intensityLevel ?? this.intensityLevel,
      coachingCueKey: coachingCueKey ?? this.coachingCueKey,
      coachingCueFallback: coachingCueFallback ?? this.coachingCueFallback,
      stepPurpose: stepPurpose ?? this.stepPurpose,
      stepPurposeLabel: stepPurposeLabel ?? this.stepPurposeLabel,
      stepGoal: stepGoal ?? this.stepGoal,
      whatToNotice: whatToNotice ?? this.whatToNotice,
      avoidMistakes: avoidMistakes ?? this.avoidMistakes,
      coachTip: coachTip ?? this.coachTip,
      playerFocusNote: playerFocusNote ?? this.playerFocusNote,
      isAssessmentStep: isAssessmentStep ?? this.isAssessmentStep,
      isRetestStep: isRetestStep ?? this.isRetestStep,
    );
  }
}

class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.shortDescriptionKey,
    required this.shortDescriptionFallback,
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
    required this.modeCompatibility,
    required this.environmentCompatibility,
    this.accessTier = AccessTier.free,
    this.sessionLevelTag = SessionLevelTag.freeStarter,
  });

  final String id;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String shortDescriptionKey;
  final String shortDescriptionFallback;
  final int durationMinutes;
  final SessionIntensity intensity;
  final SessionEquipmentLevel equipmentLevel;
  final List<SessionStepEquipmentCode> requiredEquipment;
  final List<SessionGoal> goals;
  final List<SessionPainTarget> painTargets;
  final List<SessionTag> tags;
  final bool isSilentFriendly;
  final bool isBeginnerFriendly;
  final String coverVariant;
  final SessionModeCompatibility modeCompatibility;
  final SessionEnvironmentCompatibility environmentCompatibility;
  final AccessTier accessTier;
  final SessionLevelTag sessionLevelTag;

  bool get isCoreAccess => accessTier != AccessTier.free;
  bool get isTherapyGrade => sessionLevelTag != SessionLevelTag.freeStarter;

  bool get requiresSpecialEquipment {
    return requiredEquipment.any(
      (item) => item != SessionStepEquipmentCode.none &&
          item != SessionStepEquipmentCode.chair &&
          item != SessionStepEquipmentCode.desk &&
          item != SessionStepEquipmentCode.wall,
    );
  }
}

class SessionDetail {
  const SessionDetail({
    required this.summary,
    required this.longDescriptionKey,
    required this.longDescriptionFallback,
    required this.whyItHelpsKey,
    required this.whyItHelpsFallback,
    required this.preparationNotes,
    required this.steps,
    required this.cautions,
    required this.contraindications,
    required this.recommendedUseCases,
    required this.equipment,
    required this.createdAt,
    required this.updatedAt,
  });

  final SessionSummary summary;
  final String longDescriptionKey;
  final String longDescriptionFallback;
  final String whyItHelpsKey;
  final String whyItHelpsFallback;
  final List<String> preparationNotes;
  final List<SessionStep> steps;
  final List<SessionCaution> cautions;
  final List<SessionCaution> contraindications;
  final List<String> recommendedUseCases;
  final List<String> equipment;
  final DateTime createdAt;
  final DateTime updatedAt;
}

SessionStepPurpose? sessionStepPurposeFromDb(Object? value) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'check':
      return SessionStepPurpose.check;
    case 'control':
      return SessionStepPurpose.control;
    case 'activate':
      return SessionStepPurpose.activate;
    case 'release':
      return SessionStepPurpose.release;
    case 'retest':
      return SessionStepPurpose.retest;
    default:
      return null;
  }
}

String sessionStepPurposeToDb(SessionStepPurpose value) {
  switch (value) {
    case SessionStepPurpose.check:
      return 'check';
    case SessionStepPurpose.control:
      return 'control';
    case SessionStepPurpose.activate:
      return 'activate';
    case SessionStepPurpose.release:
      return 'release';
    case SessionStepPurpose.retest:
      return 'retest';
  }
}

String sessionStepPurposeLabel(SessionStepPurpose value) {
  switch (value) {
    case SessionStepPurpose.check:
      return 'Check';
    case SessionStepPurpose.control:
      return 'Control';
    case SessionStepPurpose.activate:
      return 'Activate';
    case SessionStepPurpose.release:
      return 'Release';
    case SessionStepPurpose.retest:
      return 'Retest';
  }
}

SessionStepMovementPattern sessionStepMovementPatternFromDb(
  Object? value, {
  required SessionStepType legacyStepType,
}) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'setup':
      return SessionStepMovementPattern.setup;
    case 'assessment':
      return SessionStepMovementPattern.assessment;
    case 'mobility':
      return SessionStepMovementPattern.mobility;
    case 'stretch':
      return SessionStepMovementPattern.stretch;
    case 'release':
      return SessionStepMovementPattern.release;
    case 'activation':
      return SessionStepMovementPattern.activation;
    case 'strength':
      return SessionStepMovementPattern.strength;
    case 'endurance':
      return SessionStepMovementPattern.endurance;
    case 'posture':
      return SessionStepMovementPattern.posture;
    case 'breathing':
      return SessionStepMovementPattern.breathing;
    case 'cooldown':
      return SessionStepMovementPattern.cooldown;
    case 'habit':
      return SessionStepMovementPattern.habit;
    default:
      return _legacyMovementPatternForStepType(legacyStepType);
  }
}

SessionStepSideMode sessionStepSideModeFromDb(Object? value) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'left':
      return SessionStepSideMode.left;
    case 'right':
      return SessionStepSideMode.right;
    case 'left_right':
      return SessionStepSideMode.leftRight;
    case 'both_sides':
      return SessionStepSideMode.bothSides;
    case 'single_side':
      return SessionStepSideMode.singleSide;
    case 'none':
    default:
      return SessionStepSideMode.none;
  }
}

SessionEquipmentLevel sessionEquipmentLevelFromDb(Object? value) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'simple':
      return SessionEquipmentLevel.simple;
    case 'expanded':
      return SessionEquipmentLevel.expanded;
    case 'none':
    default:
      return SessionEquipmentLevel.none;
  }
}

String sessionEquipmentLevelToDb(SessionEquipmentLevel value) {
  switch (value) {
    case SessionEquipmentLevel.none:
      return 'none';
    case SessionEquipmentLevel.simple:
      return 'simple';
    case SessionEquipmentLevel.expanded:
      return 'expanded';
  }
}

SessionStepEquipmentCode sessionStepEquipmentCodeFromDb(Object? value) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'chair':
      return SessionStepEquipmentCode.chair;
    case 'desk':
      return SessionStepEquipmentCode.desk;
    case 'wall':
      return SessionStepEquipmentCode.wall;
    case 'towel':
      return SessionStepEquipmentCode.towel;
    case 'small_cushion':
      return SessionStepEquipmentCode.smallCushion;
    case 'lumbar_roll':
      return SessionStepEquipmentCode.lumbarRoll;
    case 'mini_band':
      return SessionStepEquipmentCode.miniBand;
    case 'long_band':
    case 'resistance_band':
      return SessionStepEquipmentCode.longBand;
    case 'massage_ball':
      return SessionStepEquipmentCode.massageBall;
    case 'soft_ball':
    case 'therapy_ball':
      return SessionStepEquipmentCode.softBall;
    case 'water_bottle':
    case 'light_dumbbell':
      return SessionStepEquipmentCode.waterBottle;
    case 'dowel':
    case 'broomstick':
      return SessionStepEquipmentCode.dowel;
    case 'yoga_mat':
      return SessionStepEquipmentCode.yogaMat;
    case 'foam_roller':
      return SessionStepEquipmentCode.foamRoller;
    case 'none':
    default:
      return SessionStepEquipmentCode.none;
  }
}

SessionStepIntensityLevel sessionStepIntensityLevelFromDb(
  Object? value, {
  required SessionStepType legacyStepType,
}) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'very_light':
      return SessionStepIntensityLevel.veryLight;
    case 'light':
      return SessionStepIntensityLevel.light;
    case 'moderate':
      return SessionStepIntensityLevel.moderate;
    case 'strong':
      return SessionStepIntensityLevel.strong;
    default:
      return _legacyIntensityForStepType(legacyStepType);
  }
}

String sessionStepMovementPatternToDb(SessionStepMovementPattern value) {
  switch (value) {
    case SessionStepMovementPattern.setup:
      return 'setup';
    case SessionStepMovementPattern.assessment:
      return 'assessment';
    case SessionStepMovementPattern.mobility:
      return 'mobility';
    case SessionStepMovementPattern.stretch:
      return 'stretch';
    case SessionStepMovementPattern.release:
      return 'release';
    case SessionStepMovementPattern.activation:
      return 'activation';
    case SessionStepMovementPattern.strength:
      return 'strength';
    case SessionStepMovementPattern.endurance:
      return 'endurance';
    case SessionStepMovementPattern.posture:
      return 'posture';
    case SessionStepMovementPattern.breathing:
      return 'breathing';
    case SessionStepMovementPattern.cooldown:
      return 'cooldown';
    case SessionStepMovementPattern.habit:
      return 'habit';
  }
}

String sessionStepSideModeToDb(SessionStepSideMode value) {
  switch (value) {
    case SessionStepSideMode.none:
      return 'none';
    case SessionStepSideMode.left:
      return 'left';
    case SessionStepSideMode.right:
      return 'right';
    case SessionStepSideMode.leftRight:
      return 'left_right';
    case SessionStepSideMode.bothSides:
      return 'both_sides';
    case SessionStepSideMode.singleSide:
      return 'single_side';
  }
}

String sessionStepEquipmentCodeToDb(SessionStepEquipmentCode value) {
  switch (value) {
    case SessionStepEquipmentCode.none:
      return 'none';
    case SessionStepEquipmentCode.chair:
      return 'chair';
    case SessionStepEquipmentCode.desk:
      return 'desk';
    case SessionStepEquipmentCode.wall:
      return 'wall';
    case SessionStepEquipmentCode.towel:
      return 'towel';
    case SessionStepEquipmentCode.smallCushion:
      return 'small_cushion';
    case SessionStepEquipmentCode.lumbarRoll:
      return 'lumbar_roll';
    case SessionStepEquipmentCode.miniBand:
      return 'mini_band';
    case SessionStepEquipmentCode.longBand:
      return 'long_band';
    case SessionStepEquipmentCode.massageBall:
      return 'massage_ball';
    case SessionStepEquipmentCode.softBall:
      return 'soft_ball';
    case SessionStepEquipmentCode.waterBottle:
      return 'water_bottle';
    case SessionStepEquipmentCode.dowel:
      return 'dowel';
    case SessionStepEquipmentCode.yogaMat:
      return 'yoga_mat';
    case SessionStepEquipmentCode.foamRoller:
      return 'foam_roller';
  }
}

String sessionStepIntensityLevelToDb(SessionStepIntensityLevel value) {
  switch (value) {
    case SessionStepIntensityLevel.veryLight:
      return 'very_light';
    case SessionStepIntensityLevel.light:
      return 'light';
    case SessionStepIntensityLevel.moderate:
      return 'moderate';
    case SessionStepIntensityLevel.strong:
      return 'strong';
  }
}

SessionStepMovementPattern _legacyMovementPatternForStepType(
  SessionStepType type,
) {
  switch (type) {
    case SessionStepType.setup:
      return SessionStepMovementPattern.setup;
    case SessionStepType.movement:
      return SessionStepMovementPattern.mobility;
    case SessionStepType.hold:
      return SessionStepMovementPattern.stretch;
    case SessionStepType.breath:
      return SessionStepMovementPattern.breathing;
    case SessionStepType.transition:
      return SessionStepMovementPattern.posture;
    case SessionStepType.cooldown:
      return SessionStepMovementPattern.cooldown;
  }
}

SessionStepIntensityLevel _legacyIntensityForStepType(SessionStepType type) {
  switch (type) {
    case SessionStepType.setup:
    case SessionStepType.breath:
    case SessionStepType.cooldown:
      return SessionStepIntensityLevel.veryLight;
    case SessionStepType.movement:
    case SessionStepType.hold:
    case SessionStepType.transition:
      return SessionStepIntensityLevel.light;
  }
}

SessionLevelTag sessionLevelTagFromDb(Object? value) {
  final normalized = _normalizeDbValue(value);

  switch (normalized) {
    case 'therapy':
      return SessionLevelTag.therapy;
    case 'advanced_therapy':
      return SessionLevelTag.advancedTherapy;
    case 'flagship':
      return SessionLevelTag.flagship;
    case 'free_starter':
    default:
      return SessionLevelTag.freeStarter;
  }
}

String sessionLevelTagToDb(SessionLevelTag value) {
  switch (value) {
    case SessionLevelTag.freeStarter:
      return 'free_starter';
    case SessionLevelTag.therapy:
      return 'therapy';
    case SessionLevelTag.advancedTherapy:
      return 'advanced_therapy';
    case SessionLevelTag.flagship:
      return 'flagship';
  }
}

String _normalizeDbValue(Object? value) {
  return value?.toString().trim().toLowerCase() ?? '';
}
