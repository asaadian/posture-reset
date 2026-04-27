// lib/features/billing/domain/purchase_verification_repository.dart

import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_models.dart';

abstract class PurchaseVerificationRepository {
  Future<BillingVerificationResult> verifyPurchase({
    required PurchaseDetails purchase,
  });
}