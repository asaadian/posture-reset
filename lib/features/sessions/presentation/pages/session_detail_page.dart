// lib/features/sessions/presentation/pages/session_detail_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/feedback/route_not_found_page.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/premium_lock_badge.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../player/application/session_continuity_providers.dart';
import '../../../player/domain/session_feedback_models.dart';
import '../../../player/domain/session_run_models.dart';
import '../../application/sessions_providers.dart';
import '../../domain/session_models.dart';

class SessionDetailPage extends ConsumerWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      ref.invalidate(sessionDetailProvider(sessionId));
      ref.invalidate(accessSnapshotProvider);
      ref.invalidate(isSessionSavedProvider(sessionId));
      ref.invalidate(recentSessionRunsProvider);
    });

    final detailAsync = ref.watch(sessionDetailProvider(sessionId));

    return ResponsivePageScaffold(
      title: Text(
        t.get('session_detail_nav_title', fallback: 'Session Detail'),
      ),
      bodyBuilder: (context, pageInfo) {
        return detailAsync.when(
          loading: () => const _SessionDetailLoadingView(),
          error: (_, __) => _SessionDetailErrorView(
            onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
          ),
          data: (detail) {
            if (detail == null) {
              return const RouteNotFoundPage(
                attemptedLocation: '/app/sessions/detail/:id',
              );
            }

            return ListView(
              padding: EdgeInsets.only(
                bottom: pageInfo.isCompact ? 34 : 46,
              ),
              children: [
                ResponsiveContentSection(
                  spacing: 14,
                  children: [
                    _DetailContent(detail: detail),
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

class _DetailContent extends ConsumerStatefulWidget {
  const _DetailContent({required this.detail});

  final SessionDetail detail;

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  bool _isSaving = false;
  bool _lockedViewTracked = false;

  void _trackLockedDetailView({
    required SessionSummary summary,
    required bool isLocked,
  }) {
    if (_lockedViewTracked || !isLocked) return;
    _lockedViewTracked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(
        ref.read(analyticsServiceProvider).track(
              AnalyticsEvent(
                eventName: AnalyticsEvents.lockedFeatureViewed,
                sourceSurface: AnalyticsSurfaces.sessionDetail,
                featureKey: 'core_session_detail',
                sessionId: summary.id,
                accessTier: summary.accessTier.name,
                entitlementKey: 'core_access',
                metadata: {
                  'surface_variant': 'detail_page',
                },
              ),
            ),
      );
    });
  }

  void _trackLockedStartTapped(SessionSummary summary) {
    unawaited(
      ref.read(analyticsServiceProvider).track(
            AnalyticsEvent(
              eventName: AnalyticsEvents.lockedFeatureCtaTapped,
              sourceSurface: AnalyticsSurfaces.sessionDetail,
              featureKey: 'core_session_start',
              sessionId: summary.id,
              accessTier: summary.accessTier.name,
              entitlementKey: 'core_access',
              metadata: {
                'cta': 'unlock_core',
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final summary = detail.summary;

    final saveState = ref.watch(isSessionSavedProvider(summary.id));
    final isSignedIn = ref.watch(isAuthenticatedProvider);
    final recentRunsAsync = ref.watch(recentSessionRunsProvider);

    final accessSnapshot = ref.watch(accessSnapshotProvider).maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

    final accessDecision = AccessPolicy.canAccessTier(
      snapshot: accessSnapshot,
      tier: summary.accessTier,
      feature: LockedFeature.sessionPlayer,
    );

    final isLocked = !accessDecision.allowed;
    _trackLockedDetailView(
      summary: summary,
      isLocked: isLocked,
    );

    final matchingRun = recentRunsAsync.maybeWhen(
      data: (runs) {
        for (final run in runs) {
          if (run.sessionId != summary.id) continue;
          if (run.status == SessionRunStatus.started) return run;

          if (run.status == SessionRunStatus.abandoned &&
              run.completedSteps > 0 &&
              run.completedSteps < run.totalSteps) {
            return run;
          }
        }

        return null;
      },
      orElse: () => null,
    );

    final startLabel = matchingRun == null
        ? null
        : matchingRun.status == SessionRunStatus.started
            ? AppText.get(
                context,
                key: 'continuity_continue_cta',
                fallback: 'Continue',
              )
            : AppText.get(
                context,
                key: 'continuity_resume_cta',
                fallback: 'Resume',
              );

    final isSaved = saveState.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    final playerSource = SessionEntrySource.sessionDetail.dbValue;
    final playerPath = '/app/sessions/player/${summary.id}?source=$playerSource';

    final title = AppText.get(
      context,
      key: summary.titleKey,
      fallback: summary.titleFallback,
    );

    final subtitle = AppText.get(
      context,
      key: summary.subtitleKey,
      fallback: summary.subtitleFallback,
    );

    final description = AppText.get(
      context,
      key: detail.longDescriptionKey,
      fallback: detail.longDescriptionFallback,
    );

    final why = AppText.get(
      context,
      key: detail.whyItHelpsKey,
      fallback: detail.whyItHelpsFallback,
    );

    final actualDurationMinutes = _durationMinutesFromSteps(
      detail.steps,
      fallback: summary.durationMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SessionDetailHeroPanel(
          sessionId: summary.id,
          title: title,
          subtitle: subtitle,
          description: _mergeSessionDescription(
            description: description,
            why: why,
          ),
          durationMinutes: actualDurationMinutes,
          levelLabel: _sessionLevelLabel(context, summary.sessionLevelTag),
          isLocked: isLocked,
        ),
        if (isLocked) ...[
          const SizedBox(height: 12),
          const PremiumLockBadge(),
        ],
        const SizedBox(height: 10),
        _SessionDetailInfoPanel(
          painTargets: summary.painTargets,
          equipment: _equipmentLabelsForDetail(context, detail),
          stepCount: detail.steps.length,
        ),
        const SizedBox(height: 10),
        _PrimaryActionPanel(
          isLocked: isLocked,
          isSaved: isSaved,
          isSaving: _isSaving,
          requiresSignInHint: !isSignedIn,
          startLabel: isLocked ? null : startLabel,
          onStartPressed: () {
            if (isLocked) {
              _trackLockedStartTapped(summary);
              context.pushNamed('premium');
              return;
            }

            if (!isSignedIn) {
              final redirect = Uri.encodeComponent(playerPath);
              context.push('/auth?mode=signin&redirect=$redirect');
              return;
            }

            context.push(playerPath);
          },
          onSavePressed: _isSaving
              ? null
              : () async {
                  await _handleSavePressed(
                    context: context,
                    ref: ref,
                    isSignedIn: isSignedIn,
                    isSaved: isSaved,
                    sessionId: summary.id,
                  );
                },
        ),
        if (detail.cautions.isNotEmpty ||
            detail.contraindications.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SafetyPanel(
            cautions: detail.cautions
                .map(
                  (item) => AppText.get(
                    context,
                    key: item.messageKey,
                    fallback: item.messageFallback,
                  ),
                )
                .toList(growable: false),
            avoid: detail.contraindications
                .map(
                  (item) => AppText.get(
                    context,
                    key: item.messageKey,
                    fallback: item.messageFallback,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  Future<void> _handleSavePressed({
    required BuildContext context,
    required WidgetRef ref,
    required bool isSignedIn,
    required bool isSaved,
    required String sessionId,
  }) async {
    final t = AppText.of(context);
    final repository = ref.read(savedSessionsRepositoryProvider);

    if (!isSignedIn) {
      final redirect = Uri.encodeComponent('/app/sessions/detail/$sessionId');
      if (!context.mounted) return;
      context.push('/auth?mode=signin&redirect=$redirect');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (isSaved) {
        await repository.unsaveSession(sessionId);
      } else {
        await repository.saveSession(sessionId);
      }

      ref.invalidate(savedSessionIdsProvider);
      ref.invalidate(savedSessionContinuityItemsProvider);
      ref.invalidate(recentlySavedSessionsProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved
                ? t.get(
                    'session_detail_unsaved_success',
                    fallback: 'Session removed from saved.',
                  )
                : t.get(
                    'session_detail_saved_success',
                    fallback: 'Session saved.',
                  ),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.get(
              'session_detail_save_failed',
              fallback: 'Could not update saved session.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

String _mergeSessionDescription({
  required String description,
  required String why,
}) {
  final primary = description.trim();
  final secondary = why.trim();

  if (primary.isEmpty) return secondary;
  if (secondary.isEmpty) return primary;
  if (primary == secondary) return primary;

  return '$primary\n\n$secondary';
}


int _durationMinutesFromSteps(
  List<SessionStep> steps, {
  required int fallback,
}) {
  final totalSeconds = steps.fold<int>(
    0,
    (total, step) => total + step.durationSeconds,
  );

  if (totalSeconds <= 0) return fallback;
  return (totalSeconds / 60).ceil().clamp(1, 1 << 30);
}

class _SessionDetailHeroPanel extends StatelessWidget {
  const _SessionDetailHeroPanel({
    required this.sessionId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.durationMinutes,
    required this.levelLabel,
    required this.isLocked,
  });

  final String sessionId;
  final String title;
  final String subtitle;
  final String description;
  final int durationMinutes;
  final String levelLabel;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final badges = <String>[
      t
          .get(
            'sessions_duration_minutes_format',
            fallback: '{minutes} min',
          )
          .replaceAll('{minutes}', durationMinutes.toString()),
      levelLabel,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 232,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: isDark ? 0.52 : 0.46),
                const Color(0xFF0F172A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _RemoteSessionCoverImage(
                sessionId: sessionId,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                fallbackBuilder: (_) => const _SessionCoverFallback(
                  iconSize: 44,
                  dark: true,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.black.withValues(alpha: 0.38),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImageBadge(
                      icon: isLocked ? Icons.lock_rounded : Icons.bolt_rounded,
                      label: isLocked
                          ? t.get('premium_title', fallback: 'Premium')
                          : t.get('session_detail_label', fallback: 'Session'),
                    ),
                    const Spacer(),
                    Text(
                      t
                          .get(
                            'session_detail_duration_big_label',
                            fallback: '{minutes} MIN',
                          )
                          .replaceAll('{minutes}', durationMinutes.toString()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.86,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 236,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.96),
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: badges
                          .take(4)
                          .map(
                            (item) => _ImageChip(label: item),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle.trim().isNotEmpty) ...[
                Text(
                  subtitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (description.trim().isNotEmpty)
                Text(
                  description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _ImageChip extends StatelessWidget {
  const _ImageChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
      ),
    );
  }
}


class _SessionDetailInfoPanel extends StatelessWidget {
  const _SessionDetailInfoPanel({
    required this.painTargets,
    required this.equipment,
    required this.stepCount,
  });

  final List<SessionPainTarget> painTargets;
  final List<String> equipment;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final targetLabels = painTargets
        .map(
          (item) => AppText.get(
            context,
            key: item.labelKey,
            fallback: item.labelFallback,
          ).trim(),
        )
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final bodyItems = targetLabels.isEmpty
        ? <String>[t.get('session_detail_body_target_general', fallback: 'General')]
        : targetLabels;

    final equipmentItems = equipment
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final stepsText = t
        .get('session_detail_steps_count_format', fallback: '{count} steps')
        .replaceAll('{count}', stepCount.toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.56),
                  colors.surface.withValues(alpha: 0.38),
                ]
              : [
                  colors.surface.withValues(alpha: 0.98),
                  colors.surfaceContainerLowest.withValues(alpha: 0.92),
                ],
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactInfoRow(
            icon: Icons.accessibility_new_rounded,
            title: t.get(
              'session_detail_body_targets_title',
              fallback: 'Body',
            ),
            items: bodyItems,
            emptyFallback: t.get(
              'session_detail_body_target_general',
              fallback: 'General',
            ),
            maxVisibleItems: 2,
          ),
          const SizedBox(height: 7),
          _CompactInfoRow(
            icon: Icons.inventory_2_outlined,
            title: t.get(
              'session_detail_equipment_title',
              fallback: 'Equipment',
            ),
            items: equipmentItems,
            emptyFallback: t.get(
              'session_detail_equipment_none',
              fallback: 'No equipment',
            ),
            maxVisibleItems: 3,
          ),
          const SizedBox(height: 7),
          _CompactInfoRow(
            icon: Icons.format_list_numbered_rounded,
            title: t.get(
              'session_detail_steps_title_compact',
              fallback: 'Steps',
            ),
            items: <String>[stepsText],
            emptyFallback: stepsText,
            maxVisibleItems: 1,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _CompactInfoRow extends StatelessWidget {
  const _CompactInfoRow({
    required this.icon,
    required this.title,
    required this.items,
    required this.emptyFallback,
    required this.maxVisibleItems,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final String emptyFallback;
  final int maxVisibleItems;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final resolvedItems = items.isEmpty ? <String>[emptyFallback] : items;
    final visibleItems = resolvedItems.take(maxVisibleItems).toList(growable: false);
    final hiddenCount = resolvedItems.length - visibleItems.length;

    return Tooltip(
      message: resolvedItems.join(' • '),
      waitDuration: const Duration(milliseconds: 420),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: emphasized
              ? colors.primary.withValues(alpha: isDark ? 0.13 : 0.08)
              : isDark
                  ? colors.surface.withValues(alpha: 0.32)
                  : colors.surfaceContainerLowest.withValues(alpha: 0.76),
          border: Border.all(
            color: emphasized
                ? colors.primary.withValues(alpha: 0.18)
                : colors.outlineVariant.withValues(alpha: isDark ? 0.42 : 0.30),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
              ),
              child: Icon(icon, color: colors.primary, size: 15),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 78,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _InlineInfoChips(
                items: visibleItems,
                hiddenCount: hiddenCount,
                emphasized: emphasized,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineInfoChips extends StatelessWidget {
  const _InlineInfoChips({
    required this.items,
    required this.hiddenCount,
    required this.emphasized,
  });

  final List<String> items;
  final int hiddenCount;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            items.join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: emphasized ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(width: 6),
          _InfoOverflowPill(count: hiddenCount),
        ],
      ],
    );
  }
}

class _InfoOverflowPill extends StatelessWidget {
  const _InfoOverflowPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: 0.11),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '+$count',
        maxLines: 1,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _PrimaryActionPanel extends StatelessWidget {
  const _PrimaryActionPanel({
    required this.isLocked,
    required this.isSaved,
    required this.isSaving,
    required this.requiresSignInHint,
    required this.onStartPressed,
    required this.onSavePressed,
    this.startLabel,
  });

  final bool isLocked;
  final bool isSaved;
  final bool isSaving;
  final bool requiresSignInHint;
  final VoidCallback onStartPressed;
  final VoidCallback? onSavePressed;
  final String? startLabel;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final startText = startLabel ??
        t.get(
          'session_detail_start_cta',
          fallback: 'Start Session',
        );

    final saveText = isSaving
        ? t.get('session_detail_saving_cta', fallback: 'Saving...')
        : isSaved
            ? t.get('session_detail_saved_cta', fallback: 'Saved')
            : t.get('session_detail_save_cta', fallback: 'Save');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.70),
                  colors.surface.withValues(alpha: 0.94),
                ]
              : [
                  colors.surface.withValues(alpha: 0.90),
                  colors.surfaceContainerLow.withValues(alpha: 0.82),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.76 : 0.62),
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 390;

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: onStartPressed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: Icon(
                        isLocked
                            ? Icons.lock_outline_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(startText),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: isSaving ? null : onSavePressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                            ),
                      label: Text(saveText),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: FilledButton.icon(
                      onPressed: onStartPressed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: Icon(
                        isLocked
                            ? Icons.lock_outline_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(startText),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: OutlinedButton.icon(
                      onPressed: isSaving ? null : onSavePressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                            ),
                      label: Text(saveText),
                    ),
                  ),
                ],
              );
            },
          ),
          if (requiresSignInHint) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    t.get(
                      'session_detail_save_requires_account_hint',
                      fallback: 'Saving requires sign-in.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}



class _SafetyPanel extends StatelessWidget {
  const _SafetyPanel({
    required this.cautions,
    required this.avoid,
  });

  final List<String> cautions;
  final List<String> avoid;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final visibleCautions =
        cautions.where((item) => item.trim().isNotEmpty).take(2).toList();
    final visibleAvoid =
        avoid.where((item) => item.trim().isNotEmpty).take(2).toList();

    return Theme(
      data: theme.copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    colors.surfaceContainerHigh.withValues(alpha: 0.70),
                    colors.surface.withValues(alpha: 0.94),
                  ]
                : [
                    colors.surface.withValues(alpha: 0.90),
                    colors.surfaceContainerLow.withValues(alpha: 0.82),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: isDark ? 0.76 : 0.62),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(
            Icons.health_and_safety_rounded,
            color: colors.primary,
          ),
          title: Text(
            t.get(
              'session_detail_safety_title',
              fallback: 'Safety',
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            t.get(
              'session_detail_safety_compact_subtitle',
              fallback: 'Check before you start.',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            if (visibleCautions.isNotEmpty)
              _SafetyGroup(
                title: t.get(
                  'session_detail_warning_title',
                  fallback: 'Use caution if',
                ),
                icon: Icons.warning_amber_rounded,
                items: visibleCautions,
              ),
            if (visibleCautions.isNotEmpty && visibleAvoid.isNotEmpty)
              const SizedBox(height: 10),
            if (visibleAvoid.isNotEmpty)
              _SafetyGroup(
                title: t.get(
                  'session_detail_avoid_title',
                  fallback: 'Avoid or stop if',
                ),
                icon: Icons.gpp_bad_rounded,
                items: visibleAvoid,
              ),
          ],
        ),
      ),
    );
  }
}


class _SmallTitle extends StatelessWidget {
  const _SmallTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: colors.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ],
    );
  }
}

class _SafetyGroup extends StatelessWidget {
  const _SafetyGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.48)
            : colors.surface.withValues(alpha: 0.66),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.68 : 0.54),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallTitle(icon: icon, title: title),
          const SizedBox(height: 9),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '• $item',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SessionDetailLoadingView extends StatelessWidget {
  const _SessionDetailLoadingView();

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

class _SessionDetailErrorView extends StatelessWidget {
  const _SessionDetailErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 36,
                  color: colors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  t.get(
                    'session_detail_error_title',
                    fallback: 'Could not load session',
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
                    'session_detail_error_subtitle',
                    fallback:
                        'Something went wrong while loading this session. Please try again.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(t.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


List<String> _equipmentLabelsForDetail(
  BuildContext context,
  SessionDetail detail,
) {
  final rawEquipment = detail.equipment
      .map((item) => _prettyEquipmentText(context, item))
      .where((item) => item.trim().isNotEmpty)
      .toSet();

  final stepEquipment = detail.steps
      .map((step) => step.effectiveEquipmentCode)
      .where((code) => code != SessionStepEquipmentCode.none)
      .map((code) => _equipmentCodeLabel(context, code))
      .where((item) => item.trim().isNotEmpty)
      .toSet();

  final merged = <String>{
    ...rawEquipment,
    ...stepEquipment,
  }.toList(growable: false);

  merged.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return merged;
}

String _prettyEquipmentText(BuildContext context, String raw) {
  final normalized = raw.trim().toLowerCase();
  switch (normalized) {
    case '':
    case 'none':
    case 'no_equipment':
      return '';
    case 'chair':
      return AppText.get(context, key: 'equipment_chair', fallback: 'Chair');
    case 'desk':
      return AppText.get(context, key: 'equipment_desk', fallback: 'Desk');
    case 'wall':
      return AppText.get(context, key: 'equipment_wall', fallback: 'Wall');
    case 'towel':
      return AppText.get(context, key: 'equipment_towel', fallback: 'Towel');
    case 'small_cushion':
      return AppText.get(
        context,
        key: 'equipment_small_cushion',
        fallback: 'Small cushion',
      );
    case 'lumbar_roll':
      return AppText.get(
        context,
        key: 'equipment_lumbar_roll',
        fallback: 'Lumbar roll',
      );
    case 'mini_band':
      return AppText.get(
        context,
        key: 'equipment_mini_band',
        fallback: 'Mini band',
      );
    case 'long_band':
    case 'resistance_band':
      return AppText.get(
        context,
        key: 'equipment_long_band',
        fallback: 'Resistance band',
      );
    case 'massage_ball':
      return AppText.get(
        context,
        key: 'equipment_massage_ball',
        fallback: 'Massage ball',
      );
    case 'soft_ball':
      return AppText.get(
        context,
        key: 'equipment_soft_ball',
        fallback: 'Soft ball',
      );
    case 'water_bottle':
      return AppText.get(
        context,
        key: 'equipment_water_bottle',
        fallback: 'Water bottle',
      );
    case 'dowel':
    case 'broomstick':
      return AppText.get(
        context,
        key: 'equipment_dowel',
        fallback: 'Dowel / broomstick',
      );
    case 'yoga_mat':
      return AppText.get(
        context,
        key: 'equipment_yoga_mat',
        fallback: 'Yoga mat',
      );
    case 'foam_roller':
      return AppText.get(
        context,
        key: 'equipment_foam_roller',
        fallback: 'Foam roller',
      );
    default:
      return raw
          .trim()
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map((part) => '${part.characters.first.toUpperCase()}${part.substring(1)}')
          .join(' ');
  }
}

String _equipmentCodeLabel(
  BuildContext context,
  SessionStepEquipmentCode code,
) {
  switch (code) {
    case SessionStepEquipmentCode.none:
      return '';
    case SessionStepEquipmentCode.chair:
      return AppText.get(context, key: 'equipment_chair', fallback: 'Chair');
    case SessionStepEquipmentCode.desk:
      return AppText.get(context, key: 'equipment_desk', fallback: 'Desk');
    case SessionStepEquipmentCode.wall:
      return AppText.get(context, key: 'equipment_wall', fallback: 'Wall');
    case SessionStepEquipmentCode.towel:
      return AppText.get(context, key: 'equipment_towel', fallback: 'Towel');
    case SessionStepEquipmentCode.smallCushion:
      return AppText.get(
        context,
        key: 'equipment_small_cushion',
        fallback: 'Small cushion',
      );
    case SessionStepEquipmentCode.lumbarRoll:
      return AppText.get(
        context,
        key: 'equipment_lumbar_roll',
        fallback: 'Lumbar roll',
      );
    case SessionStepEquipmentCode.miniBand:
      return AppText.get(
        context,
        key: 'equipment_mini_band',
        fallback: 'Mini band',
      );
    case SessionStepEquipmentCode.longBand:
      return AppText.get(
        context,
        key: 'equipment_long_band',
        fallback: 'Resistance band',
      );
    case SessionStepEquipmentCode.massageBall:
      return AppText.get(
        context,
        key: 'equipment_massage_ball',
        fallback: 'Massage ball',
      );
    case SessionStepEquipmentCode.softBall:
      return AppText.get(
        context,
        key: 'equipment_soft_ball',
        fallback: 'Soft ball',
      );
    case SessionStepEquipmentCode.waterBottle:
      return AppText.get(
        context,
        key: 'equipment_water_bottle',
        fallback: 'Water bottle',
      );
    case SessionStepEquipmentCode.dowel:
      return AppText.get(
        context,
        key: 'equipment_dowel',
        fallback: 'Dowel / broomstick',
      );
    case SessionStepEquipmentCode.yogaMat:
      return AppText.get(
        context,
        key: 'equipment_yoga_mat',
        fallback: 'Yoga mat',
      );
    case SessionStepEquipmentCode.foamRoller:
      return AppText.get(
        context,
        key: 'equipment_foam_roller',
        fallback: 'Foam roller',
      );
  }
}



String _sessionLevelLabel(BuildContext context, SessionLevelTag level) {
  final t = AppText.of(context);

  switch (level) {
    case SessionLevelTag.freeStarter:
      return t.get('session_level_free_starter', fallback: 'Starter');
    case SessionLevelTag.therapy:
      return t.get('session_level_therapy', fallback: 'Therapy');
    case SessionLevelTag.advancedTherapy:
      return t.get('session_level_advanced_therapy', fallback: 'Advanced therapy');
    case SessionLevelTag.flagship:
      return t.get('session_level_flagship', fallback: 'Flagship');
  }
}



const String _remoteSessionCoverBaseUrl =
    'https://weglabs.com/data/desk-workout/covers/sessions';

String _remoteSessionCoverUrl(String sessionId) =>
    '$_remoteSessionCoverBaseUrl/$sessionId.webp';

class _RemoteSessionCoverImage extends StatelessWidget {
  const _RemoteSessionCoverImage({
    required this.sessionId,
    required this.fit,
    required this.alignment,
    required this.fallbackBuilder,
  });

  final String sessionId;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WidgetBuilder fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _remoteSessionCoverUrl(sessionId),
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallbackBuilder(context);
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/sessions/$sessionId.png',
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallbackBuilder(context),
      ),
    );
  }
}

class _SessionCoverFallback extends StatelessWidget {
  const _SessionCoverFallback({
    this.iconSize = 34,
    this.dark = false,
  });

  final double iconSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  colors.primary.withValues(alpha: 0.30),
                  colors.tertiary.withValues(alpha: 0.16),
                  const Color(0xFF0F172A),
                ]
              : [
                  colors.primary.withValues(alpha: 0.16),
                  colors.tertiary.withValues(alpha: 0.10),
                  const Color(0xFFF7FAFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.self_improvement_rounded,
        color: dark ? Colors.white.withValues(alpha: 0.80) : colors.primary,
        size: iconSize,
      ),
    );
  }
}
