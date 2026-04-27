// lib/features/re_engagement/data/re_engagement_repository_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../player/domain/session_continuity_models.dart';
import '../../player/domain/session_continuity_repository.dart';
import '../../player/domain/session_run_models.dart';
import '../../profile/domain/profile_models.dart';
import '../domain/re_engagement_models.dart';
import '../domain/re_engagement_records_repository.dart';
import '../domain/re_engagement_repository.dart';

class ReEngagementRepositoryImpl implements ReEngagementRepository {
  ReEngagementRepositoryImpl({
    required SupabaseClient client,
    required SessionContinuityRepository continuityRepository,
    required ReEngagementRecordsRepository recordsRepository,
    required UserPreferences? preferences,
  })  : _client = client,
        _continuityRepository = continuityRepository,
        _recordsRepository = recordsRepository,
        _preferences = preferences;

  final SupabaseClient _client;
  final SessionContinuityRepository _continuityRepository;
  final ReEngagementRecordsRepository _recordsRepository;
  final UserPreferences? _preferences;

  @override
  Future<ReEngagementSnapshot> getSnapshot() async {
    final notificationsEnabled = _preferences?.notificationsEnabled ?? false;
    if (!notificationsEnabled) {
      return const ReEngagementSnapshot(
        notificationsEnabled: false,
        candidates: <ReEngagementCandidate>[],
        topCandidate: null,
      );
    }

    final continuity = await _continuityRepository.getSnapshot();
    final records = await _recordsRepository.getRecentRecords(limit: 40);
    final recentRuns = await _getRecentRuns(limit: 16);
    final quickFixEvents = await _getRecentQuickFixEvents(limit: 24);

    final candidates = <ReEngagementCandidate>[
      ..._buildContinueCandidates(continuity, records),
      ..._buildQuickReliefCandidates(quickFixEvents, recentRuns, records),
      ..._buildConsistencyCandidates(recentRuns, records),
      ..._buildSavedReturnCandidates(continuity, recentRuns, records),
    ]..sort(_compareCandidates);

    return ReEngagementSnapshot(
      notificationsEnabled: true,
      candidates: candidates,
      topCandidate: candidates.isEmpty ? null : candidates.first,
    );
  }

  @override
  Future<void> markShown(ReEngagementCandidate candidate) {
    return _recordsRepository.upsertRecord(
      type: candidate.type,
      candidateKey: candidate.candidateKey,
      status: ReEngagementStatus.shown,
      sessionId: candidate.sessionId,
      painAreaCode: candidate.painAreaCode,
      metadata: candidate.metadata,
    );
  }

  @override
  Future<void> markActed(ReEngagementCandidate candidate) {
    return _recordsRepository.upsertRecord(
      type: candidate.type,
      candidateKey: candidate.candidateKey,
      status: ReEngagementStatus.acted,
      sessionId: candidate.sessionId,
      painAreaCode: candidate.painAreaCode,
      metadata: candidate.metadata,
    );
  }

  @override
  Future<void> markDismissed(ReEngagementCandidate candidate) {
    return _recordsRepository.upsertRecord(
      type: candidate.type,
      candidateKey: candidate.candidateKey,
      status: ReEngagementStatus.dismissed,
      sessionId: candidate.sessionId,
      painAreaCode: candidate.painAreaCode,
      metadata: candidate.metadata,
    );
  }

