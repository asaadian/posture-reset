// lib/features/access/domain/entitlements_repository.dart

import 'access_models.dart';

abstract class EntitlementsRepository {
  Future<Set<Entitlement>> fetchActiveEntitlements(String userId);
}