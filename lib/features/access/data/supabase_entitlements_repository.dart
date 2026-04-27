// lib/features/access/data/supabase_entitlements_repository.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/access_models.dart';
import '../domain/entitlements_repository.dart';

class SupabaseEntitlementsRepository implements EntitlementsRepository {
  const SupabaseEntitlementsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Set<Entitlement>> fetchActiveEntitlements(String userId) async {
    try {
      final rows = await _client
          .from('user_entitlements')
          .select('entitlement_key,status')
          .eq('user_id', userId)
          .inFilter('status', const ['active', 'granted']);

      final entitlements = <Entitlement>{};

      for (final row in rows) {
        final entitlement = Entitlement.fromKey(
          row['entitlement_key'] as String?,
        );

        if (entitlement != null) {
          entitlements.add(entitlement);
        }
      }

      return entitlements;
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('fetchActiveEntitlements failed: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      return <Entitlement>{};
    } catch (error, stackTrace) {
      debugPrint('fetchActiveEntitlements failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return <Entitlement>{};
    }
  }
}