// lib/core/analytics/analytics_event.dart

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.eventName,
    this.sourceSurface,
    this.featureKey,
    this.sessionId,
    this.accessTier,
    this.entitlementKey,
    this.productId,
    this.resultCode,
    this.metadata = const <String, Object?>{},
  });

  final String eventName;
  final String? sourceSurface;
  final String? featureKey;
  final String? sessionId;
  final String? accessTier;
  final String? entitlementKey;
  final String? productId;
  final String? resultCode;
  final Map<String, Object?> metadata;

  Map<String, Object?> toInsertMap({
    required String userId,
  }) {
    return {
      'user_id': userId,
      'event_name': eventName,
      'source_surface': sourceSurface,
      'feature_key': featureKey,
      'session_id': sessionId,
      'access_tier': accessTier,
      'entitlement_key': entitlementKey,
      'product_id': productId,
      'result_code': resultCode,
      'metadata': metadata,
    };
  }
}

abstract final class AnalyticsEvents {
  static const paywallViewed = 'paywall_viewed';
  static const unlockTapped = 'unlock_tapped';
  static const purchaseStarted = 'purchase_started';
  static const purchaseSuccess = 'purchase_success';
  static const purchaseCancelled = 'purchase_cancelled';
  static const purchaseFailed = 'purchase_failed';
  static const restoreTapped = 'restore_tapped';
  static const restoreSuccess = 'restore_success';
  static const restoreFailed = 'restore_failed';
  static const lockedFeatureViewed = 'locked_feature_viewed';
  static const lockedFeatureCtaTapped = 'locked_feature_cta_tapped';
}

abstract final class AnalyticsSurfaces {
  static const dashboard = 'dashboard';
  static const sessionsLibrary = 'sessions_library';
  static const sessionDetail = 'session_detail';
  static const quickFix = 'quick_fix';
  static const bodyMap = 'body_map';
  static const insights = 'insights';
  static const saved = 'saved';
  static const history = 'history';
  static const profile = 'profile';
  static const premium = 'premium';
}