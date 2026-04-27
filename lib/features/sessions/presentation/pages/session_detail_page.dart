// lib/features/sessions/presentation/pages/session_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../player/domain/session_feedback_models.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/adaptive_section_title.dart';
import '../../../../shared/widgets/feedback/route_not_found_page.dart';
import '../../application/sessions_providers.dart';
import '../../domain/session_models.dart';
import '../widgets/session_detail_action_bar.dart';
import '../widgets/session_detail_hero_card.dart';
import '../widgets/session_detail_info_card.dart';
import '../widgets/session_detail_warning_card.dart';
import '../../../player/application/session_continuity_providers.dart';
import '../../../player/domain/session_run_models.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/premium_lock_badge.dart';

class SessionDetailPage extends ConsumerWidget {
  const SessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final detailAsync = ref.watch(sessionDetailProvider(sessionId));

    void goBackSafely() {
      if (context.canPop()) {
        context.pop();
        return;
      }

      context.go('/app/sessions');
    }

    return ResponsivePageScaffold(
      title: Text(
        t.get('session_detail_nav_title', fallback: 'Session Detail'),
      ),
      actions: [
        IconButton(
          onPressed: goBackSafely,
          tooltip: t.get('session_detail_back_tooltip', fallback: 'Back'),
          icon: const Icon(Icons.arrow_back),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        return detailAsync.when(
          loading: () => const _SessionDetailLoadingView(),
          error: (error, stackTrace) => _SessionDetailErrorView(
            onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
          ),
          data: (detail) {
            if (detail == null) {
              return const RouteNotFoundPage(
                attemptedLocation: '/app/sessions/detail/:id',
              );
            }

            return ListView(
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
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

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final saveState = ref.watch(isSessionSavedProvider(detail.summary.id));
    final isSignedIn = ref.watch(isAuthenticatedProvider);
    final recentRunsAsync = ref.watch(recentSessionRunsProvider);

    final accessSnapshot = ref.watch(accessSnapshotProvider).maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

    final accessDecision = AccessPolicy.canAccessTier(
      snapshot: accessSnapshot,
      tier: detail.summary.accessTier,
      feature: LockedFeature.sessionPlayer,
    );

    final isLocked = !accessDecision.allowed;

    final matchingRun = recentRunsAsync.maybeWhen(
      data: (runs) {
        for (final run in runs) {
          if (run.sessionId != detail.summary.id) continue;
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
    final playerPath = '/app/sessions/player/${detail.summary.id}?source=$playerSource';

    final modeChips = <String>[
      if (detail.summary.modeCompatibility.dadMode)
        AppText.get(context, key: 'session_mode_dad', fallback: 'Dad Mode'),
      if (detail.summary.modeCompatibility.nightMode)
        AppText.get(context, key: 'session_mode_night', fallback: 'Night Mode'),
      if (detail.summary.modeCompatibility.focusMode)
        AppText.get(context, key: 'session_mode_focus', fallback: 'Focus Mode'),
      if (detail.summary.modeCompatibility.painReliefMode)
        AppText.get(
          context,
          key: 'session_mode_pain_relief',
          fallback: 'Pain Relief Mode',
        ),
    ];

    final environmentChips = <String>[
      if (detail.summary.environmentCompatibility.deskFriendly)
        AppText.get(
          context,
          key: 'session_env_desk_friendly',
          fallback: 'Desk-friendly',
        ),
      if (detail.summary.environmentCompatibility.officeFriendly)
        AppText.get(
          context,
          key: 'session_env_office_friendly',
          fallback: 'Office-friendly',
        ),
      if (detail.summary.environmentCompatibility.homeFriendly)
        AppText.get(
          context,
          key: 'session_env_home_friendly',
          fallback: 'Home-friendly',
        ),
      if (detail.summary.environmentCompatibility.noMatRequired)
        AppText.get(
          context,
          key: 'session_env_no_mat',
          fallback: 'No mat required',
        ),
      if (detail.summary.environmentCompatibility.lowSpaceFriendly)
        AppText.get(
          context,
          key: 'session_env_low_space',
          fallback: 'Low-space friendly',
        ),
      if (detail.summary.environmentCompatibility.quietFriendly)
        AppText.get(
          context,
          key: 'session_env_quiet',
          fallback: 'Quiet-friendly',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SessionDetailHeroCard(
          title: AppText.get(
            context,
            key: detail.summary.titleKey,
            fallback: detail.summary.titleFallback,
          ),
          subtitle: AppText.get(
            context,
            key: detail.summary.subtitleKey,
            fallback: detail.summary.subtitleFallback,
          ),
          description: AppText.get(
            context,
            key: detail.longDescriptionKey,
            fallback: detail.longDescriptionFallback,
          ),
          durationMinutes: detail.summary.durationMinutes,
          isSilentFriendly: detail.summary.isSilentFriendly,
          isBeginnerFriendly: detail.summary.isBeginnerFriendly,
          metaTags: [
            _intensityLabel(context, detail.summary.intensity),
            ...detail.summary.tags.map(
              (tag) => AppText.get(
                context,
                key: tag.labelKey,
                fallback: tag.labelFallback,
              ),
            ),
          ],
        ),
        if (isLocked) ...[
          const SizedBox(height: 12),
          const PremiumLockBadge(),
        ],
        const SizedBox(height: 16),
        SessionDetailActionBar(
          isLocked: isLocked,
          startLabel: isLocked ? null : startLabel,
          onStartPressed: () {
            if (isLocked) {
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
                  final t = AppText.of(context);
                  final repository = ref.read(savedSessionsRepositoryProvider);

                  if (!isSignedIn) {
                    final redirect = Uri.encodeComponent(
                      '/app/sessions/detail/${detail.summary.id}',
                    );
                    if (!context.mounted) return;
                    context.push('/auth?mode=signin&redirect=$redirect');
                    return;
                  }

                  setState(() {
                    _isSaving = true;
                  });

                  try {
                    if (isSaved) {
                      await repository.unsaveSession(detail.summary.id);
                    } else {
                      await repository.saveSession(detail.summary.id);
                    }

                    ref.invalidate(savedSessionIdsProvider);

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
                },
          isSaved: isSaved,
          isSaving: _isSaving,
          requiresSignInHint: !isSignedIn,
        ),
        const SizedBox(height: 24),

        AdaptiveSectionTitle(
          titleKey: 'session_detail_about_title',
          titleFallback: 'About This Session',
          subtitleKey: 'session_detail_about_subtitle',
          subtitleFallback: 'Only the essentials.',
        ),
        const SizedBox(height: 12),

        SessionDetailInfoCard(
          title: AppText.of(context).get(
            'session_detail_why_title',
            fallback: 'Why It Helps',
          ),
          icon: Icons.auto_awesome_outlined,
          lines: [
            AppText.get(
              context,
              key: detail.whyItHelpsKey,
              fallback: detail.whyItHelpsFallback,
            ),
          ],
        ),

        if (detail.summary.painTargets.isNotEmpty ||
            detail.summary.goals.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SessionHighlightsCard(
            targets: detail.summary.painTargets
                .map(
                  (target) => AppText.get(
                    context,
                    key: target.labelKey,
                    fallback: target.labelFallback,
                  ),
                )
                .toList(growable: false),
            goals: detail.summary.goals
                .map((goal) => _goalLabel(context, goal))
                .toList(growable: false),
          ),
        ],

        if (modeChips.isNotEmpty ||
            environmentChips.isNotEmpty ||
            detail.equipment.isNotEmpty ||
            detail.preparationNotes.isNotEmpty ||
            detail.recommendedUseCases.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AdaptiveSectionTitle(
            titleKey: 'session_detail_quick_fit_title',
            titleFallback: 'Quick Fit',
          ),
          const SizedBox(height: 12),
          _CompactSessionFitCard(
            modeChips: modeChips,
            environmentChips: environmentChips,
            equipment: detail.equipment,
            preparationNotes: detail.preparationNotes,
            recommendedUseCases: detail.recommendedUseCases,
          ),
        ],

        if (detail.cautions.isNotEmpty ||
            detail.contraindications.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AdaptiveSectionTitle(
            titleKey: 'session_detail_safety_title',
            titleFallback: 'Safety Notes',
          ),
          const SizedBox(height: 12),
          if (detail.cautions.isNotEmpty)
            SessionDetailWarningCard(
              title: AppText.of(context).get(
                'session_detail_warning_title',
                fallback: 'Use Caution If',
              ),
              icon: Icons.warning_amber_rounded,
              lines: detail.cautions
                  .map(
                    (item) => AppText.get(
                      context,
                      key: item.messageKey,
                      fallback: item.messageFallback,
                    ),
                  )
                  .toList(growable: false),
            ),
          if (detail.cautions.isNotEmpty &&
              detail.contraindications.isNotEmpty)
            const SizedBox(height: 12),
          if (detail.contraindications.isNotEmpty)
            SessionDetailWarningCard(
              title: AppText.of(context).get(
                'session_detail_avoid_title',
                fallback: 'Avoid Or Stop If',
              ),
              icon: Icons.gpp_bad_outlined,
              lines: detail.contraindications
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
}

class _SessionHighlightsCard extends StatelessWidget {
  const _SessionHighlightsCard({
    required this.targets,
    required this.goals,
  });

  final List<String> targets;
  final List<String> goals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (targets.isNotEmpty)
              _ChipGroupBlock(
                icon: Icons.my_location_outlined,
                title: AppText.get(
                  context,
                  key: 'session_detail_targets_title',
                  fallback: 'Targets',
                ),
                chips: targets,
              ),
            if (targets.isNotEmpty && goals.isNotEmpty)
              const SizedBox(height: 14),
            if (goals.isNotEmpty)
              _ChipGroupBlock(
                icon: Icons.flag_outlined,
                title: AppText.get(
                  context,
                  key: 'session_detail_goals_title',
                  fallback: 'Goals',
                ),
                chips: goals,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactSessionFitCard extends StatelessWidget {
  const _CompactSessionFitCard({
    required this.modeChips,
    required this.environmentChips,
    required this.equipment,
    required this.preparationNotes,
    required this.recommendedUseCases,
  });

  final List<String> modeChips;
  final List<String> environmentChips;
  final List<String> equipment;
  final List<String> preparationNotes;
  final List<String> recommendedUseCases;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (modeChips.isNotEmpty)
              _ChipGroupBlock(
                icon: Icons.tune_outlined,
                title: AppText.get(
                  context,
                  key: 'session_detail_modes_title',
                  fallback: 'Works Well With',
                ),
                chips: modeChips,
              ),
            if (modeChips.isNotEmpty && environmentChips.isNotEmpty)
              const SizedBox(height: 14),
            if (environmentChips.isNotEmpty)
              _ChipGroupBlock(
                icon: Icons.home_work_outlined,
                title: AppText.get(
                  context,
                  key: 'session_detail_environment_title',
                  fallback: 'Best Environment',
                ),
                chips: environmentChips,
              ),
            if ((modeChips.isNotEmpty || environmentChips.isNotEmpty) &&
                (equipment.isNotEmpty ||
                    preparationNotes.isNotEmpty ||
                    recommendedUseCases.isNotEmpty))
              const SizedBox(height: 14),
            if (equipment.isNotEmpty ||
                preparationNotes.isNotEmpty ||
                recommendedUseCases.isNotEmpty)
              _MiniBulletInfoGrid(
                equipment: equipment,
                preparationNotes: preparationNotes,
                recommendedUseCases: recommendedUseCases,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipGroupBlock extends StatelessWidget {
  const _ChipGroupBlock({
    required this.icon,
    required this.title,
    required this.chips,
  });

  final IconData icon;
  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((item) => _InfoChip(label: item)).toList(),
        ),
      ],
    );
  }
}

class _MiniBulletInfoGrid extends StatelessWidget {
  const _MiniBulletInfoGrid({
    required this.equipment,
    required this.preparationNotes,
    required this.recommendedUseCases,
  });

  final List<String> equipment;
  final List<String> preparationNotes;
  final List<String> recommendedUseCases;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      if (equipment.isNotEmpty)
        _MiniInfoBlock(
          title: AppText.get(
            context,
            key: 'session_detail_equipment_title',
            fallback: 'Equipment',
          ),
          icon: Icons.fitness_center_outlined,
          items: equipment,
        ),
      if (preparationNotes.isNotEmpty)
        _MiniInfoBlock(
          title: AppText.get(
            context,
            key: 'session_detail_preparation_title',
            fallback: 'Preparation',
          ),
          icon: Icons.checklist_outlined,
          items: preparationNotes,
        ),
      if (recommendedUseCases.isNotEmpty)
        _MiniInfoBlock(
          title: AppText.get(
            context,
            key: 'session_detail_best_for_title',
            fallback: 'Best For',
          ),
          icon: Icons.person_outline,
          items: recommendedUseCases,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (!isWide) {
          return Column(
            children: [
              for (var i = 0; i < blocks.length; i++) ...[
                blocks[i],
                if (i != blocks.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < blocks.length; i++) ...[
              Expanded(child: blocks[i]),
              if (i != blocks.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _MiniInfoBlock extends StatelessWidget {
  const _MiniInfoBlock({
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
    final visibleItems = items.take(3).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surface.withValues(alpha: 0.55),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 36,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  t.get(
                    'session_detail_error_title',
                    fallback: 'Could not load session',
                  ),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  t.get(
                    'session_detail_error_subtitle',
                    fallback:
                        'Something went wrong while loading this session. Please try again.',
                  ),
                  style: theme.textTheme.bodyMedium,
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

String _intensityLabel(BuildContext context, SessionIntensity intensity) {
  final t = AppText.of(context);

  switch (intensity) {
    case SessionIntensity.gentle:
      return t.get('session_intensity_gentle', fallback: 'Gentle');
    case SessionIntensity.light:
      return t.get('session_intensity_light', fallback: 'Light');
    case SessionIntensity.moderate:
      return t.get('session_intensity_moderate', fallback: 'Moderate');
    case SessionIntensity.strong:
      return t.get('session_intensity_strong', fallback: 'Strong');
  }
}

String _goalLabel(BuildContext context, SessionGoal goal) {
  final t = AppText.of(context);

  switch (goal) {
    case SessionGoal.painRelief:
      return t.get('session_goal_pain_relief', fallback: 'Pain relief');
    case SessionGoal.postureReset:
      return t.get('session_goal_posture_reset', fallback: 'Posture reset');
    case SessionGoal.focusPrep:
      return t.get('session_goal_focus_prep', fallback: 'Focus prep');
    case SessionGoal.recovery:
      return t.get('session_goal_recovery', fallback: 'Recovery');
    case SessionGoal.mobility:
      return t.get('session_goal_mobility', fallback: 'Mobility');
    case SessionGoal.decompression:
      return t.get('session_goal_decompression', fallback: 'Decompression');
  }
}