  Future<List<SessionRun>> _getRecentRuns({int limit = 16}) async {
    final user = _client.auth.currentUser;
    if (user == null) return const <SessionRun>[];

    final response = await _client
        .from('session_runs')
        .select('''
id,
user_id,
session_id,
status,
started_at,
completed_at,
abandoned_at,
total_steps,
completed_steps,
total_elapsed_seconds,
last_step_id,
exit_reason,
created_at,
updated_at,
entry_source
''')
        .eq('user_id', user.id)
        .order('started_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map(
          (row) => SessionRun.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _getRecentQuickFixEvents({
    int limit = 24,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return const <Map<String, dynamic>>[];

    final response = await _client
        .from('quick_fix_events')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  List<ReEngagementCandidate> _buildContinueCandidates(
    SessionContinuitySnapshot continuity,
    List<ReEngagementRecord> records,
  ) {
    final candidate = continuity.continueCandidate;
    if (candidate == null) return const <ReEngagementCandidate>[];

    final key = switch (candidate.reason) {
      ContinuityReason.activeRun =>
        'continue:${candidate.run?.id ?? candidate.sessionId}',
      ContinuityReason.resumableRun =>
        'resume:${candidate.run?.id ?? candidate.sessionId}',
      ContinuityReason.recentSaved => 'saved:${candidate.sessionId}',
      ContinuityReason.recentCompleted => 'repeat:${candidate.sessionId}',
    };

    if (_isBlockedByCooldown(
      records: records,
      candidateKey: key,
      cooldownHours: 8,
    )) {
      return const <ReEngagementCandidate>[];
    }

    return [
      ReEngagementCandidate(
        id: key,
        type: ReEngagementType.continueSession,
        priority: ReEngagementPriority.high,
        titleKey: 're_engagement_continue_title',
        titleFallback: _continueTitleFallback(candidate),
        bodyKey: 're_engagement_continue_body',
        bodyFallback: _continueBodyFallback(candidate),
        createdAt: DateTime.now().toUtc(),
        candidateKey: key,
        sessionId: candidate.sessionId,
        continuityAction: candidate.action,
        metadata: {
          'reason': candidate.reason.name,
          'action': candidate.action.name,
        },
      ),
    ];
  }

  List<ReEngagementCandidate> _buildQuickReliefCandidates(
    List<Map<String, dynamic>> quickFixEvents,
    List<SessionRun> recentRuns,
    List<ReEngagementRecord> records,
  ) {
    if (quickFixEvents.length < 2) return const <ReEngagementCandidate>[];

    final recentCompleted = recentRuns.any(
      (run) =>
          run.status == SessionRunStatus.completed &&
          DateTime.now().toUtc().difference(run.startedAt).inHours < 18,
    );
    if (recentCompleted) return const <ReEngagementCandidate>[];

    final counts = <String, int>{};
    for (final event in quickFixEvents.take(8)) {
      final code = (event['selected_problem_code'] as String?)?.trim();
      if (code == null || code.isEmpty) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }

    if (counts.isEmpty) return const <ReEngagementCandidate>[];

    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final winner = top.first;
    if (winner.value < 2) return const <ReEngagementCandidate>[];

    final key = 'quick_relief:${winner.key}:${_dayBucket()}';

    if (_isBlockedByCooldown(
      records: records,
      candidateKey: key,
      cooldownHours: 20,
    )) {
      return const <ReEngagementCandidate>[];
    }

    return [
      ReEngagementCandidate(
        id: key,
        type: ReEngagementType.quickRelief,
        priority: ReEngagementPriority.medium,
        titleKey: 're_engagement_quick_relief_title',
        titleFallback: 'Quick relief available',
        bodyKey: 're_engagement_quick_relief_body',
        bodyFallback: _quickReliefBodyFallback(winner.key),
        createdAt: DateTime.now().toUtc(),
        candidateKey: key,
        painAreaCode: winner.key,
        metadata: {
          'problem_code': winner.key,
          'repeat_hits': winner.value,
        },
      ),
    ];
  }

  List<ReEngagementCandidate> _buildConsistencyCandidates(
    List<SessionRun> recentRuns,
    List<ReEngagementRecord> records,
  ) {
    if (recentRuns.length < 2) return const <ReEngagementCandidate>[];

    final latest = recentRuns.first.startedAt;
    final hoursSinceLatest =
        DateTime.now().toUtc().difference(latest).inHours;

    if (hoursSinceLatest < 48) {
      return const <ReEngagementCandidate>[];
    }

    final completedCount = recentRuns
        .where((run) => run.status == SessionRunStatus.completed)
        .length;
    if (completedCount < 2) {
      return const <ReEngagementCandidate>[];
    }

    final key = 'consistency:${_weekBucket()}';

    if (_isBlockedByCooldown(
      records: records,
      candidateKey: key,
      cooldownHours: 36,
    )) {
      return const <ReEngagementCandidate>[];
    }

    return [
      ReEngagementCandidate(
        id: key,
        type: ReEngagementType.consistencyRecovery,
        priority: ReEngagementPriority.low,
        titleKey: 're_engagement_consistency_title',
        titleFallback: 'Get back into rhythm',
        bodyKey: 're_engagement_consistency_body',
        bodyFallback: 'Your recent recovery streak cooled off. A short session can reset momentum.',
        createdAt: DateTime.now().toUtc(),
        candidateKey: key,
        metadata: {
          'hours_since_latest_run': hoursSinceLatest,
          'completed_runs_considered': completedCount,
        },
      ),
    ];
  }

  List<ReEngagementCandidate> _buildSavedReturnCandidates(
    SessionContinuitySnapshot continuity,
    List<SessionRun> recentRuns,
    List<ReEngagementRecord> records,
  ) {
    final hasImmediateContinue = continuity.continueCandidate != null &&
        (continuity.continueCandidate!.reason == ContinuityReason.activeRun ||
            continuity.continueCandidate!.reason ==
                ContinuityReason.resumableRun);

    if (hasImmediateContinue) return const <ReEngagementCandidate>[];
    if (continuity.savedItems.isEmpty) return const <ReEngagementCandidate>[];

    final latestRunAt =
        recentRuns.isEmpty ? null : recentRuns.first.startedAt;
    final latestGapHours = latestRunAt == null
        ? 999
        : DateTime.now().toUtc().difference(latestRunAt).inHours;

    if (latestGapHours < 72) return const <ReEngagementCandidate>[];

    final saved = continuity.savedItems.first;
    final key = 'saved_return:${saved.session.id}:${_weekBucket()}';

    if (_isBlockedByCooldown(
      records: records,
      candidateKey: key,
      cooldownHours: 60,
    )) {
      return const <ReEngagementCandidate>[];
    }

    return [
      ReEngagementCandidate(
        id: key,
        type: ReEngagementType.returnToSaved,
        priority: ReEngagementPriority.low,
        titleKey: 're_engagement_saved_title',
        titleFallback: 'Return to a saved session',
        bodyKey: 're_engagement_saved_body',
        bodyFallback:
            'You already bookmarked a session that fits your recovery flow.',
        createdAt: DateTime.now().toUtc(),
        candidateKey: key,
        sessionId: saved.session.id,
        continuityAction: saved.action,
        metadata: {
          'saved_action': saved.action.name,
        },
      ),
    ];
  }

  bool _isBlockedByCooldown({
    required List<ReEngagementRecord> records,
    required String candidateKey,
    required int cooldownHours,
  }) {
    final match = records.cast<ReEngagementRecord?>().firstWhere(
          (item) => item?.candidateKey == candidateKey,
          orElse: () => null,
        );

    if (match == null) return false;
    if (match.status == ReEngagementStatus.acted) return true;
    if (match.status == ReEngagementStatus.dismissed) {
      return DateTime.now().toUtc().difference(match.updatedAt).inHours <
          cooldownHours;
    }
    if (match.status == ReEngagementStatus.shown) {
      return DateTime.now().toUtc().difference(match.updatedAt).inHours <
          cooldownHours;
    }
    return false;
  }

  int _compareCandidates(
    ReEngagementCandidate a,
    ReEngagementCandidate b,
  ) {
    final byPriority = _priorityWeight(b.priority) - _priorityWeight(a.priority);
    if (byPriority != 0) return byPriority;
    return b.createdAt.compareTo(a.createdAt);
    }

  int _priorityWeight(ReEngagementPriority priority) {
    switch (priority) {
      case ReEngagementPriority.high:
        return 3;
      case ReEngagementPriority.medium:
        return 2;
      case ReEngagementPriority.low:
        return 1;
    }
  }

  String _continueTitleFallback(ContinueSessionCandidate candidate) {
    switch (candidate.action) {
      case ContinuityActionType.continueSession:
        return 'Continue your session';
      case ContinuityActionType.resumeSession:
        return 'Resume where you left off';
      case ContinuityActionType.repeatSession:
        return 'Repeat your last session';
      case ContinuityActionType.startSession:
        return 'Start this saved session';
    }
  }

  String _continueBodyFallback(ContinueSessionCandidate candidate) {
    switch (candidate.reason) {
      case ContinuityReason.activeRun:
        return 'You already have an active recovery session ready to continue.';
      case ContinuityReason.resumableRun:
        return 'Your previous session stopped mid-flow and can be resumed.';
      case ContinuityReason.recentSaved:
        return 'A recently saved session is ready whenever you want to return.';
      case ContinuityReason.recentCompleted:
        return 'Your last completed session is a good repeat candidate.';
    }
  }

  String _quickReliefBodyFallback(String painAreaCode) {
    switch (painAreaCode) {
      case 'neck':
        return 'You have been returning to neck relief patterns. A short reset may help.';
      case 'shoulder':
        return 'Shoulder relief keeps showing up in your recent quick fixes.';
      case 'wrist':
        return 'Wrist-focused relief appears repeatedly in your recent activity.';
      case 'back':
        return 'Lower-back relief has been a repeated need in your recent activity.';
      case 'eye':
        return 'Eye-strain relief has been coming up repeatedly.';
      case 'stress':
        return 'Stress-reset patterns are showing up repeatedly in your recent activity.';
      default:
        return 'A short recovery reset matches your recent quick-fix pattern.';
    }
  }

  String _dayBucket() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month}-${now.day}';
  }

  String _weekBucket() {
    final now = DateTime.now().toUtc();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month}-${monday.day}';
  }
}