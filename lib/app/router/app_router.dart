// lib/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_callback_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/insights/presentation/pages/logs_page.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../../features/player/domain/session_feedback_models.dart';
import '../../features/player/presentation/pages/session_history_page.dart';
import '../../features/player/presentation/pages/session_player_page.dart';
import '../../features/profile/presentation/pages/premium_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/programs/presentation/pages/recovery_program_detail_page.dart';
import '../../features/programs/presentation/pages/recovery_programs_page.dart';
import '../../features/quick_fix/presentation/pages/quick_fix_page.dart';
import '../../features/sessions/presentation/pages/saved_sessions_page.dart';
import '../../features/sessions/presentation/pages/session_detail_page.dart';
import '../../features/sessions/presentation/pages/sessions_library_page.dart';
import '../../shared/widgets/feedback/route_not_found_page.dart';
import '../shell/main_shell.dart';
import '../startup/initial_route_page.dart';

final appRootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: '/startup',
    errorBuilder: (context, state) =>
        RouteNotFoundPage(attemptedLocation: state.uri.toString()),
    routes: [

      GoRoute(
        path: '/startup',
        name: 'startup-route',
        builder: (context, state) => const InitialRoutePage(),
      ),
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
                path: '/app/programs',
                name: 'recovery-programs',
                builder: (context, state) => const RecoveryProgramsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'recovery-program-detail',
                    builder: (context, state) {
                      final programId = state.pathParameters['id'];
                      if (programId == null || programId.isEmpty) {
                        return const RouteNotFoundPage(
                          attemptedLocation: '/app/programs/:id',
                        );
                      }
                      return RecoveryProgramDetailPage(programId: programId);
                    },
                  ),
                ],
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
            redirectTo: redirectTo?.trim().isNotEmpty == true
                ? redirectTo
                : '/app/dashboard',
          );
        },
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'auth-callback',
        builder: (context, state) => const AuthCallbackPage(),
      ),
      GoRoute(
        path: '/callback',
        name: 'auth-callback-short',
        builder: (context, state) => const AuthCallbackPage(),
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
        path: '/app/insights/logs',
        name: 'logs',
        builder: (context, state) => const LogsPage(),
      ),

      GoRoute(
        path: '/app/notifications',
        name: 'notification-center',
        builder: (context, state) => const NotificationCenterPage(),
      ),
      GoRoute(
        path: '/app/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      GoRoute(
        path: '/app/profile/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/app/profile/premium',
        name: 'premium',
        builder: (context, state) => const PremiumPage(),
      ),
    ],
  );
});
