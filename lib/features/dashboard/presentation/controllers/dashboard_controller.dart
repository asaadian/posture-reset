// lib/features/dashboard/presentation/controllers/dashboard_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../data/dashboard_repository_impl.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/dashboard_snapshot.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DashboardRepositoryImpl(client);
});

final dashboardControllerProvider =
    FutureProvider.autoDispose<DashboardSnapshot>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardSnapshot();
});

final dashboardHasContentProvider = Provider.autoDispose<bool>((ref) {
  final asyncValue = ref.watch(dashboardControllerProvider);

  return asyncValue.maybeWhen(
    data: (snapshot) => snapshot.hasContent,
    orElse: () => false,
  );
});