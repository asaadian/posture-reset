// lib/features/sessions/presentation/pages/saved_sessions_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';
import '../../../player/application/session_continuity_providers.dart';
import '../widgets/saved_session_card.dart';

class SavedSessionsPage extends ConsumerWidget {
  const SavedSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final savedAsync = ref.watch(savedSessionContinuityItemsProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(
        t.get('saved_sessions_title', fallback: 'Saved Sessions'),
      ),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.savedSessions,
        );

        if (accessAsync.isLoading) {
          return const _SavedSessionsLoadingState();
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              ResponsiveContentSection(
                spacing: pageInfo.sectionSpacing,
                children: [
                  const _SavedSessionsLockedViewedTracker(),
                  LockedFeatureCard(
                    title: t.get(
                      'saved_sessions_locked_title',
                      fallback: 'Save your favorite sessions',
                    ),
                    message: t.get(
                      'saved_sessions_locked_message',
                      fallback:
                          'Unlock to keep them here.',
                    ),
                    icon: Icons.bookmark_added_outlined,
                    onUpgrade: () {
                      unawaited(
                        ref.read(analyticsServiceProvider).track(
                              AnalyticsEvent(
                                eventName:
                                    AnalyticsEvents.lockedFeatureCtaTapped,
                                sourceSurface: AnalyticsSurfaces.saved,
                                featureKey: LockedFeature.savedSessions.code,
                                accessTier: AccessTier.coreAccess.code,
                                entitlementKey: Entitlement.coreAccess.key,
                              ),
                            ),
                      );

                      context.pushNamed('premium');
                    },
                  ),
                ],
              ),
            ],
          );
        }

        return savedAsync.when(
          loading: () => const _SavedSessionsLoadingState(),
          error: (error, stackTrace) => _SavedSessionsErrorState(
            message: t.get(
              'saved_sessions_error',
              fallback: 'Could not load saved sessions.',
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
                children: [
                  ResponsiveContentSection(
                    spacing: pageInfo.sectionSpacing,
                    children: const [
                      _SavedSessionsEmptyCard(),
                    ],
                  ),
                ],
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
                  children: [
                    ...items.asMap().entries.map(
                      (entry) => _SavedSessionListEntry(
                        index: entry.key,
                        child: SavedSessionCard(item: entry.value),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SavedSessionsLockedViewedTracker extends ConsumerStatefulWidget {
  const _SavedSessionsLockedViewedTracker();

  @override
  ConsumerState<_SavedSessionsLockedViewedTracker> createState() =>
      _SavedSessionsLockedViewedTrackerState();
}

class _SavedSessionsLockedViewedTrackerState
    extends ConsumerState<_SavedSessionsLockedViewedTracker> {
  bool _tracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_tracked) return;
    _tracked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(
        ref.read(analyticsServiceProvider).track(
              AnalyticsEvent(
                eventName: AnalyticsEvents.lockedFeatureViewed,
                sourceSurface: AnalyticsSurfaces.saved,
                featureKey: LockedFeature.savedSessions.code,
                accessTier: AccessTier.coreAccess.code,
                entitlementKey: Entitlement.coreAccess.key,
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

class _SavedSessionsLoadingState extends StatelessWidget {
  const _SavedSessionsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _SavedSessionsErrorState extends StatelessWidget {
  const _SavedSessionsErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        colors.surfaceContainerHigh.withValues(alpha: 0.76),
                        colors.surface.withValues(alpha: 0.96),
                      ]
                    : [
                        colors.surface.withValues(alpha: 0.94),
                        colors.surfaceContainerLow.withValues(alpha: 0.88),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.76 : 0.64,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.18)
                      : colors.primary.withValues(alpha: 0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: colors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedSessionsEmptyCard extends StatelessWidget {
  const _SavedSessionsEmptyCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.76),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.surface.withValues(alpha: 0.94),
                  colors.surfaceContainerLow.withValues(alpha: 0.88),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: isDark ? 0.76 : 0.64,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : colors.primary.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.24 : 0.16),
              ),
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 25,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.get(
              'saved_sessions_empty_title',
              fallback: 'No saved sessions yet',
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t.get(
              'saved_sessions_empty_body',
              fallback:
                  'Tap Save on any session to find it here.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.goNamed('sessions'),
            icon: const Icon(Icons.grid_view_rounded),
            label: Text(
              t.get(
                'saved_sessions_browse_cta',
                fallback: 'Browse Sessions',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSessionListEntry extends StatelessWidget {
  const _SavedSessionListEntry({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}
