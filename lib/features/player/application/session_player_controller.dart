// lib/features/player/application/session_player_controller.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../sessions/application/sessions_providers.dart';
import '../../sessions/domain/session_models.dart';
import '../domain/session_feedback_models.dart';
import '../domain/session_feedback_repository.dart';
import '../domain/session_run_models.dart';
import '../domain/session_runs_repository.dart';
import '../domain/session_step_event_models.dart';
import '../domain/session_step_events_repository.dart';
import 'session_player_state.dart';
import '../../access/application/access_providers.dart';
import '../../access/domain/access_models.dart';
import '../../access/domain/access_policy.dart';

class SessionPlayerController extends ChangeNotifier {
  SessionPlayerController({
    required Ref ref,
    required String sessionId,
    required SessionRunsRepository runsRepository,
    required SessionFeedbackRepository feedbackRepository,
    required SessionStepEventsRepository stepEventsRepository,
    SessionEntrySource entrySource = SessionEntrySource.sessionDetail,
  })  : _ref = ref,
        _sessionId = sessionId,
        _runsRepository = runsRepository,
        _feedbackRepository = feedbackRepository,
        _stepEventsRepository = stepEventsRepository,
        _entrySource = entrySource {
    _init();
  }

  final Ref _ref;
  final String _sessionId;
  final SessionRunsRepository _runsRepository;
  final SessionFeedbackRepository _feedbackRepository;
  final SessionStepEventsRepository _stepEventsRepository;
  final SessionEntrySource _entrySource;

  SessionPlayerState _state = const SessionPlayerState();
  SessionPlayerState get state => _state;

  Timer? _ticker;
  bool _runFinalized = false;

  void _setState(SessionPlayerState value) {
    _state = value;
    notifyListeners();
  }

  int _elapsedBeforeStepIndex(int stepIndex) {
    if (_state.steps.isEmpty || stepIndex <= 0) return 0;

    final safeIndex = stepIndex.clamp(0, _state.steps.length);
    var total = 0;
    for (var i = 0; i < safeIndex; i++) {
      total += _state.steps[i].durationSeconds;
    }
    return total;
  }

  int _resolveResumedStepIndex(SessionDetail detail, SessionRun run) {
    final completedSteps = run.completedSteps.clamp(0, detail.steps.length);

    if (completedSteps >= detail.steps.length) {
      return detail.steps.length - 1;
    }

    if (completedSteps < 0) return 0;
    return completedSteps;
  }

  int _resolveResumedTotalElapsed(SessionDetail detail, SessionRun run) {
    final stepIndex = _resolveResumedStepIndex(detail, run);
    final derived = _elapsedBeforeSteps(detail.steps, stepIndex);
    return derived > 0 ? derived : run.totalElapsedSeconds;
  }

  int _elapsedBeforeSteps(List<SessionStep> steps, int stepIndex) {
    if (steps.isEmpty || stepIndex <= 0) return 0;
    final safeIndex = stepIndex.clamp(0, steps.length);
    var total = 0;
    for (var i = 0; i < safeIndex; i++) {
      total += steps[i].durationSeconds;
    }
    return total;
  }

  Future<void> _persistProgressIfNeeded() async {
    if (_state.runId == null || _state.currentStep == null || _runFinalized) return;

    try {
      await _runsRepository.updateRunProgress(
        runId: _state.runId!,
        completedSteps: _state.completedStepsCount,
        totalElapsedSeconds: _state.totalElapsedSeconds,
        lastStepId: _state.currentStep?.id,
      );
    } catch (_) {
      // Non-blocking.
    }
  }

