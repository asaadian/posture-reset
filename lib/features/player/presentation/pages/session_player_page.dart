// lib/features/player/presentation/pages/session_player_page.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../insights/application/insights_providers.dart';
import '../../../programs/application/recovery_program_providers.dart';
import '../../../programs/domain/recovery_program_models.dart';
import '../../../sessions/application/sessions_providers.dart';
import '../../../sessions/domain/session_models.dart';
import '../../application/player_providers.dart';
import '../../application/session_player_controller.dart';
import '../../application/session_player_state.dart';
import '../../domain/session_feedback_models.dart';
import '../widgets/player_control_panel.dart';
import '../widgets/player_feedback_sheet.dart';
import '../widgets/player_media_zone.dart';


class _MissionCompletionSheet extends StatelessWidget {
  const _MissionCompletionSheet({
    required this.completedMission,
    required this.nextMission,
    required this.completedCount,
    required this.totalCount,
    required this.streakCount,
    required this.journeyCompleted,
    required this.phaseCompleted,
  });

  final RecoveryProgramDay? completedMission;
  final RecoveryProgramDay? nextMission;
  final int completedCount;
  final int totalCount;
  final int streakCount;
  final bool journeyCompleted;
  final bool phaseCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final progress = totalCount <= 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);
    final completionMessage = (completedMission?.completionMessage ?? '').trim();
    final nextTitle = (nextMission?.titleFallback ?? '').trim();
    final tomorrowPreview = (completedMission?.tomorrowPreview ?? '').trim();
    final completedPhaseTitle = (completedMission?.phaseTitle ?? '').trim();
    final nextPhaseTitle = (nextMission?.phaseTitle ?? '').trim();
    final headline = journeyCompleted
        ? 'Journey complete'
        : phaseCompleted
            ? 'Phase complete'
            : 'Mission complete';

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                media.size.width >= 720 ? 30 : 20,
                24,
                media.size.width >= 720 ? 30 : 20,
                20 + media.viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.24),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      journeyCompleted
                          ? Icons.emoji_events_rounded
                          : phaseCompleted
                              ? Icons.workspace_premium_rounded
                              : Icons.check_rounded,
                      size: 40,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completionMessage.isNotEmpty
                        ? completionMessage
                        : journeyCompleted
                            ? 'You completed the full therapy journey.'
                            : phaseCompleted
                                ? completedPhaseTitle.isNotEmpty
                                    ? '$completedPhaseTitle is complete. Your next phase is now ready.'
                                    : 'This phase is complete. Your next phase is now ready.'
                                : 'This mission is now part of your completed path.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Journey progress',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$completedCount / $totalCount',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: colors.surfaceContainerHighest,
                          ),
                        ),
                        if (streakCount > 0) ...[
                          const SizedBox(height: 13),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 19,
                                color: colors.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$streakCount mission streak',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (phaseCompleted && !journeyCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.tertiaryContainer.withValues(alpha: 0.88),
                            colors.primaryContainer.withValues(alpha: 0.74),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colors.tertiary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: colors.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Milestone reached',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colors.onTertiaryContainer,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextPhaseTitle.isNotEmpty
                                      ? '$nextPhaseTitle unlocked'
                                      : 'The next phase is unlocked',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colors.onTertiaryContainer,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!journeyCompleted &&
                      (nextTitle.isNotEmpty || tomorrowPreview.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_open_rounded,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next mission unlocked',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextTitle.isNotEmpty
                                      ? nextTitle
                                      : tomorrowPreview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.route_rounded),
                      label: Text(
                        journeyCompleted ? 'View completed journey' : 'Back to journey',
                      ),
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
          ),
        ),
      ),
    );
  }
}

class SessionPlayerPage extends ConsumerStatefulWidget {
  const SessionPlayerPage({
    super.key,
    required this.sessionId,
    this.entrySource = SessionEntrySource.sessionDetail,
  });

  final String sessionId;
  final SessionEntrySource entrySource;

  @override
  ConsumerState<SessionPlayerPage> createState() => _SessionPlayerPageState();
}

class _SessionPlayerPageState extends ConsumerState<SessionPlayerPage> {
  String? _feedbackSheetShownForRunId;
  bool _preSessionSheetResolved = false;
  final _guideHeaderKey = GlobalKey();
  final _guideMediaKey = GlobalKey();
  final _guideTimerKey = GlobalKey();
  final _guideInstructionKey = GlobalKey();
  final _guideControlsKey = GlobalKey();

  SessionPlayerArgs get _playerArgs => SessionPlayerArgs(
        sessionId: widget.sessionId,
        entrySource: widget.entrySource,
      );

  Future<void> showPreSessionSheetIfNeeded(SessionPlayerState state) async {
    if (_preSessionSheetResolved) return;

    final shouldAutoStartWithoutPreSheet = mounted &&
        state.canRenderPlayer &&
        state.session != null &&
        state.runId == null &&
        !state.resumedRun;

    if (!shouldAutoStartWithoutPreSheet) {
      if (mounted) {
        setState(() => _preSessionSheetResolved = true);
      }
      return;
    }

    final controller = ref.read(sessionPlayerControllerProvider(_playerArgs));

    await controller.skipPreSessionCapture();

    if (!mounted) return;

    final refreshed =
        ref.read(sessionPlayerControllerProvider(_playerArgs)).state;

    if (refreshed.runId != null && !refreshed.isCompleted) {
      controller.resume();
    }

    if (!mounted) return;

    setState(() => _preSessionSheetResolved = true);
  }

  Future<void> _refreshDataAfterRun({String? programId}) async {
    // The dashboard may still be alive under the player route. Invalidating here
    // makes the next dashboard frame use fresh completion, streak, program,
    // weekly minutes, and recent-run data without requiring manual pull refresh.
    ref.invalidate(insightsSelectedRangeProvider);
    ref.invalidate(insightsSnapshotProvider);
    ref.invalidate(dashboardControllerProvider);
    ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
    ref.invalidate(recoveryProgramSummariesProvider);
    if (programId != null) {
      ref.invalidate(recoveryProgramDetailProvider(programId));
      ref.invalidate(recoveryProgramProgressProvider(programId));
      ref.invalidate(recoveryProgramDayProgressMapProvider(programId));
    }
    ref.invalidate(sessionSummariesProvider);
    ref.invalidate(savedSessionIdsProvider);

    await Future.wait<void>([
      _ignoreRefreshError(ref.read(dashboardControllerProvider.future)),
      _ignoreRefreshError(
        ref.read(activeRecoveryProgramDashboardProgressProvider.future),
      ),
      _ignoreRefreshError(ref.read(recoveryProgramSummariesProvider.future)),
      if (programId != null)
        _ignoreRefreshError(
          ref.read(recoveryProgramDetailProvider(programId).future),
        ),
      if (programId != null)
        _ignoreRefreshError(
          ref.read(recoveryProgramProgressProvider(programId).future),
        ),
      if (programId != null)
        _ignoreRefreshError(
          ref.read(recoveryProgramDayProgressMapProvider(programId).future),
        ),
      _ignoreRefreshError(ref.read(sessionSummariesProvider.future)),
      _ignoreRefreshError(ref.read(savedSessionIdsProvider.future)),
    ]);
  }

  Future<void> _ignoreRefreshError<T>(Future<T> future) async {
    try {
      await future;
    } catch (_) {
      // Keep navigation responsive even if one dashboard section fails to reload.
    }
  }

  List<String> _insightPainAreaCodesFor(SessionDetail session) {
    final codes = <String>[];

    void add(String raw) {
      final code = _canonicalInsightBodyCode(raw);
      if (code.isEmpty) return;
      if (!codes.contains(code)) codes.add(code);
    }

    for (final target in session.summary.painTargets) {
      add(target.code);
    }
    for (final step in session.steps) {
      for (final code in step.bodyTargetCodes) {
        add(code);
      }
    }
    for (final tag in session.summary.tags) {
      add(tag.code);
    }

    if (codes.isEmpty) codes.add('neck');
    return codes.take(3).toList(growable: false);
  }

