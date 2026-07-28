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

const String _premiumHeroGifAsset = 'assets/images/premium_recovery_loop.gif';

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
      title: Text(t.get('premium_page_title', fallback: 'Core Access')),
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
              _PremiumValueDeck(hasCoreAccess: hasCoreAccess),
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
  const _PremiumHeroCard({
    required this.hasCoreAccess,
    required this.isBusy,
  });

  final bool hasCoreAccess;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 236,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF07101F),
                  Color(0xFF111A32),
                  Color(0xFF0A2230),
                ]
              : const [
                  Color(0xFF111827),
                  Color(0xFF27348A),
                  Color(0xFF075C64),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.18),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _premiumHeroGifAsset,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) {
                return _PremiumFallbackVisual(
                  accent: colors.primary,
                  secondary: colors.secondary,
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF050814).withValues(alpha: 0.96),
                    const Color(0xFF050814).withValues(alpha: 0.74),
                    const Color(0xFF050814).withValues(alpha: 0.24),
                  ],
                  stops: const [0.0, 0.58, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 72,
            top: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroPill(
                  icon: hasCoreAccess
                      ? Icons.verified_rounded
                      : Icons.workspace_premium_rounded,
                  label: hasCoreAccess
                      ? t.get('premium_status_core_active', fallback: 'Unlocked')
                      : t.get('premium_visual_pill', fallback: 'One-time Core'),
                ),
                const Spacer(),
                Text(
                  hasCoreAccess
                      ? t.get(
                          'premium_hero_unlocked_title',
                          fallback: 'Core Access is active.',
                        )
                      : t.get(
                          'premium_visual_title_v2',
                          fallback: 'Unlock the full recovery system.',
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasCoreAccess
                      ? t.get(
                          'premium_hero_unlocked_body_v2',
                          fallback:
                              'Programs, full sessions, Quick Fix, insights, saved items, and history are available.',
                        )
                      : t.get(
                          'premium_visual_body_v2',
                          fallback:
                              'Programs, full sessions, Quick Fix, insights, saved items, and history — one unlock.',
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: _HeroMiniBadge(
              icon: Icons.route_rounded,
              label: t.get('premium_programs_badge', fallback: 'Programs'),
            ),
          ),
          if (isBusy)
            Positioned(
              right: 16,
              top: 16,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumValueDeck extends StatelessWidget {
  const _PremiumValueDeck({required this.hasCoreAccess});

  final bool hasCoreAccess;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _PremiumValueItem(
        icon: Icons.route_rounded,
        title: t.get('premium_value_programs_title', fallback: 'Recovery programs'),
      ),
      _PremiumValueItem(
        icon: Icons.self_improvement_rounded,
        title: t.get('premium_value_sessions_title', fallback: 'Full sessions'),
      ),
      _PremiumValueItem(
        icon: Icons.flash_on_rounded,
        title: t.get('premium_value_quick_fix_title', fallback: 'Quick Fix'),
      ),
      _PremiumValueItem(
        icon: Icons.insights_rounded,
        title: t.get('premium_value_insights_title', fallback: 'Insights'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.72),
                  colors.primary.withValues(alpha: 0.07),
                  colors.surface.withValues(alpha: 0.94),
                ]
              : [
                  colors.surfaceContainerLowest.withValues(alpha: 0.98),
                  colors.primary.withValues(alpha: 0.045),
                  colors.secondary.withValues(alpha: 0.035),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.62 : 0.50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactSectionHeader(
            title: hasCoreAccess
                ? t.get(
                    'premium_value_active_title',
                    fallback: 'Your unlocked toolkit',
                  )
                : t.get(
                    'premium_value_title',
                    fallback: 'What Core unlocks',
                  ),
            subtitle: t.get(
              'premium_value_subtitle_v2',
              fallback: 'Full access in one unlock.',
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 4 : 2;
              const spacing = 8.0;
              final width =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _PremiumValueTile(item: item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
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
                ? t.get(
                    'premium_plan_unlocked_subtitle',
                    fallback: 'Your full recovery toolkit is unlocked.',
                  )
                : t.get(
                    'premium_plan_subtitle_v2',
                    fallback:
                        'One-time unlock. No subscription. Restore anytime with the same Google Play account.',
                  ),
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

class _CompactSectionHeader extends StatelessWidget {
  const _CompactSectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colors.primary.withValues(alpha: 0.12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
          ),
          child: Icon(Icons.workspace_premium_rounded, color: colors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumValueItem {
  const _PremiumValueItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;
}

class _PremiumValueTile extends StatelessWidget {
  const _PremiumValueTile({required this.item});

  final _PremiumValueItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: isDark
            ? colors.surface.withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.70),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.56 : 0.46),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            ),
            child: Icon(item.icon, size: 19, color: colors.primary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
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
    final t = AppText.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PlanDot(active: hasCoreAccess),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            t.get(
              'premium_plan_title',
              fallback: 'Core Access',
            ),
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
                t.get(
                  'premium_plan_lifetime_badge',
                  fallback: 'One-time',
                ),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniBadge extends StatelessWidget {
  const _HeroMiniBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
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
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final foreground = muted ? colors.onSurfaceVariant : colors.primary;

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
              color: muted ? colors.onSurfaceVariant : colors.onSurface,
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

class _PremiumFallbackVisual extends StatelessWidget {
  const _PremiumFallbackVisual({
    required this.accent,
    required this.secondary,
  });

  final Color accent;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF050814),
                        accent.withValues(alpha: 0.18),
                        const Color(0xFF090D18),
                      ]
                    : [
                        const Color(0xFF111827),
                        accent.withValues(alpha: 0.14),
                        const Color(0xFF1F2937),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          right: -42,
          top: -44,
          child: _GlowBlob(
            size: 170,
            color: accent.withValues(alpha: isDark ? 0.22 : 0.18),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 18,
          child: _DeskRecoveryFigure(
            accent: accent,
            secondary: secondary,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _PremiumMotionLinesPainter(
              color: Colors.white.withValues(alpha: isDark ? 0.045 : 0.035),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _DeskRecoveryFigure extends StatelessWidget {
  const _DeskRecoveryFigure({
    required this.accent,
    required this.secondary,
  });

  final Color accent;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      height: 142,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 24,
            child: Container(
              width: 118,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            right: 8,
            child: Container(
              width: 56,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF101827).withValues(alpha: 0.88),
                border: Border.all(
                  color: secondary.withValues(alpha: 0.20),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 42,
            left: 32,
            child: Container(
              width: 54,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  colors: [
                    secondary.withValues(alpha: 0.92),
                    accent.withValues(alpha: 0.72),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 42,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE2BFA8),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 58,
            child: Container(
              width: 40,
              height: 22,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(8),
                ),
                color: Color(0xFF121827),
              ),
            ),
          ),
          Positioned(
            top: 62,
            left: 10,
            child: Transform.rotate(
              angle: -0.62,
              child: Container(
                width: 64,
                height: 13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
          Positioned(
            top: 64,
            right: 12,
            child: Transform.rotate(
              angle: 0.58,
              child: Container(
                width: 64,
                height: 13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumMotionLinesPainter extends CustomPainter {
  const _PremiumMotionLinesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 7; i++) {
      final y = 28.0 + (i * 28);
      final path = Path()
        ..moveTo(-20, y)
        ..cubicTo(
          size.width * 0.24,
          y - 20,
          size.width * 0.48,
          y + 22,
          size.width + 20,
          y - 8,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumMotionLinesPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

String _purchaseButtonLabel(
  BuildContext context,
  BillingState billingState,
) {
  final t = AppText.of(context);

  switch (billingState.status) {
    case BillingPurchaseStatus.loadingProducts:
      return t.get(
        'premium_loading_products_cta',
        fallback: 'Checking store…',
      );
    case BillingPurchaseStatus.purchasing:
      return t.get(
        'premium_purchasing_cta',
        fallback: 'Opening store…',
      );
    case BillingPurchaseStatus.verifying:
      return t.get(
        'premium_verifying_cta',
        fallback: 'Verifying…',
      );
    case BillingPurchaseStatus.productUnavailable:
      return t.get(
        'premium_product_unavailable_cta',
        fallback: 'Product unavailable',
      );
    case BillingPurchaseStatus.purchased:
    case BillingPurchaseStatus.restored:
      return t.get(
        'premium_already_unlocked_cta',
        fallback: 'Already unlocked',
      );
    case BillingPurchaseStatus.idle:
    case BillingPurchaseStatus.cancelled:
    case BillingPurchaseStatus.failed:
      return t.get(
        'access_unlock_core_cta',
        fallback: 'Unlock Core',
      );
  }
}

String _billingFailureMessage(
  BuildContext context,
  BillingFailure failure,
) {
  final t = AppText.of(context);

  switch (failure.code) {
    case 'purchase_token_already_used':
      return t.get(
        'premium_error_purchase_linked_to_another_account',
        fallback:
            'This purchase is already linked to another account. Sign in with the account used for the original unlock.',
      );

    case 'not_authenticated':
      return t.get(
        'premium_error_not_authenticated',
        fallback: 'Sign in first so your purchase can be verified.',
      );

    case 'restore_no_purchase_found':
      return t.get(
        'premium_restore_no_purchase_found',
        fallback:
            'No previous Core Access purchase was found for this Google Play account.',
      );

    case 'missing_purchase_token':
    case 'missing_purchase_payload':
      return t.get(
        'premium_error_missing_purchase_payload',
        fallback:
            'The store did not return a valid purchase receipt. Please try restore or contact support.',
      );

    case 'invalid_product_id':
    case 'store_product_mismatch':
      return t.get(
        'premium_error_product_mismatch',
        fallback:
            'The store product does not match this app version. Please update the app or contact support.',
      );

    case 'purchase_not_completed':
      return t.get(
        'premium_error_purchase_not_completed',
        fallback: 'The purchase was not completed. Please try again.',
      );

    case 'unsupported_platform':
      return t.get(
        'premium_error_unsupported_platform',
        fallback: 'Purchases are currently available only on Android.',
      );

    case 'store_unavailable':
      return t.get(
        'premium_error_store_unavailable',
        fallback:
            'Google Play billing is not available on this device. Please install the app from Google Play.',
      );

    case 'product_unavailable':
      return t.get(
        'premium_error_product_unavailable',
        fallback:
            'Core Access is not available from the store right now. Please try again later.',
      );

    case 'purchase_cancelled':
      return t.get(
        'premium_purchase_cancelled',
        fallback: 'Purchase was cancelled.',
      );

    case 'purchase_start_failed':
    case 'purchase_error':
    case 'purchase_stream_error':
      return t.get(
        'premium_error_purchase_failed',
        fallback: 'The purchase could not be started. Please try again.',
      );

    case 'verification_failed':
    case 'verification_exception':
    case 'verify_purchase_failed':
    case 'function_exception':
    case 'invalid_verification_response':
      return t.get(
        'premium_error_verification_failed',
        fallback:
            'The purchase could not be verified. Please try restore or contact support.',
      );

    default:
      return t.get(
        'premium_billing_error_body',
        fallback:
            'Billing is not ready or the purchase could not be verified. Please try again.',
      );
  }
}
