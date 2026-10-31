// lib/features/programs/presentation/pages/recovery_program_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/recovery_program_providers.dart';
import '../../domain/recovery_program_models.dart';

class RecoveryProgramDetailPage extends ConsumerWidget {
  const RecoveryProgramDetailPage({
    super.key,
    required this.programId,
  });

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;
      ref.invalidate(recoveryProgramDetailProvider(programId));
      ref.invalidate(recoveryProgramProgressProvider(programId));
      ref.invalidate(recoveryProgramDayProgressMapProvider(programId));
      ref.invalidate(accessSnapshotProvider);
    });

    final detailAsync = ref.watch(recoveryProgramDetailProvider(programId));
    final progressAsync = ref.watch(recoveryProgramProgressProvider(programId));
    final dayProgressAsync =
        ref.watch(recoveryProgramDayProgressMapProvider(programId));
    final actionState = ref.watch(recoveryProgramActionControllerProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);
    final activeProgramAsync =
        ref.watch(activeRecoveryProgramDashboardProgressProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('program_detail_title', fallback: 'Program')),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        return detailAsync.when(
          loading: () => ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 132 : 48),
            children: const [
              ResponsiveContentSection(
                spacing: 12,
                children: [
                  _ProgramHeroSkeleton(),
                  _ProgramDaySkeleton(),
                  _ProgramDaySkeleton(),
                  _ProgramDaySkeleton(),
                ],
              ),
            ],
          ),
          error: (error, _) => ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 132 : 48),
            children: [
              ResponsiveContentSection(
                spacing: 12,
                children: [
                  _ProgramLoadErrorCard(
                    error: error.toString(),
                    onRetry: () => ref.invalidate(
                      recoveryProgramDetailProvider(programId),
                    ),
                  ),
                ],
              ),
            ],
          ),
          data: (detail) {
            if (detail == null) {
              return ListView(
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 132 : 48),
                children: const [
                  ResponsiveContentSection(
                    spacing: 12,
                    children: [_ProgramNotFoundCard()],
                  ),
                ],
              );
            }

            final progress = progressAsync.maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );
            final dayProgress = dayProgressAsync.maybeWhen(
              data: (value) => value,
              orElse: () => const <int, RecoveryProgramDayProgress>{},
            );
            final activeProgram = activeProgramAsync.maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(recoveryProgramDetailProvider(programId));
                ref.invalidate(recoveryProgramProgressProvider(programId));
                ref.invalidate(recoveryProgramDayProgressMapProvider(programId));

                await ref.read(recoveryProgramDetailProvider(programId).future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 132 : 48),
                children: [
                  ResponsiveContentSection(
                    spacing: 12,
                    children: [
                      if (progressAsync.hasError || dayProgressAsync.hasError)
                        _ProgramSyncWarningCard(
                          onRetry: () {
                            ref.invalidate(recoveryProgramProgressProvider(programId));
                            ref.invalidate(
                              recoveryProgramDayProgressMapProvider(programId),
                            );
                            ref.invalidate(
                              activeRecoveryProgramDashboardProgressProvider,
                            );
                          },
                        ),
                      _ProgramDetailContent(
                        detail: detail,
                        progress: progress,
                        dayProgress: dayProgress,
                        accessSnapshot: accessSnapshot,
                        actionState: actionState,
                        activeProgram: activeProgram,
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



class _ProgramDetailContent extends StatelessWidget {
  const _ProgramDetailContent({
    required this.detail,
    required this.progress,
    required this.dayProgress,
    required this.accessSnapshot,
    required this.actionState,
    required this.activeProgram,
  });

  final RecoveryProgramDetail detail;
  final RecoveryProgramProgress? progress;
  final Map<int, RecoveryProgramDayProgress> dayProgress;
  final AccessSnapshot accessSnapshot;
  final AsyncValue<void> actionState;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoPane = constraints.maxWidth >= 920;

        final hero = _ProgramHero(
          detail: detail,
          progress: progress,
          accessSnapshot: accessSnapshot,
          actionState: actionState,
          activeProgram: activeProgram,
        );

        final days = _ProgramDaysSection(
          detail: detail,
          progress: progress,
          dayProgress: dayProgress,
          actionState: actionState,
          accessSnapshot: accessSnapshot,
        );

        if (!useTwoPane) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hero,
              const SizedBox(height: 12),
              days,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 9, child: hero),
            const SizedBox(width: 16),
            Expanded(flex: 11, child: days),
          ],
        );
      },
    );
  }
}

