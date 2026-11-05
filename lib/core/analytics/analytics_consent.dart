import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No optional analytics SDK is initialized before an explicit grant.
enum AnalyticsConsentStatus { loading, unknown, denied, granted }

const _consentKey = 'desk_workout.optional_analytics_consent.v1';

final analyticsConsentProvider =
    NotifierProvider<AnalyticsConsentController, AnalyticsConsentStatus>(
  AnalyticsConsentController.new,
);

class AnalyticsConsentController extends Notifier<AnalyticsConsentStatus> {
  String? _activeUserId;
  bool _loaded = false;

  @override
  AnalyticsConsentStatus build() => AnalyticsConsentStatus.loading;

  Future<void> loadForUser(String? userId) async {
    if (_loaded && _activeUserId == userId) return;

    final previousUser = _activeUserId;
    _activeUserId = userId;
    _loaded = true;
    state = AnalyticsConsentStatus.loading;

    // A sign-out/account switch instantly blocks all optional analytics.
    await PosthogAnalyticsRuntime.disable();
    if (previousUser != null && previousUser != userId) {
      await PosthogAnalyticsRuntime.resetIdentity();
    }

    if (userId == null) {
      state = AnalyticsConsentStatus.unknown;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('$_consentKey.$userId');
      if (_activeUserId != userId) return;

      final saved = switch (value) {
        'granted' => AnalyticsConsentStatus.granted,
        'denied' => AnalyticsConsentStatus.denied,
        _ => AnalyticsConsentStatus.unknown,
      };
      if (saved == AnalyticsConsentStatus.granted) {
        await PosthogAnalyticsRuntime.enable();
      }
      if (_activeUserId == userId) state = saved;
    } catch (error) {
      if (_activeUserId == userId) state = AnalyticsConsentStatus.unknown;
      debugPrint('Optional analytics consent could not be loaded: $error');
    }
  }

  Future<void> choose(bool allow) async {
    final userId = _activeUserId;
    if (userId == null) return;

    // A refusal takes effect immediately, even before the disk write.
    if (!allow) {
      state = AnalyticsConsentStatus.denied;
      await PosthogAnalyticsRuntime.disable();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_consentKey.$userId', allow ? 'granted' : 'denied');

    if (_activeUserId != userId) return;
    if (allow) {
      await PosthogAnalyticsRuntime.enable();
      if (_activeUserId == userId) state = AnalyticsConsentStatus.granted;
    }
  }
}

class PosthogAnalyticsRuntime {
  PosthogAnalyticsRuntime._();

  // Public project configuration injected at build time. Do not ship
  // development, production, or fallback tokens in committed source files.
  static const String host = String.fromEnvironment('POSTHOG_HOST');
  static const String projectToken =
      String.fromEnvironment('POSTHOG_PROJECT_TOKEN');

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
      ..sessionReplay = false;

    await Posthog().setup(config);
    _initialized = true;
  }

  static Future<void> enable() async {
    final decision = ++_decisionVersion;
    try {
      if (projectToken.isEmpty || !host.startsWith('https://')) {
        debugPrint('PostHog is unconfigured: analytics remains disabled.');
        return;
      }
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

  static Future<void> resetIdentity() async {
    if (!_initialized) return;
    try {
      await Posthog().reset();
    } catch (error) {
      debugPrint('PostHog reset failed: $error');
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
