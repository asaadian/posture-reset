// lib/core/update/app_update_prompt_gate.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/application/auth_providers.dart';
import '../config/app_env.dart';
import '../localization/app_text.dart';

class AppUpdatePromptGate extends ConsumerStatefulWidget {
  const AppUpdatePromptGate({
    super.key,
    required this.router,
    required this.navigatorKey,
    required this.child,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<AppUpdatePromptGate> createState() => _AppUpdatePromptGateState();
}

class _AppUpdatePromptGateState extends ConsumerState<AppUpdatePromptGate>
    with WidgetsBindingObserver {
  static DateTime? _lastCheckedAt;
  bool _dialogOpen = false;
  bool _initialCheckQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _queueInitialCheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkForUpdate());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next == null || previous?.id == next.id) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(() async {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          if (!mounted) return;
          await _checkForUpdate(force: true);
        }());
      });
    });

    return widget.child;
  }

  void _queueInitialCheck() {
    if (_initialCheckQueued) return;
    _initialCheckQueued = true;

    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      await _checkForUpdate(force: true);
    }());
  }

  Future<void> _checkForUpdate({bool force = false}) async {
    if (_dialogOpen || !mounted) return;

    try {
      var path = widget.router.routerDelegate.currentConfiguration.uri.path;
      if (path == '/startup') {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        path = widget.router.routerDelegate.currentConfiguration.uri.path;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('[UpdateCheck] skipped: user is not signed in. path=$path');
        return;
      }

      if (!path.startsWith('/app')) {
        debugPrint('[UpdateCheck] skipped: route is not inside signed-in app shell. path=$path');
        return;
      }

      final now = DateTime.now();
      final last = _lastCheckedAt;
      if (!force && last != null && now.difference(last) < const Duration(minutes: 2)) {
        return;
      }
      _lastCheckedAt = now;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber.trim()) ?? 0;
      final data = await _loadRuntimeConfig();

      debugPrint('[UpdateCheck] path=$path current=${packageInfo.version}+$currentBuild row=$data');

      if (data == null) {
        debugPrint('[UpdateCheck] No runtime config row. Run supabase/sql/app_runtime_config.sql.');
        return;
      }

      final latestBuild = _readInt(data['latest_build_number']);
      if (latestBuild == null) {
        debugPrint('[UpdateCheck] latest_build_number is missing or invalid: ${data['latest_build_number']}');
        return;
      }

      if (latestBuild <= currentBuild) {
        debugPrint('[UpdateCheck] No update. latestBuild=$latestBuild currentBuild=$currentBuild');
        return;
      }

      final latestVersion = data['latest_version_name']?.toString().trim();
      final updateUrl = data['update_url']?.toString().trim();
      final forceUpdate = data['force_update'] == true;
      final message = data['message']?.toString().trim();

      await _showUpdateDialog(
        currentVersion: packageInfo.version,
        latestVersion: latestVersion?.isNotEmpty == true ? latestVersion! : null,
        updateUrl: updateUrl?.isNotEmpty == true ? updateUrl! : _defaultPlayStoreUrl(),
        forceUpdate: forceUpdate,
        message: message?.isNotEmpty == true ? message! : null,
      );
    } catch (error, stackTrace) {
      debugPrint('[UpdateCheck] failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>?> _loadRuntimeConfig() async {
    final client = Supabase.instance.client;

    try {
      final rpcResult = await client.rpc(
        'get_app_runtime_config',
        params: {'p_platform': 'android'},
      );

      final normalized = _normalizeRuntimeConfigResult(rpcResult);
      if (normalized != null) return normalized;
    } catch (error) {
      debugPrint('[UpdateCheck] RPC fallback to table select: $error');
    }

    final row = await client
        .from('app_runtime_config')
        .select(
          'platform, latest_build_number, latest_version_name, update_url, force_update, message, updated_at',
        )
        .eq('platform', 'android')
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Map<String, dynamic>? _normalizeRuntimeConfigResult(Object? value) {
    if (value == null) return null;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }

    return null;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  String _defaultPlayStoreUrl() {
    return 'https://play.google.com/store/apps/details?id=${AppEnv.androidPackageName}';
  }

  Future<void> _showUpdateDialog({
    required String currentVersion,
    required String? latestVersion,
    required String updateUrl,
    required bool forceUpdate,
    required String? message,
  }) async {
    if (_dialogOpen || !mounted) return;

    final dialogContext = widget.navigatorKey.currentContext;
    if (dialogContext == null) {
      debugPrint('[UpdateCheck] Navigator context not ready.');
      return;
    }

    _dialogOpen = true;

    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: !forceUpdate,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final t = AppText.of(context);

        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            icon: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
              ),
              child: Icon(Icons.system_update_alt_rounded, color: colors.onPrimary),
            ),
            title: Text(
              t.get(
                forceUpdate ? 'update_required_title' : 'update_available_title',
                fallback: forceUpdate ? 'Update required' : 'Update available',
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              message ??
                  t.get(
                    'update_available_body',
                    fallback: latestVersion == null
                        ? 'A newer version is available. Update the app for the latest fixes and improvements.'
                        : 'Version $latestVersion is available. Update the app for the latest fixes and improvements.',
                  ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.get('update_later_cta', fallback: 'Later')),
                ),
              FilledButton.icon(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(updateUrl),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!forceUpdate && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(t.get('update_now_cta', fallback: 'Update')),
              ),
            ],
          ),
        );
      },
    );

    _dialogOpen = false;
  }
}
