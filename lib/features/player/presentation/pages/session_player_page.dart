// lib/features/player/presentation/pages/session_player_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../sessions/domain/session_models.dart';
import '../../application/player_providers.dart';
import '../../application/session_player_controller.dart';
import '../../application/session_player_state.dart';
import '../../domain/session_feedback_models.dart';
import '../widgets/player_control_panel.dart';
import '../widgets/player_current_step_card.dart';
import '../widgets/player_feedback_sheet.dart';
import '../widgets/player_media_zone.dart';
import '../widgets/player_progress_card.dart';
import '../widgets/player_top_bar.dart';

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
  String? _preSessionSheetShownForSessionId;
  String? _feedbackSheetShownForRunId;

  SessionPlayerArgs get _playerArgs => SessionPlayerArgs(
        sessionId: widget.sessionId,
        entrySource: widget.entrySource,
      );

  Future<void> showPreSessionSheetIfNeeded(
    SessionPlayerState state,
  ) async {
    if (!mounted ||
        !state.canRenderPlayer ||
        state.session == null ||
        !state.requiresPreSessionCapture ||
        state.runId != null ||
        state.resumedRun) {
      return;
    }

    final sessionId = state.session!.summary.id;
    if (_preSessionSheetShownForSessionId == sessionId) {
      return;
    }

    _preSessionSheetShownForSessionId = sessionId;

    final controller = ref.read(sessionPlayerControllerProvider(_playerArgs));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return PlayerPreSessionStateSheet(
          initialEntrySource: widget.entrySource,
          onSubmit: controller.startRunWithPreSessionState,
        );
      },
    );

    if (!mounted) return;

    final refreshed =
        ref.read(sessionPlayerControllerProvider(_playerArgs)).state;

    if (refreshed.runId == null && refreshed.requiresPreSessionCapture) {
      await controller.skipPreSessionCapture();
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

    if (_feedbackSheetShownForRunId == state.runId) {
      return;
    }

    _feedbackSheetShownForRunId = state.runId;

    final controller = ref.read(sessionPlayerControllerProvider(_playerArgs));

    final sessionTitle = AppText.get(
      context,
      key: state.session!.summary.titleKey,
      fallback: state.session!.summary.titleFallback,
    );

    await showModalBottomSheet<void>(
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
          onSubmit: controller.submitPostSessionResult,
        );
      },
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
    if (state.isLoading || state.isSavingExit) {
      return false;
    }

    if (state.isCompleted || state.runId == null) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            final t = AppText.of(dialogContext);

            return AlertDialog(
              title: Text(
                t.get(
                  'player_exit_title',
                  fallback: 'End session?',
                ),
              ),
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
                    t.get(
                      'player_exit_cancel_cta',
                      fallback: 'Keep session',
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    t.get(
                      'player_exit_confirm_cta',
                      fallback: 'End session',
                    ),
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

      await showModalBottomSheet<void>(
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
            onSubmit: controller.submitPostSessionResult,
          );
        },
      );
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
          final sectionGap = pageInfo.isCompact ? 14.0 : 18.0;

          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              if (state.canRenderPlayer && state.session != null)
                PlayerTopBar(
                  sessionTitle: AppText.get(
                    context,
                    key: state.session!.summary.titleKey,
                    fallback: state.session!.summary.titleFallback,
                  ),
                  stepLabel: state.isCompleted
                      ? t.get('player_status_completed', fallback: 'Completed')
                      : '${t.get('player_step_label_prefix', fallback: 'Step')} ${state.currentStepIndex + 1} / ${state.totalSteps}',
                  isCompleted: state.isCompleted,
                  onClosePressed: () async {
                    final canExit = await handleExit(state, controller);
                    if (!mounted || !canExit) return;
                    safeBackToDetailOrSessions();
                  },
                ),
              if (state.canRenderPlayer && state.session != null)
                SizedBox(height: sectionGap),
              if (state.isLoading || state.isStartingRun)
                const _PlayerLoadingView()
              else if (state.authRequired)
                _PlayerAuthRequiredView(sessionId: widget.sessionId)
              else if (state.accessLocked)
                _PlayerErrorView(
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
                  primaryLabel: t.get(
                    'access_unlock_core_cta',
                    fallback: 'Unlock Core',
                  ),
                )
              else if (state.notFound)
                _PlayerErrorView(
                  title: t.get(
                    'player_not_found_title',
                    fallback: 'Session not found',
                  ),
                  message: t.get(
                    'player_not_found_message',
                    fallback:
                        'The requested session could not be found or is no longer available.',
                  ),
                  onPrimaryPressed: safeBackToDetailOrSessions,
                  primaryLabel: t.get(
                    'player_back_cta',
                    fallback: 'Back',
                  ),
                )
              else if (state.hasNoSteps)
                _PlayerErrorView(
                  title: t.get(
                    'player_no_steps_title',
                    fallback: 'No steps available',
                  ),
                  message: t.get(
                    'player_no_steps_message',
                    fallback:
                        'This session does not contain any playable steps yet.',
                  ),
                  onPrimaryPressed: safeBackToDetailOrSessions,
                  primaryLabel: t.get(
                    'player_back_cta',
                    fallback: 'Back',
                  ),
                )
              else if (state.errorMessage != null && !state.canRenderPlayer)
                _PlayerErrorView(
                  title: t.get(
                    'player_error_title',
                    fallback: 'Could not start player',
                  ),
                  message: state.errorMessage!,
                  onPrimaryPressed: controller.restart,
                  primaryLabel: t.commonRetry,
                )
              else if (state.session == null || state.currentStep == null)
                _PlayerErrorView(
                  title: t.get(
                    'player_error_title',
                    fallback: 'Could not start player',
                  ),
                  message: t.get(
                    'player_error_subtitle',
                    fallback: 'Something went wrong while loading this session.',
                  ),
                  onPrimaryPressed: controller.restart,
                  primaryLabel: t.commonRetry,
                )
              else
                _PlayerMainColumn(
                  state: state,
                  onPauseResumePressed: controller.togglePause,
                  onPreviousPressed: controller.previousStep,
                  onNextPressed: controller.nextStep,
                  onSkipPressed: controller.skipStep,
                  onReplayPressed: controller.replayStep,
                  onFinishPressed: controller.completeSession,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerMainColumn extends StatelessWidget {
  const _PlayerMainColumn({
    required this.state,
    required this.onPauseResumePressed,
    required this.onPreviousPressed,
    required this.onNextPressed,
    required this.onSkipPressed,
    required this.onReplayPressed,
    required this.onFinishPressed,
  });

  final SessionPlayerState state;
  final VoidCallback onPauseResumePressed;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback onReplayPressed;
  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final step = state.currentStep!;
    final stepTypeLabel = _stepTypeLabel(context, step.stepType);

    final hasBreathing =
        (step.breathingCueKey?.isNotEmpty ?? false) ||
        (step.breathingCueFallback?.isNotEmpty ?? false);

    final hasSafety =
        (step.safetyNoteKey?.isNotEmpty ?? false) ||
        (step.safetyNoteFallback?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerMediaZone(
          stepTitle: AppText.get(
            context,
            key: step.titleKey,
            fallback: step.titleFallback,
          ),
          stepTypeLabel: stepTypeLabel,
        ),
        const SizedBox(height: 14),
        PlayerProgressCard(
          progress: state.progress,
          currentStepIndex: state.currentStepIndex,
          totalSteps: state.totalSteps,
          totalElapsedSeconds: state.totalElapsedSeconds,
          totalRemainingSeconds: state.remainingSessionSeconds,
          currentStepRemainingSeconds: state.remainingCurrentStepSeconds,
        ),
        const SizedBox(height: 14),
        PlayerControlPanel(
          isPaused: state.isPaused,
          isCompleted: state.isCompleted,
          canGoPrevious: state.canGoPrevious,
          canGoNext: state.canGoNext,
          canSkip: state.canSkipCurrentStep,
          canReplay: state.canReplay,
          onPreviousPressed: onPreviousPressed,
          onPauseResumePressed: onPauseResumePressed,
          onNextPressed: onNextPressed,
          onSkipPressed: onSkipPressed,
          onReplayPressed: onReplayPressed,
          onFinishPressed: onFinishPressed,
        ),
        const SizedBox(height: 14),
        PlayerCurrentStepCard(
          stepLabel:
              '${t.get('player_current_step_label', fallback: 'Current Step')} ${state.currentStepIndex + 1}',
          stepTitle: AppText.get(
            context,
            key: step.titleKey,
            fallback: step.titleFallback,
          ),
          stepInstruction: AppText.get(
            context,
            key: step.instructionKey,
            fallback: step.instructionFallback,
          ),
          stepTypeLabel: stepTypeLabel,
          durationSeconds: step.durationSeconds,
          bodyTargetCodes: step.bodyTargetCodes,
          isSkippable: step.isSkippable,
        ),
        if (hasBreathing || hasSafety) ...[
          const SizedBox(height: 14),
          _CompactPlayerNotes(
            breathingText: hasBreathing
                ? AppText.get(
                    context,
                    key: step.breathingCueKey ?? '',
                    fallback: step.breathingCueFallback ?? '',
                  )
                : null,
            safetyText: hasSafety
                ? AppText.get(
                    context,
                    key: step.safetyNoteKey ?? '',
                    fallback: step.safetyNoteFallback ?? '',
                  )
                : null,
          ),
        ],
      ],
    );
  }
}

