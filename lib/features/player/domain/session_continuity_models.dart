// lib/features/player/domain/session_continuity_models.dart

import '../../sessions/domain/session_models.dart';
import 'session_run_models.dart';

enum ContinuityReason {
  activeRun,
  resumableRun,
  recentSaved,
  recentCompleted,
}

enum ContinuityActionType {
  continueSession,
  resumeSession,
  startSession,
  repeatSession,
}

class ContinueSessionCandidate {
  const ContinueSessionCandidate({
    required this.session,
    required this.reason,
    required this.action,
    this.run,
  });

  final SessionSummary session;
  final SessionRun? run;
  final ContinuityReason reason;
  final ContinuityActionType action;

  bool get hasRun => run != null;
  String get sessionId => session.id;
}

class SessionHistoryItem {
  const SessionHistoryItem({
    required this.run,
    required this.session,
    required this.isResumable,
  });

  final SessionRun run;
  final SessionSummary session;
  final bool isResumable;
}

class SavedSessionContinuityItem {
  const SavedSessionContinuityItem({
    required this.session,
    required this.savedAt,
    required this.latestRun,
    required this.action,
  });

  final SessionSummary session;
  final DateTime savedAt;
  final SessionRun? latestRun;
  final ContinuityActionType action;

  bool get hasRun => latestRun != null;
  bool get isResumable =>
      action == ContinuityActionType.continueSession ||
      action == ContinuityActionType.resumeSession;
}

class SessionContinuitySnapshot {
  const SessionContinuitySnapshot({
    required this.continueCandidate,
    required this.historyItems,
    required this.savedItems,
  });

  final ContinueSessionCandidate? continueCandidate;
  final List<SessionHistoryItem> historyItems;
  final List<SavedSessionContinuityItem> savedItems;

  bool get hasHistory => historyItems.isNotEmpty;
  bool get hasSaved => savedItems.isNotEmpty;
}