class _ProgramHero extends ConsumerWidget {
  const _ProgramHero({
    required this.detail,
    required this.progress,
    required this.accessSnapshot,
    required this.actionState,
    required this.activeProgram,
  });

  final RecoveryProgramDetail detail;
  final RecoveryProgramProgress? progress;
  final AccessSnapshot accessSnapshot;
  final AsyncValue<void> actionState;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final viewModel = _HeroViewModel.from(
      detail: detail,
      progress: progress,
      accessSnapshot: accessSnapshot,
      actionBusy: actionState.isLoading,
      t: t,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroImage(
          viewModel: viewModel,
          onPrimaryPressed: null,
        ),
        const SizedBox(height: 10),
        _HeroCTA(
          busy: viewModel.actionBusy,
          completed: viewModel.completed,
          currentDay: viewModel.currentDay,
          onPressed: viewModel.actionBusy || viewModel.completed
              ? null
              : () => _handleHeroPrimaryTap(
                    context: context,
                    ref: ref,
                    detail: detail,
                    accessSnapshot: accessSnapshot,
                    viewModel: viewModel,
                    activeProgram: activeProgram,
                  ),
        ),
      ],
    );
  }
}

Future<void> _handleHeroPrimaryTap({
  required BuildContext context,
  required WidgetRef ref,
  required RecoveryProgramDetail detail,
  required AccessSnapshot accessSnapshot,
  required _HeroViewModel viewModel,
  required RecoveryProgramDashboardProgress? activeProgram,
}) async {
  if (viewModel.completed) return;

  if (!viewModel.started) {
    final shouldBegin = await _showStartJourneyDialog(
      context: context,
      program: viewModel.program,
      activeProgram: activeProgram,
    );
    if (!shouldBegin || !context.mounted) return;

    final success = await ref
        .read(recoveryProgramActionControllerProvider.notifier)
        .startProgram(viewModel.program.id);
    if (!success || !context.mounted) return;
  }

  final targetDay = detail.days.firstWhere(
    (day) => day.dayNumber == viewModel.currentDay,
    orElse: () => detail.days.first,
  );

  final locked = targetDay.isLockedFor(
    accessSnapshot: accessSnapshot,
    programAccessTier: viewModel.program.accessTier,
  );

  if (locked) {
    if (context.mounted) context.push('/app/profile/premium');
    return;
  }

  final shouldStart = await _showMissionBriefingSheet(
    context: context,
    day: targetDay,
  );
  if (!shouldStart || !context.mounted) return;

  final success = await ref
      .read(recoveryProgramActionControllerProvider.notifier)
      .startProgramDay(
        programId: viewModel.program.id,
        dayNumber: targetDay.dayNumber,
      );

  if (!success || !context.mounted) return;

  context.pushNamed(
    'session-player',
    pathParameters: {'id': targetDay.sessionId},
    queryParameters: const {'source': 'dashboard'},
  );
}