  String _canonicalInsightBodyCode(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'neck':
      case 'cervical':
        return 'neck';
      case 'shoulder':
      case 'shoulders':
      case 'scapula':
      case 'scapular':
        return 'shoulders';
      case 'upper_back':
      case 'upper back':
      case 'thoracic':
      case 'chest':
        return 'upper_back';
      case 'back':
      case 'lower_back':
      case 'low_back':
      case 'lower back':
      case 'lumbar':
      case 'core':
        return 'lower_back';
      case 'hip':
      case 'hips':
      case 'glute':
      case 'glutes':
      case 'hips_glutes':
      case 'hamstring':
      case 'hamstrings':
        return 'hips_glutes';
      case 'forearm':
      case 'forearms':
      case 'mouse_arm':
        return 'forearms';
      case 'wrist':
      case 'wrists':
        return 'wrists';
      case 'hand':
      case 'hands':
      case 'finger':
      case 'fingers':
        return 'hands';
      case 'eye':
      case 'eyes':
        return 'eyes';
      default:
        return raw.trim().toLowerCase();
    }
  }

  Future<void> showPostSessionFeedbackSheetIfNeeded(
    SessionPlayerState state,
  ) async {
    if (!mounted ||
        !state.isCompleted ||
        state.runId == null ||
        state.session == null ||
        state.feedbackSubmitted) {
      return;
    }

    if (_feedbackSheetShownForRunId == state.runId) return;

    _feedbackSheetShownForRunId = state.runId;
    final controller = ref.read(sessionPlayerControllerProvider(_playerArgs));
    final programBeforeFeedback = await _matchingActiveProgramFor(state);

    final sessionTitle = AppText.get(
      context,
      key: state.session!.summary.titleKey,
      fallback: state.session!.summary.titleFallback,
    );

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return PlayerPostSessionFeedbackSheet(
          sessionTitle: sessionTitle,
          totalSteps: state.totalSteps,
          totalElapsedSeconds: state.totalElapsedSeconds,
          isAbandoned: false,
          initialEntrySource: widget.entrySource,
          initialPainAreaCodes: _insightPainAreaCodesFor(state.session!),
          onSubmit: controller.submitPostSessionResult,
        );
      },
    );

    if (!mounted) return;

    if (programBeforeFeedback != null) {
      await _ensureProgramMissionCompleted(
        progress: programBeforeFeedback,
        state: state,
      );
    }

    // The run is already completed before the feedback sheet appears.
    // Even when the user closes the sheet without saving feedback, dashboard
    // progress, recent activity, weekly minutes, and program state must refresh.
    await _refreshDataAfterRun(
      programId: programBeforeFeedback?.programId,
    );
    if (!mounted) return;

    if (programBeforeFeedback != null) {
      await _showMissionCompletionSheet(
        context: context,
        progressBeforeCompletion: programBeforeFeedback,
      );
      if (!mounted) return;

      context.goNamed(
        'recovery-program-detail',
        pathParameters: {'id': programBeforeFeedback.programId},
      );
      return;
    }

    context.goNamed('dashboard');
  }

  Future<RecoveryProgramDashboardProgress?> _matchingActiveProgramFor(
    SessionPlayerState state,
  ) async {
    if (widget.entrySource != SessionEntrySource.dashboard) return null;

    try {
      final progress = await ref.read(
        activeRecoveryProgramDashboardProgressProvider.future,
      );
      if (progress == null || progress.isCompleted) return null;
      if (!progress.hasCurrentSession) return null;
      if (progress.currentSessionId != state.session?.summary.id) return null;
      return progress;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureProgramMissionCompleted({
    required RecoveryProgramDashboardProgress progress,
    required SessionPlayerState state,
  }) async {
    try {
      final repository = ref.read(recoveryProgramsRepositoryProvider);
      final dayProgress = await repository.getProgramDayProgressMap(
        progress.programId,
      );
      if (dayProgress[progress.currentDay]?.isCompleted ?? false) return;

      final elapsedSeconds = state.totalElapsedSeconds > 0
          ? state.totalElapsedSeconds
          : state.totalSessionDurationSeconds;

      await repository.completeProgramDay(
        programId: progress.programId,
        dayNumber: progress.currentDay,
        sessionRunId: state.runId,
        minutesCompleted: (elapsedSeconds / 60).ceil().clamp(0, 1 << 30),
      );

      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(recoveryProgramDetailProvider(progress.programId));
      ref.invalidate(recoveryProgramProgressProvider(progress.programId));
      ref.invalidate(
        recoveryProgramDayProgressMapProvider(progress.programId),
      );
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
    } catch (error, stackTrace) {
      debugPrint('Mission completion fallback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _showMissionCompletionSheet({
    required BuildContext context,
    required RecoveryProgramDashboardProgress progressBeforeCompletion,
  }) async {
    RecoveryProgramDetail? detail;
    RecoveryProgramProgress? updatedProgress;

    try {
      detail = await ref.read(
        recoveryProgramDetailProvider(progressBeforeCompletion.programId).future,
      );
      updatedProgress = await ref.read(
        recoveryProgramProgressProvider(progressBeforeCompletion.programId).future,
      );
    } catch (_) {
      // Use a compact generic completion state if fresh journey data is unavailable.
    }

    if (!context.mounted) return;

    RecoveryProgramDay? completedMission;
    RecoveryProgramDay? nextMission;
    if (detail != null) {
      for (final day in detail.days) {
        if (day.dayNumber == progressBeforeCompletion.currentDay) {
          completedMission = day;
        }
        if (day.dayNumber == progressBeforeCompletion.currentDay + 1) {
          nextMission = day;
        }
      }
    }

    final completedCount = updatedProgress?.completedDayCount ??
        (progressBeforeCompletion.completedDayCount + 1);
    final totalCount = detail?.days.length ?? progressBeforeCompletion.durationDays;
    final journeyCompleted = updatedProgress?.isCompleted ??
        completedCount >= totalCount;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _MissionCompletionSheet(
        completedMission: completedMission,
        nextMission: nextMission,
        completedCount: completedCount,
        totalCount: totalCount,
        streakCount: updatedProgress?.streakCount ??
            progressBeforeCompletion.streakCount,
        journeyCompleted: journeyCompleted,
        phaseCompleted: completedMission?.isPhaseEnd == true,
      ),
    );
  }

  void safeBackToDetailOrSessions() {
    final targetDetail = '/app/sessions/detail/${widget.sessionId}';

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(targetDetail);
  }

  Future<bool> handleExit(
    SessionPlayerState state,
    SessionPlayerController controller,
  ) async {
    if (state.isLoading || state.isSavingExit) return false;

    if (state.isCompleted || state.runId == null) return true;

    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            final t = AppText.of(dialogContext);

            return AlertDialog(
              title: Text(t.get('player_exit_title', fallback: 'End session?')),
              content: Text(
                t.get(
                  'player_exit_message',
                  fallback:
                      'Your current session will be closed and progress will be saved as an incomplete run.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    t.get('player_exit_cancel_cta', fallback: 'Keep session'),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    t.get('player_exit_confirm_cta', fallback: 'End session'),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldExit) return false;

    await controller.abandonSession(exitReason: 'user_exit');
    if (!mounted) return true;

    final refreshed =
        ref.read(sessionPlayerControllerProvider(_playerArgs)).state;

    if (refreshed.runId != null &&
        refreshed.session != null &&
        !refreshed.feedbackSubmitted) {
      final sessionTitle = AppText.get(
        context,
        key: refreshed.session!.summary.titleKey,
        fallback: refreshed.session!.summary.titleFallback,
      );

      final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          return PlayerPostSessionFeedbackSheet(
            sessionTitle: sessionTitle,
            totalSteps: refreshed.completedStepsCount,
            totalElapsedSeconds: refreshed.totalElapsedSeconds,
            isAbandoned: true,
            initialEntrySource: widget.entrySource,
            initialPainAreaCodes: _insightPainAreaCodesFor(refreshed.session!),
            onSubmit: controller.submitPostSessionResult,
          );
        },
      );

      if (!mounted) return true;

      // The abandoned run has already been saved before this sheet opens.
      // Refresh dashboard-related providers even if the user closes the sheet
      // without submitting feedback.
      await _refreshDataAfterRun();
      if (!mounted) return saved != true;

      if (saved == true) {
        context.goNamed('dashboard');
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final controller = ref.watch(sessionPlayerControllerProvider(_playerArgs));
    final state = controller.state;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showPreSessionSheetIfNeeded(state);
      if (!mounted) return;
      await showPostSessionFeedbackSheetIfNeeded(state);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final canExit = await handleExit(state, controller);
        if (!mounted || !canExit) return;

        safeBackToDetailOrSessions();
      },
      child: ResponsivePageScaffold(
        title: Text(t.get('session_player_title', fallback: 'Player')),
        bodyBuilder: (context, pageInfo) {
          if (state.isLoading || state.isStartingRun) {
            return const _PlayerLoadingView();
          }

          if (state.authRequired) {
            return _PlayerAuthRequiredView(sessionId: widget.sessionId);
          }

          if (state.accessLocked) {
            return _PlayerErrorView(
              title: t.get(
                'player_access_locked_title',
                fallback: 'Core Access required',
              ),
              message: t.get(
                'player_access_locked_message',
                fallback:
                    'This session is part of Core Access. Unlock once to use the full recovery toolkit.',
              ),
              onPrimaryPressed: () => context.pushNamed('premium'),
              primaryLabel: t.get('access_unlock_core_cta', fallback: 'Unlock Core'),
            );
          }

          if (state.notFound) {
            return _PlayerErrorView(
              title: t.get('player_not_found_title', fallback: 'Session not found'),
              message: t.get(
                'player_not_found_message',
                fallback:
                    'The requested session could not be found or is no longer available.',
              ),
              onPrimaryPressed: safeBackToDetailOrSessions,
              primaryLabel: t.get('player_back_cta', fallback: 'Back'),
            );
          }

          if (state.hasNoSteps) {
            return _PlayerErrorView(
              title: t.get('player_no_steps_title', fallback: 'No steps available'),
              message: t.get(
                'player_no_steps_message',
                fallback: 'This session does not contain any playable steps yet.',
              ),
              onPrimaryPressed: safeBackToDetailOrSessions,
              primaryLabel: t.get('player_back_cta', fallback: 'Back'),
            );
          }

          if (state.errorMessage != null && !state.canRenderPlayer) {
            return _PlayerErrorView(
              title: t.get('player_error_title', fallback: 'Could not start player'),
              message: state.errorMessage!,
              onPrimaryPressed: controller.restart,
              primaryLabel: t.commonRetry,
            );
          }

          if (state.session == null || state.currentStep == null) {
            return _PlayerErrorView(
              title: t.get('player_error_title', fallback: 'Could not start player'),
              message: t.get(
                'player_error_subtitle',
                fallback: 'Something went wrong while loading this session.',
              ),
              onPrimaryPressed: controller.restart,
              primaryLabel: t.commonRetry,
            );
          }

          if (!_preSessionSheetResolved) {
            return const _PlayerLoadingView();
          }

          return _PlayerSpotlightOnboarding(
            storageKey: 'player_guide_spotlight_v1',
            steps: [
              _PlayerSpotlightStep(
                targetKey: _guideHeaderKey,
                icon: Icons.stacked_line_chart_rounded,
                title: t.get(
                  'guide_player_header_title',
                  fallback: 'Session progress',
                ),
                body: t.get(
                  'guide_player_header_body',
                  fallback:
                      'This top card shows the session title and your overall progress. Tap close only when you want to leave the session.',
                ),
              ),
              _PlayerSpotlightStep(
                targetKey: _guideMediaKey,
                icon: Icons.play_circle_outline_rounded,
                title: t.get(
                  'guide_player_video_title',
                  fallback: 'Movement demo',
                ),
                body: t.get(
                  'guide_player_video_body',
                  fallback:
                      'Follow the video for the safe movement shape. You can expand it or mute/unmute without leaving the player.',
                ),
              ),
              _PlayerSpotlightStep(
                targetKey: _guideTimerKey,
                icon: Icons.timer_outlined,
                title: t.get(
                  'guide_player_timer_title',
                  fallback: 'Main timer',
                ),
                body: t.get(
                  'guide_player_timer_body',
                  fallback:
                      'Use this large timer as the source of truth for the current step.',
                ),
              ),
              _PlayerSpotlightStep(
                targetKey: _guideInstructionKey,
                icon: Icons.notes_rounded,
                title: t.get(
                  'guide_player_instruction_title',
                  fallback: 'Instruction card',
                ),
                body: t.get(
                  'guide_player_instruction_body',
                  fallback:
                      'Read the short instruction here. Extra coaching, breathing, and safety notes stay compact inside this card.',
                ),
              ),
              _PlayerSpotlightStep(
                targetKey: _guideControlsKey,
                icon: Icons.touch_app_rounded,
                title: t.get(
                  'guide_player_controls_title',
                  fallback: 'Controls',
                ),
                body: t.get(
                  'guide_player_controls_body',
                  fallback:
                      'Control the session from here: previous, replay, pause, skip, next, or finish on the last step.',
                ),
              ),
            ],
            child: _FocusedPlayerShell(
              state: state,
              headerGuideKey: _guideHeaderKey,
              mediaGuideKey: _guideMediaKey,
              timerGuideKey: _guideTimerKey,
              instructionGuideKey: _guideInstructionKey,
              controlsGuideKey: _guideControlsKey,
              onClosePressed: () async {
                final canExit = await handleExit(state, controller);
                if (!mounted || !canExit) return;
                safeBackToDetailOrSessions();
              },
              onPauseResumePressed: controller.togglePause,
              onPreviousPressed: controller.previousStep,
              onNextPressed: controller.nextStep,
              onSkipPressed: controller.skipStep,
              onReplayPressed: controller.replayStep,
              onFinishPressed: controller.completeSession,
            ),
          );
        },
      ),
    );
  }
}

class _PlayerSpotlightStep {
  const _PlayerSpotlightStep({
    required this.targetKey,
    required this.icon,
    required this.title,
    required this.body,
  });

  final GlobalKey targetKey;
  final IconData icon;
  final String title;
  final String body;
}

class _PlayerSpotlightOnboarding extends StatefulWidget {
  const _PlayerSpotlightOnboarding({
    required this.storageKey,
    required this.steps,
    required this.child,
  });

  final String storageKey;
  final List<_PlayerSpotlightStep> steps;
  final Widget child;

  @override
  State<_PlayerSpotlightOnboarding> createState() =>
      _PlayerSpotlightOnboardingState();
}

class _PlayerSpotlightOnboardingState extends State<_PlayerSpotlightOnboarding> {
  bool _visible = false;
  bool _loaded = false;
  int _index = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  @override
  void didUpdateWidget(covariant _PlayerSpotlightOnboarding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTargetRect());
    }
  }

  Future<void> _loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(widget.storageKey) ?? false;
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _visible = !hasSeen && widget.steps.isNotEmpty;
    });
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTargetRect());
    }
  }

  void _refreshTargetRect() {
    if (!mounted || !_visible || widget.steps.isEmpty) return;

    final overlayBox = context.findRenderObject() as RenderBox?;
    final targetContext = widget.steps[_index].targetKey.currentContext;
    final targetBox = targetContext?.findRenderObject() as RenderBox?;

    if (overlayBox == null || targetBox == null || !targetBox.hasSize) return;

    final topLeft = targetBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final rawRect = topLeft & targetBox.size;
    final bounds = Offset.zero & overlayBox.size;
    final nextRect = rawRect.inflate(8).intersect(bounds);

    if (_targetRect == nextRect) return;
    setState(() => _targetRect = nextRect);
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.storageKey, true);
    if (!mounted) return;
    setState(() {
      _visible = false;
      _targetRect = null;
    });
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      unawaited(_complete());
      return;
    }

    setState(() {
      _index += 1;
      _targetRect = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTargetRect());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_loaded && _visible && widget.steps.isNotEmpty)
          Positioned.fill(
            child: _PlayerSpotlightOverlay(
              step: widget.steps[_index],
              stepIndex: _index,
              totalSteps: widget.steps.length,
              targetRect: _targetRect,
              onNext: _next,
              onSkip: _complete,
            ),
          ),
      ],
    );
  }
}

