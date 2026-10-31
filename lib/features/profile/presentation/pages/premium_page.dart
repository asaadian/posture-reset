// lib/features/profile/presentation/pages/premium_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../billing/application/billing_controller.dart';
import '../../../billing/application/billing_providers.dart';
import '../../../billing/application/billing_state.dart';
import '../../../billing/domain/billing_models.dart';

DateTime? _lastPremiumPaywallViewedTrackedAt;

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final accessAsync = ref.watch(accessSnapshotProvider);
    final billingController = ref.watch(billingControllerProvider);
    final billingState = billingController.state;

    ref.listen<BillingController>(billingControllerProvider, (previous, next) {
      final previousStatus = previous?.state.status;
      final nextState = next.state;

      if (previousStatus == nextState.status) return;

      if (nextState.status == BillingPurchaseStatus.purchased ||
          nextState.status == BillingPurchaseStatus.restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.get(
                nextState.status == BillingPurchaseStatus.restored
                    ? 'premium_restore_success'
                    : 'premium_purchase_success',
                fallback: nextState.status == BillingPurchaseStatus.restored
                    ? 'Core Access restored successfully.'
                    : 'Core Access unlocked successfully.',
              ),
            ),
          ),
        );
      }

      if (nextState.status == BillingPurchaseStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.get(
                'premium_purchase_cancelled',
                fallback: 'Purchase was cancelled.',
              ),
            ),
          ),
        );
      }

      if (nextState.status == BillingPurchaseStatus.failed) {
        final failureCode = nextState.failure?.code;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failureCode == 'restore_no_purchase_found'
                  ? t.get(
                      'premium_restore_no_purchase_found',
                      fallback:
                          'No previous Core Access purchase was found for this Google Play account.',
                    )
                  : t.get(
                      'premium_purchase_failed',
                      fallback:
                          'Purchase could not be completed. Please try again.',
                    ),
            ),
          ),
        );
      }
    });

    return ResponsivePageScaffold(
      title: const Text('Premium'),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final hasCoreAccess = accessSnapshot.hasCoreAccess;
        final isSignedIn = accessSnapshot.isAuthenticated;
        final isBusy = accessAsync.isLoading || billingState.isBusy;

        Future<void> handleUnlock() async {
          unawaited(
            ref.read(analyticsServiceProvider).track(
                  const AnalyticsEvent(
                    eventName: AnalyticsEvents.unlockTapped,
                    sourceSurface: AnalyticsSurfaces.premium,
                    featureKey: 'core_access_paywall',
                    entitlementKey: 'core_access',
                    productId: 'core_access_lifetime',
                  ),
                ),
          );

          if (!isSignedIn) {
            final redirect = Uri.encodeComponent('/app/profile/premium');
            context.push('/auth?mode=signin&redirect=$redirect');
            return;
          }

          await billingController.purchaseCoreAccess(
            sourceSurface: AnalyticsSurfaces.premium,
          );
        }

        Future<void> handleRestore() async {
          unawaited(
            ref.read(analyticsServiceProvider).track(
                  const AnalyticsEvent(
                    eventName: AnalyticsEvents.restoreTapped,
                    sourceSurface: AnalyticsSurfaces.premium,
                    featureKey: 'core_access_paywall',
                    entitlementKey: 'core_access',
                    productId: 'core_access_lifetime',
                  ),
                ),
          );

          if (!isSignedIn) {
            final redirect = Uri.encodeComponent('/app/profile/premium');
            context.push('/auth?mode=signin&redirect=$redirect');
            return;
          }

          await billingController.restorePurchases(
            sourceSurface: AnalyticsSurfaces.premium,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(accessSnapshotProvider);
            await billingController.loadProducts();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 118 : 42),
            children: [
              const _PaywallViewedTracker(),
              _PremiumHeroCard(
                hasCoreAccess: hasCoreAccess,
                isBusy: isBusy,
              ),
              const SizedBox(height: 12),
              const _PremiumBenefitsList(),
              const SizedBox(height: 12),
              _PremiumPurchaseCard(
                hasCoreAccess: hasCoreAccess,
                isSignedIn: isSignedIn,
                isBusy: isBusy,
                billingState: billingState,
                onUnlockPressed: handleUnlock,
                onRestorePressed: handleRestore,
              ),
              if (billingState.failure != null) ...[
                const SizedBox(height: 12),
                _BillingFailureBanner(failure: billingState.failure!),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PaywallViewedTracker extends ConsumerStatefulWidget {
  const _PaywallViewedTracker();

  @override
  ConsumerState<_PaywallViewedTracker> createState() =>
      _PaywallViewedTrackerState();
}

class _PaywallViewedTrackerState extends ConsumerState<_PaywallViewedTracker> {
  bool _tracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_tracked) return;
    _tracked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final now = DateTime.now().toUtc();
      final lastTracked = _lastPremiumPaywallViewedTrackedAt;

      if (lastTracked != null &&
          now.difference(lastTracked) < const Duration(minutes: 5)) {
        return;
      }

      _lastPremiumPaywallViewedTrackedAt = now;

      unawaited(
        ref.read(analyticsServiceProvider).track(
              const AnalyticsEvent(
                eventName: AnalyticsEvents.paywallViewed,
                sourceSurface: AnalyticsSurfaces.premium,
                featureKey: 'core_access_paywall',
                entitlementKey: 'core_access',
                productId: 'core_access_lifetime',
              ),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard({required this.hasCoreAccess, required this.isBusy});

  final bool hasCoreAccess;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(23, 20, 23, 23),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36), topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18), bottomRight: Radius.circular(36),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF13263D), Color(0xFF176C69)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset('assets/images/premium-badge.png',
              width: 70, height: 70,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.workspace_premium_rounded, color: Color(0xFFFFD58A), size: 60)),
            const Spacer(),
            const Text('DESK WORKOUT PREMIUM',
              style: TextStyle(color: Color(0xFF9AE7D3),
                fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            if (isBusy) ...[
              const SizedBox(width: 9),
              const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ],
          ]),
          const SizedBox(height: 20),
          Text(hasCoreAccess ? 'Your Premium is active'
              : 'Your complete desk recovery companion',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white, fontWeight: FontWeight.w900, height: 1.08)),
          const SizedBox(height: 10),
          Text(hasCoreAccess
              ? 'All sessions and recovery tools are ready for you.'
              : 'Every reset, guided program and insight. One payment, yours to keep.',
            style: const TextStyle(color: Color(0xFFD8E8E9),
              fontSize: 13, height: 1.45)),
        ],
      ),
    );
  }
}

