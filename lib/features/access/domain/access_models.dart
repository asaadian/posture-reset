// lib/features/access/domain/access_models.dart

enum AccessTier {
  free,
  coreAccess,
  premiumLater;

  String get code {
    switch (this) {
      case AccessTier.free:
        return 'free';
      case AccessTier.coreAccess:
        return 'core_access';
      case AccessTier.premiumLater:
        return 'premium_later';
    }
  }

  static AccessTier fromCode(String? value) {
    switch ((value ?? '').trim()) {
      case 'core_access':
        return AccessTier.coreAccess;
      case 'premium_later':
        return AccessTier.premiumLater;
      case 'free':
      default:
        return AccessTier.free;
    }
  }
}

enum Entitlement {
  coreAccess,
  adaptiveCoaching,
  reminderDelivery;

  String get key {
    switch (this) {
      case Entitlement.coreAccess:
        return 'core_access';
      case Entitlement.adaptiveCoaching:
        return 'adaptive_coaching';
      case Entitlement.reminderDelivery:
        return 'reminder_delivery';
    }
  }

  static Entitlement? fromKey(String? value) {
    switch ((value ?? '').trim()) {
      case 'core_access':
        return Entitlement.coreAccess;
      case 'adaptive_coaching':
        return Entitlement.adaptiveCoaching;
      case 'reminder_delivery':
        return Entitlement.reminderDelivery;
      default:
        return null;
    }
  }
}

enum LockedFeature {
  session,
  sessionPlayer,
  quickFixFullAccess,
  bodyMapRecommendations,
  savedSessions,
  sessionHistory,
  continuityAdvanced,
  insightsFullAccess,
  insightsHeatmap,
  insightsLogs,
  adaptivePlans,
  reminderDelivery;

  String get code {
    switch (this) {
      case LockedFeature.session:
        return 'session';
      case LockedFeature.sessionPlayer:
        return 'session_player';
      case LockedFeature.quickFixFullAccess:
        return 'quick_fix_full_access';
      case LockedFeature.bodyMapRecommendations:
        return 'body_map_recommendations';
      case LockedFeature.savedSessions:
        return 'saved_sessions';
      case LockedFeature.sessionHistory:
        return 'session_history';
      case LockedFeature.continuityAdvanced:
        return 'continuity_advanced';
      case LockedFeature.insightsFullAccess:
        return 'insights_full_access';
      case LockedFeature.insightsHeatmap:
        return 'insights_heatmap';
      case LockedFeature.insightsLogs:
        return 'insights_logs';
      case LockedFeature.adaptivePlans:
        return 'adaptive_plans';
      case LockedFeature.reminderDelivery:
        return 'reminder_delivery';
    }
  }
}

class AccessDecision {
  const AccessDecision.allowed()
      : allowed = true,
        requiredEntitlement = null,
        requiredTier = AccessTier.free,
        lockedFeature = null;

  const AccessDecision.locked({
    required this.requiredEntitlement,
    required this.requiredTier,
    required this.lockedFeature,
  }) : allowed = false;

  final bool allowed;
  final Entitlement? requiredEntitlement;
  final AccessTier requiredTier;
  final LockedFeature? lockedFeature;
}

class AccessSnapshot {
  const AccessSnapshot({
    required this.userId,
    required this.entitlements,
  });

  final String? userId;
  final Set<Entitlement> entitlements;

  bool get isAuthenticated => userId != null;

  bool hasEntitlement(Entitlement entitlement) {
    return entitlements.contains(entitlement);
  }

  bool get hasCoreAccess => hasEntitlement(Entitlement.coreAccess);

  static const guest = AccessSnapshot(
    userId: null,
    entitlements: <Entitlement>{},
  );

  AccessSnapshot copyWith({
    String? userId,
    Set<Entitlement>? entitlements,
  }) {
    return AccessSnapshot(
      userId: userId ?? this.userId,
      entitlements: entitlements ?? this.entitlements,
    );
  }
}