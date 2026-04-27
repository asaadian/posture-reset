// lib/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/body_map/presentation/pages/body_map_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/insights/presentation/pages/heatmap_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/insights/presentation/pages/logs_page.dart';
import '../../features/player/domain/session_feedback_models.dart';
import '../../features/player/presentation/pages/session_history_page.dart';
import '../../features/player/presentation/pages/session_player_page.dart';
import '../../features/profile/presentation/pages/audio_settings_page.dart';
import '../../features/profile/presentation/pages/integrations_page.dart';
import '../../features/profile/presentation/pages/mode_settings_page.dart';
import '../../features/profile/presentation/pages/notification_settings_page.dart';
import '../../features/profile/presentation/pages/premium_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/quick_fix/presentation/pages/quick_fix_page.dart';
import '../../features/sessions/presentation/pages/saved_sessions_page.dart';
import '../../features/sessions/presentation/pages/session_detail_page.dart';
import '../../features/sessions/presentation/pages/sessions_library_page.dart';
import '../../shared/widgets/feedback/route_not_found_page.dart';
import '../shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/app/dashboard',
    errorBuilder: (context, state) =>
        RouteNotFoundPage(attemptedLocation: state.uri.toString()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/sessions',
                name: 'sessions',
                builder: (context, state) => const SessionsLibraryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/quick-fix',
                name: 'quick-fix',
                builder: (context, state) => const QuickFixPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/insights',
                name: 'insights',
                builder: (context, state) => const InsightsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) {
          final modeParam = state.uri.queryParameters['mode'];
          final redirectTo = state.uri.queryParameters['redirect'];

          final initialMode =
              modeParam == 'signup' ? AuthMode.signUp : AuthMode.signIn;

          return AuthPage(
            initialMode: initialMode,
            redirectTo: redirectTo,
          );
        },
      ),
      GoRoute(
        path: '/app/body-map',
        name: 'body-map',
        builder: (context, state) => const BodyMapPage(),
      ),
      GoRoute(
        path: '/app/saved',
        name: 'saved-sessions',
        builder: (context, state) => const SavedSessionsPage(),
      ),
      GoRoute(
        path: '/app/history',
        name: 'session-history',
        builder: (context, state) => const SessionHistoryPage(),
      ),
      GoRoute(
        path: '/app/sessions/detail/:id',
        name: 'session-detail',
        builder: (context, state) {
          final sessionId = state.pathParameters['id'];
          if (sessionId == null || sessionId.isEmpty) {
            return const RouteNotFoundPage(
              attemptedLocation: '/app/sessions/detail/:id',
            );
          }
          return SessionDetailPage(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/app/sessions/player/:id',
        name: 'session-player',
        builder: (context, state) {
          final sessionId = state.pathParameters['id'];
          if (sessionId == null || sessionId.isEmpty) {
            return const RouteNotFoundPage(
              attemptedLocation: '/app/sessions/player/:id',
            );
          }

          final entrySource = SessionEntrySource.fromRaw(
            state.uri.queryParameters['source'],
          );

          return SessionPlayerPage(
            sessionId: sessionId,
            entrySource: entrySource,
          );
        },
      ),
      GoRoute(
        path: '/app/insights/heatmap',
        name: 'heatmap',
        builder: (context, state) => const HeatmapPage(),
      ),
      GoRoute(
        path: '/app/insights/logs',
        name: 'logs',
        builder: (context, state) => const LogsPage(),
      ),
      GoRoute(
        path: '/app/profile/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/app/profile/settings/audio',
        name: 'audio-settings',
        builder: (context, state) => const AudioSettingsPage(),
      ),
      GoRoute(
        path: '/app/profile/settings/notifications',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/app/profile/settings/modes',
        name: 'mode-settings',
        builder: (context, state) => const ModeSettingsPage(),
      ),
      GoRoute(
        path: '/app/profile/premium',
        name: 'premium',
        builder: (context, state) => const PremiumPage(),
      ),
      GoRoute(
        path: '/app/profile/integrations',
        name: 'integrations',
        builder: (context, state) => const IntegrationsPage(),
      ),
    ],
  );
});