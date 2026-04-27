// lib/features/access/domain/access_policy.dart

import 'access_models.dart';

class AccessPolicy {
  const AccessPolicy._();

  static Entitlement? requiredEntitlementForTier(AccessTier tier) {
    switch (tier) {
      case AccessTier.free:
        return null;
      case AccessTier.coreAccess:
        return Entitlement.coreAccess;
      case AccessTier.premiumLater:
        return Entitlement.adaptiveCoaching;
    }
  }

  static Entitlement? requiredEntitlementForFeature(LockedFeature feature) {
    switch (feature) {
      case LockedFeature.session:
      case LockedFeature.sessionPlayer:
      case LockedFeature.quickFixFullAccess:
      case LockedFeature.bodyMapRecommendations:
      case LockedFeature.savedSessions:
      case LockedFeature.sessionHistory:
      case LockedFeature.continuityAdvanced:
      case LockedFeature.insightsFullAccess:
      case LockedFeature.insightsHeatmap:
      case LockedFeature.insightsLogs:
        return Entitlement.coreAccess;

      case LockedFeature.adaptivePlans:
        return Entitlement.adaptiveCoaching;

      case LockedFeature.reminderDelivery:
        return Entitlement.reminderDelivery;
    }
  }

  static AccessTier requiredTierForFeature(LockedFeature feature) {
    switch (feature) {
      case LockedFeature.session:
      case LockedFeature.sessionPlayer:
      case LockedFeature.quickFixFullAccess:
      case LockedFeature.bodyMapRecommendations:
      case LockedFeature.savedSessions:
      case LockedFeature.sessionHistory:
      case LockedFeature.continuityAdvanced:
      case LockedFeature.insightsFullAccess:
      case LockedFeature.insightsHeatmap:
      case LockedFeature.insightsLogs:
        return AccessTier.coreAccess;

      case LockedFeature.adaptivePlans:
      case LockedFeature.reminderDelivery:
        return AccessTier.premiumLater;
    }
  }

  static AccessDecision canAccessTier({
    required AccessSnapshot snapshot,
    required AccessTier tier,
    LockedFeature? feature,
  }) {
    final entitlement = requiredEntitlementForTier(tier);

    if (entitlement == null) {
      return const AccessDecision.allowed();
    }

    if (snapshot.hasEntitlement(entitlement)) {
      return const AccessDecision.allowed();
    }

    return AccessDecision.locked(
      requiredEntitlement: entitlement,
      requiredTier: tier,
      lockedFeature: feature,
    );
  }

 static AccessDecision canAccessFeature({
  required AccessSnapshot snapshot,
  required LockedFeature feature,
}) {
  final entitlement = requiredEntitlementForFeature(feature);

  if (entitlement == null) {
    return const AccessDecision.allowed();
  }

  if (snapshot.hasEntitlement(entitlement)) {
    return const AccessDecision.allowed();
  }

  return AccessDecision.locked(
    requiredEntitlement: entitlement,
    requiredTier: requiredTierForFeature(feature),
    lockedFeature: feature,
  );
}

  static bool isPreviewAllowed(AccessTier tier) {
    switch (tier) {
      case AccessTier.free:
      case AccessTier.coreAccess:
        return true;
      case AccessTier.premiumLater:
        return false;
    }
  }
}