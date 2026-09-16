// lib/features/player/presentation/pages/session_player_page.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/localization/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../insights/application/insights_providers.dart';
import '../../../insights/domain/insights_snapshot.dart';
import '../../../programs/application/recovery_program_providers.dart';
import '../../../programs/domain/recovery_program_models.dart';
import '../../../sessions/application/sessions_providers.dart';
import '../../../sessions/domain/session_models.dart';
import '../../application/player_providers.dart';
import '../../application/session_player_controller.dart';
import '../../application/session_player_state.dart';
import '../../domain/session_feedback_models.dart';
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
    final t = AppText.of(context);
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
        ? t.get('player_journey_complete', fallback: 'Journey complete')
        : phaseCompleted
            ? t.get('player_phase_complete', fallback: 'Phase complete')
            : t.get('player_mission_complete', fallback: 'Mission complete');

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
                            ? t.get('player_journey_complete_body', fallback: 'You completed the full therapy journey.')
                            : phaseCompleted
                                ? completedPhaseTitle.isNotEmpty
                                    ? t.get('player_phase_named_complete_body', fallback: '{phase} is complete. Your next phase is now ready.').replaceAll('{phase}', completedPhaseTitle)
                                    : t.get('player_phase_complete_body', fallback: 'This phase is complete. Your next phase is now ready.')
                                : t.get('player_mission_complete_body', fallback: 'This mission is now part of your completed path.'),
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
                              t.get('player_journey_progress', fallback: 'Journey progress'),
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
                                t.get('player_mission_streak', fallback: '{count} mission streak').replaceAll('{count}', streakCount.toString()),
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
                                  t.get('player_milestone_reached', fallback: 'Milestone reached'),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colors.onTertiaryContainer,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextPhaseTitle.isNotEmpty
                                      ? t.get('player_phase_unlocked_named', fallback: '{phase} unlocked').replaceAll('{phase}', nextPhaseTitle)
                                      : t.get('player_next_phase_unlocked', fallback: 'The next phase is unlocked'),
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
                                  t.get('player_next_mission_unlocked', fallback: 'Next mission unlocked'),
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
                        journeyCompleted
                            ? t.get('player_view_completed_journey', fallback: 'View completed journey')
                            : t.get('player_back_to_journey', fallback: 'Back to journey'),
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
  final FlutterTts _voiceTts = FlutterTts();
  String? _spokenStepVoiceKey;
  bool _voiceGuidanceEnabled = true;


  @override
  void initState() {
    super.initState();
    unawaited(_configureVoiceGuidance());
  }

  Future<void> _configureVoiceGuidance() async {
    await _voiceTts.setSpeechRate(0.46);
    await _voiceTts.setPitch(1.0);
    await _voiceTts.setVolume(1.0);
    await _voiceTts.awaitSpeakCompletion(false);
  }

  Future<void> _speakCurrentStep(
    SessionPlayerState state, {
    bool force = false,
  }) async {
    if (!_voiceGuidanceEnabled || state.isPaused || state.isCompleted) return;

    final step = state.currentStep;
    if (step == null) return;

    final locale = ref.read(appLocaleControllerProvider);
    final wantsGerman = locale.languageCode.toLowerCase() == 'de';
    final germanScript = step.voiceScriptDe?.trim() ?? '';
    final englishScript = (step.voiceScript ??
            step.shortInstruction ??
            step.instructionFallback)
        .trim();

    final useGerman = wantsGerman && germanScript.isNotEmpty;
    final script = useGerman ? germanScript : englishScript;
    if (script.isEmpty) return;

    final speechLanguageCode = useGerman ? 'de' : 'en';
    final speechKey = '${step.id}:$speechLanguageCode';
    if (!force && _spokenStepVoiceKey == speechKey) return;

    _spokenStepVoiceKey = speechKey;
    await _voiceTts.stop();
    await _voiceTts.setLanguage(useGerman ? 'de-DE' : 'en-US');
    await _voiceTts.speak(script);
  }

  Future<void> _toggleVoiceGuidance(SessionPlayerState state) async {
    setState(() => _voiceGuidanceEnabled = !_voiceGuidanceEnabled);
    if (!_voiceGuidanceEnabled) {
      await _voiceTts.stop();
      return;
    }
    await _speakCurrentStep(state, force: true);
  }

  Future<void> _handlePauseResume(SessionPlayerController controller, SessionPlayerState state) async {
    if (!state.isPaused) {
      await _voiceTts.stop();
    }
    controller.togglePause();
  }

  Future<void> _handlePrevious(SessionPlayerController controller) async {
    await _voiceTts.stop();
    controller.previousStep();
  }

  Future<void> _handleNext(SessionPlayerController controller) async {
    await _voiceTts.stop();
    controller.nextStep();
  }

  Future<void> _handleReplay(SessionPlayerController controller) async {
    await _voiceTts.stop();
    controller.replayStep();
  }

  @override
  void dispose() {
    unawaited(_voiceTts.stop());
    super.dispose();
  }

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
    ref.read(insightsRefreshSignalProvider.notifier).markDirty();
    for (final range in InsightsRange.values) {
      ref.invalidate(insightsSnapshotProvider(range));
    }
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
    if (!mounted) return;

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
      if (!mounted) return;
      await _speakCurrentStep(state);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final canExit = await handleExit(state, controller);
        if (!mounted || !canExit) return;

        safeBackToDetailOrSessions();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
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
              onPauseResumePressed: () => _handlePauseResume(controller, state),
              onPreviousPressed: () => _handlePrevious(controller),
              onNextPressed: () => _handleNext(controller),
              onSkipPressed: controller.skipStep,
              onReplayPressed: () => _handleReplay(controller),
              onFinishPressed: controller.completeSession,
              voiceGuidanceEnabled: _voiceGuidanceEnabled,
              onVoiceGuidancePressed: () => _toggleVoiceGuidance(state),
            ),
          );
            },
          ),
        ),
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
    required this.voiceGuidanceEnabled,
    required this.onVoiceGuidancePressed,
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
  final bool voiceGuidanceEnabled;
  final VoidCallback onVoiceGuidancePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactContent = constraints.maxHeight < 860 || constraints.maxWidth < 430;
        final bodyTargets = state.currentStep?.bodyTargetCodes ?? const <String>[];
        final content = _GlassHudPlayerContent(
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
          voiceGuidanceEnabled: voiceGuidanceEnabled,
          onVoiceGuidancePressed: onVoiceGuidancePressed,
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


class _GlassHudPlayerContent extends StatelessWidget {
  const _GlassHudPlayerContent({
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
    required this.voiceGuidanceEnabled,
    required this.onVoiceGuidancePressed,
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
  final bool voiceGuidanceEnabled;
  final VoidCallback onVoiceGuidancePressed;

  @override
  Widget build(BuildContext context) {
    final step = state.currentStep!;
    final stepTitle = AppText.get(context, key: step.titleKey, fallback: step.titleFallback);
    final instruction = AppText.get(context, key: step.instructionKey, fallback: step.instructionFallback);
    final shortInstruction = (step.shortInstruction?.trim().isNotEmpty ?? false)
        ? step.shortInstruction!.trim()
        : instruction.trim();
    final stepTypeLabel = _movementPatternLabel(context, step.effectiveMovementPattern);
    final stepProgress = step.durationSeconds <= 0
        ? 0.0
        : (state.currentStepElapsedSeconds / step.durationSeconds).clamp(0.0, 1.0).toDouble();
    final media = MediaQuery.of(context);
    final accent = _zoneAccentColor(Theme.of(context).colorScheme, step.bodyTargetCodes);

    final mediaWidget = KeyedSubtree(
      key: mediaGuideKey,
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
        progress: stepProgress,
        fillAvailableHeight: true,
        mediaFit: BoxFit.cover,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final colors = Theme.of(context).colorScheme;
        final metricText = step.repetitionCount != null && step.repetitionCount! > 0
            ? '${step.repetitionCount} ${AppText.get(context, key: 'player_reps_suffix', fallback: 'reps')}'
            : step.holdSeconds != null && step.holdSeconds! > 0
                ? '${step.holdSeconds}s hold'
                : null;

        final isLandscape = media.orientation == Orientation.landscape;
        final contentMaxWidth = isLandscape ? 920.0 : 720.0;
        final videoHeight = isLandscape
            ? (constraints.maxHeight * 0.46).clamp(250.0, 390.0)
            : (constraints.maxHeight * 0.40).clamp(285.0, 420.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 12 + media.padding.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Stack(
                key: headerGuideKey,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: SizedBox(
                      height: videoHeight,
                      child: mediaWidget,
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 20,
                    child: _MinimalOverlayButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: onClosePressed,
                    ),
                  ),
                  Positioned(
                    right: 28,
                    top: 20,
                    child: _MinimalTimePill(
                      seconds: state.remainingSessionSeconds,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  compactHeight ? 20 : 28,
                  24,
                  0,
                ),
                child: Column(
                  children: [
                    KeyedSubtree(
                      key: timerGuideKey,
                      child: _MinimalTimerBlock(
                        remainingSeconds: state.remainingCurrentStepSeconds,
                        progress: stepProgress,
                        accent: accent,
                      ),
                    ),
                    SizedBox(height: compactHeight ? 12 : 18),
                    Text(
                      stepTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.08,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Text(
                          AppText.get(context, key: 'player_step_of', fallback: 'Step {current} of {total}')
                              .replaceAll('{current}', '${state.currentStepIndex + 1}')
                              .replaceAll('{total}', '${state.totalSteps}'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (metricText != null) ...[
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            metricText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: compactHeight ? 14 : 20),
                    KeyedSubtree(
                      key: instructionGuideKey,
                      child: _MinimalInstructionBlock(
                        cue: shortInstruction,
                        accent: accent,
                        voiceEnabled: voiceGuidanceEnabled,
                        onVoicePressed: onVoiceGuidancePressed,
                        onMoreGuidance: () => _showGlassGuidanceSheet(
                          context,
                          stepTitle: stepTitle,
                          instruction: instruction,
                          coaching: _resolveOptionalText(
                            context,
                            key: step.coachingCueKey,
                            fallback: step.coachingCueFallback,
                          ),
                          breathing: _resolveOptionalText(
                            context,
                            key: step.breathingCueKey,
                            fallback: step.breathingCueFallback,
                          ),
                          safety: _resolveOptionalText(
                            context,
                            key: step.safetyNoteKey,
                            fallback: step.safetyNoteFallback,
                          ),
                          stepGoal: _safeDynamicString(
                            step,
                            (value) => value.stepGoal,
                          ),
                          whatToNotice: _safeDynamicString(
                            step,
                            (value) => value.whatToNotice,
                          ),
                          avoidMistakes: _safeDynamicStringList(
                            step,
                            (value) => value.avoidMistakes,
                          ),
                          coachTip: _safeDynamicString(
                            step,
                            (value) => value.coachTip,
                          ),
                          accent: accent,
                        ),
                      ),
                    ),
                    SizedBox(height: compactHeight ? 16 : 24),
                    KeyedSubtree(
                      key: controlsGuideKey,
                      child: _MinimalControlDock(
                        isPaused: state.isPaused,
                        isCompleted: state.isCompleted,
                        canPrevious: state.canGoPrevious,
                        canReplay: state.canReplay,
                        canNext: state.canGoNext,
                        isLastStep: state.isLastStep,
                        onPrevious: onPreviousPressed,
                        onReplay: onReplayPressed,
                        onPauseResume: onPauseResumePressed,
                        onNext: state.isLastStep
                            ? onFinishPressed
                            : onNextPressed,
                        accent: accent,
                      ),
                    ),

                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        );
      },
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


class _MinimalOverlayButton extends StatelessWidget {
  const _MinimalOverlayButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
    if (onPressed == null) return button;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: button,
      ),
    );
  }
}

class _MinimalTimePill extends StatelessWidget {
  const _MinimalTimePill({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Text(
        _formatDuration(seconds),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
      ),
    );
  }
}

class _MinimalTimerBlock extends StatelessWidget {
  const _MinimalTimerBlock({
    required this.remainingSeconds,
    required this.progress,
    required this.accent,
  });

  final int remainingSeconds;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Text(
          _formatDuration(remainingSeconds),
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 72,
            height: 0.98,
            fontWeight: FontWeight.w300,
            letterSpacing: -4,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppText.get(context, key: 'player_left', fallback: 'LEFT'),
          style: theme.textTheme.labelLarge?.copyWith(
            color: accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 340,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1050),
            curve: Curves.linear,
            builder: (context, animatedProgress, _) {
              return Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: SizedBox(
                      height: 10,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fillWidth = constraints.maxWidth * animatedProgress;
                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: colors.outlineVariant.withValues(alpha: 0.26),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              Container(
                                width: fillWidth,
                                height: 5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [accent.withValues(alpha: 0.70), accent],
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.24),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              if (fillWidth > 4)
                                Positioned(
                                  left: (fillWidth - 5).clamp(0.0, constraints.maxWidth - 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: accent, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.28),
                                          blurRadius: 7,
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
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MinimalInstructionBlock extends StatelessWidget {
  const _MinimalInstructionBlock({
    required this.cue,
    required this.accent,
    required this.voiceEnabled,
    required this.onVoicePressed,
    required this.onMoreGuidance,
  });

  final String cue;
  final Color accent;
  final bool voiceEnabled;
  final VoidCallback onVoicePressed;
  final VoidCallback onMoreGuidance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Text(
          cue,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.38,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: onMoreGuidance,
              icon: const Icon(Icons.notes_rounded, size: 19),
              label: Text(AppText.get(context, key: 'player_more_guidance', fallback: 'More guidance')),
              style: FilledButton.styleFrom(
                foregroundColor: accent,
                backgroundColor: accent.withValues(alpha: 0.10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onVoicePressed,
              icon: Icon(
                voiceEnabled
                    ? Icons.graphic_eq_rounded
                    : Icons.voice_over_off_rounded,
                size: 19,
              ),
              label: Text(
                voiceEnabled
                    ? AppText.get(context, key: 'player_voice_on', fallback: 'Voice on')
                    : AppText.get(context, key: 'player_voice_off', fallback: 'Voice off'),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: voiceEnabled ? accent : colors.onSurfaceVariant,
                backgroundColor: voiceEnabled
                    ? accent.withValues(alpha: 0.10)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MinimalControlDock extends StatelessWidget {
  const _MinimalControlDock({
    required this.isPaused,
    required this.isCompleted,
    required this.canPrevious,
    required this.canReplay,
    required this.canNext,
    required this.isLastStep,
    required this.onPrevious,
    required this.onReplay,
    required this.onPauseResume,
    required this.onNext,
    required this.accent,
  });

  final bool isPaused;
  final bool isCompleted;
  final bool canPrevious;
  final bool canReplay;
  final bool canNext;
  final bool isLastStep;
  final VoidCallback onPrevious;
  final VoidCallback onReplay;
  final VoidCallback onPauseResume;
  final VoidCallback onNext;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      height: 88,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              tooltip: 'Previous step',
              onPressed: canPrevious ? onPrevious : null,
              icon: const Icon(Icons.skip_previous_rounded, size: 32),
            ),
          ),
          Expanded(
            child: IconButton(
              tooltip: 'Replay step',
              onPressed: (!isCompleted && canReplay) ? onReplay : null,
              icon: const Icon(Icons.replay_rounded, size: 30),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: IconButton(
              onPressed: isCompleted ? null : onPauseResume,
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: colors.onPrimary,
                size: 40,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: (!isCompleted && (isLastStep || canNext))
                  ? onNext
                  : null,
              icon: Icon(
                isLastStep ? Icons.check_rounded : Icons.skip_next_rounded,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> _showGlassGuidanceSheet(
  BuildContext context, {
  required String stepTitle,
  required String instruction,
  required String? coaching,
  required String? breathing,
  required String? safety,
  required String? stepGoal,
  required String? whatToNotice,
  required List<String> avoidMistakes,
  required String? coachTip,
  required Color accent,
}) async {
  final t = AppText.of(context);
  final items = <MapEntry<String, String>>[
    MapEntry(t.get('player_guidance_how_to', fallback: 'How to do it'), instruction),
    if (stepGoal != null) MapEntry(t.get('player_guidance_goal', fallback: 'Goal'), stepGoal),
    if (whatToNotice != null) MapEntry(t.get('player_guidance_notice', fallback: 'What to notice'), whatToNotice),
    if (coaching != null) MapEntry(t.get('player_guidance_coach_cue', fallback: 'Coach cue'), coaching),
    if (breathing != null) MapEntry(t.get('player_guidance_breathing', fallback: 'Breathing'), breathing),
    if (coachTip != null) MapEntry(t.get('player_guidance_coach_tip', fallback: 'Coach tip'), coachTip),
    if (safety != null) MapEntry(t.get('player_guidance_safety', fallback: 'Safety'), safety),
    if (avoidMistakes.isNotEmpty)
      MapEntry(
        t.get('player_guidance_avoid_mistakes', fallback: 'Avoid these mistakes'),
        avoidMistakes.map((item) => '• $item').join('\n'),
      ),
  ];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colors = theme.colorScheme;

      return DraggableScrollableSheet(
        initialChildSize: .58,
        minChildSize: .38,
        maxChildSize: .9,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.tune_rounded, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stepTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest
                              .withValues(alpha: .45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.key,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              item.value,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
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


Color _zoneAccentColor(ColorScheme colors, List<String> codes) {
  final normalized = codes.map((code) => code.trim().toLowerCase()).toSet();

  if (normalized.any((code) =>
      code == 'neck' || code == 'cervical' || code == 'cervical_spine')) {
    return colors.primary;
  }
  if (normalized.any((code) =>
      code == 'shoulder' ||
      code == 'shoulders' ||
      code == 'upper_back' ||
      code == 'thoracic' ||
      code == 'thoracic_spine')) {
    return colors.tertiary;
  }
  if (normalized.any((code) =>
      code == 'wrist' ||
      code == 'wrists' ||
      code == 'hand' ||
      code == 'hands' ||
      code == 'forearm' ||
      code == 'forearms' ||
      code == 'mouse_arm')) {
    return colors.secondary;
  }
  if (normalized.any((code) =>
      code == 'lower_back' ||
      code == 'lumbar' ||
      code == 'lumbar_spine' ||
      code == 'hip' ||
      code == 'hips' ||
      code == 'glute' ||
      code == 'glutes' ||
      code == 'hips_glutes')) {
    return colors.primaryContainer;
  }
  if (normalized.any((code) => code == 'eye' || code == 'eyes')) {
    return colors.secondary;
  }

  return colors.primary;
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


String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