class _PlayerSpotlightOverlay extends StatelessWidget {
  const _PlayerSpotlightOverlay({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
  });

  final _PlayerSpotlightStep step;
  final int stepIndex;
  final int totalSteps;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);

    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rect = targetRect;
          final cardWidth = math.min(constraints.maxWidth - 28, 360.0);
          final cardHeightEstimate = 178.0;
          final safeRect = rect ?? Rect.fromLTWH(
            18,
            constraints.maxHeight * 0.22,
            constraints.maxWidth - 36,
            74,
          );
          final left = (safeRect.center.dx - (cardWidth / 2))
              .clamp(14.0, math.max(14.0, constraints.maxWidth - cardWidth - 14))
              .toDouble();
          var top = safeRect.bottom + 12;
          if (top + cardHeightEstimate > constraints.maxHeight - 12) {
            top = math.max(12.0, safeRect.top - cardHeightEstimate - 12);
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpotlightScrimPainter(
                    targetRect: rect,
                    radius: 26,
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: cardWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: colors.surface.withValues(alpha: 0.98),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: colors.primary.withValues(alpha: 0.12),
                              ),
                              child: Icon(step.icon, color: colors.primary, size: 19),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${stepIndex + 1}/$totalSteps',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          step.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: onSkip,
                              child: Text(
                                t.get('guide_skip_cta', fallback: 'Skip'),
                              ),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: onNext,
                              icon: Icon(
                                stepIndex >= totalSteps - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                stepIndex >= totalSteps - 1
                                    ? t.get('guide_done_cta', fallback: 'Done')
                                    : t.get('guide_next_cta', fallback: 'Next'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _SpotlightScrimPainter extends CustomPainter {
  const _SpotlightScrimPainter({
    required this.targetRect,
    required this.radius,
  });

  final Rect? targetRect;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final rect = targetRect;
    if (rect != null && !rect.isEmpty) {
      fullPath.addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      );
      fullPath.fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(
      fullPath,
      Paint()..color = Colors.black.withValues(alpha: 0.68),
    );

    if (rect == null || rect.isEmpty) return;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.34),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightScrimPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.radius != radius;
  }
}

class _FocusedPlayerShell extends StatelessWidget {
  const _FocusedPlayerShell({
    required this.state,
    required this.headerGuideKey,
    required this.mediaGuideKey,
    required this.timerGuideKey,
    required this.instructionGuideKey,
    required this.controlsGuideKey,
    required this.onClosePressed,
    required this.onPauseResumePressed,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.onSkipPressed,
    required this.onReplayPressed,
    required this.onFinishPressed,
  });

  final SessionPlayerState state;
  final GlobalKey headerGuideKey;
  final GlobalKey mediaGuideKey;
  final GlobalKey timerGuideKey;
  final GlobalKey instructionGuideKey;
  final GlobalKey controlsGuideKey;
  final VoidCallback onClosePressed;
  final VoidCallback onPauseResumePressed;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback onReplayPressed;
  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactContent = constraints.maxHeight < 860 || constraints.maxWidth < 430;
        final bodyTargets = state.currentStep?.bodyTargetCodes ?? const <String>[];
        final content = _FocusedPlayerContent(
          state: state,
          headerGuideKey: headerGuideKey,
          mediaGuideKey: mediaGuideKey,
          timerGuideKey: timerGuideKey,
          instructionGuideKey: instructionGuideKey,
          controlsGuideKey: controlsGuideKey,
          onClosePressed: onClosePressed,
          onPauseResumePressed: onPauseResumePressed,
          onPreviousPressed: onPreviousPressed,
          onNextPressed: onNextPressed,
          onSkipPressed: onSkipPressed,
          onReplayPressed: onReplayPressed,
          onFinishPressed: onFinishPressed,
          compactHeight: compactContent,
        );

        return _FocusModeBackdrop(
          bodyTargetCodes: bodyTargets,
          progress: state.progress,
          isPaused: state.isPaused,
          isCompleted: state.isCompleted,
          child: SizedBox(
            height: constraints.maxHeight,
            child: content,
          ),
        );
      },
    );
  }
}

