import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../legal/legal_document_page.dart';
import 'analytics_consent.dart';

/// Offers a separate, genuinely optional choice once after entering the app.
/// The policy/terms acceptance checkbox is never used as analytics consent.
class AnalyticsConsentGate extends ConsumerStatefulWidget {
  const AnalyticsConsentGate({
    super.key,
    required this.router,
    required this.navigatorKey,
    required this.child,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<AnalyticsConsentGate> createState() =>
      _AnalyticsConsentGateState();
}

class _AnalyticsConsentGateState extends ConsumerState<AnalyticsConsentGate> {
  bool _promptQueued = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_queuePrompt);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = ref.read(currentUserProvider)?.id;
      unawaited(
        ref.read(analyticsConsentProvider.notifier).loadForUser(userId).then((_) {
          if (mounted) _queuePrompt();
        }),
      );
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_queuePrompt);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      unawaited(
        ref.read(analyticsConsentProvider.notifier).loadForUser(next?.id),
      );
    });
    ref.listen(analyticsConsentProvider, (_, __) => _queuePrompt());
    return widget.child;
  }

  void _queuePrompt() {
    if (_promptQueued || _dialogOpen || !mounted) return;
    _promptQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(() async {
        await Future<void>.delayed(const Duration(milliseconds: 750));
        _promptQueued = false;
        if (!mounted || _dialogOpen) return;
        if (ref.read(analyticsConsentProvider) != AnalyticsConsentStatus.unknown) {
          return;
        }
        final path = widget.router.routerDelegate.currentConfiguration.uri.path;
        if (!path.startsWith('/app/')) return;
        final navigatorContext = widget.navigatorKey.currentContext;
        if (navigatorContext == null) return;
        await _ask(navigatorContext);
      }());
    });
  }

  Future<void> _ask(BuildContext navigatorContext) async {
    _dialogOpen = true;
    try {
      await showDialog<void>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          final de = Localizations.localeOf(dialogContext).languageCode == 'de';
          return PopScope(
            canPop: false,
            child: AlertDialog(
              icon: const Icon(Icons.insights_outlined),
              title: Text(de ? 'Anonyme Nutzungsanalyse?' : 'Optional app analytics?'),
              content: Text(
                de
                    ? 'Dürfen wir die Nutzung wichtiger App-Funktionen mit PostHog EU messen, um Desk Workout zu verbessern? Es werden keine Namen, E-Mail-Adressen oder Angaben zu Beschwerden übermittelt. Keine Bildschirmaufzeichnung. Die Entscheidung ist freiwillig und jederzeit in den Einstellungen änderbar.'
                    : 'May we measure how key app features are used with PostHog EU to improve Desk Workout? We do not send names, email addresses or health complaints. Screen recording is disabled. This is optional and can be changed in Settings at any time.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LegalDocumentPage(
                          kind: LegalDocumentKind.privacy,
                        ),
                      ),
                    );
                  },
                  child: Text(de ? 'Datenschutz lesen' : 'Read privacy policy'),
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(analyticsConsentProvider.notifier).choose(false);
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: Text(de ? 'Ablehnen' : 'Decline'),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref.read(analyticsConsentProvider.notifier).choose(true);
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: Text(de ? 'Zustimmen' : 'Allow'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _dialogOpen = false;
    }
  }
}
