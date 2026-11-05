// lib/core/analytics/analytics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import '../supabase/supabase_providers.dart';
import 'analytics_service.dart';
import 'analytics_consent.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);

  if (ref.watch(analyticsConsentProvider) != AnalyticsConsentStatus.granted) {
    return const _DisabledAnalyticsService();
  }

  return ConsentAwareAnalyticsService(
    SupabaseAnalyticsService(client: client, userId: user?.id),
  );
});

class _DisabledAnalyticsService implements AnalyticsService {
  const _DisabledAnalyticsService();

  @override
  Future<void> track(AnalyticsEvent event) async {}
}