class _FocusModeBackdrop extends StatelessWidget {
  const _FocusModeBackdrop({
    required this.bodyTargetCodes,
    required this.progress,
    required this.isPaused,
    required this.isCompleted,
    required this.child,
  });

  final List<String> bodyTargetCodes;
  final double progress;
  final bool isPaused;
  final bool isCompleted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.12, -0.46),
          radius: 1.20,
          colors: isDark
              ? [
                  accent.withValues(alpha: isPaused ? 0.13 : 0.20),
                  colors.tertiary.withValues(alpha: 0.08),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  accent.withValues(alpha: isPaused ? 0.08 : 0.14),
                  colors.tertiaryContainer.withValues(alpha: 0.12),
                  colors.surfaceContainerLowest.withValues(alpha: 0.98),
                ],
        ),
      ),
      child: child,
    );
  }
}

class _FocusedPlayerContent extends StatelessWidget {
  const _FocusedPlayerContent({
    required this.state,
    required this.headerGuideKey,
    required this.mediaGuideKey,
    required this.timerGuideKey,
    required this.instructionGuideKey,
    required this.controlsGuideKey,
    required this.onClosePressed,
    required this.onPauseResumePressed,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.onSkipPressed,
    required this.onReplayPressed,
    required this.onFinishPressed,
    required this.compactHeight,
  });

  final SessionPlayerState state;
  final GlobalKey headerGuideKey;
  final GlobalKey mediaGuideKey;
  final GlobalKey timerGuideKey;
  final GlobalKey instructionGuideKey;
  final GlobalKey controlsGuideKey;
  final VoidCallback onClosePressed;
  final VoidCallback onPauseResumePressed;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback onReplayPressed;
  final VoidCallback onFinishPressed;
  final bool compactHeight;

  @override
  Widget build(BuildContext context) {
    final step = state.currentStep!;
    final session = state.session!;
    final stepTitle = AppText.get(
      context,
      key: step.titleKey,
      fallback: step.titleFallback,
    );
    final instruction = AppText.get(
      context,
      key: step.instructionKey,
      fallback: step.instructionFallback,
    );
    final sessionTitle = AppText.get(
      context,
      key: session.summary.titleKey,
      fallback: session.summary.titleFallback,
    );
    final stepTypeLabel = _movementPatternLabel(
      context,
      step.effectiveMovementPattern,
    );

    final breathingText = _resolveOptionalText(
      context,
      key: step.breathingCueKey,
      fallback: step.breathingCueFallback,
    );

    final safetyText = _resolveOptionalText(
      context,
      key: step.safetyNoteKey,
      fallback: step.safetyNoteFallback,
    );

    final coachingText = _resolveOptionalText(
      context,
      key: step.coachingCueKey,
      fallback: step.coachingCueFallback,
    );

    final isAssessmentStep = _safeDynamicBool(
      step,
      (value) => value.isAssessmentStep,
    );
    final isRetestStep = _safeDynamicBool(
      step,
      (value) => value.isRetestStep,
    );
    final stepPurposeLabel = _safeDynamicString(
          step,
          (value) => value.stepPurposeLabel,
        ) ??
        _fallbackPurposeLabel(
          context,
          isAssessmentStep: isAssessmentStep,
          isRetestStep: isRetestStep,
          movementPattern: step.effectiveMovementPattern,
        );
    final stepGoal = _safeDynamicString(step, (value) => value.stepGoal);
    final whatToNotice = _safeDynamicString(step, (value) => value.whatToNotice);
    final avoidMistakes = _safeDynamicStringList(
      step,
      (value) => value.avoidMistakes,
    );
    final coachTip = _safeDynamicString(step, (value) => value.coachTip);
    final playerFocusNote = _safeDynamicString(
      step,
      (value) => value.playerFocusNote,
    );
    final stepProgress = step.durationSeconds <= 0
        ? 0.0
        : (state.currentStepElapsedSeconds / step.durationSeconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final constrainedMediaHeight = isLandscape
        ? (mediaQuery.size.width / (16 / 8.2)).clamp(260.0, 420.0).toDouble()
        : null;

    final gap = compactHeight ? 6.0 : 8.0;
    final controlGap = compactHeight ? 5.0 : 8.0;

    final headerWidget = KeyedSubtree(
      key: headerGuideKey,
      child: _FocusedTopBar(
        sessionTitle: sessionTitle,
        stepIndex: state.currentStepIndex,
        totalSteps: state.totalSteps,
        totalRemainingSeconds: state.remainingSessionSeconds,
        progress: state.progress,
        bodyTargetCodes: step.bodyTargetCodes,
        isCompleted: state.isCompleted,
        onClosePressed: onClosePressed,
      ),
    );

    final mediaWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: mediaGuideKey,
        child: constrainedMediaHeight == null
            ? PlayerMediaZone(
                key: ValueKey(step.id),
                stepTitle: stepTitle,
                stepTypeLabel: stepTypeLabel,
                bodyTargetCodes: step.bodyTargetCodes,
                visualType: step.visualType,
                mediaUrl: step.visualUrl,
                posterUrl: step.visualThumbnailUrl,
                exerciseDurationSeconds: step.durationSeconds,
                visualDurationSeconds: step.visualDurationSeconds,
                isPaused: state.isPaused,
                isCompleted: state.isCompleted,
                progress: state.progress,
              )
            : SizedBox(
                height: constrainedMediaHeight,
                child: PlayerMediaZone(
                  key: ValueKey(step.id),
                  stepTitle: stepTitle,
                  stepTypeLabel: stepTypeLabel,
                  bodyTargetCodes: step.bodyTargetCodes,
                  visualType: step.visualType,
                  mediaUrl: step.visualUrl,
                  posterUrl: step.visualThumbnailUrl,
                  exerciseDurationSeconds: step.durationSeconds,
                  visualDurationSeconds: step.visualDurationSeconds,
                  isPaused: state.isPaused,
                  isCompleted: state.isCompleted,
                  progress: state.progress,
                ),
              ),
      ),
    );

    final timerWidget = KeyedSubtree(
      key: timerGuideKey,
      child: _StepTimerFocusCard(
        stepRemainingSeconds: state.remainingCurrentStepSeconds,
        totalRemainingSeconds: state.remainingSessionSeconds,
        stepIndex: state.currentStepIndex,
        totalSteps: state.totalSteps,
        progress: stepProgress,
        bodyTargetCodes: step.bodyTargetCodes,
        repetitionCount: step.repetitionCount,
        holdSeconds: step.holdSeconds,
        sideMode: step.effectiveSideMode,
        compact: compactHeight,
      ),
    );

