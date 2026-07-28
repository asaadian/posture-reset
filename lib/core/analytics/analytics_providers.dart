// lib/core/analytics/analytics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../supabase/supabase_providers.dart';
import 'analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);

  return SupabaseAnalyticsService(
    client: client,
    userId: user?.id,
  );
});