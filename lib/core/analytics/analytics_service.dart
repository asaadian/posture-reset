// lib/core/analytics/analytics_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'analytics_event.dart';

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