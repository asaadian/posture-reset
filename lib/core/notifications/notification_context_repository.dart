// lib/core/notifications/notification_context_repository.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum RecoveryNotificationKind {
  continueProgram,
  continueSession,
  returnToRecovery,
  featureNudge,
  dailyReset,
}

class RecoveryNotificationPlan {
  const RecoveryNotificationPlan({
    required this.kind,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.payload,
    this.userId,
    this.deferToday = false,
  });

  final RecoveryNotificationKind kind;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final String payload;
  final String? userId;

  /// When true, the reminder is scheduled from tomorrow onward. This prevents
  /// a same-day reminder after the user has already completed a recovery
  /// session today.
  final bool deferToday;

  RecoveryNotificationPlan copyWith({
    RecoveryNotificationKind? kind,
    String? title,
    String? body,
    int? hour,
    int? minute,
    String? payload,
    Object? userId = _sentinel,
    bool? deferToday,
  }) {
    return RecoveryNotificationPlan(
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      payload: payload ?? this.payload,
      userId: identical(userId, _sentinel) ? this.userId : userId as String?,
      deferToday: deferToday ?? this.deferToday,
    );
  }

  static const Object _sentinel = Object();
}

abstract class NotificationContextRepository {
  Future<RecoveryNotificationPlan> buildPlanForUser(String userId);
}

