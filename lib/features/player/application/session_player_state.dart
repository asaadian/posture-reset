// lib/features/player/application/session_player_state.dart

import '../../sessions/domain/session_models.dart';
import '../domain/session_feedback_models.dart';

class SessionPlayerState {
  const SessionPlayerState({
    this.isLoading = true,
    this.isStartingRun = false,
    this.isSavingExit = false,
    this.isSubmittingPreSessionState = false,
    this.isSubmittingFeedback = false,
    this.errorMessage,
    this.session,
    this.runId,
    this.resumedRun = false,
    this.currentStepIndex = 0,
    this.currentStepElapsedSeconds = 0,
    this.totalElapsedSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.isCompleted = false,
    this.authRequired = false,
    this.accessLocked = false,
    this.notFound = false,
    this.hasNoSteps = false,
    this.requiresPreSessionCapture = false,
    this.preSessionCaptureCompleted = false,
    this.feedbackSubmitted = false,
    this.entrySource = SessionEntrySource.sessionDetail,
  });

  final bool isLoading;
  final bool isStartingRun;
  final bool isSavingExit;
  final bool isSubmittingPreSessionState;
  final bool isSubmittingFeedback;
  final String? errorMessage;
  final SessionDetail? session;
  final String? runId;
  final bool resumedRun;
  final int currentStepIndex;
  final int currentStepElapsedSeconds;
  final int totalElapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final bool authRequired;
  final bool accessLocked;
  final bool notFound;
  final bool hasNoSteps;
  final bool requiresPreSessionCapture;
  final bool preSessionCaptureCompleted;
  final bool feedbackSubmitted;
  final SessionEntrySource entrySource;

  SessionPlayerState copyWith({
    bool? isLoading,
    bool? isStartingRun,
    bool? isSavingExit,
    bool? isSubmittingPreSessionState,
    bool? isSubmittingFeedback,
    String? errorMessage,
    bool clearErrorMessage = false,
    SessionDetail? session,
    String? runId,
    bool clearRunId = false,
    bool? resumedRun,
    int? currentStepIndex,
    int? currentStepElapsedSeconds,
    int? totalElapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    bool? authRequired,
    bool? accessLocked,
    bool? notFound,
    bool? hasNoSteps,
    bool? requiresPreSessionCapture,
    bool? preSessionCaptureCompleted,
    bool? feedbackSubmitted,
    SessionEntrySource? entrySource,
  }) {
    return SessionPlayerState(
      isLoading: isLoading ?? this.isLoading,
      isStartingRun: isStartingRun ?? this.isStartingRun,
      isSavingExit: isSavingExit ?? this.isSavingExit,
      isSubmittingPreSessionState:
          isSubmittingPreSessionState ?? this.isSubmittingPreSessionState,
      isSubmittingFeedback:
          isSubmittingFeedback ?? this.isSubmittingFeedback,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      session: session ?? this.session,
      runId: clearRunId ? null : (runId ?? this.runId),
      resumedRun: resumedRun ?? this.resumedRun,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentStepElapsedSeconds:
          currentStepElapsedSeconds ?? this.currentStepElapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      authRequired: authRequired ?? this.authRequired,
      accessLocked: accessLocked ?? this.accessLocked,
      notFound: notFound ?? this.notFound,
      hasNoSteps: hasNoSteps ?? this.hasNoSteps,
      requiresPreSessionCapture:
          requiresPreSessionCapture ?? this.requiresPreSessionCapture,
      preSessionCaptureCompleted:
          preSessionCaptureCompleted ?? this.preSessionCaptureCompleted,
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
      entrySource: entrySource ?? this.entrySource,
    );
  }

  List<SessionStep> get steps => session?.steps ?? const <SessionStep>[];

  bool get hasSession => session != null;

  bool get canRenderPlayer =>
      hasSession &&
      !authRequired &&
      !accessLocked &&
      !notFound &&
      !hasNoSteps;

  int get totalSteps => steps.length;

  SessionStep? get currentStep {
    if (steps.isEmpty) return null;
    if (currentStepIndex < 0 || currentStepIndex >= steps.length) return null;
    return steps[currentStepIndex];
  }

  SessionStep? get nextStep {
    final nextIndex = currentStepIndex + 1;
    if (nextIndex < 0 || nextIndex >= steps.length) return null;
    return steps[nextIndex];
  }

  int get currentStepDurationSeconds => currentStep?.durationSeconds ?? 0;

  int get totalSessionDurationSeconds {
    return steps.fold<int>(0, (sum, step) => sum + step.durationSeconds);
  }

  int get remainingCurrentStepSeconds {
    final remaining = currentStepDurationSeconds - currentStepElapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  int get remainingSessionSeconds {
    final remaining = totalSessionDurationSeconds - totalElapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    final total = totalSessionDurationSeconds;
    if (total <= 0) return 0;
    final raw = totalElapsedSeconds / total;
    return raw.clamp(0.0, 1.0);
  }

  bool get isLastStep => currentStepIndex >= totalSteps - 1;

  bool get canGoPrevious =>
      !isLoading &&
      !isCompleted &&
      !accessLocked &&
      currentStepIndex > 0 &&
      runId != null;

  bool get canGoNext =>
      !isLoading &&
      !isCompleted &&
      !accessLocked &&
      totalSteps > 0 &&
      runId != null;

  bool get canReplay =>
      !isLoading &&
      !isCompleted &&
      !accessLocked &&
      currentStep != null &&
      runId != null;

  bool get canSkipCurrentStep {
    final step = currentStep;
    if (step == null ||
        isCompleted ||
        isLoading ||
        accessLocked ||
        runId == null) {
      return false;
    }
    return step.isSkippable;
  }

  int get completedStepsCount {
    if (isCompleted) return totalSteps;
    return currentStepIndex.clamp(0, totalSteps);
  }
}