Future<bool> _showStartJourneyDialog({
  required BuildContext context,
  required RecoveryProgramSummary program,
  required RecoveryProgramDashboardProgress? activeProgram,
}) async {
  final t = AppText.of(context);
  final isSwitching = activeProgram != null &&
      activeProgram.programId != program.id &&
      !activeProgram.isCompleted;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        icon: Icon(
          isSwitching ? Icons.swap_horiz_rounded : Icons.route_rounded,
          color: colors.primary,
        ),
        title: Text(
          isSwitching
              ? t.get('program_switch_title', fallback: 'Switch journey?')
              : t.get('program_start_title', fallback: 'Start this journey?'),
        ),
        content: Text(
          isSwitching
              ? t.get(
                  'program_switch_body',
                  fallback:
                      'Your progress in the current journey will stay saved. This journey will become your active path.',
                )
              : t.get(
                  'program_start_body',
                  fallback:
                      'Your first mission will unlock now. Progress is saved after every completed mission.',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.get('common_cancel', fallback: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              isSwitching
                  ? t.get('program_switch_cta', fallback: 'Switch journey')
                  : t.get('program_begin_cta', fallback: 'Begin journey'),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<bool> _showMissionBriefingSheet({
  required BuildContext context,
  required RecoveryProgramDay day,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _MissionBriefingSheet(day: day),
  );
  return result ?? false;
}

class _MissionBriefingSheet extends StatelessWidget {
  const _MissionBriefingSheet({required this.day});

  final RecoveryProgramDay day;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 720;
    final title = t.get(day.titleKey, fallback: day.titleFallback);
    final sessionTitle = day.session == null
        ? ''
        : t.get(day.session!.titleKey, fallback: day.session!.titleFallback);
    final objective = (day.objective ?? '').trim();
    final whyToday = (day.whyToday ?? '').trim();
    final expected = (day.expectedResult ?? '').trim();
    final therapistNote = (day.therapistNote ?? '').trim();
    final minutes = day.session?.durationMinutes ?? 0;

    Widget infoCard({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final body = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isWide ? 28 : 20,
          14,
          isWide ? 28 : 20,
          18 + media.viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    day.isAssessmentDay
                        ? Icons.radar_rounded
                        : day.isRecoveryDay
                            ? Icons.self_improvement_rounded
                            : Icons.flag_rounded,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.phaseTitle} • ${AppText.of(context).get('program_mission_label', fallback: 'Mission')} ${day.dayNumber}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (sessionTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                sessionTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MissionBriefChip(
                  icon: Icons.schedule_rounded,
                  label: minutes > 0
                      ? '$minutes ${AppText.of(context).get('common_min', fallback: 'min')}'
                      : AppText.of(context).get('program_short_session', fallback: 'Short session'),
                ),
                _MissionBriefChip(
                  icon: Icons.bolt_rounded,
                  label: '${AppText.of(context).get('program_load_label', fallback: 'Load')} ${day.loadLevel}/5',
                ),
                if (day.isAssessmentDay)
                  _MissionBriefChip(
                    icon: Icons.analytics_outlined,
                    label: AppText.of(context).get('program_assessment_label', fallback: 'Assessment'),
                  ),
                if (day.isRecoveryDay)
                  _MissionBriefChip(
                    icon: Icons.spa_outlined,
                    label: AppText.of(context).get('program_recovery_label', fallback: 'Recovery'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (objective.isNotEmpty)
              infoCard(
                icon: Icons.track_changes_rounded,
                label: AppText.of(context).get('program_today_target', fallback: 'Today’s target'),
                value: objective,
              ),
            if (whyToday.isNotEmpty) ...[
              const SizedBox(height: 10),
              infoCard(
                icon: Icons.lightbulb_outline_rounded,
                label: AppText.of(context).get('program_why_mission', fallback: 'Why this mission'),
                value: whyToday,
              ),
            ],
            if (expected.isNotEmpty) ...[
              const SizedBox(height: 10),
              infoCard(
                icon: Icons.auto_graph_rounded,
                label: AppText.of(context).get('program_notice_after', fallback: 'What to notice after'),
                value: expected,
              ),
            ],
            if (therapistNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                therapistNote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(AppText.of(context).get('program_start_mission', fallback: 'Start mission')),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Center(child: body),
      ),
    );
  }
}

class _MissionBriefChip extends StatelessWidget {
  const _MissionBriefChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroViewModel {
  const _HeroViewModel({
    required this.program,
    required this.today,
    required this.hasCoreAccess,
    required this.phaseCode,
    required this.phaseTitle,
    required this.objective,
    required this.expected,
    required this.started,
    required this.completed,
    required this.currentDay,
    required this.completedCount,
    required this.totalCount,
    required this.actionBusy,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDay today;
  final bool hasCoreAccess;
  final String phaseCode;
  final String phaseTitle;
  final String objective;
  final String expected;
  final bool started;
  final bool completed;
  final int currentDay;
  final int completedCount;
  final int totalCount;
  final bool actionBusy;

  static _HeroViewModel from({
    required RecoveryProgramDetail detail,
    required RecoveryProgramProgress? progress,
    required AccessSnapshot accessSnapshot,
    required bool actionBusy,
    required AppTextReader t,
  }) {
    final program = detail.summary;
    final subtitle = t.get(
      program.subtitleKey,
      fallback: program.subtitleFallback,
    );
    final currentDay = progress?.currentDay ?? 1;
    final today = detail.days.firstWhere(
      (day) => day.dayNumber == currentDay,
      orElse: () => detail.days.first,
    );
    final programTitle = t.get(
      program.titleKey,
      fallback: program.titleFallback,
    );
    final programGoal = t.get(
      program.programGoalKey,
      fallback: program.programGoalFallback,
    );
    final shortDescription = t.get(
      program.shortDescriptionKey,
      fallback: program.shortDescriptionFallback,
    );

    return _HeroViewModel(
      program: program,
      today: today,
      hasCoreAccess: accessSnapshot.hasCoreAccess,
      phaseCode: 'THERAPY JOURNEY',
      phaseTitle: programTitle,
      objective: programGoal.trim().isNotEmpty ? programGoal : subtitle,
      expected: shortDescription,
      started: progress != null,
      completed: progress?.isCompleted ?? false,
      currentDay: currentDay,
      completedCount: progress?.completedDayCount ?? 0,
      totalCount: program.durationDays,
      actionBusy: actionBusy,
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.viewModel,
    required this.onPrimaryPressed,
  });

  final _HeroViewModel viewModel;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final heroHeight = shortestSide < 380 ? 224.0 : 238.0;

    return Container(
      height: heroHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: _programGradient(viewModel.program.id),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _RemoteProgramCoverImage(
            programId: viewModel.program.id,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            fallbackBuilder: (_) => const SizedBox.shrink(),
          ),
          const _HeroImageScrim(),
          _HeroOverlay(
            viewModel: viewModel,
            onPrimaryPressed: onPrimaryPressed,
          ),
        ],
      ),
    );
  }
}

class _HeroImageScrim extends StatelessWidget {
  const _HeroImageScrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
    );
  }
}

class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay({
    required this.viewModel,
    required this.onPrimaryPressed,
  });

  final _HeroViewModel viewModel;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroTopRow(
            program: viewModel.program,
            hasCoreAccess: viewModel.hasCoreAccess,
          ),
          const Spacer(),
          _HeroTodaySummary(
            phaseCode: viewModel.phaseCode,
            phaseTitle: viewModel.phaseTitle,
          ),
          _HeroProgress(
            currentDay: viewModel.currentDay,
            completedCount: viewModel.completedCount,
            totalCount: viewModel.totalCount,
          ),
        ],
      ),
    );
  }
}

