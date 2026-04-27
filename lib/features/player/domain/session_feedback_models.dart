// lib/features/player/domain/session_feedback_models.dart

enum SessionEntrySource {
  quickFix,
  sessionDetail,
  sessionsLibrary,
  dashboard,
  profile,
  reminders,
  unknown;

  static SessionEntrySource fromRaw(String? raw) {
    switch (raw) {
      case 'quick_fix':
      case 'quickFix':
        return SessionEntrySource.quickFix;
      case 'session_detail':
      case 'sessionDetail':
        return SessionEntrySource.sessionDetail;
      case 'sessions_library':
      case 'sessionsLibrary':
        return SessionEntrySource.sessionsLibrary;
      case 'dashboard':
        return SessionEntrySource.dashboard;
      case 'profile':
        return SessionEntrySource.profile;
      case 'reminders':
        return SessionEntrySource.reminders;
      default:
        return SessionEntrySource.unknown;
    }
  }

  String get dbValue {
    switch (this) {
      case SessionEntrySource.quickFix:
        return 'quick_fix';
      case SessionEntrySource.sessionDetail:
        return 'session_detail';
      case SessionEntrySource.sessionsLibrary:
        return 'sessions_library';
      case SessionEntrySource.dashboard:
        return 'dashboard';
      case SessionEntrySource.profile:
        return 'profile';
      case SessionEntrySource.reminders:
        return 'reminders';
      case SessionEntrySource.unknown:
        return 'unknown';
    }
  }
}

enum SessionStateLevel {
  low,
  medium,
  high,
}

enum SessionIntentCode {
  relief,
  reset,
  focus,
  unwind,
}

enum SessionDelta {
  worse,
  same,
  better,
}

enum SessionPerceivedFit {
  poor,
  okay,
  great,
}

enum SessionFeedbackCompletionStatus {
  completed,
  abandoned,
}

class SessionStateSnapshotInput {
  const SessionStateSnapshotInput({
    required this.energyLevel,
    required this.stressLevel,
    required this.focusLevel,
    required this.painAreaCodes,
    required this.intentCode,
    required this.entrySource,
  });

  final SessionStateLevel energyLevel;
  final SessionStateLevel stressLevel;
  final SessionStateLevel focusLevel;
  final List<String> painAreaCodes;
  final SessionIntentCode intentCode;
  final SessionEntrySource entrySource;
}

class SessionFeedbackInput {
  const SessionFeedbackInput({
    required this.completionStatus,
    required this.helped,
    required this.tensionDelta,
    required this.painDelta,
    required this.energyDelta,
    required this.perceivedFit,
    required this.wouldRepeat,
    required this.entrySource,
  });

  final SessionFeedbackCompletionStatus completionStatus;
  final bool helped;
  final SessionDelta tensionDelta;
  final SessionDelta painDelta;
  final SessionDelta energyDelta;
  final SessionPerceivedFit perceivedFit;
  final bool wouldRepeat;
  final SessionEntrySource entrySource;
}

class PlayerPostSessionResult {
  const PlayerPostSessionResult({
    required this.feedback,
    required this.afterState,
  });

  final SessionFeedbackInput feedback;
  final SessionStateSnapshotInput afterState;
}