    final instructionWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: instructionGuideKey,
        child: _CoachCuePanel(
          key: ValueKey('${step.id}_coach'),
          stepLabel: '${state.currentStepIndex + 1}/${state.totalSteps}',
          title: stepTitle,
          instruction: instruction,
          stepTypeLabel: stepTypeLabel,
          stepPurposeLabel: stepPurposeLabel,
          stepGoal: stepGoal,
          whatToNotice: whatToNotice,
          avoidMistakes: avoidMistakes,
          coachTip: coachTip,
          playerFocusNote: playerFocusNote,
          isAssessmentStep: isAssessmentStep,
          isRetestStep: isRetestStep,
          coachingText: coachingText,
          breathingText: breathingText,
          safetyText: safetyText,
          movementPattern: step.effectiveMovementPattern,
          repetitionCount: step.repetitionCount,
          holdSeconds: step.holdSeconds,
          stepDurationSeconds: step.durationSeconds,
          sideMode: step.effectiveSideMode,
          equipmentCode: step.effectiveEquipmentCode,
          intensityLevel: step.effectiveIntensityLevel,
          bodyTargetCodes: step.bodyTargetCodes,
          progress: state.progress,
          isPaused: state.isPaused,
          isCompleted: state.isCompleted,
          compact: compactHeight,
        ),
      ),
    );

    final controlsWidget = KeyedSubtree(
      key: controlsGuideKey,
      child: PlayerControlPanel(
        isPaused: state.isPaused,
        isCompleted: state.isCompleted,
        canGoPrevious: state.canGoPrevious,
        canGoNext: state.canGoNext,
        canSkip: state.canSkipCurrentStep,
        canReplay: state.canReplay,
        isLastStep: state.isLastStep,
        onPreviousPressed: onPreviousPressed,
        onPauseResumePressed: onPauseResumePressed,
        onNextPressed: onNextPressed,
        onSkipPressed: onSkipPressed,
        onReplayPressed: onReplayPressed,
        onFinishPressed: onFinishPressed,
      ),
    );

    if (isLandscape) {
      return Scrollbar(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom + 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget,
              SizedBox(height: gap),
              mediaWidget,
              SizedBox(height: gap),
              timerWidget,
              SizedBox(height: gap),
              instructionWidget,
              SizedBox(height: controlGap),
              controlsWidget,
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerWidget,
        SizedBox(height: gap),
        mediaWidget,
        SizedBox(height: gap),
        timerWidget,
        SizedBox(height: gap),
        Flexible(
          fit: FlexFit.loose,
          child: instructionWidget,
        ),
        SizedBox(height: controlGap),
        if (!compactHeight) const Spacer(),
        controlsWidget,
      ],
    );
  }

  String? _safeDynamicString(Object source, Object? Function(dynamic value) reader) {
    try {
      final value = reader(source);
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  bool _safeDynamicBool(Object source, Object? Function(dynamic value) reader) {
    try {
      final value = reader(source);
      if (value is bool) return value;
      if (value is String) return value.trim().toLowerCase() == 'true';
      return false;
    } catch (_) {
      return false;
    }
  }

  List<String> _safeDynamicStringList(
    Object source,
    Object? Function(dynamic value) reader,
  ) {
    try {
      final value = reader(source);
      if (value is Iterable) {
        return value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      if (value is String && value.trim().isNotEmpty) {
        return <String>[value.trim()];
      }
      return const <String>[];
    } catch (_) {
      return const <String>[];
    }
  }

  String _fallbackPurposeLabel(
    BuildContext context, {
    required bool isAssessmentStep,
    required bool isRetestStep,
    required SessionStepMovementPattern movementPattern,
  }) {
    if (isRetestStep) {
      return AppText.get(context, key: 'player_step_purpose_retest', fallback: 'Retest');
    }
    if (isAssessmentStep) {
      return AppText.get(context, key: 'player_step_purpose_check', fallback: 'Check');
    }

    switch (movementPattern) {
      case SessionStepMovementPattern.release:
      case SessionStepMovementPattern.stretch:
      case SessionStepMovementPattern.mobility:
        return AppText.get(context, key: 'player_step_purpose_release', fallback: 'Release');
      case SessionStepMovementPattern.activation:
      case SessionStepMovementPattern.strength:
      case SessionStepMovementPattern.endurance:
        return AppText.get(context, key: 'player_step_purpose_activate', fallback: 'Activate');
      default:
        return AppText.get(context, key: 'player_step_purpose_control', fallback: 'Control');
    }
  }

  String? _resolveOptionalText(
    BuildContext context, {
    required String? key,
    required String? fallback,
  }) {
    final hasKey = key != null && key.trim().isNotEmpty;
    final hasFallback = fallback != null && fallback.trim().isNotEmpty;
    if (!hasKey && !hasFallback) return null;

    final value = AppText.get(
      context,
      key: key ?? '',
      fallback: fallback ?? '',
    ).trim();

    return value.isEmpty ? null : value;
  }
}

class _FocusedTopBar extends StatelessWidget {
  const _FocusedTopBar({
    required this.sessionTitle,
    required this.stepIndex,
    required this.totalSteps,
    required this.totalRemainingSeconds,
    required this.progress,
    required this.bodyTargetCodes,
    required this.isCompleted,
    required this.onClosePressed,
  });

  final String sessionTitle;
  final int stepIndex;
  final int totalSteps;
  final int totalRemainingSeconds;
  final double progress;
  final List<String> bodyTargetCodes;
  final bool isCompleted;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.surface.withValues(alpha: 0.86),
                  colors.surfaceContainerHigh.withValues(alpha: 0.68),
                ]
              : [
                  colors.surfaceContainerLowest.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.82),
                ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.30 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.12 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 66,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClosePressed,
                  tooltip: t.get('player_close_tooltip', fallback: 'Close player'),
                  icon: const Icon(Icons.close_rounded, size: 22),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sessionTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -0.12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 13,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _SessionProgressWavePainter(
                          progress: progress.clamp(0.0, 1.0),
                          accent: accent,
                          trackColor: colors.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.40 : 0.58,
                          ),
                          glowColor: accent.withValues(
                            alpha: isDark ? 0.26 : 0.18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SessionRemainingPill(
                seconds: totalRemainingSeconds,
                accent: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionRemainingPill extends StatelessWidget {
  const _SessionRemainingPill({
    required this.seconds,
    required this.accent,
  });

  final int seconds;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 82),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: accent.withValues(alpha: isDark ? 0.13 : 0.09),
          border: Border.all(color: accent.withValues(alpha: isDark ? 0.22 : 0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(seconds),
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                AppText.get(context, key: 'player_session_remaining_short', fallback: 'LEFT').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SessionProgressWavePainter extends CustomPainter {
  const _SessionProgressWavePainter({
    required this.progress,
    required this.accent,
    required this.trackColor,
    required this.glowColor,
  });

  final double progress;
  final Color accent;
  final Color trackColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerY = size.height * 0.55;
    final amplitude = math.max(2.0, size.height * 0.22);
    final activeWidth = size.width * progress.clamp(0.0, 1.0);

    Path buildPath(double width) {
      final path = Path()..moveTo(0, centerY);
      final steps = math.max(18, width ~/ 8);
      for (var i = 0; i <= steps; i++) {
        final x = size.width * i / steps;
        final phase = (x / size.width) * math.pi * 4.2;
        final y = centerY + math.sin(phase) * amplitude;
        path.lineTo(x, y);
      }
      return path;
    }

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0
      ..color = trackColor;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = glowColor;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.6
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.72),
          accent,
        ],
      ).createShader(Offset.zero & size);

    final fullPath = buildPath(size.width);
    canvas.drawPath(fullPath, trackPaint);

    if (activeWidth <= 0) return;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, activeWidth, size.height));
    canvas.drawPath(fullPath, glowPaint);
    canvas.drawPath(fullPath, activePaint);
    canvas.restore();

    final dotX = activeWidth.clamp(2.0, size.width - 2.0);
    final phase = (dotX / size.width) * math.pi * 4.2;
    final dotY = centerY + math.sin(phase) * amplitude;

    canvas.drawCircle(
      Offset(dotX, dotY),
      3.2,
      Paint()..color = accent,
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      6.0,
      Paint()..color = glowColor,
    );
  }

  @override
  bool shouldRepaint(covariant _SessionProgressWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.glowColor != glowColor;
  }
}

class _CoachCuePanel extends StatelessWidget {
  const _CoachCuePanel({
    super.key,
    required this.stepLabel,
    required this.title,
    required this.instruction,
    required this.stepTypeLabel,
    required this.stepPurposeLabel,
    required this.stepGoal,
    required this.whatToNotice,
    required this.avoidMistakes,
    required this.coachTip,
    required this.playerFocusNote,
    required this.isAssessmentStep,
    required this.isRetestStep,
    required this.coachingText,
    required this.breathingText,
    required this.safetyText,
    required this.movementPattern,
    required this.repetitionCount,
    required this.holdSeconds,
    required this.stepDurationSeconds,
    required this.sideMode,
    required this.equipmentCode,
    required this.intensityLevel,
    required this.bodyTargetCodes,
    required this.progress,
    required this.isPaused,
    required this.isCompleted,
    required this.compact,
  });

  final String stepLabel;
  final String title;
  final String instruction;
  final String stepTypeLabel;
  final String stepPurposeLabel;
  final String? stepGoal;
  final String? whatToNotice;
  final List<String> avoidMistakes;
  final String? coachTip;
  final String? playerFocusNote;
  final bool isAssessmentStep;
  final bool isRetestStep;
  final String? coachingText;
  final String? breathingText;
  final String? safetyText;
  final SessionStepMovementPattern movementPattern;
  final int? repetitionCount;
  final int? holdSeconds;
  final int stepDurationSeconds;
  final SessionStepSideMode sideMode;
  final SessionStepEquipmentCode equipmentCode;
  final SessionStepIntensityLevel intensityLevel;
  final List<String> bodyTargetCodes;
  final double progress;
  final bool isPaused;
  final bool isCompleted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final tightHeight = compact || (maxHeight.isFinite && maxHeight < 285);
        final panel = _buildPanel(context, tightHeight: tightHeight);

