// lib/features/profile/presentation/pages/premium_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../billing/application/billing_controller.dart';
import '../../../billing/application/billing_providers.dart';
import '../../../billing/application/billing_state.dart';
import '../../../billing/domain/billing_models.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.get(
                'premium_purchase_failed',
                fallback: 'Purchase could not be completed. Please try again.',
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
          if (!isSignedIn) {
            final redirect = Uri.encodeComponent('/app/profile/premium');
            context.push('/auth?mode=signin&redirect=$redirect');
            return;
          }

          await billingController.purchaseCoreAccess();
        }

        Future<void> handleRestore() async {
          if (!isSignedIn) {
            final redirect = Uri.encodeComponent('/app/profile/premium');
            context.push('/auth?mode=signin&redirect=$redirect');
            return;
          }

          await billingController.restorePurchases();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(accessSnapshotProvider);
            await billingController.loadProducts();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              _PremiumCompactHero(
                hasCoreAccess: hasCoreAccess,
                isSignedIn: isSignedIn,
                isBusy: isBusy,
                billingState: billingState,
                onUnlockPressed: handleUnlock,
                onRestorePressed: handleRestore,
              ),
              const SizedBox(height: 14),
              _CompactStatusRow(
                hasCoreAccess: hasCoreAccess,
                isSignedIn: isSignedIn,
                accessLoading: accessAsync.isLoading,
                billingState: billingState,
              ),
              if (billingState.failure != null) ...[
                const SizedBox(height: 14),
                _BillingFailureBanner(failure: billingState.failure!),
              ],
              const SizedBox(height: 14),
              _CompactBenefitPanel(),
              const SizedBox(height: 14),
              _FutureSubscriptionNote(),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumCompactHero extends StatelessWidget {
  const _PremiumCompactHero({
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

    final price = billingState.selectedProduct?.price ??
        t.get(
          'premium_product_price_unavailable',
          fallback: 'Price unavailable',
        );

    final title = hasCoreAccess
        ? t.get(
            'premium_hero_unlocked_title',
            fallback: 'Core Access is active.',
          )
        : t.get(
            'premium_hero_title',
            fallback: 'Unlock the full recovery toolkit.',
          );

    final body = hasCoreAccess
        ? t.get(
            'premium_hero_unlocked_body',
            fallback:
                'Full sessions, insights, saved continuity, and body-map recommendations are available.',
          )
        : t.get(
            'premium_hero_body_compact',
            fallback:
                'One-time unlock. No ads. No subscription pressure. Built for focused recovery.',
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.20),
            const Color(0xFF63E4D7).withValues(alpha: 0.10),
            colors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            final visual = _PremiumOrb(
              hasCoreAccess: hasCoreAccess,
              isLoading: isBusy,
            );

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CorePill(
                  icon: hasCoreAccess
                      ? Icons.verified_rounded
                      : Icons.lock_rounded,
                  label: hasCoreAccess
                      ? t.get(
                          'premium_status_core_active',
                          fallback: 'Unlocked',
                        )
                      : t.get(
                          'premium_status_free',
                          fallback: 'Free plan',
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  price,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                _HeroActions(
                  hasCoreAccess: hasCoreAccess,
                  isSignedIn: isSignedIn,
                  isBusy: isBusy,
                  billingState: billingState,
                  onUnlockPressed: onUnlockPressed,
                  onRestorePressed: onRestorePressed,
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 12, child: content),
                  const SizedBox(width: 18),
                  Expanded(flex: 6, child: visual),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 150, child: visual),
                const SizedBox(height: 16),
                content,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
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
    final t = AppText.of(context);

    final unlockButton = FilledButton.icon(
      onPressed: hasCoreAccess || isBusy ? null : onUnlockPressed,
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
      ),
    );

    final restoreButton = OutlinedButton.icon(
      onPressed: isBusy ? null : onRestorePressed,
      icon: const Icon(Icons.restore_rounded),
      label: Text(
        t.get(
          'premium_restore_cta',
          fallback: 'Restore',
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              unlockButton,
              const SizedBox(height: 10),
              restoreButton,
              if (!isSignedIn) ...[
                const SizedBox(height: 8),
                _SignInHint(),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 7, child: unlockButton),
            const SizedBox(width: 10),
            Expanded(flex: 5, child: restoreButton),
          ],
        );
      },
    );
  }
}

class _CompactStatusRow extends StatelessWidget {
  const _CompactStatusRow({
    required this.hasCoreAccess,
    required this.isSignedIn,
    required this.accessLoading,
    required this.billingState,
  });

  final bool hasCoreAccess;
  final bool isSignedIn;
  final bool accessLoading;
  final BillingState billingState;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final items = [
      _StatusChipData(
        icon: isSignedIn ? Icons.person_rounded : Icons.person_off_rounded,
        label: isSignedIn
            ? t.get('premium_status_signed_in', fallback: 'Signed in')
            : t.get('premium_status_guest', fallback: 'Guest'),
      ),
      _StatusChipData(
        icon: hasCoreAccess ? Icons.verified_rounded : Icons.lock_outline,
        label: accessLoading
            ? t.get('premium_status_loading', fallback: 'Checking')
            : hasCoreAccess
                ? t.get('premium_status_core', fallback: 'Core active')
                : t.get('premium_status_free', fallback: 'Free'),
      ),
      _StatusChipData(
        icon: Icons.block_rounded,
        label: t.get('premium_signal_no_ads', fallback: 'No ads'),
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _StatusChip(item: item)).toList(),
    );
  }
}

