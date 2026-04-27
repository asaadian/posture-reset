// lib/features/access/application/access_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/supabase_entitlements_repository.dart';
import '../domain/access_models.dart';
import '../domain/entitlements_repository.dart';

final entitlementsRepositoryProvider = Provider<EntitlementsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseEntitlementsRepository(client);
});

final accessSnapshotProvider = FutureProvider<AccessSnapshot>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return AccessSnapshot.guest;
  }

  final repository = ref.watch(entitlementsRepositoryProvider);
  final entitlements = await repository.fetchActiveEntitlements(user.id);

  return AccessSnapshot(
    userId: user.id,
    entitlements: entitlements,
  );
});

final hasCoreAccessProvider = Provider<bool>((ref) {
  final snapshot = ref.watch(accessSnapshotProvider);

  return snapshot.maybeWhen(
    data: (value) => value.hasCoreAccess,
    orElse: () => false,
  );
});