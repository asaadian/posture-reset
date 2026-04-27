// lib/features/billing/domain/billing_repository.dart

import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_models.dart';

abstract class BillingRepository {
  Future<bool> isAvailable();

  Future<List<BillingProductDetails>> loadProducts({
    required Set<String> productIds,
  });

  Stream<List<PurchaseDetails>> get purchaseUpdates;

  Future<void> buyNonConsumable({
    required String productId,
  });

  Future<void> restorePurchases();

  Future<void> completePurchase(PurchaseDetails purchase);
}