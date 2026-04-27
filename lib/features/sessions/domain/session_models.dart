// lib/features/sessions/domain/session_models.dart

import '../../access/domain/access_models.dart';

enum SessionIntensity {
  gentle,
  light,
  moderate,
  strong,
}

enum SessionStepType {
  setup,
  movement,
  hold,
  breath,
  transition,
  cooldown,
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
    required this.goals,
    required this.painTargets,
    required this.tags,
    required this.isSilentFriendly,
    required this.isBeginnerFriendly,
    required this.coverVariant,
    required this.modeCompatibility,
    required this.environmentCompatibility,
    this.accessTier = AccessTier.free,
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
  final List<SessionGoal> goals;
  final List<SessionPainTarget> painTargets;
  final List<SessionTag> tags;
  final bool isSilentFriendly;
  final bool isBeginnerFriendly;
  final String coverVariant;
  final SessionModeCompatibility modeCompatibility;
  final SessionEnvironmentCompatibility environmentCompatibility;
  final AccessTier accessTier;
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