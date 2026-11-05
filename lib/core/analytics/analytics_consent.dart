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
    // A refusal takes effect before writing preferences.
    if (!allow) {
      state = AnalyticsConsentStatus.denied;
      await PosthogAnalyticsRuntime.disable();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consentKey, allow ? 'granted' : 'denied');
    if (allow) {
      state = AnalyticsConsentStatus.granted;
      await PosthogAnalyticsRuntime.enable();
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
  static int _decisionVersion = 0;
  static Future<void>? _setupFuture;

  static const Set<String> _allowedEvents = {
    'app_opened',
    'tab_selected',
    'session_started',
    'session_completed',
    'session_abandoned',
    'program_started',
    'program_day_started',
    'program_day_completed',
    'quick_fix_recommendation_viewed',
    'paywall_viewed',
    'unlock_tapped',
    'purchase_started',
    'purchase_success',
    'purchase_cancelled',
    'purchase_failed',
    'restore_tapped',
    'restore_success',
    'restore_failed',
    'locked_feature_viewed',
    'locked_feature_cta_tapped',
  };

  static const Set<String> _allowedSurfaces = {
    'dashboard', 'sessions_library', 'explore', 'quick_fix', 'body_map',
    'insights', 'saved', 'history', 'profile', 'premium', 'session_detail',
    'programs',
  };

  static Future<void> _setup() async {
    final config = PostHogConfig(projectToken)
      ..host = host
      ..debug = kDebugMode
      ..captureApplicationLifecycleEvents = false
      ..sessionReplay = false
      ..preloadFeatureFlags = false;

    await Posthog().setup(config);
    _initialized = true;
  }

  static Future<void> enable() async {
    final decision = ++_decisionVersion;
    try {
      if (!_initialized) {
        _setupFuture ??= _setup();
        await _setupFuture;
      }
      if (decision != _decisionVersion) return;
      await Posthog().enable();
      if (decision != _decisionVersion) {
        await Posthog().disable();
        return;
      }
      _enabled = true;
      await capture(eventName: 'app_opened');
    } catch (error) {
      _enabled = false;
      _setupFuture = null;
      debugPrint('PostHog opt-in failed: $error');
    }
  }

  static Future<void> disable() async {
    ++_decisionVersion;
    _enabled = false;
    try {
      // If a grant is still initializing, ensure a later refusal wins.
      if (_setupFuture != null && !_initialized) {
        await _setupFuture;
      }
      if (_initialized) await Posthog().disable();
    } catch (error) {
      debugPrint('PostHog opt-out failed: $error');
    }
  }

  /// Never forward user IDs, free text, selected body areas, symptoms,
  /// session/program IDs, product identifiers, or arbitrary metadata.
  static Future<void> capture({
    required String eventName,
    String? surface,
    String? feature,
    String? result,
    String? tier,
  }) async {
    if (!_enabled || !_initialized || !_allowedEvents.contains(eventName)) return;
    try {
      final properties = <String, Object>{
        if (surface != null && _allowedSurfaces.contains(surface))
          'surface': surface,
      };
      await Posthog().capture(eventName: eventName, properties: properties);
    } catch (error) {
      debugPrint('PostHog capture failed: $error');
    }
  }

}
