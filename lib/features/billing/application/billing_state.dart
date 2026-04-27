// lib/features/billing/application/billing_state.dart

import '../domain/billing_models.dart';

class BillingState {
  const BillingState({
    required this.status,
    required this.isStoreAvailable,
    required this.products,
    this.selectedProduct,
    this.failure,
  });

  const BillingState.initial()
      : status = BillingPurchaseStatus.idle,
        isStoreAvailable = false,
        products = const <BillingProductDetails>[],
        selectedProduct = null,
        failure = null;

  final BillingPurchaseStatus status;
  final bool isStoreAvailable;
  final List<BillingProductDetails> products;
  final BillingProductDetails? selectedProduct;
  final BillingFailure? failure;

  bool get isBusy {
    return status == BillingPurchaseStatus.loadingProducts ||
        status == BillingPurchaseStatus.purchasing ||
        status == BillingPurchaseStatus.verifying;
  }

  bool get canPurchase {
    return isStoreAvailable &&
        selectedProduct != null &&
        !isBusy;
  }

  BillingState copyWith({
    BillingPurchaseStatus? status,
    bool? isStoreAvailable,
    List<BillingProductDetails>? products,
    BillingProductDetails? selectedProduct,
    BillingFailure? failure,
    bool clearFailure = false,
  }) {
    return BillingState(
      status: status ?? this.status,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}