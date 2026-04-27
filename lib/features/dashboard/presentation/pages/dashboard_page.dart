// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../player/application/session_continuity_providers.dart';
import '../../../player/domain/session_continuity_models.dart';
import '../../../player/domain/session_feedback_models.dart';
import '../../domain/dashboard_snapshot.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(dashboardControllerProvider);
    await ref.read(dashboardControllerProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final continueCandidateAsync = ref.watch(continueSessionCandidateProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('dashboard_title', fallback: 'Dashboard')),
      actions: [
        _LanguageSwitcherAction(ref: ref),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          onPressed: () => context.goNamed('profile'),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        return dashboardAsync.when(
          loading: () => const _DashboardLoadingState(),
          error: (error, stackTrace) => _DashboardErrorState(
            message: '$error',
            onRetry: () => ref.invalidate(dashboardControllerProvider),
          ),
          data: (snapshot) {
            if (!snapshot.hasContent) {
              return RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    _DashboardEmptyState(),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: pageInfo.isCompact ? 28 : 36,
                ),
                children: [
                  ResponsiveContentSection(
                    spacing: pageInfo.sectionSpacing,
                    children: [
                      continueCandidateAsync.maybeWhen(
                        data: (candidate) => _DashboardHero(
                          snapshot: snapshot,
                          candidate: candidate,
                          accessSnapshot: accessAsync.maybeWhen(
                            data: (value) => value,
                            orElse: () => AccessSnapshot.guest,
                          ),
                        ),
                        orElse: () => _DashboardHero(
                          snapshot: snapshot,
                          candidate: null,
                          accessSnapshot: accessAsync.maybeWhen(
                            data: (value) => value,
                            orElse: () => AccessSnapshot.guest,
                          ),
                        ),
                      ),
                      _DashboardMetricsSection(snapshot: snapshot),
                      _RecoverySignalsSurface(snapshot: snapshot),
                      _RecentRunsSurface(snapshot: snapshot),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LanguageSwitcherAction extends StatelessWidget {
  const _LanguageSwitcherAction({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return PopupMenuButton<Locale>(
      tooltip: AppText.get(
        context,
        key: 'settings_language_sheet_title',
        fallback: 'Language',
      ),
      icon: const Icon(Icons.language_rounded),
      onSelected: (locale) {
        ref.read(appLocaleControllerProvider.notifier).setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              const Text('EN'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppText.get(
                    context,
                    key: 'settings_language_english',
                    fallback: 'English',
                  ),
                ),
              ),
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('de'),
          child: Row(
            children: [
              const Text('DE'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppText.get(
                    context,
                    key: 'settings_language_german',
                    fallback: 'German',
                  ),
                ),
              ),
              if (currentLocale.languageCode == 'de')
                const Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('fa'),
          child: Row(
            children: [
              const Text('FA'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppText.get(
                    context,
                    key: 'settings_language_persian',
                    fallback: 'Persian',
                  ),
                ),
              ),
              if (currentLocale.languageCode == 'fa')
                const Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.snapshot,
    required this.candidate,
    required this.accessSnapshot,
  });

  final DashboardSnapshot snapshot;
  final ContinueSessionCandidate? candidate;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 940;

        return _GlassSurface(
          radius: 32,
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              const Positioned(
                top: -28,
                right: -16,
                child: _AmbientGlow(size: 170),
              ),
              const Positioned(
                bottom: -34,
                left: -20,
                child: _AmbientGlow(size: 160),
              ),
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: _HeroPrimaryCluster(snapshot: snapshot),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 10,
                      child: _HeroActionPanel(
                        snapshot: snapshot,
                        candidate: candidate,
                        accessSnapshot: accessSnapshot,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroPrimaryCluster(snapshot: snapshot),
                    const SizedBox(height: 14),
                    _HeroActionPanel(
                      snapshot: snapshot,
                      candidate: candidate,
                      accessSnapshot: accessSnapshot,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPrimaryCluster extends StatelessWidget {
  const _HeroPrimaryCluster({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalHero = width >= 430;
        final orbSize = width >= 700 ? 196.0 : 172.0;
        final ringSize = width >= 700 ? 172.0 : 148.0;
        final coreSize = width >= 700 ? 106.0 : 94.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (horizontalHero)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.get(
                            'dashboard_hero_title',
                            fallback: 'What should your body do next?',
                          ),
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.02,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.get(
                            'dashboard_hero_body',
                            fallback:
                                'Use readiness, current signals, and your next best action.',
                          ),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.24,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RecoveryOrb(
                    snapshot: snapshot,
                    size: orbSize,
                    ringSize: ringSize,
                    coreSize: coreSize,
                  ),
                ],
              )
            else ...[
              Text(
                t.get(
                  'dashboard_hero_title',
                  fallback: 'What should your body do next?',
                ),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.02,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                t.get(
                  'dashboard_hero_body',
                  fallback:
                      'Use readiness, current signals, and your next best action.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.24,
                    ),
              ),
              const SizedBox(height: 12),
              Center(
                child: _RecoveryOrb(
                  snapshot: snapshot,
                  size: 156,
                  ringSize: 136,
                  coreSize: 88,
                ),
              ),
            ],
            const SizedBox(height: 14),
            _StateChipGrid(snapshot: snapshot),
          ],
        );
      },
    );
  }
}

class _StateChipGrid extends StatelessWidget {
  const _StateChipGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _StateMetricCard(
        icon: Icons.bolt_rounded,
        label: AppText.get(
          context,
          key: 'dashboard_state_energy',
          fallback: 'Energy',
        ),
        value: _stateLevelLabel(context, snapshot.currentEnergyLevel),
      ),
      _StateMetricCard(
        icon: Icons.spa_outlined,
        label: AppText.get(
          context,
          key: 'dashboard_state_stress',
          fallback: 'Stress',
        ),
        value: _stateLevelLabel(context, snapshot.currentStressLevel),
      ),
      _StateMetricCard(
        icon: Icons.center_focus_strong_rounded,
        label: AppText.get(
          context,
          key: 'dashboard_state_focus',
          fallback: 'Focus',
        ),
        value: _stateLevelLabel(context, snapshot.currentFocusLevel),
      ),
    ];

    return Row(
      children: [
        Expanded(child: chips[0]),
        const SizedBox(width: 8),
        Expanded(child: chips[1]),
        const SizedBox(width: 8),
        Expanded(child: chips[2]),
      ],
    );
  }
}

class _StateMetricCard extends StatelessWidget {
  const _StateMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionPanel extends StatelessWidget {
  const _HeroActionPanel({
    required this.snapshot,
    required this.candidate,
    required this.accessSnapshot,
  });

  final DashboardSnapshot snapshot;
  final ContinueSessionCandidate? candidate;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final nextSession = snapshot.nextSession;
    final title = nextSession == null
        ? AppText.get(
            context,
            key: 'dashboard_next_session_empty',
            fallback: 'No next session yet',
          )
        : AppText.get(
            context,
            key: nextSession.titleKey,
            fallback: nextSession.titleFallback,
          );

    final duration =
        nextSession == null ? '--' : '${nextSession.durationMinutes}m';
    final dominantZone = _painAreaLabel(context, snapshot.dominantPainAreaCode);
    final nextSessionLocked =
        nextSession != null &&
        nextSession.requiresCoreAccess &&
        !nextSession.isActiveRun &&
        !accessSnapshot.hasCoreAccess;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.74),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (candidate != null) ...[
            _CompactContinuityBanner(candidate: candidate!),
            const SizedBox(height: 12),
          ],
          Text(
            AppText.get(
              context,
              key: 'dashboard_next_session_title',
              fallback: 'Next Best Action',
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          _NextBestActionPanel(
            sessionTitle: title,
            dominantZone: dominantZone,
            duration: duration,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 420) {
                return Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: FilledButton.icon(
                        onPressed: () => context.pushNamed('body-map'),
                        icon: const Icon(Icons.accessibility_new_rounded),
                        label: Text(
                          AppText.get(
                            context,
                            key: 'dashboard_open_body_map',
                            fallback: 'Open Body Map',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 8,
                      child: OutlinedButton.icon(
                        onPressed: nextSession == null
                            ? () => context.goNamed('quick-fix')
                            : nextSessionLocked
                                ? () => context.pushNamed('premium')
                                : nextSession.isActiveRun
                                    ? () => context.pushNamed(
                                          'session-player',
                                          pathParameters: {'id': nextSession.sessionId},
                                          queryParameters: const {'source': 'dashboard'},
                                        )
                                    : () => context.pushNamed(
                                          'session-detail',
                                          pathParameters: {'id': nextSession.sessionId},
                                        ),
                        icon: Icon(
                          nextSession == null
                              ? Icons.flash_on_rounded
                              : nextSessionLocked
                                  ? Icons.lock_open_rounded
                                  : nextSession.isActiveRun
                                      ? Icons.play_arrow_rounded
                                      : Icons.open_in_new_rounded,
                        ),
                        label: Text(
                          nextSession == null
                              ? AppText.get(
                                  context,
                                  key: 'dashboard_open_quick_fix',
                                  fallback: 'Quick Fix',
                                )
                              : nextSessionLocked
                                  ? AppText.get(
                                      context,
                                      key: 'access_unlock_core_cta',
                                      fallback: 'Unlock Core',
                                    )
                                  : nextSession.isActiveRun
                                      ? AppText.get(
                                          context,
                                          key: 'dashboard_continue_now',
                                          fallback: 'Continue',
                                        )
                                      : AppText.get(
                                          context,
                                          key: 'dashboard_preview_session',
                                          fallback: 'Preview',
                                        ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.pushNamed('body-map'),
                      icon: const Icon(Icons.accessibility_new_rounded),
                      label: Text(
                        AppText.get(
                          context,
                          key: 'dashboard_open_body_map',
                          fallback: 'Open Body Map',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: nextSession == null
                          ? () => context.goNamed('quick-fix')
                          : nextSessionLocked
                              ? () => context.pushNamed('premium')
                              : nextSession.isActiveRun
                                  ? () => context.pushNamed(
                                        'session-player',
                                        pathParameters: {'id': nextSession.sessionId},
                                        queryParameters: const {'source': 'dashboard'},
                                      )
                                  : () => context.pushNamed(
                                        'session-detail',
                                        pathParameters: {'id': nextSession.sessionId},
                                      ),
                      icon: Icon(
                        nextSession == null
                            ? Icons.flash_on_rounded
                            : nextSessionLocked
                                ? Icons.lock_open_rounded
                                : nextSession.isActiveRun
                                    ? Icons.play_arrow_rounded
                                    : Icons.open_in_new_rounded,
                      ),
                      label: Text(
                        nextSession == null
                            ? AppText.get(
                                context,
                                key: 'dashboard_open_quick_fix',
                                fallback: 'Quick Fix',
                              )
                            : nextSessionLocked
                                ? AppText.get(
                                    context,
                                    key: 'access_unlock_core_cta',
                                    fallback: 'Unlock Core',
                                  )
                                : nextSession.isActiveRun
                                    ? AppText.get(
                                        context,
                                        key: 'dashboard_continue_now',
                                        fallback: 'Continue',
                                      )
                                    : AppText.get(
                                        context,
                                        key: 'dashboard_preview_session',
                                        fallback: 'Preview',
                                      ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NextBestActionPanel extends StatelessWidget {
  const _NextBestActionPanel({
    required this.sessionTitle,
    required this.dominantZone,
    required this.duration,
  });

  final String sessionTitle;
  final String dominantZone;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 15,
          child: _ActionFeatureCard(
            label: AppText.get(
              context,
              key: 'dashboard_next_session_label',
              fallback: 'Session',
            ),
            value: sessionTitle,
            icon: Icons.auto_awesome_rounded,
            emphasized: true,
            compactValue: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: _ActionFeatureCard(
            label: '',
            value: duration,
            icon: Icons.schedule_rounded,
            compactValue: true,
          ),
        ),
      ],
    );
  }
}

class _ActionFeatureCard extends StatelessWidget {
  const _ActionFeatureCard({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasized = false,
    this.compactValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasized;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasLabel = label.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        minHeight: hasLabel ? 72 : 58,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: hasLabel ? 10 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: emphasized
            ? LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.12),
                  colors.surfaceContainerHighest.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: emphasized ? null : colors.surfaceContainerHighest,
        border: Border.all(
          color: emphasized
              ? primary.withValues(alpha: 0.22)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasLabel) ...[
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: emphasized ? primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Text(
            value,
            maxLines: compactValue ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: (compactValue
                    ? textTheme.titleSmall
                    : textTheme.titleMedium)
                ?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactContinuityBanner extends StatelessWidget {
  const _CompactContinuityBanner({required this.candidate});

  final ContinueSessionCandidate candidate;

  bool get _canOpenPlayerDirectly {
    return candidate.reason == ContinuityReason.activeRun ||
        candidate.reason == ContinuityReason.resumableRun ||
        candidate.action == ContinuityActionType.continueSession ||
        candidate.action == ContinuityActionType.resumeSession;
  }

  @override
  Widget build(BuildContext context) {
    final title = AppText.get(
      context,
      key: candidate.session.titleKey,
      fallback: candidate.session.titleFallback,
    );

    final actionLabel = _canOpenPlayerDirectly
        ? _continuityActionLabel(context, candidate.action)
        : AppText.get(
            context,
            key: 'continuity_preview_cta',
            fallback: 'Preview',
          );

    final actionIcon = _canOpenPlayerDirectly
        ? Icons.play_arrow_rounded
        : Icons.open_in_new_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.14),
            ),
            child: Icon(
              actionIcon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              if (_canOpenPlayerDirectly) {
                context.pushNamed(
                  'session-player',
                  pathParameters: {'id': candidate.sessionId},
                  queryParameters: const {'source': 'dashboard'},
                );
                return;
              }

              context.pushNamed(
                'session-detail',
                pathParameters: {'id': candidate.sessionId},
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricsSection extends StatelessWidget {
  const _DashboardMetricsSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final completed = snapshot.completedSessionsThisWeek;
    final quickFixStarts = snapshot.quickFixStartsThisWeek;
    final helpRate = (snapshot.helpRate * 100).round();

    final items = [
      _MomentumTile(
        icon: Icons.check_circle_outline_rounded,
        label: AppText.get(
          context,
          key: 'dashboard_completed_this_week',
          fallback: 'Completed',
        ),
        value: '$completed',
      ),
      _MomentumTile(
        icon: Icons.flash_on_outlined,
        label: AppText.get(
          context,
          key: 'dashboard_quick_fix_this_week',
          fallback: 'Quick Fix',
        ),
        value: '$quickFixStarts',
      ),
      _MomentumTile(
        icon: Icons.favorite_border_rounded,
        label: AppText.get(
          context,
          key: 'dashboard_help_rate',
          fallback: 'Help Rate',
        ),
        value: '$helpRate%',
        featured: true,
      ),
    ];

    return _PremiumSurface(
      title: AppText.get(
        context,
        key: 'dashboard_momentum_title',
        fallback: 'Momentum',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return Row(
              children: [
                Expanded(child: items[0]),
                const SizedBox(width: 10),
                Expanded(child: items[1]),
                const SizedBox(width: 10),
                Expanded(child: items[2]),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: items[0]),
                  const SizedBox(width: 10),
                  Expanded(child: items[1]),
                ],
              ),
              const SizedBox(height: 10),
              items[2],
            ],
          );
        },
      ),
    );
  }
}

class _MomentumTile extends StatelessWidget {
  const _MomentumTile({
    required this.icon,
    required this.label,
    required this.value,
    this.featured = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: featured ? 74 : 68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: featured
            ? LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.10),
                  Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.94),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: featured
            ? null
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.74),
        border: Border.all(
          color: featured
              ? primary.withValues(alpha: 0.20)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecoverySignalsSurface extends StatelessWidget {
  const _RecoverySignalsSurface({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final dominantZone = _painAreaLabel(context, snapshot.dominantPainAreaCode);
    final helpRate = (snapshot.helpRate * 100).round();
    final consistency = (snapshot.consistencyScore * 100).round();
    final topZones = snapshot.bodyZones.take(3).toList();

    return _PremiumSurface(
      title: AppText.get(
        context,
        key: 'dashboard_body_signals_title',
        fallback: 'Recovery Signals',
      ),
      child: Column(
        children: [
          _SignalCoreOrb(helpRate: helpRate),
          const SizedBox(height: 12),
          _RecoveryStatsGrid(
            dominantZone: dominantZone,
            helpRate: helpRate,
            consistency: consistency,
          ),
          if (topZones.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children: topZones.map((zone) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BodySignalBar(zone: zone),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryStatsGrid extends StatelessWidget {
  const _RecoveryStatsGrid({
    required this.dominantZone,
    required this.helpRate,
    required this.consistency,
  });

  final String dominantZone;
  final int helpRate;
  final int consistency;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SignalStatCard(
        label: AppText.get(
          context,
          key: 'dashboard_dominant_zone',
          fallback: 'Dominant Zone',
        ),
        value: dominantZone,
        icon: Icons.adjust_rounded,
      ),
      _SignalStatCard(
        label: AppText.get(
          context,
          key: 'dashboard_help_rate',
          fallback: 'Help Rate',
        ),
        value: '$helpRate%',
        icon: Icons.favorite_rounded,
        featured: true,
      ),
      _SignalStatCard(
        label: AppText.get(
          context,
          key: 'dashboard_consistency',
          fallback: 'Consistency',
        ),
        value: '$consistency%',
        icon: Icons.track_changes_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: 8),
              Expanded(child: items[1]),
              const SizedBox(width: 8),
              Expanded(child: items[2]),
            ],
          );
        }

        if (constraints.maxWidth >= 420) {
          return Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: 8),
              Expanded(child: items[1]),
              const SizedBox(width: 8),
              Expanded(child: items[2]),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: items[0]),
                const SizedBox(width: 8),
                Expanded(child: items[1]),
              ],
            ),
            const SizedBox(height: 4),
            items[2],
          ],
        );
      },
    );
  }
}

class _SignalCoreOrb extends StatelessWidget {
  const _SignalCoreOrb({required this.helpRate});

  final int helpRate;

  @override
  Widget build(BuildContext context) {
    final progress = (helpRate / 100).clamp(0.0, 1.0);

    return Container(
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(128, 128),
                  painter: _MiniRingPainter(
                    progress: animatedProgress,
                    color: Theme.of(context).colorScheme.primary,
                    trackColor: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.22),
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.20),
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$helpRate%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          AppText.get(
                            context,
                            key: 'dashboard_help_rate',
                            fallback: 'Relief',
                          ),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignalStatCard extends StatelessWidget {
  const _SignalStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.featured = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: featured
            ? LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.10),
                  Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.94),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: featured
            ? null
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: featured
              ? primary.withValues(alpha: 0.22)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}

class _BodySignalBar extends StatelessWidget {
  const _BodySignalBar({required this.zone});

  final DashboardBodyZoneStat zone;

  @override
  Widget build(BuildContext context) {
    final progress = (zone.reliefScore.clamp(0.0, 100.0) / 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Text(
              _painAreaLabel(context, zone.painAreaCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, _) {
                  return LinearProgressIndicator(
                    value: animatedValue,
                    minHeight: 10,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${zone.hits}x',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentRunsSurface extends StatelessWidget {
  const _RecentRunsSurface({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      title: AppText.get(
        context,
        key: 'dashboard_recent_runs_title',
        fallback: 'Recent Recovery Runs',
      ),
      child: snapshot.recentRuns.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                AppText.get(
                  context,
                  key: 'dashboard_empty_recent_runs',
                  fallback: 'Recent session runs will appear here.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          : Column(
              children: snapshot.recentRuns.take(4).map((run) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecentRunCompactTile(run: run),
                );
              }).toList(),
            ),
    );
  }
}

class _RecentRunCompactTile extends StatelessWidget {
  const _RecentRunCompactTile({required this.run});

  final DashboardRecentRun run;

  @override
  Widget build(BuildContext context) {
    final title = AppText.get(
      context,
      key: run.titleKey,
      fallback: run.titleFallback,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/app/sessions/detail/${run.sessionId}'),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _runStatusColor(context, run.status).withValues(alpha: 0.12),
                ),
                child: Icon(
                  _runStatusIcon(run.status),
                  size: 20,
                  color: _runStatusColor(context, run.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${run.elapsedMinutes}m • ${_entrySourceLabel(context, run.entrySource)}'
                      '${run.primaryPainAreaCode == null ? '' : ' • ${_painAreaLabel(context, run.primaryPainAreaCode)}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RunStatusTagCompact(
                label: _runStatusLabel(context, run.status, run.helped),
                color: _runStatusColor(context, run.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunStatusTagCompact extends StatelessWidget {
  const _RunStatusTagCompact({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PremiumSurface extends StatelessWidget {
  const _PremiumSurface({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    required this.child,
    required this.radius,
    required this.padding,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHigh,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _RecoveryOrb extends StatelessWidget {
  const _RecoveryOrb({
    required this.snapshot,
    required this.size,
    required this.ringSize,
    required this.coreSize,
  });

  final DashboardSnapshot snapshot;
  final double size;
  final double ringSize;
  final double coreSize;

  @override
  Widget build(BuildContext context) {
    final score = snapshot.readinessScore.clamp(0, 100);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: score / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _PulseFieldPainter(
                  primary: Theme.of(context).colorScheme.primary,
                  secondary: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Transform.rotate(
                angle: progress * 0.18,
                child: CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _ReadinessRingPainter(
                    progress: progress,
                    color: Theme.of(context).colorScheme.primary,
                    trackColor: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.28),
                  ),
                ),
              ),
              Container(
                width: coreSize,
                height: coreSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.28),
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.14),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                            ),
                      ),
                      Text(
                        AppText.get(
                          context,
                          key: 'dashboard_readiness_title',
                          fallback: 'Readiness',
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

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

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    t.get(
                      'dashboard_error_title',
                      fallback: 'Unable to load dashboard',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message?.trim().isNotEmpty == true
                        ? message!
                        : t.get(
                            'dashboard_error_body',
                            fallback: 'Please try again.',
                          ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(
                      t.get('dashboard_error_retry', fallback: 'Retry'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardEmptyState extends ConsumerWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.dashboard_outlined, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    t.get(
                      'dashboard_empty_title',
                      fallback: 'No dashboard data yet',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.get(
                      'dashboard_empty_body',
                      fallback:
                          'Complete a session or launch a Quick Fix to populate your dashboard.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(dashboardControllerProvider),
                    child: Text(
                      t.get('dashboard_empty_refresh', fallback: 'Refresh'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseFieldPainter extends CustomPainter {
  _PulseFieldPainter({
    required this.primary,
    required this.secondary,
  });

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: 0.18),
          secondary.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawCircle(center, size.width / 2.2, fill);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final entry in <(double, double)>[
      (0.82, 0.10),
      (0.64, 0.14),
      (0.48, 0.18),
    ]) {
      ringPaint
        ..strokeWidth = 1.4
        ..color = primary.withValues(alpha: entry.$2);
      canvas.drawCircle(center, size.width * entry.$1 / 2, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseFieldPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.secondary != secondary;
  }
}

class _ReadinessRingPainter extends CustomPainter {
  _ReadinessRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.24),
          color.withValues(alpha: 0.70),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReadinessRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.60),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

String _continuityActionLabel(
  BuildContext context,
  ContinuityActionType action,
) {
  switch (action) {
    case ContinuityActionType.continueSession:
      return AppText.get(
        context,
        key: 'continuity_continue_cta',
        fallback: 'Continue',
      );
    case ContinuityActionType.resumeSession:
      return AppText.get(
        context,
        key: 'continuity_resume_cta',
        fallback: 'Resume',
      );
    case ContinuityActionType.repeatSession:
      return AppText.get(
        context,
        key: 'continuity_repeat_cta',
        fallback: 'Do Again',
      );
    case ContinuityActionType.startSession:
      return AppText.get(
        context,
        key: 'continuity_start_cta',
        fallback: 'Start',
      );
  }
}

String _stateLevelLabel(BuildContext context, SessionStateLevel? level) {
  switch (level) {
    case SessionStateLevel.low:
      return AppText.get(context, key: 'common_level_low', fallback: 'Low');
    case SessionStateLevel.medium:
      return AppText.get(
        context,
        key: 'common_level_medium',
        fallback: 'Medium',
      );
    case SessionStateLevel.high:
      return AppText.get(context, key: 'common_level_high', fallback: 'High');
    case null:
      return AppText.get(
        context,
        key: 'dashboard_state_unknown',
        fallback: 'Unknown',
      );
  }
}

String _painAreaLabel(BuildContext context, String? code) {
  switch (code) {
    case 'neck':
      return AppText.get(context, key: 'pain_neck', fallback: 'Neck');
    case 'shoulders':
      return AppText.get(
        context,
        key: 'pain_shoulders',
        fallback: 'Shoulders',
      );
    case 'upper_back':
      return AppText.get(
        context,
        key: 'pain_upper_back',
        fallback: 'Upper back',
      );
    case 'lower_back':
      return AppText.get(
        context,
        key: 'pain_lower_back',
        fallback: 'Lower back',
      );
    case 'wrists':
      return AppText.get(context, key: 'pain_wrists', fallback: 'Wrists');
    case null:
      return AppText.get(
        context,
        key: 'dashboard_zone_unknown',
        fallback: 'No clear zone yet',
      );
    default:
      return code.replaceAll('_', ' ');
  }
}

String _entrySourceLabel(BuildContext context, SessionEntrySource source) {
  switch (source) {
    case SessionEntrySource.quickFix:
      return AppText.get(
        context,
        key: 'session_entry_quick_fix',
        fallback: 'Quick Fix',
      );
    case SessionEntrySource.sessionDetail:
      return AppText.get(
        context,
        key: 'session_entry_detail',
        fallback: 'Detail',
      );
    case SessionEntrySource.sessionsLibrary:
      return AppText.get(
        context,
        key: 'session_entry_library',
        fallback: 'Library',
      );
    case SessionEntrySource.dashboard:
      return AppText.get(
        context,
        key: 'session_entry_dashboard',
        fallback: 'Dashboard',
      );
    case SessionEntrySource.profile:
      return AppText.get(
        context,
        key: 'session_entry_profile',
        fallback: 'Profile',
      );
    case SessionEntrySource.reminders:
      return AppText.get(
        context,
        key: 'session_entry_reminders',
        fallback: 'Reminders',
      );
    case SessionEntrySource.unknown:
      return AppText.get(
        context,
        key: 'common_unknown',
        fallback: 'Unknown',
      );
  }
}

IconData _runStatusIcon(DashboardRunStatus status) {
  switch (status) {
    case DashboardRunStatus.completed:
      return Icons.check_circle_outline_rounded;
    case DashboardRunStatus.abandoned:
      return Icons.exit_to_app_rounded;
    case DashboardRunStatus.started:
      return Icons.play_circle_outline_rounded;
  }
}

Color _runStatusColor(BuildContext context, DashboardRunStatus status) {
  switch (status) {
    case DashboardRunStatus.completed:
      return Theme.of(context).colorScheme.primary;
    case DashboardRunStatus.abandoned:
      return Theme.of(context).colorScheme.error;
    case DashboardRunStatus.started:
      return Theme.of(context).colorScheme.secondary;
  }
}

String _runStatusLabel(
  BuildContext context,
  DashboardRunStatus status,
  bool? helped,
) {
  switch (status) {
    case DashboardRunStatus.completed:
      if (helped == true) {
        return AppText.get(
          context,
          key: 'dashboard_run_helped',
          fallback: 'Helped',
        );
      }
      return AppText.get(
        context,
        key: 'dashboard_run_done',
        fallback: 'Done',
      );
    case DashboardRunStatus.abandoned:
      return AppText.get(
        context,
        key: 'dashboard_run_ended',
        fallback: 'Ended',
      );
    case DashboardRunStatus.started:
      return AppText.get(
        context,
        key: 'dashboard_run_started',
        fallback: 'Started',
      );
  }
}