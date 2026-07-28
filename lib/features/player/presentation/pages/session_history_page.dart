// lib/features/player/presentation/pages/session_history_page.dart

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
import '../../application/session_continuity_providers.dart';
import '../widgets/continue_session_card.dart';
import '../widgets/session_history_card.dart';

class SessionHistoryPage extends ConsumerWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final historyAsync = ref.watch(sessionHistoryItemsProvider);
    final candidateAsync = ref.watch(continueSessionCandidateProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(
        t.get('session_history_title', fallback: 'Session History'),
      ),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.sessionHistory,
        );

        if (accessAsync.isLoading) {
          return const _SessionHistoryLoadingState();
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              ResponsiveContentSection(
                spacing: pageInfo.sectionSpacing,
                children: [
                  const _SessionHistoryLockedViewedTracker(),
                  LockedFeatureCard(
                    title: t.get(
                      'session_history_locked_title',
                      fallback: 'See your past sessions',
                    ),
                    message: t.get(
                      'session_history_locked_message',
                      fallback:
                          'Unlock to track your recovery.',
                    ),
                    icon: Icons.history_rounded,
                    onUpgrade: () {
                      unawaited(
                        ref.read(analyticsServiceProvider).track(
                              AnalyticsEvent(
                                eventName:
                                    AnalyticsEvents.lockedFeatureCtaTapped,
                                sourceSurface: AnalyticsSurfaces.history,
                                featureKey: LockedFeature.sessionHistory.code,
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

        return historyAsync.when(
          loading: () => const _SessionHistoryLoadingState(),
          error: (error, stackTrace) => _SessionHistoryErrorState(
            message: t.get(
              'session_history_error',
              fallback: 'Could not load session history.',
            ),
          ),
          data: (items) {
            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
                  children: [
                    candidateAsync.maybeWhen(
                      data: (candidate) => candidate == null
                          ? const SizedBox.shrink()
                          : ContinueSessionCard(candidate: candidate),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    if (items.isEmpty)
                      const _SessionHistoryEmptyCard()
                    else
                      ...items.asMap().entries.map(
                        (entry) => _HistoryListEntry(
                          index: entry.key,
                          child: SessionHistoryCard(item: entry.value),
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

class _SessionHistoryLockedViewedTracker extends ConsumerStatefulWidget {
  const _SessionHistoryLockedViewedTracker();

  @override
  ConsumerState<_SessionHistoryLockedViewedTracker> createState() =>
      _SessionHistoryLockedViewedTrackerState();
}

class _SessionHistoryLockedViewedTrackerState
    extends ConsumerState<_SessionHistoryLockedViewedTracker> {
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
                sourceSurface: AnalyticsSurfaces.history,
                featureKey: LockedFeature.sessionHistory.code,
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

class _SessionHistoryLoadingState extends StatelessWidget {
  const _SessionHistoryLoadingState();

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

class _SessionHistoryErrorState extends StatelessWidget {
  const _SessionHistoryErrorState({
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

class _SessionHistoryEmptyCard extends StatelessWidget {
  const _SessionHistoryEmptyCard();

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.24 : 0.16),
              ),
            ),
            child: Icon(
              Icons.history_rounded,
              size: 24,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.get(
              'session_history_empty_title',
              fallback: 'No session history yet',
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
              'session_history_empty_body',
              fallback:
                  'Start a session to see it here.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryListEntry extends StatelessWidget {
  const _HistoryListEntry({
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
