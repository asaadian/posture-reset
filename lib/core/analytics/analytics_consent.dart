import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No optional analytics SDK is initialized before an explicit grant.
enum AnalyticsConsentStatus { unknown, denied, granted }

const _consentKey = 'desk_workout.optional_analytics_consent.v1';

final analyticsConsentProvider =
    NotifierProvider<AnalyticsConsentController, AnalyticsConsentStatus>(
  AnalyticsConsentController.new,
);

class AnalyticsConsentController extends Notifier<AnalyticsConsentStatus> {
  bool _loaded = false;

  @override
  AnalyticsConsentStatus build() => AnalyticsConsentStatus.unknown;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_consentKey);
      final saved = switch (value) {
        'granted' => AnalyticsConsentStatus.granted,
        'denied' => AnalyticsConsentStatus.denied,
        _ => AnalyticsConsentStatus.unknown,
      };
      state = saved;
      if (saved == AnalyticsConsentStatus.granted) {
        await PosthogAnalyticsRuntime.enable();
      }
    } catch (error) {
      debugPrint('Optional analytics initialization unavailable: $error');
    }
  }

  Future<void> choose(bool allow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consentKey, allow ? 'granted' : 'denied');

    // Stop collection immediately on withdrawal, and only initialize
    // PostHog after a persisted, affirmative decision.
    if (allow) {
      state = AnalyticsConsentStatus.granted;
      await PosthogAnalyticsRuntime.enable();
    } else {
      state = AnalyticsConsentStatus.denied;
      await PosthogAnalyticsRuntime.disable();
    }
  }
}

class PosthogAnalyticsRuntime {
  PosthogAnalyticsRuntime._();

  static const String host = 'https://eu.i.posthog.com';
  static const String projectToken =
      'phc_vKbDPpW3Ss7fhd7K2a2YAg9HJQ4M29jQ3CVDoGy6e73D';

  static bool _initialized = false;
  static bool _enabled = false;

  static Future<void> enable() async {
    try {
      if (!_initialized) {
        final config = PostHogConfig(projectToken)
          ..host = host
          ..debug = kDebugMode
          ..captureApplicationLifecycleEvents = false
          ..captureScreenViews = false
          ..sessionReplay = false;

        await Posthog().setup(config);
        _initialized = true;
      }
      await Posthog().enable();
      _enabled = true;
    } catch (error) {
      _enabled = false;
      debugPrint('PostHog opt-in failed: $error');
    }
  }

  static Future<void> disable() async {
    _enabled = false;
    if (!_initialized) return;
    try {
      await Posthog().disable();
    } catch (error) {
      debugPrint('PostHog opt-out failed: $error');
    }
  }

  /// Only strictly allowlisted, non-health event properties may leave the app.
  static Future<void> capture({
    required String eventName,
    String? surface,
    String? feature,
    String? result,
    String? tier,
  }) async {
    if (!_enabled || !_initialized) return;
    try {
      final properties = <String, Object>{
        if (surface != null) 'surface': surface,
        if (feature != null) 'feature': feature,
        if (result != null) 'result': result,
        if (tier != null) 'access_tier': tier,
      };
      await Posthog().capture(eventName: eventName, properties: properties);
    } catch (error) {
      debugPrint('PostHog capture failed: $error');
    }
  }
}