class _HeroTodaySummary extends StatelessWidget {
  const _HeroTodaySummary({
    required this.phaseCode,
    required this.phaseTitle,
  });

  final String phaseCode;
  final String phaseTitle;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          phaseCode.isEmpty
              ? t.get('program_phase_recovery', fallback: 'Recovery')
              : phaseCode.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phaseTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress({
    required this.currentDay,
    required this.completedCount,
    required this.totalCount,
  });

  final int currentDay;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final textTheme = Theme.of(context).textTheme;
    final safeTotal = totalCount <= 0 ? 1 : totalCount;
    final progress = (completedCount / safeTotal).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t
                    .get(
                      'program_day_of_total_label',
                      fallback: 'Mission {day} of {total}',
                    )
                    .replaceAll('{day}', currentDay.toString())
                    .replaceAll('{total}', totalCount.toString()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.86),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LayoutBuilder(
          builder: (context, constraints) {
            final fillWidth = constraints.maxWidth * progress;
            return SizedBox(
              height: 12,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFB9C7FF)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB9C7FF).withValues(alpha: .55),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    left: (fillWidth - 6).clamp(0.0, constraints.maxWidth - 12),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB9C7FF),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .22),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HeroCTA extends StatelessWidget {
  const _HeroCTA({
    required this.busy,
    required this.completed,
    required this.currentDay,
    required this.onPressed,
  });

  final bool busy;
  final bool completed;
  final int currentDay;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final title = completed
        ? t.get('program_completed_label', fallback: 'Completed')
        : t.get('program_continue_recovery_cta', fallback: 'Continue Recovery');
    final subtitle = t
        .get('program_cta_day_label', fallback: 'Mission {day}')
        .replaceAll('{day}', currentDay.toString());

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurfaceVariant,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: colors.onPrimary,
                ),
              )
            else
              Icon(completed ? Icons.check_rounded : Icons.play_arrow_rounded),
            const SizedBox(width: 11),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