        if (maxHeight.isFinite && maxHeight < 330) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: panel,
            ),
          );
        }

        return panel;
      },
    );
  }

  Widget _buildPanel(BuildContext context, {required bool tightHeight}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    final cleanInstruction = instruction.trim();
    final cleanFocusNote = playerFocusNote?.trim();
    final cleanGoal = stepGoal?.trim();
    final cleanNotice = whatToNotice?.trim();
    final firstAvoid = avoidMistakes
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .cast<String?>()
        .firstWhere((item) => item != null, orElse: () => null);

    final hasGoal = cleanGoal != null && cleanGoal.isNotEmpty;
    final hasNotice = cleanNotice != null && cleanNotice.isNotEmpty;
    final hasAvoid = firstAvoid != null && firstAvoid.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.58)
            : colors.surfaceContainerLowest.withValues(alpha: 0.98),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          tightHeight ? 9 : 11,
          12,
          tightHeight ? 9 : 11,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                height: 1.06,
                letterSpacing: -0.20,
              ),
            ),
            SizedBox(height: tightHeight ? 8 : 9),
            _PrimaryInstructionCard(
              text: cleanInstruction,
              accent: accent,
              isAssessment: isAssessmentStep && !isRetestStep,
              isRetest: isRetestStep,
              maxLines: tightHeight ? 5 : 6,
            ),
            if (hasGoal) ...[
              SizedBox(height: tightHeight ? 7 : 8),
              _ClinicalIntentLine(
                label: isRetestStep
                    ? AppText.get(context, key: 'player_retest_goal_label', fallback: 'Compare')
                    : AppText.get(context, key: 'player_why_step_label', fallback: 'Why'),
                text: cleanGoal,
                icon: isRetestStep ? Icons.compare_rounded : Icons.psychology_alt_rounded,
                accent: accent,
                maxLines: 99,
              ),
            ],
            SizedBox(height: tightHeight ? 6 : 8),
            Row(
              children: [
                if (hasNotice)
                  _SmallGuidanceChip(
                    icon: Icons.visibility_outlined,
                    label: AppText.get(context, key: 'player_notice_label', fallback: 'Notice'),
                    accent: accent,
                    onPressed: () => _showSingleInfoSheet(
                      context: context,
                      title: AppText.get(context, key: 'player_notice_label', fallback: 'Notice'),
                      body: cleanNotice,
                      icon: Icons.visibility_outlined,
                      accent: accent,
                    ),
                  ),
                if (hasNotice) const SizedBox(width: 7),
                if (hasAvoid)
                  _SmallGuidanceChip(
                    icon: Icons.block_rounded,
                    label: AppText.get(context, key: 'player_avoid_label', fallback: 'Avoid'),
                    accent: colors.error,
                    onPressed: () => _showSingleInfoSheet(
                      context: context,
                      title: AppText.get(context, key: 'player_avoid_label', fallback: 'Avoid'),
                      body: avoidMistakes
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .join('\n'),
                      icon: Icons.block_rounded,
                      accent: colors.error,
                    ),
                  ),
                if (hasAvoid) const SizedBox(width: 7),
                Expanded(
                  child: _GuidanceDropdownButton(
                    focusNote: cleanFocusNote,
                    coachTip: coachTip,
                    coachingText: coachingText,
                    breathingText: breathingText,
                    safetyText: safetyText,
                    movementPatternLabel: stepTypeLabel,
                    equipmentLabel: _equipmentLabel(context, equipmentCode),
                    intensityLabel: _intensityLabel(context, intensityLevel),
                    stepDurationSeconds: stepDurationSeconds,
                    accent: accent,
                    compact: tightHeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSingleInfoSheet({
    required BuildContext context,
    required String title,
    required String body,
    required IconData icon,
    required Color accent,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colors.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(icon, color: accent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _PrimaryInstructionCard extends StatelessWidget {
  const _PrimaryInstructionCard({
    required this.text,
    required this.accent,
    required this.isAssessment,
    required this.isRetest,
    required this.maxLines,
  });

  final String text;
  final Color accent;
  final bool isAssessment;
  final bool isRetest;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final icon = isAssessment
        ? Icons.search_rounded
        : isRetest
            ? Icons.compare_arrows_rounded
            : Icons.check_circle_outline_rounded;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: accent.withValues(alpha: isDark ? 0.12 : 0.080),
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.20 : 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: accent),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  height: 1.24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicalIntentLine extends StatelessWidget {
  const _ClinicalIntentLine({
    required this.label,
    required this.text,
    required this.icon,
    required this.accent,
    required this.maxLines,
  });

  final String label;
  final String text;
  final IconData icon;
  final Color accent;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
                TextSpan(text: text),
              ],
            ),
            softWrap: true,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}


class _SmallGuidanceChip extends StatelessWidget {
  const _SmallGuidanceChip({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: isDark ? 0.18 : 0.105),
                colors.surfaceContainerLowest.withValues(alpha: isDark ? 0.06 : 0.92),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: isDark ? 0.30 : 0.22)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.075),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: accent),
                const SizedBox(width: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_up_rounded, size: 15, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _GuidanceDropdownButton extends StatelessWidget {
  const _GuidanceDropdownButton({
    required this.focusNote,
    required this.coachTip,
    required this.coachingText,
    required this.breathingText,
    required this.safetyText,
    required this.movementPatternLabel,
    required this.equipmentLabel,
    required this.intensityLabel,
    required this.stepDurationSeconds,
    required this.accent,
    this.compact = false,
  });

  final String? focusNote;
  final String? coachTip;
  final String? coachingText;
  final String? breathingText;
  final String? safetyText;
  final String movementPatternLabel;
  final String equipmentLabel;
  final String intensityLabel;
  final int stepDurationSeconds;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGuidanceSheet(context),
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.18 : 0.105),
                  colors.surfaceContainerLowest.withValues(alpha: isDark ? 0.06 : 0.92),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.30 : 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.12 : 0.075),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 7 : 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: compact ? 15 : 16, color: accent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppText.get(
                        context,
                        key: 'player_guidance_more_cta',
                        fallback: 'Coach Tip',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (compact
                              ? theme.textTheme.labelMedium
                              : theme.textTheme.labelLarge)
                          ?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showGuidanceSheet(BuildContext context) {
    final items = <_GuidanceSheetItem>[
      if (coachTip != null && coachTip!.trim().isNotEmpty)
        _GuidanceSheetItem(
          icon: Icons.lightbulb_outline_rounded,
          title: AppText.get(context, key: 'player_guidance_coach_tip_title', fallback: 'Coach tip'),
          body: coachTip!.trim(),
        ),
      if (breathingText != null && breathingText!.trim().isNotEmpty)
        _GuidanceSheetItem(
          icon: Icons.air_rounded,
          title: AppText.get(context, key: 'player_guidance_breathing_title', fallback: 'Breathing'),
          body: breathingText!.trim(),
        ),
      if (safetyText != null && safetyText!.trim().isNotEmpty)
        _GuidanceSheetItem(
          icon: Icons.health_and_safety_rounded,
          title: AppText.get(context, key: 'player_guidance_safety_title', fallback: 'Safety'),
          body: safetyText!.trim(),
        ),
    ];

    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.46,
          minChildSize: 0.30,
          maxChildSize: 0.82,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colors.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppText.get(
                      sheetContext,
                      key: 'player_guidance_sheet_title',
                      fallback: 'Step guidance',
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _GuidanceSheetTile(item: item, accent: accent);
                      },
                    ),
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

class _GuidanceSheetItem {
  const _GuidanceSheetItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _GuidanceSheetTile extends StatelessWidget {
  const _GuidanceSheetTile({required this.item, required this.accent});

  final _GuidanceSheetItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.52),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: accent, size: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RecoveryCompanion extends StatefulWidget {
  const _RecoveryCompanion({
    required this.bodyTargetCodes,
    required this.breathing,
    required this.warning,
    required this.paused,
    required this.completed,
    required this.size,
  });

  final List<String> bodyTargetCodes;
  final bool breathing;
  final bool warning;
  final bool paused;
  final bool completed;
  final double size;

  @override
  State<_RecoveryCompanion> createState() => _RecoveryCompanionState();
}

class _RecoveryCompanionState extends State<_RecoveryCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final zoneAccent = _zoneAccentColor(colors, widget.bodyTargetCodes);
    final accent = widget.completed
        ? colors.primary
        : widget.warning
            ? Color.lerp(zoneAccent, colors.error, 0.34) ?? zoneAccent
            : zoneAccent;
    final icon = widget.completed
        ? Icons.check_rounded
        : widget.paused
            ? Icons.pause_rounded
            : _zoneIcon(widget.bodyTargetCodes);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final value = widget.paused ? 0.38 : _pulse.value;
        final breathScale = widget.breathing ? 0.97 + (value * 0.10) : 0.99 + (value * 0.05);
        final bobY = widget.paused ? 0.0 : -3.5 + (value * 7.0);
        final tilt = widget.paused ? 0.0 : math.sin(value * math.pi * 2) * 0.035;
        final blink = value > 0.78 && value < 0.88;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: breathScale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _CompanionAura(
                      size: widget.size,
                      accent: accent,
                      value: value,
                    ),
                    Positioned(
                      top: widget.size * 0.04,
                      child: _CompanionAntenna(
                        size: widget.size,
                        accent: accent,
                        value: value,
                      ),
                    ),
                    Positioned(
                      bottom: widget.size * 0.10,
                      left: widget.size * 0.08,
                      child: _CompanionArm(
                        size: widget.size,
                        accent: accent,
                        left: true,
                        value: value,
                      ),
                    ),
                    Positioned(
                      bottom: widget.size * 0.10,
                      right: widget.size * 0.08,
                      child: _CompanionArm(
                        size: widget.size,
                        accent: accent,
                        left: false,
                        value: value,
                      ),
                    ),
                    Positioned(
                      bottom: widget.size * 0.07,
                      child: _CompanionBody(
                        size: widget.size,
                        accent: accent,
                        icon: icon,
                        blink: blink,
                        warning: widget.warning,
                        completed: widget.completed,
                      ),
                    ),
                    Positioned(
                      right: widget.size * 0.04,
                      top: widget.size * 0.08,
                      child: _CompanionSpark(
                        size: widget.size,
                        accent: accent,
                        value: value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompanionAura extends StatelessWidget {
  const _CompanionAura({
    required this.size,
    required this.accent,
    required this.value,
  });

  final double size;
  final Color accent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * (0.95 + value * 0.12),
      height: size * (0.95 + value * 0.12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.34),
            accent.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _CompanionAntenna extends StatelessWidget {
  const _CompanionAntenna({
    required this.size,
    required this.accent,
    required this.value,
  });

  final double size;
  final Color accent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -value * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 0.11,
            height: size * 0.11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.56),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: size * 0.12,
            color: accent.withValues(alpha: 0.42),
          ),
        ],
      ),
    );
  }
}

class _CompanionBody extends StatelessWidget {
  const _CompanionBody({
    required this.size,
    required this.accent,
    required this.icon,
    required this.blink,
    required this.warning,
    required this.completed,
  });

  final double size;
  final Color accent;
  final IconData icon;
  final bool blink;
  final bool warning;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size * 0.68,
      height: size * 0.74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.38),
          topRight: Radius.circular(size * 0.38),
          bottomLeft: Radius.circular(size * 0.24),
          bottomRight: Radius.circular(size * 0.24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.72 : 0.34),
            colors.surface.withValues(alpha: isDark ? 0.74 : 0.92),
            accent.withValues(alpha: isDark ? 0.30 : 0.20),
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: 0.50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.18,
            left: size * 0.20,
            child: _CompanionEye(accent: accent, blink: blink),
          ),
          Positioned(
            top: size * 0.18,
            right: size * 0.20,
            child: _CompanionEye(accent: accent, blink: blink),
          ),
          Positioned(
            top: size * 0.36,
            child: Container(
              width: size * 0.18,
              height: 2.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: accent.withValues(alpha: 0.78),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: size * 0.31,
              height: size * 0.31,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.16),
                border: Border.all(color: accent.withValues(alpha: 0.32)),
              ),
              child: Icon(
                warning && !completed ? Icons.shield_outlined : icon,
                color: accent,
                size: size * 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionEye extends StatelessWidget {
  const _CompanionEye({required this.accent, required this.blink});

  final Color accent;
  final bool blink;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      width: 5.5,
      height: blink ? 1.5 : 6.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.45),
            blurRadius: 7,
          ),
        ],
      ),
    );
  }
}

