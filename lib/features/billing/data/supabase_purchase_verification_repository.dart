import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../domain/billing_models.dart';
import '../domain/purchase_verification_repository.dart';

class SupabasePurchaseVerificationRepository
    implements PurchaseVerificationRepository {
  const SupabasePurchaseVerificationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<BillingVerificationResult> verifyPurchase({
    required PurchaseDetails purchase,
  }) async {
    if (!Platform.isAndroid) {
      return const BillingVerificationResult(
        ok: false,
        errorCode: 'unsupported_platform',
      );
    }

    final session = _client.auth.currentSession;
    final accessToken = session?.accessToken.trim() ?? '';

    if (accessToken.isEmpty) {
      debugPrint('verifyPurchase blocked: missing Supabase auth session');

      return const BillingVerificationResult(
        ok: false,
        errorCode: 'not_authenticated',
      );
    }

    final token = purchase.verificationData.serverVerificationData.trim();

    if (token.isEmpty) {
      return const BillingVerificationResult(
        ok: false,
        errorCode: 'missing_purchase_token',
      );
    }

    try {
      final response = await _client.functions.invoke(
        'verify_purchase',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'platform': BillingPlatform.android.code,
          'productId': purchase.productID,
          'purchaseToken': token,
          'packageName': AppEnv.androidPackageName,
        },
      );

      final data = response.data;

      if (data is! Map) {
        debugPrint('verifyPurchase invalid response: $data');

        return const BillingVerificationResult(
          ok: false,
          errorCode: 'invalid_verification_response',
        );
      }

      final ok = data['ok'] == true;

      if (!ok) {
        final errorCode = data['error']?.toString() ?? 'verification_failed';
        debugPrint('verifyPurchase rejected by function: $data');

        return BillingVerificationResult(
          ok: false,
          errorCode: errorCode,
        );
      }

      final entitlement = data['entitlement'];

      if (entitlement is Map) {
        return BillingVerificationResult(
          ok: true,
          entitlementKey: entitlement['entitlement_key']?.toString(),
          status: entitlement['status']?.toString(),
        );
      }

      return const BillingVerificationResult(
        ok: true,
        entitlementKey: 'core_access',
        status: 'active',
      );
    } on FunctionException catch (error, stackTrace) {
      debugPrint('verifyPurchase function failed: ${error.details}');
      debugPrintStack(stackTrace: stackTrace);

      final details = error.details;
      if (details is Map) {
        return BillingVerificationResult(
          ok: false,
          errorCode: details['error']?.toString() ?? 'function_exception',
        );
      }

      return BillingVerificationResult(
        ok: false,
        errorCode: error.reasonPhrase ?? 'function_exception',
      );
    } catch (error, stackTrace) {
      debugPrint('verifyPurchase failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return BillingVerificationResult(
        ok: false,
        errorCode: error.toString(),
      );
    }
  }
}