class SupabaseNotificationContextRepository
    implements NotificationContextRepository {
  SupabaseNotificationContextRepository(this._client);

  final SupabaseClient _client;

  static const int _defaultHour = 18;
  static const int _defaultMinute = 30;

  /// A half-finished session is only useful as notification context while it is
  /// still fresh. Older abandoned sessions become stale and the active program
  /// is a better reminder target.
  static const int _unfinishedSessionFreshHours = 24;

  @override
  Future<RecoveryNotificationPlan> buildPlanForUser(String userId) async {
    RecoveryNotificationPlan? plan;

    plan ??= await _freshUnfinishedSessionPlan(userId);
    plan ??= await _activeProgramPlan(userId);
    plan ??= await _returnToRecoveryPlan(userId);
    plan ??= await _featureNudgePlan(userId);
    plan ??= RecoveryNotificationPlan(
      kind: RecoveryNotificationKind.dailyReset,
      title: 'Time for a quick reset',
      body: 'Take two focused minutes for your neck, back, or wrists.',
      hour: _defaultHour,
      minute: _defaultMinute,
      payload: 'posture_reset://quick_fix',
      userId: userId,
    );

    final completedToday = await _hasCompletedRecoveryToday(userId);
    if (!completedToday) return plan;

    return plan.copyWith(
      deferToday: true,
      title: _tomorrowTitleFor(plan.kind),
      body: _tomorrowBodyFor(plan.kind),
    );
  }

  Future<RecoveryNotificationPlan?> _freshUnfinishedSessionPlan(
    String userId,
  ) async {
    try {
      final since = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: _unfinishedSessionFreshHours));

      final rows = await _client
          .from('session_runs')
          .select('id,session_id,status,started_at,created_at,completed_at')
          .eq('user_id', userId)
          .gte('started_at', since.toIso8601String())
          .order('started_at', ascending: false)
          .limit(10);

      if (rows is! List || rows.isEmpty) return null;

      for (final item in rows) {
        final run = Map<String, dynamic>.from(item as Map);
        final status = _string(run['status']).toLowerCase();
        final completedAt = _date(run['completed_at']);
        final startedAt = _date(run['started_at'] ?? run['created_at']);
        final sessionId = _string(run['session_id']);

        if (sessionId.isEmpty || startedAt == null) continue;

        final isFresh = DateTime.now().toUtc().difference(startedAt).inHours <=
            _unfinishedSessionFreshHours;
        if (!isFresh) continue;

        final looksFinished = completedAt != null ||
            status == 'completed' ||
            status == 'finished' ||
            status == 'done';
        if (looksFinished) continue;

        final looksUnfinished = status == 'abandoned' ||
            status == 'started' ||
            status == 'in_progress' ||
            status == 'running' ||
            status == 'active' ||
            status == 'paused' ||
            status.isEmpty;
        if (!looksUnfinished) continue;

        final title = await _sessionTitle(sessionId);

        return RecoveryNotificationPlan(
          kind: RecoveryNotificationKind.continueSession,
          title: 'Finish your recovery session',
          body: title == null
              ? 'You started a session. Finish it with one clean reset.'
              : 'Continue $title and complete today’s reset.',
          hour: 18,
          minute: 15,
          payload: 'posture_reset://session/$sessionId',
          userId: userId,
        );
      }

      return null;
    } catch (error, stackTrace) {
      debugPrint('[Notifications] unfinished session plan skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<RecoveryNotificationPlan?> _activeProgramPlan(String userId) async {
    try {
      final rows = await _client
          .from('user_recovery_program_dashboard_view')
          .select()
          .inFilter('status', const ['active', 'paused'])
          .order('last_started_day_at', ascending: false)
          .limit(1);

      if (rows is! List || rows.isEmpty) return null;

      final row = Map<String, dynamic>.from(rows.first as Map);
      final programId = _string(row['program_id'] ?? row['id']);
      final title = _firstNonEmptyString([
        row['program_title_fallback'],
        row['title_fallback'],
        row['program_title'],
      ]);
      final currentDay = _int(row['current_day']) ??
          _int(row['next_day_number']) ??
          ((_int(row['completed_day_count']) ?? 0) + 1);

      return RecoveryNotificationPlan(
        kind: RecoveryNotificationKind.continueProgram,
        title: 'Continue your recovery program',
        body: title == null
            ? 'Day $currentDay is ready. Keep the recovery chain moving.'
            : '$title — Day $currentDay is ready.',
        hour: 18,
        minute: 30,
        payload: programId.isEmpty
            ? 'posture_reset://programs'
            : 'posture_reset://program/$programId/day/$currentDay',
        userId: userId,
      );
    } catch (error, stackTrace) {
      debugPrint('[Notifications] active program plan skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<RecoveryNotificationPlan?> _returnToRecoveryPlan(String userId) async {
    try {
      final rows = await _client
          .from('session_runs')
          .select('started_at,completed_at,created_at')
          .eq('user_id', userId)
          .order('started_at', ascending: false)
          .limit(1);

      if (rows is! List || rows.isEmpty) return null;

      final row = Map<String, dynamic>.from(rows.first as Map);
      final last = _date(row['completed_at'] ?? row['started_at'] ?? row['created_at']);
      if (last == null) return null;

      final days = DateTime.now().toUtc().difference(last).inDays;
      if (days < 2) return null;

      return RecoveryNotificationPlan(
        kind: RecoveryNotificationKind.returnToRecovery,
        title: 'Restart with a short reset',
        body: 'It has been $days days. Start with one low-friction desk recovery session.',
        hour: 18,
        minute: 45,
        payload: 'posture_reset://quick_fix',
        userId: userId,
      );
    } catch (error, stackTrace) {
      debugPrint('[Notifications] return plan skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<RecoveryNotificationPlan?> _featureNudgePlan(String userId) async {
    try {
      final rows = await _client
          .from('analytics_events')
          .select('event_name,source_surface,created_at')
          .eq('user_id', userId)
          .inFilter('event_name', const [
            'locked_feature_viewed',
            'locked_feature_cta_tapped',
            'paywall_viewed',
          ])
          .order('created_at', ascending: false)
          .limit(1);

      if (rows is! List || rows.isEmpty) return null;

      final row = Map<String, dynamic>.from(rows.first as Map);
      final createdAt = _date(row['created_at']);
      if (createdAt != null &&
          DateTime.now().toUtc().difference(createdAt).inHours > 72) {
        return null;
      }

      final surface = _string(row['source_surface']);
      final area = surface.isEmpty ? 'your recovery tools' : surface.replaceAll('_', ' ');

      return RecoveryNotificationPlan(
        kind: RecoveryNotificationKind.featureNudge,
        title: 'Unlock deeper recovery tools',
        body: 'You checked $area. Core Access keeps programs, history, and premium sessions available.',
        hour: 19,
        minute: 15,
        payload: 'posture_reset://premium',
        userId: userId,
      );
    } catch (error, stackTrace) {
      debugPrint('[Notifications] feature plan skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> _hasCompletedRecoveryToday(String userId) async {
    try {
      final now = DateTime.now().toUtc();
      final startOfToday = DateTime.utc(now.year, now.month, now.day);

      final rows = await _client
          .from('session_runs')
          .select('completed_at,status,started_at')
          .eq('user_id', userId)
          .gte('started_at', startOfToday.toIso8601String())
          .order('started_at', ascending: false)
          .limit(5);

      if (rows is! List || rows.isEmpty) return false;

      for (final item in rows) {
        final row = Map<String, dynamic>.from(item as Map);
        final status = _string(row['status']).toLowerCase();
        final completedAt = _date(row['completed_at']);
        if (completedAt != null ||
            status == 'completed' ||
            status == 'finished' ||
            status == 'done') {
          return true;
        }
      }
      return false;
    } catch (error, stackTrace) {
      debugPrint('[Notifications] completed-today check skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  String _tomorrowTitleFor(RecoveryNotificationKind kind) {
    switch (kind) {
      case RecoveryNotificationKind.continueSession:
        return 'Continue tomorrow';
      case RecoveryNotificationKind.continueProgram:
        return 'Next program step tomorrow';
      case RecoveryNotificationKind.returnToRecovery:
      case RecoveryNotificationKind.featureNudge:
      case RecoveryNotificationKind.dailyReset:
        return 'Recovery reminder set for tomorrow';
    }
  }

  String _tomorrowBodyFor(RecoveryNotificationKind kind) {
    switch (kind) {
      case RecoveryNotificationKind.continueSession:
        return 'You already completed recovery work today. Your session reminder will wait until tomorrow.';
      case RecoveryNotificationKind.continueProgram:
        return 'You already completed recovery work today. Your next program reminder will wait until tomorrow.';
      case RecoveryNotificationKind.returnToRecovery:
      case RecoveryNotificationKind.featureNudge:
      case RecoveryNotificationKind.dailyReset:
        return 'You already completed recovery work today. The next reminder will wait until tomorrow.';
    }
  }

  Future<String?> _sessionTitle(String sessionId) async {
    try {
      final row = await _client
          .from('session_templates')
          .select('title_fallback')
          .eq('id', sessionId)
          .maybeSingle();
      if (row == null) return null;
      final title = _string((row as Map)['title_fallback']);
      return title.isEmpty ? null : title;
    } catch (_) {
      return null;
    }
  }

  String? _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      final text = _string(value);
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String _string(Object? value) => value?.toString().trim() ?? '';

  int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  DateTime? _date(Object? value) {
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}