class _PremiumBenefitsList extends StatelessWidget {
  const _PremiumBenefitsList();

  @override
  Widget build(BuildContext context) {
    const benefits = [
      'Every recovery session',
      'All guided programs',
      'Full Quick Fix recommendations',
      'Insights, history and saved sessions',
    ];
    return Column(
      children: [
        Center(
          child: Image.asset('assets/images/premium-badge.png',
            width: 126, height: 126, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFD9A956), size: 104)),
        ),
        const SizedBox(height: 10),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded,
              size: 19, color: Color(0xFF22A68B)),
            const SizedBox(width: 12),
            Expanded(child: Text(benefit,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700))),
          ]),
        )),
      ],
    );
  }
}

class _PremiumPurchaseCard extends StatelessWidget {
  const _PremiumPurchaseCard({
    required this.hasCoreAccess,
    required this.isSignedIn,
    required this.isBusy,
    required this.billingState,
    required this.onUnlockPressed,
    required this.onRestorePressed,
  });

  final bool hasCoreAccess;
  final bool isSignedIn;
  final bool isBusy;
  final BillingState billingState;
  final VoidCallback onUnlockPressed;
  final VoidCallback onRestorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final price = billingState.selectedProduct?.price ??
        t.get(
          'premium_product_price_unavailable',
          fallback: 'Price unavailable',
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.18),
                  colors.tertiary.withValues(alpha: 0.08),
                  colors.surfaceContainerHigh.withValues(alpha: 0.92),
                ]
              : [
                  colors.primary.withValues(alpha: 0.09),
                  colors.tertiary.withValues(alpha: 0.055),
                  colors.surfaceContainerLowest.withValues(alpha: 0.98),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PurchaseHeader(
            hasCoreAccess: hasCoreAccess,
            price: price,
          ),
          const SizedBox(height: 10),
          Text(
            hasCoreAccess
                ? 'Your Premium access is ready.'
                : 'Pay once. Keep access. No subscription.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const _PlanSignalLine(),
          const SizedBox(height: 16),
          _PrimaryPurchaseButton(
            hasCoreAccess: hasCoreAccess,
            isBusy: isBusy,
            billingState: billingState,
            onPressed: onUnlockPressed,
          ),
          const SizedBox(height: 10),
          _RestoreButton(
            isBusy: isBusy,
            onPressed: onRestorePressed,
          ),
          if (!isSignedIn && !hasCoreAccess) ...[
            const SizedBox(height: 9),
            Text(
              t.get(
                'premium_sign_in_hint',
                fallback: 'Sign in first so access can be restored later.',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PurchaseHeader extends StatelessWidget {
  const _PurchaseHeader({
    required this.hasCoreAccess,
    required this.price,
  });

  final bool hasCoreAccess;
  final String price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PlanDot(active: hasCoreAccess),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hasCoreAccess ? 'Premium active' : 'Premium lifetime',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: colors.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                'Pay once',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              price,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanSignalLine extends StatelessWidget {
  const _PlanSignalLine();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SignalPill(
          icon: Icons.all_inclusive_rounded,
          label: t.get(
            'premium_signal_lifetime',
            fallback: 'Lifetime',
          ),
        ),
        _SignalPill(
          icon: Icons.restore_rounded,
          label: t.get(
            'premium_signal_restore',
            fallback: 'Restore supported',
          ),
        ),
        _SignalPill(
          icon: Icons.block_rounded,
          label: t.get(
            'premium_signal_no_subscription',
            fallback: 'No subscription',
          ),
        ),
      ],
    );
  }
}







class _PrimaryPurchaseButton extends StatelessWidget {
  const _PrimaryPurchaseButton({
    required this.hasCoreAccess,
    required this.isBusy,
    required this.billingState,
    required this.onPressed,
  });

  final bool hasCoreAccess;
  final bool isBusy;
  final BillingState billingState;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: hasCoreAccess || isBusy ? null : onPressed,
        icon: isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                hasCoreAccess
                    ? Icons.check_circle_rounded
                    : Icons.lock_open_rounded,
              ),
        label: Text(
          hasCoreAccess
              ? t.get(
                  'premium_already_unlocked_cta',
                  fallback: 'Already unlocked',
                )
              : _purchaseButtonLabel(context, billingState),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({
    required this.isBusy,
    required this.onPressed,
  });

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onPressed,
        icon: const Icon(Icons.restore_rounded),
        label: Text(
          t.get(
            'premium_restore_cta',
            fallback: 'Restore',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _BillingFailureBanner extends StatelessWidget {
  const _BillingFailureBanner({required this.failure});

  final BillingFailure failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.78),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _billingFailureMessage(context, failure),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalPill extends StatelessWidget {
  const _SignalPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final foreground = colors.primary;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.42)
            : colors.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.68 : 0.52),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDot extends StatelessWidget {
  const _PlanDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? colors.primary : colors.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 13 : 0,
          height: active ? 13 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

