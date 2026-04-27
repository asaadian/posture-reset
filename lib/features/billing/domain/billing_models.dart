// lib/features/billing/domain/billing_models.dart

enum BillingProduct {
  coreAccessLifetime;

  String get entitlementKey {
    switch (this) {
      case BillingProduct.coreAccessLifetime:
        return 'core_access';
    }
  }
}

enum BillingPlatform {
  android,
  ios;

  String get code {
    switch (this) {
      case BillingPlatform.android:
        return 'android';
      case BillingPlatform.ios:
        return 'ios';
    }
  }
}

enum BillingPurchaseStatus {
  idle,
  loadingProducts,
  productUnavailable,
  purchasing,
  verifying,
  purchased,
  restored,
  cancelled,
  failed;
}

class BillingProductDetails {
  const BillingProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final double rawPrice;
  final String currencyCode;
}

class BillingFailure {
  const BillingFailure({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class BillingVerificationResult {
  const BillingVerificationResult({
    required this.ok,
    this.entitlementKey,
    this.status,
    this.errorCode,
  });

  final bool ok;
  final String? entitlementKey;
  final String? status;
  final String? errorCode;
}