  Future<void> _trackStepEvent({
    required SessionStepEventType eventType,
    SessionStep? step,
    int? stepIndex,
    int? stepElapsedSeconds,
    int? totalElapsedSeconds,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final runId = _state.runId;
    final session = _state.session;
    final targetStep = step ?? _state.currentStep;

    if (runId == null || session == null || targetStep == null) return;

    try {
      await _stepEventsRepository.trackEvent(
        input: SessionStepEventInput(
          runId: runId,
          sessionId: session.summary.id,
          stepId: targetStep.id,
          stepIndex: stepIndex ?? _state.currentStepIndex,
          eventType: eventType,
          stepElapsedSeconds:
              (stepElapsedSeconds ?? _state.currentStepElapsedSeconds).clamp(
            0,
            1 << 30,
          ),
          totalElapsedSeconds:
              (totalElapsedSeconds ?? _state.totalElapsedSeconds).clamp(
            0,
            1 << 30,
          ),
          metadata: metadata,
        ),
      );
    } catch (_) {
      // Non-blocking analytics/persistence trail.
    }
  }

  Future<void> _init() async {
  _ticker?.cancel();
  _ticker = null;
  _runFinalized = false;

  _setState(
    _state.copyWith(
      isLoading: true,
      isStartingRun: false,
      isSavingExit: false,
      isSubmittingPreSessionState: false,
      isSubmittingFeedback: false,
      clearErrorMessage: true,
      authRequired: false,
      accessLocked: false,
      notFound: false,
      hasNoSteps: false,
      isCompleted: false,
      isRunning: false,
      isPaused: false,
      currentStepIndex: 0,
      currentStepElapsedSeconds: 0,
      totalElapsedSeconds: 0,
      resumedRun: false,
      requiresPreSessionCapture: false,
      preSessionCaptureCompleted: false,
      feedbackSubmitted: false,
      entrySource: _entrySource,
      clearRunId: true,
    ),
  );

  try {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      _setState(
        _state.copyWith(
          isLoading: false,
          authRequired: true,
        ),
      );
      return;
    }

    final detail = await _ref.read(sessionDetailProvider(_sessionId).future);

    if (detail == null) {
      _setState(
        _state.copyWith(
          isLoading: false,
          notFound: true,
        ),
      );
      return;
    }

    if (detail.steps.isEmpty) {
      _setState(
        _state.copyWith(
          isLoading: false,
          session: detail,
          hasNoSteps: true,
          entrySource: _entrySource,
        ),
      );
      return;
    }

    final latestActiveRun = await _runsRepository.getLatestActiveRun();
    if (latestActiveRun != null && latestActiveRun.sessionId == _sessionId) {
      final resumedStepIndex =
          _resolveResumedStepIndex(detail, latestActiveRun);
      final resumedElapsed =
          _resolveResumedTotalElapsed(detail, latestActiveRun);

      _setState(
        _state.copyWith(
          isLoading: false,
          session: detail,
          runId: latestActiveRun.id,
          resumedRun: true,
          isRunning: true,
          isPaused: false,
          accessLocked: false,
          requiresPreSessionCapture: false,
          preSessionCaptureCompleted: true,
          currentStepIndex: resumedStepIndex,
          currentStepElapsedSeconds: 0,
          totalElapsedSeconds: resumedElapsed,
          entrySource: latestActiveRun.entrySource,
        ),
      );

      _startTicker();
      return;
    }

    final runs = await _runsRepository.getRunsBySessionId(_sessionId, limit: 8);
    SessionRun? resumableRun;
    for (final run in runs) {
      final isResumable = run.status == SessionRunStatus.abandoned &&
          run.completedSteps > 0 &&
          run.completedSteps < run.totalSteps;
      if (isResumable) {
        resumableRun = run;
        break;
      }
    }

    if (resumableRun != null) {
      final resumedStepIndex = _resolveResumedStepIndex(detail, resumableRun);
      final resumedElapsed = _resolveResumedTotalElapsed(detail, resumableRun);

      _setState(
        _state.copyWith(
          isLoading: false,
          session: detail,
          runId: resumableRun.id,
          resumedRun: true,
          isRunning: true,
          isPaused: false,
          accessLocked: false,
          requiresPreSessionCapture: false,
          preSessionCaptureCompleted: true,
          currentStepIndex: resumedStepIndex,
          currentStepElapsedSeconds: 0,
          totalElapsedSeconds: resumedElapsed,
          entrySource: resumableRun.entrySource,
        ),
      );

      _startTicker();
      return;
    }

    final accessSnapshot = await _ref.read(accessSnapshotProvider.future);
    final accessDecision = AccessPolicy.canAccessTier(
      snapshot: accessSnapshot,
      tier: detail.summary.accessTier,
      feature: LockedFeature.sessionPlayer,
    );

    if (!accessDecision.allowed) {
      _setState(
        _state.copyWith(
          isLoading: false,
          session: detail,
          accessLocked: true,
          isRunning: false,
          isPaused: false,
          requiresPreSessionCapture: false,
          preSessionCaptureCompleted: false,
          entrySource: _entrySource,
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        isLoading: false,
        session: detail,
        accessLocked: false,
        requiresPreSessionCapture: true,
        entrySource: _entrySource,
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('SessionPlayerController._init failed: $error');
    debugPrintStack(stackTrace: stackTrace);

    _setState(
      _state.copyWith(
        isLoading: false,
        isStartingRun: false,
        errorMessage: 'Could not start this session.',
      ),
    );
  }
}

  Future<void> startRunWithPreSessionState(
    SessionStateSnapshotInput input,
  ) async {
    if (_state.session == null || _state.runId != null) return;

    _setState(
      _state.copyWith(
        isStartingRun: true,
        isSubmittingPreSessionState: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final firstStep = _state.session!.steps.first;

      final runId = await _runsRepository.startRun(
        sessionId: _state.session!.summary.id,
        totalSteps: _state.session!.steps.length,
        firstStepId: firstStep.id,
        entrySource: _entrySource,
      );

      final snapshotInput = SessionStateSnapshotInput(
        energyLevel: input.energyLevel,
        stressLevel: input.stressLevel,
        focusLevel: input.focusLevel,
        painAreaCodes: input.painAreaCodes,
        intentCode: input.intentCode,
        entrySource: _entrySource,
      );

      await _feedbackRepository.saveBeforeStateSnapshot(
        runId: runId,
        sessionId: _state.session!.summary.id,
        input: snapshotInput,
      );

      _setState(
        _state.copyWith(
          runId: runId,
          resumedRun: false,
          isStartingRun: false,
          isSubmittingPreSessionState: false,
          isRunning: true,
          isPaused: false,
          currentStepIndex: 0,
          currentStepElapsedSeconds: 0,
          totalElapsedSeconds: 0,
          requiresPreSessionCapture: false,
          preSessionCaptureCompleted: true,
          entrySource: _entrySource,
        ),
      );

      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepStarted,
          step: firstStep,
          stepIndex: 0,
          stepElapsedSeconds: 0,
          totalElapsedSeconds: 0,
          metadata: {
            'entry_source': _entrySource.dbValue,
            'pre_session_capture_completed': true,
          },
        ),
      );

      _startTicker();
    } catch (error, stackTrace) {
      debugPrint('startRunWithPreSessionState failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _setState(
        _state.copyWith(
          isStartingRun: false,
          isSubmittingPreSessionState: false,
          errorMessage: 'Could not save your session state and start the run.',
        ),
      );
    }
  }

  Future<void> skipPreSessionCapture() async {
    if (_state.session == null || _state.runId != null) return;

    _setState(
      _state.copyWith(
        isStartingRun: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final firstStep = _state.session!.steps.first;

      final runId = await _runsRepository.startRun(
        sessionId: _state.session!.summary.id,
        totalSteps: _state.session!.steps.length,
        firstStepId: firstStep.id,
        entrySource: _entrySource,
      );

      _setState(
        _state.copyWith(
          runId: runId,
          resumedRun: false,
          isStartingRun: false,
          isRunning: true,
          isPaused: false,
          currentStepIndex: 0,
          currentStepElapsedSeconds: 0,
          totalElapsedSeconds: 0,
          requiresPreSessionCapture: false,
          preSessionCaptureCompleted: false,
          entrySource: _entrySource,
        ),
      );

      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepStarted,
          step: firstStep,
          stepIndex: 0,
          stepElapsedSeconds: 0,
          totalElapsedSeconds: 0,
          metadata: {
            'entry_source': _entrySource.dbValue,
            'pre_session_capture_completed': false,
          },
        ),
      );

      _startTicker();
    } catch (error, stackTrace) {
      debugPrint('skipPreSessionCapture failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _setState(
        _state.copyWith(
          isStartingRun: false,
          errorMessage: 'Could not start this session.',
        ),
      );
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleTick();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _handleTick() {
    if (_state.isLoading ||
        _state.isPaused ||
        _state.isCompleted ||
        !_state.isRunning ||
        _state.currentStep == null) {
      return;
    }

    final currentStep = _state.currentStep!;
    final nextStepElapsed = _state.currentStepElapsedSeconds + 1;
    final nextTotalElapsed = _state.totalElapsedSeconds + 1;

    if (nextStepElapsed >= currentStep.durationSeconds) {
      if (_state.isLastStep) {
        _setState(
          _state.copyWith(
            currentStepElapsedSeconds: currentStep.durationSeconds,
            totalElapsedSeconds: _state.totalSessionDurationSeconds,
          ),
        );
        unawaited(completeSession());
        return;
      }

      final nextIndex = _state.currentStepIndex + 1;
      final nextStep = _state.steps[nextIndex];
      final nextStepTotalElapsed = _elapsedBeforeStepIndex(nextIndex);

      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepCompleted,
          step: currentStep,
          stepIndex: _state.currentStepIndex,
          stepElapsedSeconds: currentStep.durationSeconds,
          totalElapsedSeconds: nextStepTotalElapsed,
          metadata: const {
            'transition': 'auto',
          },
        ),
      );

      _setState(
        _state.copyWith(
          currentStepIndex: nextIndex,
          currentStepElapsedSeconds: 0,
          totalElapsedSeconds: nextStepTotalElapsed,
        ),
      );

      unawaited(_persistProgressIfNeeded());

      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepStarted,
          step: nextStep,
          stepIndex: nextIndex,
          stepElapsedSeconds: 0,
          totalElapsedSeconds: nextStepTotalElapsed,
          metadata: const {
            'transition': 'auto',
          },
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        currentStepElapsedSeconds: nextStepElapsed,
        totalElapsedSeconds: nextTotalElapsed,
      ),
    );
  }