class _CompactPlayerNotes extends StatelessWidget {
  const _CompactPlayerNotes({
    required this.breathingText,
    required this.safetyText,
  });

  final String? breathingText;
  final String? safetyText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            if (breathingText != null && breathingText!.trim().isNotEmpty)
              _CompactPlayerNoteRow(
                icon: Icons.air,
                title: AppText.get(
                  context,
                  key: 'player_breath_cue_title',
                  fallback: 'Breathing Cue',
                ),
                body: breathingText!,
              ),
            if (breathingText != null &&
                breathingText!.trim().isNotEmpty &&
                safetyText != null &&
                safetyText!.trim().isNotEmpty)
              const SizedBox(height: 10),
            if (safetyText != null && safetyText!.trim().isNotEmpty)
              _CompactPlayerNoteRow(
                icon: Icons.health_and_safety_outlined,
                title: AppText.get(
                  context,
                  key: 'player_safety_note_title',
                  fallback: 'Safety Note',
                ),
                body: safetyText!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactPlayerNoteRow extends StatelessWidget {
  const _CompactPlayerNoteRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(body),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerLoadingView extends StatelessWidget {
  const _PlayerLoadingView();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              t.get('player_loading_title', fallback: 'Preparing player...'),
            ),
          ],
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

    if (isAuthenticated) {
      return const SizedBox.shrink();
    }

    final redirect = Uri.encodeComponent('/app/sessions/player/$sessionId');

    return _PlayerErrorView(
      title: t.get(
        'player_auth_required_title',
        fallback: 'Sign in required',
      ),
      message: t.get(
        'player_auth_required_message',
        fallback: 'You need an account to start and track session runs.',
      ),
      onPrimaryPressed: () {
        context.push('/auth?mode=signin&redirect=$redirect');
      },
      primaryLabel: t.get(
        'player_auth_required_cta',
        fallback: 'Sign in',
      ),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: const Icon(Icons.arrow_forward),
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

String _stepTypeLabel(BuildContext context, SessionStepType type) {
  final t = AppText.of(context);

  switch (type) {
    case SessionStepType.setup:
      return t.get('session_step_type_setup', fallback: 'Setup');
    case SessionStepType.movement:
      return t.get('session_step_type_movement', fallback: 'Movement');
    case SessionStepType.hold:
      return t.get('session_step_type_hold', fallback: 'Hold');
    case SessionStepType.breath:
      return t.get('session_step_type_breath', fallback: 'Breath');
    case SessionStepType.transition:
      return t.get('session_step_type_transition', fallback: 'Transition');
    case SessionStepType.cooldown:
      return t.get('session_step_type_cooldown', fallback: 'Cooldown');
  }
}