class _CompanionArm extends StatelessWidget {
  const _CompanionArm({
    required this.size,
    required this.accent,
    required this.left,
    required this.value,
  });

  final double size;
  final Color accent;
  final bool left;
  final double value;

  @override
  Widget build(BuildContext context) {
    final angle = (left ? -0.48 : 0.48) + (math.sin(value * math.pi * 2) * 0.09);
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size * 0.08,
        height: size * 0.29,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0.36),
              accent.withValues(alpha: 0.10),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanionSpark extends StatelessWidget {
  const _CompanionSpark({
    required this.size,
    required this.accent,
    required this.value,
  });

  final double size;
  final Color accent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.78 + value * 0.24,
      child: Icon(
        Icons.auto_awesome_rounded,
        color: accent.withValues(alpha: 0.70),
        size: size * 0.18,
      ),
    );
  }
}

class _StepTimerFocusCard extends StatelessWidget {
  const _StepTimerFocusCard({
    required this.stepRemainingSeconds,
    required this.totalRemainingSeconds,
    required this.stepIndex,
    required this.totalSteps,
    required this.progress,
    required this.bodyTargetCodes,
    required this.repetitionCount,
    required this.holdSeconds,
    required this.sideMode,
    required this.compact,
  });

  final int stepRemainingSeconds;
  final int totalRemainingSeconds;
  final int stepIndex;
  final int totalSteps;
  final double progress;
  final List<String> bodyTargetCodes;
  final int? repetitionCount;
  final int? holdSeconds;
  final SessionStepSideMode sideMode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = _zoneAccentColor(colors, bodyTargetCodes);

    return _CompactStepTimerBar(
      stepRemainingSeconds: stepRemainingSeconds,
      totalRemainingSeconds: totalRemainingSeconds,
      progress: progress,
      accent: accent,
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      repetitionCount: repetitionCount,
      holdSeconds: holdSeconds,
      sideMode: sideMode,
      compact: compact,
    );
  }
}

class _CompactStepTimerBar extends StatelessWidget {
  const _CompactStepTimerBar({
    required this.stepRemainingSeconds,
    required this.totalRemainingSeconds,
    required this.progress,
    required this.accent,
    required this.stepIndex,
    required this.totalSteps,
    required this.repetitionCount,
    required this.holdSeconds,
    required this.sideMode,
    required this.compact,
  });

  final int stepRemainingSeconds;
  final int totalRemainingSeconds;
  final double progress;
  final Color accent;
  final int stepIndex;
  final int totalSteps;
  final int? repetitionCount;
  final int? holdSeconds;
  final SessionStepSideMode sideMode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final stepProgress = progress.clamp(0.0, 1.0).toDouble();
    final ringAccent = Color.lerp(accent, colors.secondary, isDark ? 0.46 : 0.38)!;
    final height = compact ? 126.0 : 140.0;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: isDark ? 0.085 : 0.055),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepCountdownRing(
                  seconds: stepRemainingSeconds,
                  progress: stepProgress,
                  accent: ringAccent,
                  compact: compact,
                ),
                SizedBox(width: compact ? 16 : 22),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: compact ? 120 : 142,
                    maxWidth: compact ? 158 : 190,
                  ),
                  child: _CycleTargetCard(
                    repetitionCount: repetitionCount,
                    holdSeconds: holdSeconds,
                    sideMode: sideMode,
                    stepIndex: stepIndex,
                    totalSteps: totalSteps,
                    accent: ringAccent,
                    compact: compact,
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

class _StepCountdownRing extends StatelessWidget {
  const _StepCountdownRing({
    required this.seconds,
    required this.progress,
    required this.accent,
    required this.compact,
  });

  final int seconds;
  final double progress;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = compact ? 122.0 : 136.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0).toDouble()),
      // Keep the ring moving continuously between the controller's 1-second
      // timer ticks. A linear ~1s interpolation avoids the visible step/jump
      // that happens when the painter only receives whole-second progress.
      duration: const Duration(milliseconds: 1040),
      curve: Curves.linear,
      builder: (context, animatedProgress, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size - 18,
                height: size - 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isDark
                        ? [
                            colors.surface.withValues(alpha: 0.78),
                            colors.surfaceContainerHigh.withValues(alpha: 0.48),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.96),
                            accent.withValues(alpha: 0.08),
                          ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.68),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: Size.square(size),
                painter: _StepCountdownRingPainter(
                  progress: animatedProgress,
                  accent: accent,
                  trackColor: colors.surfaceContainerHighest.withValues(
                    alpha: isDark ? 0.26 : 0.52,
                  ),
                  glowColor: accent.withValues(alpha: isDark ? 0.38 : 0.24),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(seconds),
                    maxLines: 1,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 0.88,
                      letterSpacing: -1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppText.get(
                      context,
                      key: 'player_step_remaining_title_short',
                      fallback: 'LEFT',
                    ).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: 1.25,
                    ),
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

class _CycleTargetCard extends StatelessWidget {
  const _CycleTargetCard({
    required this.repetitionCount,
    required this.holdSeconds,
    required this.sideMode,
    required this.stepIndex,
    required this.totalSteps,
    required this.accent,
    required this.compact,
  });

  final int? repetitionCount;
  final int? holdSeconds;
  final SessionStepSideMode sideMode;
  final int stepIndex;
  final int totalSteps;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final primary = _primaryDoseLabel(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final numberStyle = theme.textTheme.displaySmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w900,
      height: 0.88,
      letterSpacing: -1.2,
    );

    return Padding(
      padding: EdgeInsets.only(right: compact ? 4 : 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppText.get(context, key: 'player_dose_target_label', fallback: 'Cycles').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: 1.18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  primary.main,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: numberStyle,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  primary.unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InlineStepLabel(
            stepIndex: stepIndex,
            totalSteps: totalSteps,
            accent: accent,
          ),
        ],
      ),
    );
  }

  _DoseValue _primaryDoseLabel(BuildContext context) {
    if (repetitionCount != null && repetitionCount! > 0) {
      final full = AppText.get(
        context,
        key: 'player_dose_reps_label',
        fallback: '{count} reps',
      ).replaceAll('{count}', repetitionCount.toString());
      return _DoseValue(
        main: repetitionCount.toString(),
        unit: AppText.get(context, key: 'player_dose_reps_unit', fallback: 'reps'),
        fullText: full,
      );
    }

    if (holdSeconds != null && holdSeconds! > 0) {
      final full = AppText.get(
        context,
        key: 'player_dose_control_label',
        fallback: '{seconds}s hold',
      ).replaceAll('{seconds}', holdSeconds.toString());
      return _DoseValue(
        main: holdSeconds.toString(),
        unit: AppText.get(context, key: 'player_dose_seconds_unit', fallback: 'sec hold'),
        fullText: full,
      );
    }

    final fallback = AppText.get(context, key: 'player_dose_controlled', fallback: 'Controlled');
    return _DoseValue(main: '∞', unit: fallback, fullText: fallback);
  }

}