class _HeroTopRow extends StatelessWidget {
  const _HeroTopRow({
    required this.program,
    required this.hasCoreAccess,
  });

  final RecoveryProgramSummary program;
  final bool hasCoreAccess;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: const Icon(Icons.route_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            t.get('program_path_label', fallback: 'Recovery program'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        _AccessBadge(
          hasCoreAccess: hasCoreAccess,
          freeDayCount: program.freeDayCount,
        ),
      ],
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({
    required this.hasCoreAccess,
    required this.freeDayCount,
  });

  final bool hasCoreAccess;
  final int freeDayCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        hasCoreAccess
            ? t.get('program_unlocked_label', fallback: 'Unlocked')
            : t
                .get(
                  'program_free_preview_count',
                  fallback: '{count} free preview missions',
                )
                .replaceAll('{count}', freeDayCount.toString()),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}



class _ProgramDaysSection extends StatelessWidget {
  const _ProgramDaysSection({
    required this.detail,
    required this.progress,
    required this.dayProgress,
    required this.actionState,
    required this.accessSnapshot,
  });

  final RecoveryProgramDetail detail;
  final RecoveryProgramProgress? progress;
  final Map<int, RecoveryProgramDayProgress> dayProgress;
  final AsyncValue<void> actionState;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final days = [...detail.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    final currentDay = progress?.currentDay ?? 1;
    final completed = days.where(
      (day) => dayProgress[day.dayNumber]?.isCompleted ?? false,
    ).length;

    if (days.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          t.get('program_no_days_title', fallback: 'No missions available yet.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.get('program_sessions_title', fallback: 'Your sessions'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Text(
                '$completed / ${days.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < days.length; i++)
          Padding(
            key: ValueKey('program-session-${days[i].dayNumber}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: _CompactProgramDayTile(
              day: days[i],
              currentDay: currentDay,
              dayProgress: dayProgress[days[i].dayNumber],
              actionState: actionState,
              accessSnapshot: accessSnapshot,
              programAccessTier: detail.summary.accessTier,
              isLast: i == days.length - 1,
            ),
          ),
      ],
    );
  }
}

Color _phaseAccent(String code, ColorScheme colors) {
  switch (code) {
    case 'calm':
      return const Color(0xFF6F7CFF);
    case 'release':
      return const Color(0xFF20A4A8);
    case 'activate':
      return const Color(0xFFF59E0B);
    case 'control':
      return const Color(0xFF8B5CF6);
    case 'stability':
      return const Color(0xFF16A34A);
    case 'integrate':
      return const Color(0xFFEA580C);
    case 'maintain':
      return const Color(0xFF0F766E);
    default:
      return colors.primary;
  }
}

IconData _phaseIcon(String code) {
  switch (code) {
    case 'calm':
      return Icons.self_improvement_rounded;
    case 'release':
      return Icons.air_rounded;
    case 'activate':
      return Icons.bolt_rounded;
    case 'control':
      return Icons.tune_rounded;
    case 'stability':
      return Icons.shield_outlined;
    case 'integrate':
      return Icons.hub_rounded;
    case 'maintain':
      return Icons.all_inclusive_rounded;
    default:
      return Icons.route_rounded;
  }
}



class _SafeAnimatedProgramDay extends StatefulWidget {
  const _SafeAnimatedProgramDay({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_SafeAnimatedProgramDay> createState() => _SafeAnimatedProgramDayState();
}

class _SafeAnimatedProgramDayState extends State<_SafeAnimatedProgramDay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 140 + (widget.index * 180)), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.18),
        duration: const Duration(milliseconds: 760),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _visible ? 1 : 0.96,
          duration: const Duration(milliseconds: 760),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}


