// lib/app/shell/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_locale_controller.dart';
import '../../core/localization/app_text.dart';
import '../../core/notifications/notification_permission_prompt_gate.dart';
import '../../core/notifications/notification_reminder_sync_gate.dart';
import '../../core/notifications/notification_tap_router_gate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_controller.dart';
import '../../core/update/app_update_prompt_gate.dart';
import '../router/app_router.dart';
import '../startup/app_startup_gate.dart';
import '../startup/auth_route_gate.dart';

class PostureResetApp extends ConsumerWidget {
  const PostureResetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleControllerProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeControllerProvider);

    return MaterialApp.router(
      title: AppText.staticAppTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.materialThemeMode,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppText.supportedLocales,
      localizationsDelegates: [
        AppText.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final routedChild = child ?? const SizedBox.shrink();

        return AppStartupGate(
          child: AuthRouteGate(
            router: router,
            child: AppUpdatePromptGate(
              router: router,
              navigatorKey: appRootNavigatorKey,
              child: NotificationPermissionPromptGate(
                router: router,
                navigatorKey: appRootNavigatorKey,
                child: NotificationTapRouterGate(
                  router: router,
                  navigatorKey: appRootNavigatorKey,
                  child: NotificationReminderSyncGate(
                    child: routedChild,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
