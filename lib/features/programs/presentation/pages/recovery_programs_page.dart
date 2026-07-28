import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../application/recovery_program_providers.dart';
import '../../domain/recovery_program_models.dart';

class RecoveryProgramsPage extends ConsumerWidget {
  const RecoveryProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final programsAsync = ref.watch(recoveryProgramSummariesProvider);
    final activeAsync = ref.watch(activeRecoveryProgramDashboardProgressProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('programs_title', fallback: 'Programs')),
      bodyBuilder: (context, pageInfo) {
        return programsAsync.when(
          loading: () => const _ProgramsLoadingView(),
          error: (error, stackTrace) => _ProgramsErrorView(
            onRetry: () {
              ref.invalidate(recoveryProgramSummariesProvider);
              ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
              ref.invalidate(accessSnapshotProvider);
            },
          ),
          data: (programs) {
            final active = activeAsync.maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );
            final access = accessAsync.maybeWhen(
              data: (value) => value,
              orElse: () => AccessSnapshot.guest,
            );

            final sorted = [...programs]
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            final activeSummary = active == null
                ? null
                : sorted.cast<RecoveryProgramSummary?>().firstWhere(
                      (program) => program?.id == active.programId,
                      orElse: () => null,
                    );

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(recoveryProgramSummariesProvider);
                ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
                ref.invalidate(accessSnapshotProvider);
                await Future.wait([
                  ref.read(recoveryProgramSummariesProvider.future),
                  ref.read(activeRecoveryProgramDashboardProgressProvider.future),
                ]);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: pageInfo.isCompact ? 120 : 48,
                ),
                children: [
                  ResponsiveContentSection(
                    spacing: 18,
                    children: [
                      _ProgramsIntroHeader(
                        count: sorted.length,
                        hasActiveProgram: active != null,
                      ),
                      if (active != null && activeSummary != null)
                        _ActiveJourneyCard(
                          program: activeSummary,
                          progress: active,
                        ),
                      _SectionHeader(
                        title: active == null
                            ? t.get(
                                'programs_browse_all_title',
                                fallback: 'Choose your recovery path',
                              )
                            : t.get(
                                'programs_more_journeys_title',
                                fallback: 'More programs',
                              ),
                        subtitle: t.get(
                          'programs_section_subtitle',
                          fallback:
                              'Structured plans designed for consistent progress.',
                        ),
                      ),
                      if (sorted.isEmpty)
                        _EmptyProgramsCard(
                          onRefresh: () {
                            ref.invalidate(recoveryProgramSummariesProvider);
                          },
                        )
                      else
                        _ProgramsGrid(
                          programs: sorted,
                          activeProgramId: active?.programId,
                          accessSnapshot: access,
                        ),
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

class _ProgramsIntroHeader extends StatelessWidget {
  const _ProgramsIntroHeader({
    required this.count,
    required this.hasActiveProgram,
  });

  final int count;
  final bool hasActiveProgram;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.78),
            colors.tertiaryContainer.withValues(alpha: 0.62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.88),
            ),
            child: Icon(Icons.route_rounded, color: colors.primary, size: 27),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveProgram
                      ? t.get(
                          'programs_header_active',
                          fallback: 'Keep your momentum',
                        )
                      : t.get(
                          'programs_header_new',
                          fallback: 'Build a healthier workday',
                        ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.get(
                    'programs_header_body',
                    fallback:
                        '$count guided programs with a clear daily structure.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJourneyCard extends StatelessWidget {
  const _ActiveJourneyCard({
    required this.program,
    required this.progress,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDashboardProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);
    final safeProgress = progress.progressFraction.clamp(0.0, 1.0);
    final percent = (safeProgress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(
          'recovery-program-detail',
          pathParameters: {'id': program.id},
        ),
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          height: 292,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: _programGradient(program.id),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RemoteProgramCoverImage(programId: program.id),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xE6000000),
                        Color(0x99000000),
                        Color(0x22000000),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _GlassBadge(
                            icon: Icons.play_circle_fill_rounded,
                            label: t.get(
                              'program_active_badge',
                              fallback: 'Active program',
                            ),
                          ),
                          const Spacer(),
                          _GlassBadge(
                            icon: Icons.local_fire_department_rounded,
                            label: '${progress.streakCount}',
                          ),
                        ],
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.get(
                                program.titleKey,
                                fallback: program.titleFallback,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Day ${progress.currentDay} of ${progress.durationDays} · $percent% complete',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _PremiumProgressBar(value: safeProgress),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_arrow_rounded,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        t.get(
                                          'dashboard_programs_continue_cta',
                                          fallback: 'Continue',
                                        ),
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _ProgramsGrid extends StatelessWidget {
  const _ProgramsGrid({
    required this.programs,
    required this.activeProgramId,
    required this.accessSnapshot,
  });

  final List<RecoveryProgramSummary> programs;
  final String? activeProgramId;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final visible = programs
        .where((program) => program.id != activeProgramId)
        .toList(growable: false);
    final items = visible.isEmpty ? programs : visible;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        const spacing = 14.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (program) => SizedBox(
                  width: itemWidth,
                  child: _ProgramCard(
                    program: program,
                    isLocked: program.accessTier == AccessTier.coreAccess &&
                        !accessSnapshot.hasCoreAccess,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.isLocked,
  });

  final RecoveryProgramSummary program;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(
          'recovery-program-detail',
          pathParameters: {'id': program.id},
        ),
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.48),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.20 : 0.06,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _programGradient(program.id),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      _RemoteProgramCoverImage(programId: program.id),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0xB8000000)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _GlassBadge(
                          icon: isLocked
                              ? Icons.workspace_premium_rounded
                              : Icons.route_rounded,
                          label: isLocked
                              ? t.get('program_premium_badge', fallback: 'Premium')
                              : '${program.durationDays} days',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(program.titleKey, fallback: program.titleFallback),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      t.get(
                        program.subtitleKey,
                        fallback: program.subtitleFallback.isNotEmpty
                            ? program.subtitleFallback
                            : program.programGoalFallback,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          label: '${program.estimatedMinutesPerDay} min/day',
                        ),
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: _difficultyLabel(program.difficulty),
                        ),
                        const Spacer(),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.primary,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumProgressBar extends StatelessWidget {
  const _PremiumProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * value.clamp(0.0, 1.0);
        return Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFBFE8FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.36),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgramsLoadingView extends StatelessWidget {
  const _ProgramsLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      children: const [
        ResponsiveContentSection(
          spacing: 16,
          children: [
            _Skeleton(height: 110),
            _Skeleton(height: 290),
            _Skeleton(height: 80),
            _Skeleton(height: 310),
          ],
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

class _ProgramsErrorView extends StatelessWidget {
  const _ProgramsErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 120),
      children: [
        ResponsiveContentSection(
          children: [
            _StateCard(
              icon: Icons.cloud_off_rounded,
              title: t.get(
                'programs_error_title',
                fallback: 'Programs are temporarily unavailable',
              ),
              body: t.get(
                'programs_error_body',
                fallback: 'Check your connection and try again.',
              ),
              actionLabel: t.get('common_retry', fallback: 'Try again'),
              onAction: onRetry,
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyProgramsCard extends StatelessWidget {
  const _EmptyProgramsCard({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return _StateCard(
      icon: Icons.explore_outlined,
      title: t.get(
        'programs_empty_title',
        fallback: 'No programs available yet',
      ),
      body: t.get(
        'programs_empty_body',
        fallback: 'Pull down or refresh to check again.',
      ),
      actionLabel: t.get('common_refresh', fallback: 'Refresh'),
      onAction: onRefresh,
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 15),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _RemoteProgramCoverImage extends StatelessWidget {
  const _RemoteProgramCoverImage({required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://weglabs.com/data/desk-workout/covers/programs/$programId.webp',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : const SizedBox.shrink();
      },
    );
  }
}

String _difficultyLabel(RecoveryProgramDifficulty difficulty) {
  switch (difficulty) {
    case RecoveryProgramDifficulty.beginner:
      return 'Beginner';
    case RecoveryProgramDifficulty.intermediate:
      return 'Intermediate';
    case RecoveryProgramDifficulty.advanced:
      return 'Advanced';
  }
}

List<Color> _programGradient(String programId) {
  switch (programId) {
    case 'prog_neck_shoulder_therapy_14':
      return const [Color(0xFF0E7490), Color(0xFF1D4ED8)];
    case 'prog_wrist_forearm_mouse_10':
      return const [Color(0xFF0F766E), Color(0xFF0F172A)];
    case 'prog_lower_back_hip_stability_14':
      return const [Color(0xFF7C3AED), Color(0xFF1E1B4B)];
    case 'prog_full_desk_worker_21':
      return const [Color(0xFF0284C7), Color(0xFF0F172A)];
    case 'prog_office_toolkit_14':
      return const [Color(0xFF334155), Color(0xFF0F766E)];
    default:
      return const [Color(0xFF2563EB), Color(0xFF0F172A)];
  }
}