Future<void> _showCompletedMissionSheet({
  required BuildContext context,
  required RecoveryProgramDay day,
}) async {
  final t = AppText.of(context);
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final title = t.get(day.titleKey, fallback: day.titleFallback);
  final completion = (day.completionMessage ?? '').trim();
  final next = (day.tomorrowPreview ?? '').trim();

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: .13),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.isPhaseEnd ? 'Milestone complete' : 'Mission complete',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (completion.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  completion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.42,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (day.isPhaseEnd) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: colors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${day.phaseTitle} completed',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (next.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Next',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  next,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(AppText.of(context).get('common_done', fallback: 'Done')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showLockedMissionSheet({
  required BuildContext context,
  required RecoveryProgramDay day,
  required int currentMission,
}) async {
  final t = AppText.of(context);
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final title = t.get(day.titleKey, fallback: day.titleFallback);
  final remaining = (day.dayNumber - currentMission).clamp(1, 999);

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_clock_rounded, color: colors.primary),
              ),
              const SizedBox(height: 14),
              Text(
                'Mission locked',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                remaining == 1
                    ? 'Complete the current mission to unlock this next step.'
                    : 'Complete the $remaining earlier missions to unlock this step.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(AppText.of(context).get('program_back_current_mission', fallback: 'Back to current mission')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CompactProgramDayTile extends ConsumerWidget {
  const _CompactProgramDayTile({
    required this.day,
    required this.currentDay,
    required this.dayProgress,
    required this.programAccessTier,
    required this.actionState,
    required this.accessSnapshot,
    required this.isLast,
  });

  final RecoveryProgramDay day;
  final int currentDay;
  final RecoveryProgramDayProgress? dayProgress;
  final AccessTier programAccessTier;
  final AsyncValue<void> actionState;
  final AccessSnapshot accessSnapshot;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accessLocked = day.isLockedFor(
      accessSnapshot: accessSnapshot,
      programAccessTier: programAccessTier,
    );
    final completed = dayProgress?.isCompleted ?? false;
    final skipped = dayProgress?.isSkipped ?? false;
    final busy = actionState.isLoading;
    final isCurrent = day.dayNumber == currentDay && !completed;
    final isFuture = day.dayNumber > currentDay;
    final title = t.get(day.titleKey, fallback: day.titleFallback);
    final sessionTitle = day.session == null
        ? t.get('program_day_missing_session', fallback: 'Missing session')
        : t.get(day.session!.titleKey, fallback: day.session!.titleFallback);
    final objective = (day.objective ?? '').trim();
    final accent = _phaseAccent(day.phaseCode.code, colors);
    final statusColor = completed
        ? const Color(0xFF16A34A)
        : skipped
            ? colors.tertiary
            : accessLocked || isFuture
                ? colors.onSurfaceVariant
                : accent;

    Future<void> handleTap() async {
      if (busy) return;

      if (completed) {
        await _showCompletedMissionSheet(
          context: context,
          day: day,
        );
        return;
      }

      if (accessLocked) {
        context.push('/app/profile/premium');
        return;
      }

      if (isFuture) {
        await _showLockedMissionSheet(
          context: context,
          day: day,
          currentMission: currentDay,
        );
        return;
      }

      if (!isCurrent || day.sessionId.trim().isEmpty) return;

      final shouldStart = await _showMissionBriefingSheet(
        context: context,
        day: day,
      );
      if (!shouldStart || !context.mounted) return;

      await ref
          .read(recoveryProgramActionControllerProvider.notifier)
          .startProgramDay(
            programId: day.programId,
            dayNumber: day.dayNumber,
          );
      if (!context.mounted) return;

      context.pushNamed(
        'session-player',
        pathParameters: {'id': day.sessionId},
        queryParameters: const {'source': 'dashboard'},
      );
    }

    final canTap = completed || accessLocked || isCurrent || isFuture;
    final compactMeta = <String>[
      if (day.isAssessmentDay) 'Assessment',
      if (day.isRecoveryDay) 'Recovery',
      if (day.isPhaseEnd) 'Milestone',
    ];

    return Padding(
      padding: EdgeInsets.only(top: 7, bottom: isLast ? 0 : 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: completed
              ? const Color(0xFF16A34A).withValues(
                  alpha: isDark ? .075 : .055,
                )
              : isCurrent
                  ? accent.withValues(alpha: isDark ? .11 : .065)
                  : Colors.transparent,
          border: Border.all(
            color: completed
                ? const Color(0xFF16A34A).withValues(alpha: .22)
                : isCurrent
                    ? accent.withValues(alpha: .34)
                    : colors.outlineVariant.withValues(alpha: .30),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? handleTap : null,
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                10,
                isCurrent ? 10 : 8,
                9,
                isCurrent ? 10 : 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? const Color(0xFF16A34A)
                          : isCurrent
                              ? accent
                              : colors.surfaceContainerHighest,
                      border: Border.all(
                        color: completed || isCurrent
                            ? Colors.transparent
                            : colors.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: completed
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 19,
                            )
                          : accessLocked || isFuture
                              ? Icon(
                                  Icons.lock_outline_rounded,
                                  color: colors.onSurfaceVariant,
                                  size: 16,
                                )
                              : Text(
                                  '${day.dayNumber}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isCurrent
                                        ? Colors.white
                                        : colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: completed
                                      ? colors.onSurfaceVariant
                                      : colors.onSurface,
                                  fontWeight: isCurrent
                                      ? FontWeight.w900
                                      : FontWeight.w800,
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      colors.onSurfaceVariant.withValues(alpha: .45),
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                margin: const EdgeInsets.only(left: 7),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'TODAY',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isCurrent && objective.isNotEmpty
                              ? objective
                              : sessionTitle,
                          maxLines: isCurrent ? 3 : 2,
                          overflow: TextOverflow.fade,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        if (isCurrent && compactMeta.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            children: [
                              for (final item in compactMeta)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: accent.withValues(alpha: .10),
                                  ),
                                  child: Text(
                                    item,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (busy && isCurrent)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      completed
                          ? Icons.verified_rounded
                          : accessLocked || isFuture
                              ? Icons.lock_rounded
                              : Icons.play_arrow_rounded,
                      color: statusColor,
                      size: isCurrent ? 24 : 20,
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





class _PhaseTransitionCard extends StatefulWidget {
  const _PhaseTransitionCard({
    required this.day,
  });

  final RecoveryProgramDay day;

  @override
  State<_PhaseTransitionCard> createState() => _PhaseTransitionCardState();
}

class _PhaseTransitionCardState extends State<_PhaseTransitionCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = animation.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _visible
          ? Container(
              key: ValueKey('phase-${widget.day.id}'),
              margin: const EdgeInsets.only(
                top: 20,
                bottom: 18,
              ),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.day.phaseCode.code.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.day.phaseTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if ((widget.day.objective ?? '').isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      widget.day.objective!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if ((widget.day.expectedResult ?? '').isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      t.get(
                        'program_expected_label',
                        fallback: 'Expected',
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.day.expectedResult!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('phase-hidden')),
    );
  }
}




class _ProgramLoadErrorCard extends StatelessWidget {
  const _ProgramLoadErrorCard({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 34, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              t.get(
                'program_detail_error_title',
                fallback: 'This journey could not load.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              t.get(
                'program_detail_error_body',
                fallback:
                    'Check your connection and try again. Your mission progress is safe.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.get('common_retry', fallback: 'Try again')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramSyncWarningCard extends StatelessWidget {
  const _ProgramSyncWarningCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.tertiary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: colors.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.get(
                'program_progress_sync_warning',
                fallback:
                    'Journey loaded, but progress could not sync. Some mission states may be outdated.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
            ),
          ),
          IconButton(
            tooltip: t.get('common_retry', fallback: 'Retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: colors.onTertiaryContainer,
          ),
        ],
      ),
    );
  }
}

class _ProgramNotFoundCard extends StatelessWidget {
  const _ProgramNotFoundCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.route_outlined, size: 34, color: colors.primary),
            const SizedBox(height: 10),
            Text(
              t.get(
                'program_not_found_title',
                fallback: 'This journey is no longer available.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              t.get(
                'program_not_found_body',
                fallback: 'Return to Programs and choose another therapy journey.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => context.go('/app/programs'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                t.get('programs_title', fallback: 'Programs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramHeroSkeleton extends StatelessWidget {
  const _ProgramHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBox(height: 260);
  }
}

class _ProgramDaySkeleton extends StatelessWidget {
  const _ProgramDaySkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBox(height: 92);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.48),
      ),
    );
  }
}

class ProgramPosterAsset {
  const ProgramPosterAsset._();

  static String pathForProgramId(String programId) {
    return 'assets/images/programs/$programId.png';
  }
}

List<Color> _programGradient(String programId) {
  switch (programId) {
    // Therapy V2 program ids.
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

    // Legacy ids kept as visual fallbacks for cached/local data.
    case 'prog_desk_neck_shoulder_reset_14':
      return const [Color(0xFF0891B2), Color(0xFF1D4ED8)];
    case 'prog_lower_back_hip_relief_14':
      return const [Color(0xFF6D28D9), Color(0xFF1E1B4B)];
    case 'prog_wrist_forearm_mouse_recovery_10':
      return const [Color(0xFF0F766E), Color(0xFF0F172A)];
    case 'prog_upper_back_posture_control_14':
      return const [Color(0xFF2563EB), Color(0xFF312E81)];
    case 'prog_full_desk_body_reset_21':
      return const [Color(0xFF0EA5E9), Color(0xFF0F172A)];
    default:
      return const [Color(0xFF2563EB), Color(0xFF0F172A)];
  }
}



const String _remoteProgramCoverBaseUrl =
    'https://weglabs.com/data/desk-workout/covers/programs';

String _remoteProgramCoverUrl(String programId) =>
    '$_remoteProgramCoverBaseUrl/$programId.webp';

class _RemoteProgramCoverImage extends StatelessWidget {
  const _RemoteProgramCoverImage({
    required this.programId,
    required this.fit,
    required this.alignment,
    required this.fallbackBuilder,
  });

  final String programId;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WidgetBuilder fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _remoteProgramCoverUrl(programId),
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallbackBuilder(context);
      },
      errorBuilder: (context, error, stackTrace) => fallbackBuilder(context),
    );
  }
}
