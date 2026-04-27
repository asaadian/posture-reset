// lib/app/shell/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_locale_controller.dart';
import '../../core/localization/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../router/app_router.dart';
import '../startup/app_startup_gate.dart';

class PostureResetApp extends ConsumerWidget {
  const PostureResetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppText.staticAppTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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
        return AppStartupGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}