  void pause() {
    if (!_state.isRunning || _state.isCompleted) return;

    unawaited(_persistProgressIfNeeded());

    unawaited(
      _trackStepEvent(
        eventType: SessionStepEventType.playerPaused,
      ),
    );

    _setState(
      _state.copyWith(
        isPaused: true,
        isRunning: false,
      ),
    );
    _stopTicker();
  }

  void resume() {
    if (_state.isCompleted || _state.currentStep == null || _state.runId == null) {
      return;
    }

    _setState(
      _state.copyWith(
        isPaused: false,
        isRunning: true,
      ),
    );

    unawaited(
      _trackStepEvent(
        eventType: SessionStepEventType.playerResumed,
      ),
    );

    _startTicker();
  }

  void togglePause() {
    if (_state.isPaused) {
      resume();
    } else {
      pause();
    }
  }

  void previousStep() {
    if (!_state.canGoPrevious) return;

    final sourceStep = _state.currentStep;
    final sourceIndex = _state.currentStepIndex;
    final targetIndex = _state.currentStepIndex - 1;
    final targetStep = _state.steps[targetIndex];
    final targetTotalElapsed = _elapsedBeforeStepIndex(targetIndex);

    if (sourceStep != null) {
      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepPrevious,
          step: sourceStep,
          stepIndex: sourceIndex,
          metadata: {
            'target_step_id': targetStep.id,
            'target_step_index': targetIndex,
          },
        ),
      );
    }

    _setState(
      _state.copyWith(
        currentStepIndex: targetIndex,
        currentStepElapsedSeconds: 0,
        totalElapsedSeconds: targetTotalElapsed,
      ),
    );

    unawaited(_persistProgressIfNeeded());

    unawaited(
      _trackStepEvent(
        eventType: SessionStepEventType.stepStarted,
        step: targetStep,
        stepIndex: targetIndex,
        stepElapsedSeconds: 0,
        totalElapsedSeconds: targetTotalElapsed,
        metadata: const {
          'transition': 'previous',
        },
      ),
    );
  }

  void nextStep() {
    if (!_state.canGoNext) return;

    if (_state.isLastStep) {
      _setState(
        _state.copyWith(
          currentStepElapsedSeconds: _state.currentStepDurationSeconds,
          totalElapsedSeconds: _state.totalSessionDurationSeconds,
        ),
      );
      unawaited(completeSession());
      return;
    }

    final sourceStep = _state.currentStep;
    final sourceIndex = _state.currentStepIndex;
    final targetIndex = _state.currentStepIndex + 1;
    final targetStep = _state.steps[targetIndex];
    final targetTotalElapsed = _elapsedBeforeStepIndex(targetIndex);

    if (sourceStep != null) {
      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepNext,
          step: sourceStep,
          stepIndex: sourceIndex,
          metadata: {
            'target_step_id': targetStep.id,
            'target_step_index': targetIndex,
          },
        ),
      );
    }

    _setState(
      _state.copyWith(
        currentStepIndex: targetIndex,
        currentStepElapsedSeconds: 0,
        totalElapsedSeconds: targetTotalElapsed,
      ),
    );

    unawaited(_persistProgressIfNeeded());

    unawaited(
      _trackStepEvent(
        eventType: SessionStepEventType.stepStarted,
        step: targetStep,
        stepIndex: targetIndex,
        stepElapsedSeconds: 0,
        totalElapsedSeconds: targetTotalElapsed,
        metadata: const {
          'transition': 'next',
        },
      ),
    );
  }

  void skipStep() {
    if (!_state.canSkipCurrentStep) return;

    final sourceStep = _state.currentStep;
    final sourceIndex = _state.currentStepIndex;

    if (sourceStep != null) {
      final targetIndex =
          _state.isLastStep ? _state.currentStepIndex : _state.currentStepIndex + 1;
      final targetStepId =
          _state.isLastStep ? null : _state.steps[targetIndex].id;

      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepSkipped,
          step: sourceStep,
          stepIndex: sourceIndex,
          metadata: {
            'target_step_id': targetStepId,
            'target_step_index': targetIndex,
          },
        ),
      );
    }

    nextStep();
  }

  void replayStep() {
    if (!_state.canReplay) return;

    final currentStep = _state.currentStep;
    if (currentStep != null) {
      unawaited(
        _trackStepEvent(
          eventType: SessionStepEventType.stepReplayed,
          step: currentStep,
          stepIndex: _state.currentStepIndex,
        ),
      );
    }

    _setState(
      _state.copyWith(
        currentStepElapsedSeconds: 0,
        totalElapsedSeconds: _elapsedBeforeStepIndex(_state.currentStepIndex),
      ),
    );

    unawaited(_persistProgressIfNeeded());
  }

  Future<void> completeSession() async {
    if (_runFinalized || _state.runId == null || _state.isCompleted) return;

    _runFinalized = true;
    _stopTicker();

    try {
      await _runsRepository.completeRun(
        runId: _state.runId!,
        completedSteps: _state.totalSteps,
        totalElapsedSeconds: _state.totalSessionDurationSeconds,
        lastStepId: _state.currentStep?.id,
      );

      final completedStep = _state.currentStep;
      final completedStepDuration = completedStep?.durationSeconds ?? 0;

      _setState(
        _state.copyWith(
          isCompleted: true,
          isRunning: false,
          isPaused: false,
          currentStepIndex: _state.totalSteps > 0 ? _state.totalSteps - 1 : 0,
          currentStepElapsedSeconds: completedStepDuration,
          totalElapsedSeconds: _state.totalSessionDurationSeconds,
        ),
      );

      if (completedStep != null) {
        unawaited(
          _trackStepEvent(
            eventType: SessionStepEventType.stepCompleted,
            step: completedStep,
            stepIndex: _state.currentStepIndex,
            stepElapsedSeconds: completedStepDuration,
            totalElapsedSeconds: _state.totalSessionDurationSeconds,
            metadata: const {
              'transition': 'session_complete',
            },
          ),
        );

        unawaited(
          _trackStepEvent(
            eventType: SessionStepEventType.sessionCompleted,
            step: completedStep,
            stepIndex: _state.currentStepIndex,
            stepElapsedSeconds: completedStepDuration,
            totalElapsedSeconds: _state.totalSessionDurationSeconds,
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('completeSession failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _runFinalized = false;
      _setState(
        _state.copyWith(
          errorMessage: 'Could not complete this session.',
        ),
      );
    }
  }

  Future<void> submitPostSessionResult(PlayerPostSessionResult result) async {
    if (_state.runId == null || _state.session == null || _state.feedbackSubmitted) {
      return;
    }

    _setState(
      _state.copyWith(
        isSubmittingFeedback: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final feedbackInput = SessionFeedbackInput(
        completionStatus: result.feedback.completionStatus,
        helped: result.feedback.helped,
        tensionDelta: result.feedback.tensionDelta,
        painDelta: result.feedback.painDelta,
        energyDelta: result.feedback.energyDelta,
        perceivedFit: result.feedback.perceivedFit,
        wouldRepeat: result.feedback.wouldRepeat,
        entrySource: _state.entrySource,
      );

      final afterStateInput = SessionStateSnapshotInput(
        energyLevel: result.afterState.energyLevel,
        stressLevel: result.afterState.stressLevel,
        focusLevel: result.afterState.focusLevel,
        painAreaCodes: result.afterState.painAreaCodes,
        intentCode: result.afterState.intentCode,
        entrySource: _state.entrySource,
      );

      await _feedbackRepository.saveFeedback(
        runId: _state.runId!,
        sessionId: _state.session!.summary.id,
        input: feedbackInput,
      );

      await _feedbackRepository.saveAfterStateSnapshot(
        runId: _state.runId!,
        sessionId: _state.session!.summary.id,
        input: afterStateInput,
      );

      _setState(
        _state.copyWith(
          isSubmittingFeedback: false,
          feedbackSubmitted: true,
          entrySource: _state.entrySource,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('submitPostSessionResult failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _setState(
        _state.copyWith(
          isSubmittingFeedback: false,
          errorMessage: 'Could not save your feedback.',
        ),
      );
    }
  }

  Future<void> abandonSession({
    required String exitReason,
  }) async {
    if (_runFinalized || _state.runId == null) return;

    _runFinalized = true;
    _stopTicker();

    _setState(_state.copyWith(isSavingExit: true));

    try {
      await _runsRepository.abandonRun(
        runId: _state.runId!,
        completedSteps: _state.completedStepsCount,
        totalElapsedSeconds: _state.totalElapsedSeconds,
        lastStepId: _state.currentStep?.id,
        exitReason: exitReason,
      );

      final currentStep = _state.currentStep;
      if (currentStep != null) {
        unawaited(
          _trackStepEvent(
            eventType: SessionStepEventType.sessionAbandoned,
            step: currentStep,
            stepIndex: _state.currentStepIndex,
            metadata: {
              'exit_reason': exitReason,
            },
          ),
        );
      }

      _setState(
        _state.copyWith(
          isSavingExit: false,
          isRunning: false,
          isPaused: false,
          entrySource: _state.entrySource,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('abandonSession failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _runFinalized = false;
      _setState(
        _state.copyWith(
          isSavingExit: false,
          errorMessage: 'Could not save session exit.',
        ),
      );
    }
  }

  Future<void> restart() async {
    await _init();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}