class _InlineStepLabel extends StatelessWidget {
  const _InlineStepLabel({
    required this.stepIndex,
    required this.totalSteps,
    required this.accent,
  });

  final int stepIndex;
  final int totalSteps;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final safeTotal = totalSteps <= 0 ? 1 : totalSteps;
    final label = AppText.get(
      context,
      key: 'player_step_counter_inline',
      fallback: 'Step {current}/{total}',
    )
        .replaceAll('{current}', (stepIndex + 1).toString())
        .replaceAll('{total}', safeTotal.toString());

    return Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: 1.05,
      ),
    );
  }
}

class _DoseValue {
  const _DoseValue({
    required this.main,
    required this.unit,
    required this.fullText,
  });

  final String main;
  final String unit;
  final String fullText;
}



class _StepCountdownRingPainter extends CustomPainter {
  const _StepCountdownRingPainter({
    required this.progress,
    required this.accent,
    required this.trackColor,
    required this.glowColor,
  });

  final double progress;
  final Color accent;
  final Color trackColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 7;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = trackColor;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = glowColor;

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.4
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          accent.withValues(alpha: 0.74),
          accent,
          accent.withValues(alpha: 0.74),
        ],
      ).createShader(rect);

    final clamped = progress.clamp(0.0, 1.0).toDouble();

    canvas.drawCircle(center, radius, track);
    if (clamped <= 0) return;
    canvas.drawArc(rect, -math.pi / 2, (math.pi * 2) * clamped, false, glow);
    canvas.drawArc(rect, -math.pi / 2, (math.pi * 2) * clamped, false, active);

    final angle = -math.pi / 2 + (math.pi * 2) * clamped;
    final dot = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    canvas.drawCircle(dot, 4.2, Paint()..color = accent);
    canvas.drawCircle(
      dot,
      2.1,
      Paint()..color = Colors.white.withValues(alpha: 0.86),
    );
  }

  @override
  bool shouldRepaint(covariant _StepCountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.glowColor != glowColor;
  }
}

Color _zoneAccentColor(ColorScheme colors, List<String> codes) {
  final primary = _primaryBodyZone(codes);
  switch (primary) {
    case 'neck':
      return colors.primary;
    case 'shoulders':
    case 'upper_back':
      return colors.tertiary;
    case 'wrists':
    case 'hands':
    case 'forearms':
      return colors.secondary;
    case 'lower_back':
    case 'hips_glutes':
      return colors.primaryContainer;
    case 'eyes':
      return colors.secondary;
    default:
      return colors.primary;
  }
}

IconData _zoneIcon(List<String> codes) {
  final primary = _primaryBodyZone(codes);
  switch (primary) {
    case 'neck':
      return Icons.self_improvement_rounded;
    case 'shoulders':
    case 'upper_back':
      return Icons.accessibility_new_rounded;
    case 'wrists':
    case 'hands':
    case 'forearms':
      return Icons.pan_tool_alt_rounded;
    case 'lower_back':
    case 'hips_glutes':
      return Icons.airline_seat_recline_normal_rounded;
    case 'eyes':
      return Icons.visibility_outlined;
    default:
      return Icons.spa_rounded;
  }
}


String _primaryBodyZone(List<String> codes) {
  if (codes.isEmpty) return 'general';
  const priority = <String>[
    'neck',
    'shoulders',
    'upper_back',
    'wrists',
    'hands',
    'forearms',
    'lower_back',
    'hips_glutes',
    'eyes',
  ];

  for (final item in priority) {
    if (codes.contains(item)) return item;
  }

  return codes.first;
}

class _PlayerLoadingView extends StatelessWidget {
  const _PlayerLoadingView();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colors.surfaceContainerHigh.withValues(alpha: 0.72),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(t.get('player_loading_title', fallback: 'Preparing player...')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerAuthRequiredView extends ConsumerWidget {
  const _PlayerAuthRequiredView({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) return const SizedBox.shrink();

    final redirect = Uri.encodeComponent('/app/sessions/player/$sessionId');

    return _PlayerErrorView(
      title: t.get('player_auth_required_title', fallback: 'Sign in required'),
      message: t.get(
        'player_auth_required_message',
        fallback: 'You need an account to start and track session runs.',
      ),
      onPrimaryPressed: () => context.push('/auth?mode=signin&redirect=$redirect'),
      primaryLabel: t.get('player_auth_required_cta', fallback: 'Sign in'),
    );
  }
}

class _PlayerErrorView extends StatelessWidget {
  const _PlayerErrorView({
    required this.title,
    required this.message,
    required this.onPrimaryPressed,
    required this.primaryLabel,
  });

  final String title;
  final String message;
  final VoidCallback onPrimaryPressed;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: colors.surfaceContainerHigh.withValues(alpha: 0.78),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.54),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 36, color: colors.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(primaryLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


String _movementPatternLabel(
  BuildContext context,
  SessionStepMovementPattern pattern,
) {
  switch (pattern) {
    case SessionStepMovementPattern.setup:
      return AppText.get(context, key: 'movement_pattern_setup', fallback: 'Setup');
    case SessionStepMovementPattern.assessment:
      return AppText.get(context, key: 'movement_pattern_assessment', fallback: 'Assessment');
    case SessionStepMovementPattern.mobility:
      return AppText.get(context, key: 'movement_pattern_mobility', fallback: 'Mobility');
    case SessionStepMovementPattern.stretch:
      return AppText.get(context, key: 'movement_pattern_stretch', fallback: 'Stretch');
    case SessionStepMovementPattern.release:
      return AppText.get(context, key: 'movement_pattern_release', fallback: 'Release');
    case SessionStepMovementPattern.activation:
      return AppText.get(context, key: 'movement_pattern_activation', fallback: 'Activation');
    case SessionStepMovementPattern.strength:
      return AppText.get(context, key: 'movement_pattern_strength', fallback: 'Strength');
    case SessionStepMovementPattern.endurance:
      return AppText.get(context, key: 'movement_pattern_endurance', fallback: 'Endurance');
    case SessionStepMovementPattern.posture:
      return AppText.get(context, key: 'movement_pattern_posture', fallback: 'Posture');
    case SessionStepMovementPattern.breathing:
      return AppText.get(context, key: 'movement_pattern_breathing', fallback: 'Breathing');
    case SessionStepMovementPattern.cooldown:
      return AppText.get(context, key: 'movement_pattern_cooldown', fallback: 'Cooldown');
    case SessionStepMovementPattern.habit:
      return AppText.get(context, key: 'movement_pattern_habit', fallback: 'Habit');
  }
}


String _equipmentLabel(BuildContext context, SessionStepEquipmentCode code) {
  switch (code) {
    case SessionStepEquipmentCode.none:
      return AppText.get(context, key: 'equipment_none', fallback: 'No equipment');
    case SessionStepEquipmentCode.chair:
      return AppText.get(context, key: 'equipment_chair', fallback: 'Chair');
    case SessionStepEquipmentCode.desk:
      return AppText.get(context, key: 'equipment_desk', fallback: 'Desk');
    case SessionStepEquipmentCode.wall:
      return AppText.get(context, key: 'equipment_wall', fallback: 'Wall');
    case SessionStepEquipmentCode.towel:
      return AppText.get(context, key: 'equipment_towel', fallback: 'Towel');
    case SessionStepEquipmentCode.smallCushion:
      return AppText.get(context, key: 'equipment_small_cushion', fallback: 'Small cushion');
    case SessionStepEquipmentCode.lumbarRoll:
      return AppText.get(context, key: 'equipment_lumbar_roll', fallback: 'Lumbar roll');
    case SessionStepEquipmentCode.miniBand:
      return AppText.get(context, key: 'equipment_mini_band', fallback: 'Mini band');
    case SessionStepEquipmentCode.longBand:
      return AppText.get(context, key: 'equipment_long_band', fallback: 'Resistance band');
    case SessionStepEquipmentCode.massageBall:
      return AppText.get(context, key: 'equipment_massage_ball', fallback: 'Massage ball');
    case SessionStepEquipmentCode.softBall:
      return AppText.get(context, key: 'equipment_soft_ball', fallback: 'Soft ball');
    case SessionStepEquipmentCode.waterBottle:
      return AppText.get(context, key: 'equipment_water_bottle', fallback: 'Water bottle');
    case SessionStepEquipmentCode.dowel:
      return AppText.get(context, key: 'equipment_dowel', fallback: 'Dowel / broomstick');
    case SessionStepEquipmentCode.yogaMat:
      return AppText.get(context, key: 'equipment_yoga_mat', fallback: 'Yoga mat');
    case SessionStepEquipmentCode.foamRoller:
      return AppText.get(context, key: 'equipment_foam_roller', fallback: 'Foam roller');
  }
}

String _intensityLabel(BuildContext context, SessionStepIntensityLevel level) {
  final raw = level.name;
  final fallback = raw
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
      .trim();

  return AppText.get(
    context,
    key: 'intensity_$raw',
    fallback: fallback.isEmpty
        ? 'Controlled'
        : '${fallback[0].toUpperCase()}${fallback.substring(1)}',
  );
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
