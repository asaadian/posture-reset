import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../access/application/access_providers.dart';
import '../domain/billing_models.dart';
import '../domain/billing_repository.dart';
import '../domain/purchase_verification_repository.dart';
import 'billing_state.dart';

class BillingController extends ChangeNotifier {
  BillingController({
    required this.ref,
    required this.productIds,
    required BillingRepository billingRepository,
    required PurchaseVerificationRepository verificationRepository,
  })  : _billingRepository = billingRepository,
        _verificationRepository = verificationRepository {
    _purchaseSubscription = _billingRepository.purchaseUpdates.listen(
      _handlePurchaseUpdates,
      onError: _handlePurchaseStreamError,
    );

    unawaited(loadProducts());
  }

  final Ref ref;
  final Set<String> productIds;
  final BillingRepository _billingRepository;
  final PurchaseVerificationRepository _verificationRepository;

  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  BillingState _state = const BillingState.initial();

  BillingState get state => _state;

  Future<void> loadProducts() async {
    _setState(
      _state.copyWith(
        status: BillingPurchaseStatus.loadingProducts,
        clearFailure: true,
      ),
    );

    try {
      final available = await _billingRepository.isAvailable();

      if (!available) {
        _setState(
          _state.copyWith(
            status: BillingPurchaseStatus.productUnavailable,
            isStoreAvailable: false,
            products: const <BillingProductDetails>[],
            selectedProduct: null,
            failure: const BillingFailure(
              code: 'store_unavailable',
              message: 'Store is not available on this device.',
            ),
          ),
        );
        return;
      }

      final products = await _billingRepository.loadProducts(
        productIds: productIds,
      );

      BillingProductDetails? selectedProduct;

      for (final product in products) {
        if (productIds.contains(product.id)) {
          selectedProduct = product;
          break;
        }
      }

      _setState(
        _state.copyWith(
          status: selectedProduct == null
              ? BillingPurchaseStatus.productUnavailable
              : BillingPurchaseStatus.idle,
          isStoreAvailable: true,
          products: products,
          selectedProduct: selectedProduct,
          failure: selectedProduct == null
              ? const BillingFailure(
                  code: 'product_unavailable',
                  message: 'Core Access product is not available.',
                )
              : null,
          clearFailure: selectedProduct != null,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('BillingController.loadProducts failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setState(
        _state.copyWith(
          status: BillingPurchaseStatus.failed,
          isStoreAvailable: false,
          failure: BillingFailure(
            code: 'load_products_failed',
            message: error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> purchaseCoreAccess() async {
    if (_state.isBusy) {
      return;
    }

    var product = _state.selectedProduct;

    if (product == null) {
      await loadProducts();
      product = _state.selectedProduct;
    }

    if (product == null) {
      return;
    }

    _setState(
      _state.copyWith(
        status: BillingPurchaseStatus.purchasing,
        clearFailure: true,
      ),
    );

    try {
      await _billingRepository.buyNonConsumable(
        productId: product.id,
      );
    } catch (error, stackTrace) {
      debugPrint('BillingController.purchaseCoreAccess failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setState(
        _state.copyWith(
          status: BillingPurchaseStatus.failed,
          failure: BillingFailure(
            code: 'purchase_start_failed',
            message: error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    if (_state.isBusy) {
      return;
    }

    _setState(
      _state.copyWith(
        status: BillingPurchaseStatus.purchasing,
        clearFailure: true,
      ),
    );

    try {
      await _billingRepository.restorePurchases();

      Future<void>.delayed(const Duration(seconds: 4), () {
        if (_state.status == BillingPurchaseStatus.purchasing) {
          _setState(
            _state.copyWith(
              status: BillingPurchaseStatus.idle,
              clearFailure: true,
            ),
          );
        }
      });
    } catch (error, stackTrace) {
      debugPrint('BillingController.restorePurchases failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setState(
        _state.copyWith(
          status: BillingPurchaseStatus.failed,
          failure: BillingFailure(
            code: 'restore_failed',
            message: error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if (!productIds.contains(purchase.productID)) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setState(
            _state.copyWith(
              status: BillingPurchaseStatus.purchasing,
              clearFailure: true,
            ),
          );
          break;

        case PurchaseStatus.canceled:
          _setState(
            _state.copyWith(
              status: BillingPurchaseStatus.cancelled,
              failure: const BillingFailure(
                code: 'purchase_cancelled',
                message: 'Purchase was cancelled.',
              ),
            ),
          );
          break;

        case PurchaseStatus.error:
          _setState(
            _state.copyWith(
              status: BillingPurchaseStatus.failed,
              failure: BillingFailure(
                code: purchase.error?.code ?? 'purchase_error',
                message: purchase.error?.message ?? 'Purchase failed.',
              ),
            ),
          );
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndGrant(purchase);
          break;
      }
    }
  }

  Future<void> _verifyAndGrant(PurchaseDetails purchase) async {
    _setState(
      _state.copyWith(
        status: BillingPurchaseStatus.verifying,
        clearFailure: true,
      ),
    );

    try {
      final result = await _verificationRepository.verifyPurchase(
        purchase: purchase,
      );

      if (!result.ok) {
        _setState(
          _state.copyWith(
            status: BillingPurchaseStatus.failed,
            failure: BillingFailure(
              code: result.errorCode ?? 'verification_failed',
              message: 'Purchase verification failed.',
            ),
          ),
        );
        return;
      }

      if (purchase.pendingCompletePurchase) {
        await _completeSafely(purchase);
      }

      ref.invalidate(accessSnapshotProvider);

      _setState(
        _state.copyWith(
          status: purchase.status == PurchaseStatus.restored
              ? BillingPurchaseStatus.restored
              : BillingPurchaseStatus.purchased,
          clearFailure: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('BillingController._verifyAndGrant failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setState(
        _state.copyWith(
          status: BillingPurchaseStatus.failed,
          failure: BillingFailure(
            code: 'verification_exception',
            message: error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _completeSafely(PurchaseDetails purchase) async {
    try {
      await _billingRepository.completePurchase(purchase);
    } catch (error, stackTrace) {
      debugPrint('BillingController.completePurchase failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handlePurchaseStreamError(Object error, StackTrace stackTrace) {
    debugPrint('Billing purchase stream failed: $error');
    debugPrintStack(stackTrace: stackTrace);

    _setState(
      _state.copyWith(
        status: BillingPurchaseStatus.failed,
        failure: BillingFailure(
          code: 'purchase_stream_error',
          message: error.toString(),
        ),
      ),
    );
  }

  void _setState(BillingState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_purchaseSubscription.cancel());
    super.dispose();
  }
}