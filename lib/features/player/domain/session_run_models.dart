// lib/features/player/domain/session_run_models.dart

import 'session_feedback_models.dart';

enum SessionRunStatus {
  started,
  completed,
  abandoned,
}

class SessionRun {
  const SessionRun({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.status,
    required this.startedAt,
    required this.totalSteps,
    required this.completedSteps,
    required this.totalElapsedSeconds,
    required this.createdAt,
    required this.updatedAt,
    required this.entrySource,
    this.completedAt,
    this.abandonedAt,
    this.lastStepId,
    this.exitReason,
  });

  final String id;
  final String userId;
  final String sessionId;
  final SessionRunStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? abandonedAt;
  final int totalSteps;
  final int completedSteps;
  final int totalElapsedSeconds;
  final String? lastStepId;
  final String? exitReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SessionEntrySource entrySource;

  bool get isActive => status == SessionRunStatus.started;

  factory SessionRun.fromMap(Map<String, dynamic> map) {
    return SessionRun(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      sessionId: map['session_id'] as String,
      status: _statusFromRaw(map['status'] as String?),
      startedAt: DateTime.parse(map['started_at'] as String).toUtc(),
      completedAt: _parseNullableDate(map['completed_at']),
      abandonedAt: _parseNullableDate(map['abandoned_at']),
      totalSteps: _asInt(map['total_steps']),
      completedSteps: _asInt(map['completed_steps']),
      totalElapsedSeconds: _asInt(map['total_elapsed_seconds']),
      lastStepId: map['last_step_id'] as String?,
      exitReason: map['exit_reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      entrySource: SessionEntrySource.fromRaw(map['entry_source'] as String?),
    );
  }

  static SessionRunStatus _statusFromRaw(String? raw) {
    switch (raw) {
      case 'completed':
        return SessionRunStatus.completed;
      case 'abandoned':
        return SessionRunStatus.abandoned;
      case 'started':
      default:
        return SessionRunStatus.started;
    }
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}