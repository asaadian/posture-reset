// lib/features/player/data/session_continuity_repository_impl.dart

import '../../sessions/domain/saved_sessions_repository.dart';
import '../../sessions/domain/session_models.dart';
import '../../sessions/domain/sessions_repository.dart';
import '../domain/session_continuity_models.dart';
import '../domain/session_continuity_repository.dart';
import '../domain/session_run_models.dart';
import '../domain/session_runs_repository.dart';

class SessionContinuityRepositoryImpl implements SessionContinuityRepository {
  SessionContinuityRepositoryImpl({
    required SessionRunsRepository sessionRunsRepository,
    required SavedSessionsRepository savedSessionsRepository,
    required SessionsRepository sessionsRepository,
  })  : _sessionRunsRepository = sessionRunsRepository,
        _savedSessionsRepository = savedSessionsRepository,
        _sessionsRepository = sessionsRepository;

  final SessionRunsRepository _sessionRunsRepository;
  final SavedSessionsRepository _savedSessionsRepository;
  final SessionsRepository _sessionsRepository;

  @override
  Future<SessionContinuitySnapshot> getSnapshot({
    int recentRunsLimit = 12,
    int savedLimit = 12,
  }) async {
    final recentRuns = await _sessionRunsRepository.getRecentRuns(
      limit: recentRunsLimit,
    );
    final savedRecords = await _savedSessionsRepository.getRecentlySavedSessionRecords(
      limit: savedLimit,
    );

    final sessionIds = <String>{
      ...recentRuns.map((e) => e.sessionId),
      ...savedRecords.map((e) => e.sessionId),
    }.toList(growable: false);

    final sessions = sessionIds.isEmpty
        ? const <SessionSummary>[]
        : await _sessionsRepository.getSessionsByIds(sessionIds);

    final sessionById = {
      for (final session in sessions) session.id: session,
    };

    final historyItems = recentRuns
        .map((run) {
          final session = sessionById[run.sessionId];
          if (session == null) return null;

          return SessionHistoryItem(
            run: run,
            session: session,
            isResumable: _isRunResumable(run),
          );
        })
        .whereType<SessionHistoryItem>()
        .toList(growable: false);

    final latestRunBySessionId = <String, SessionRun>{};
    for (final run in recentRuns) {
      latestRunBySessionId.putIfAbsent(run.sessionId, () => run);
    }

    final savedItems = savedRecords
        .map((record) {
          final session = sessionById[record.sessionId];
          if (session == null) return null;

          final latestRun = latestRunBySessionId[record.sessionId];

          return SavedSessionContinuityItem(
            session: session,
            savedAt: record.createdAt,
            latestRun: latestRun,
            action: _savedItemAction(latestRun),
          );
        })
        .whereType<SavedSessionContinuityItem>()
        .toList(growable: false);

    final continueCandidate = _buildContinueCandidate(
      recentRuns: recentRuns,
      savedItems: savedItems,
      sessionById: sessionById,
    );

    return SessionContinuitySnapshot(
      continueCandidate: continueCandidate,
      historyItems: historyItems,
      savedItems: savedItems,
    );
  }

  @override
  Future<List<SessionHistoryItem>> getHistory({
    int limit = 24,
  }) async {
    final snapshot = await getSnapshot(
      recentRunsLimit: limit,
      savedLimit: 12,
    );
    return snapshot.historyItems;
  }

  @override
  Future<List<SavedSessionContinuityItem>> getSavedSessions({
    int limit = 24,
  }) async {
    final snapshot = await getSnapshot(
      recentRunsLimit: 24,
      savedLimit: limit,
    );
    return snapshot.savedItems;
  }

  @override
  Future<ContinueSessionCandidate?> getContinueCandidate() async {
    final snapshot = await getSnapshot(
      recentRunsLimit: 12,
      savedLimit: 12,
    );
    return snapshot.continueCandidate;
  }

  ContinueSessionCandidate? _buildContinueCandidate({
    required List<SessionRun> recentRuns,
    required List<SavedSessionContinuityItem> savedItems,
    required Map<String, SessionSummary> sessionById,
  }) {
    for (final run in recentRuns) {
      if (!run.isActive) continue;
      final session = sessionById[run.sessionId];
      if (session == null) continue;

      return ContinueSessionCandidate(
        session: session,
        run: run,
        reason: ContinuityReason.activeRun,
        action: ContinuityActionType.continueSession,
      );
    }

    for (final run in recentRuns) {
      if (!_isRunResumable(run)) continue;
      final session = sessionById[run.sessionId];
      if (session == null) continue;

      return ContinueSessionCandidate(
        session: session,
        run: run,
        reason: ContinuityReason.resumableRun,
        action: ContinuityActionType.resumeSession,
      );
    }

    if (savedItems.isNotEmpty) {
      final first = savedItems.first;
      return ContinueSessionCandidate(
        session: first.session,
        run: first.latestRun,
        reason: ContinuityReason.recentSaved,
        action: first.action,
      );
    }

    for (final run in recentRuns) {
      if (run.status != SessionRunStatus.completed) continue;
      final session = sessionById[run.sessionId];
      if (session == null) continue;

      return ContinueSessionCandidate(
        session: session,
        run: run,
        reason: ContinuityReason.recentCompleted,
        action: ContinuityActionType.repeatSession,
      );
    }

    return null;
  }

  ContinuityActionType _savedItemAction(SessionRun? latestRun) {
    if (latestRun == null) {
      return ContinuityActionType.startSession;
    }

    if (latestRun.isActive) {
      return ContinuityActionType.continueSession;
    }

    if (_isRunResumable(latestRun)) {
      return ContinuityActionType.resumeSession;
    }

    if (latestRun.status == SessionRunStatus.completed) {
      return ContinuityActionType.repeatSession;
    }

    return ContinuityActionType.startSession;
  }

  bool _isRunResumable(SessionRun run) {
    return run.status == SessionRunStatus.abandoned &&
        run.completedSteps > 0 &&
        run.completedSteps < run.totalSteps;
  }
}