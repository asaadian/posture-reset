// lib/features/re_engagement/domain/re_engagement_models.dart

import '../../player/domain/session_continuity_models.dart';

enum ReEngagementType {
  continueSession,
  returnToSaved,
  quickRelief,
  consistencyRecovery,
}

enum ReEngagementPriority {
  high,
  medium,
  low,
}

enum ReEngagementStatus {
  pending,
  shown,
  acted,
  dismissed,
  expired;

  String get dbValue {
    switch (this) {
      case ReEngagementStatus.pending:
        return 'pending';
      case ReEngagementStatus.shown:
        return 'shown';
      case ReEngagementStatus.acted:
        return 'acted';
      case ReEngagementStatus.dismissed:
        return 'dismissed';
      case ReEngagementStatus.expired:
        return 'expired';
    }
  }

  static ReEngagementStatus fromRaw(String? raw) {
    switch (raw) {
      case 'shown':
        return ReEngagementStatus.shown;
      case 'acted':
        return ReEngagementStatus.acted;
      case 'dismissed':
        return ReEngagementStatus.dismissed;
      case 'expired':
        return ReEngagementStatus.expired;
      case 'pending':
      default:
        return ReEngagementStatus.pending;
    }
  }
}

class ReEngagementCandidate {
  const ReEngagementCandidate({
    required this.id,
    required this.type,
    required this.priority,
    required this.titleKey,
    required this.titleFallback,
    required this.bodyKey,
    required this.bodyFallback,
    required this.createdAt,
    required this.candidateKey,
    this.sessionId,
    this.painAreaCode,
    this.continuityAction,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final ReEngagementType type;
  final ReEngagementPriority priority;
  final String titleKey;
  final String titleFallback;
  final String bodyKey;
  final String bodyFallback;
  final String candidateKey;
  final DateTime createdAt;
  final String? sessionId;
  final String? painAreaCode;
  final ContinuityActionType? continuityAction;
  final Map<String, Object?> metadata;
}

class ReEngagementRecord {
  const ReEngagementRecord({
    required this.id,
    required this.userId,
    required this.candidateType,
    required this.candidateKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sessionId,
    this.painAreaCode,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String userId;
  final ReEngagementType candidateType;
  final String candidateKey;
  final ReEngagementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sessionId;
  final String? painAreaCode;
  final Map<String, Object?> metadata;

  factory ReEngagementRecord.fromMap(Map<String, dynamic> map) {
    return ReEngagementRecord(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      candidateType: _typeFromRaw(map['candidate_type'] as String?),
      candidateKey: map['candidate_key'] as String,
      status: ReEngagementStatus.fromRaw(map['status'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      sessionId: map['session_id'] as String?,
      painAreaCode: map['pain_area_code'] as String?,
      metadata: Map<String, Object?>.from(
        (map['metadata'] as Map?) ?? const <String, Object?>{},
      ),
    );
  }

  static ReEngagementType _typeFromRaw(String? raw) {
    switch (raw) {
      case 'return_to_saved':
        return ReEngagementType.returnToSaved;
      case 'quick_relief':
        return ReEngagementType.quickRelief;
      case 'consistency_recovery':
        return ReEngagementType.consistencyRecovery;
      case 'continue_session':
      default:
        return ReEngagementType.continueSession;
    }
  }
}

class ReEngagementSnapshot {
  const ReEngagementSnapshot({
    required this.notificationsEnabled,
    required this.candidates,
    required this.topCandidate,
  });

  final bool notificationsEnabled;
  final List<ReEngagementCandidate> candidates;
  final ReEngagementCandidate? topCandidate;

  bool get hasContent => candidates.isNotEmpty;
}