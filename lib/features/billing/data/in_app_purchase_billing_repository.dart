// lib/features/billing/data/in_app_purchase_billing_repository.dart

import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/billing_models.dart';
import '../domain/billing_repository.dart';

class InAppPurchaseBillingRepository implements BillingRepository {
  InAppPurchaseBillingRepository({
    InAppPurchase? inAppPurchase,
  }) : _iap = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  @override
  Future<bool> isAvailable() {
    return _iap.isAvailable();
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates {
    return _iap.purchaseStream;
  }

  @override
  Future<List<BillingProductDetails>> loadProducts({
    required Set<String> productIds,
  }) async {
    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    return response.productDetails.map((product) {
      return BillingProductDetails(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        rawPrice: product.rawPrice,
        currencyCode: product.currencyCode,
      );
    }).toList(growable: false);
  }

  @override
  Future<void> buyNonConsumable({
    required String productId,
  }) async {
    final response = await _iap.queryProductDetails({productId});

    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      throw StateError('Product not found: $productId');
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    final started = await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!started) {
      throw StateError('Purchase flow could not be started.');
    }
  }

  @override
  Future<void> restorePurchases() {
    return _iap.restorePurchases();
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _iap.completePurchase(purchase);
  }
}