class _CompactBenefitPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final benefits = [
      _BenefitItem(
        icon: Icons.self_improvement_rounded,
        label: t.get(
          'premium_value_sessions_title',
          fallback: 'Full session library',
        ),
      ),
      _BenefitItem(
        icon: Icons.flash_on_rounded,
        label: t.get(
          'premium_value_quick_fix_title',
          fallback: 'Full Quick Fix',
        ),
      ),
      _BenefitItem(
        icon: Icons.insights_rounded,
        label: t.get(
          'premium_value_insights_title',
          fallback: 'Full insights',
        ),
      ),
      _BenefitItem(
        icon: Icons.accessibility_new_rounded,
        label: t.get(
          'premium_value_body_map_title',
          fallback: 'Body map recommendations',
        ),
      ),
      _BenefitItem(
        icon: Icons.bookmark_added_rounded,
        label: t.get(
          'premium_value_saved_title',
          fallback: 'Saved + history',
        ),
      ),
      _BenefitItem(
        icon: Icons.route_rounded,
        label: t.get(
          'premium_value_continuity_title',
          fallback: 'Advanced continuity',
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;

          return GridView.builder(
            itemCount: benefits.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 78,
            ),
            itemBuilder: (context, index) {
              return _BenefitTile(item: benefits[index]);
            },
          );
        },
      ),
    );
  }
}

class _BenefitItem {
  const _BenefitItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.item});

  final _BenefitItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 19,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
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
    final t = AppText.of(context);

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
              t.get(
                'premium_billing_error_body',
                fallback:
                    'Billing is not ready or the purchase could not be verified. Please try again.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumOrb extends StatelessWidget {
  const _PremiumOrb({
    required this.hasCoreAccess,
    required this.isLoading,
  });

  final bool hasCoreAccess;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colors.surface.withValues(alpha: 0.50),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.30),
                  const Color(0xFF63E4D7).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceContainerHighest,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 27,
                      height: 27,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Icon(
                      hasCoreAccess
                          ? Icons.verified_rounded
                          : Icons.workspace_premium_rounded,
                      size: 40,
                      color: colors.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CorePill extends StatelessWidget {
  const _CorePill({
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
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChipData {
  const _StatusChipData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.item});

  final _StatusChipData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            item.label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    return Text(
      t.get(
        'premium_sign_in_hint',
        fallback: 'Sign in first so access can be restored later.',
      ),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.3,
      ),
    );
  }
}

class _FutureSubscriptionNote extends StatelessWidget {
  const _FutureSubscriptionNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.70),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.get(
                'premium_future_subscription_note',
                fallback:
                    'Advanced adaptive plans and reminder delivery are reserved for a later subscription layer. Core Access is the current unlock.',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
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