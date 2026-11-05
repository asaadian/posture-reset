// lib/core/analytics/analytics_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'analytics_event.dart';
import 'analytics_consent.dart';

abstract class AnalyticsService {
  Future<void> track(AnalyticsEvent event);
}

class SupabaseAnalyticsService implements AnalyticsService {
  const SupabaseAnalyticsService({
    required SupabaseClient client,
    required String? userId,
  })  : _client = client,
        _userId = userId;

  final SupabaseClient _client;
  final String? _userId;

  @override
  Future<void> track(AnalyticsEvent event) async {
    final userId = _userId?.trim();

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      await _client.from('analytics_events').insert(
            event.toInsertMap(userId: userId),
          );
    } catch (error, stackTrace) {
      debugPrint('Analytics track failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

/// Keeps existing Supabase premium events and mirrors a minimal allowlist
/// into PostHog. The provider constructs this only after explicit consent.
class ConsentAwareAnalyticsService implements AnalyticsService {
  const ConsentAwareAnalyticsService(this._supabase);

  final SupabaseAnalyticsService _supabase;

  @override
  Future<void> track(AnalyticsEvent event) async {
    await _supabase.track(event);
    await PosthogAnalyticsRuntime.capture(
      eventName: event.eventName,
      surface: event.sourceSurface,
      feature: event.featureKey,
      result: event.resultCode,
      tier: event.accessTier,
    );
  }
}
