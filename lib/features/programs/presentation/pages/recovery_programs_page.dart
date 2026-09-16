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
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(
          'recovery-program-detail',
          pathParameters: {'id': program.id},
        ),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 126,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? colors.surfaceContainerHigh.withValues(alpha: 0.62)
                : colors.surface,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.42),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.14 : 0.045,
                ),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                SizedBox(
                  width: 118,
                  height: double.infinity,
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
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      if (isLocked)
                        Positioned(
                          left: 9,
                          top: 9,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.34),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 13, 12, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  colors: _programGradient(program.id),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              t.get(
                                'program_card_label',
                                fallback: 'GUIDED PROGRAM',
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          t.get(
                            program.titleKey,
                            fallback: program.titleFallback,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Text(
                              t.get(
                                'program_card_open',
                                fallback: 'View program',
                              ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
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
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w900,
        height: 1.05,
      ),
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
            _Skeleton(height: 290),
            _Skeleton(height: 42),
            _Skeleton(height: 210),
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

String _difficultyLabel(BuildContext context, RecoveryProgramDifficulty difficulty) {
  final t = AppText.of(context);
  switch (difficulty) {
    case RecoveryProgramDifficulty.beginner:
      return t.get('program_difficulty_beginner', fallback: 'Beginner');
    case RecoveryProgramDifficulty.intermediate:
      return t.get('program_difficulty_intermediate', fallback: 'Intermediate');
    case RecoveryProgramDifficulty.advanced:
      return t.get('program_difficulty_advanced', fallback: 'Advanced');
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
