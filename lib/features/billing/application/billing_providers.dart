import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/config/app_env.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/in_app_purchase_billing_repository.dart';
import '../data/supabase_purchase_verification_repository.dart';
import '../domain/billing_repository.dart';
import '../domain/purchase_verification_repository.dart';
import 'billing_controller.dart';

final billingProductIdsProvider = Provider<Set<String>>((ref) {
  return {
    AppEnv.coreAccessProductId,
  };
});

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return InAppPurchaseBillingRepository();
});

final purchaseVerificationRepositoryProvider =
    Provider<PurchaseVerificationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePurchaseVerificationRepository(client);
});

final billingControllerProvider =
    ChangeNotifierProvider.autoDispose<BillingController>((ref) {
  return BillingController(
    ref: ref,
    productIds: ref.watch(billingProductIdsProvider),
    billingRepository: ref.watch(billingRepositoryProvider),
    verificationRepository: ref.watch(purchaseVerificationRepositoryProvider),
  );
});