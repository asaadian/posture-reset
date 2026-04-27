// lib/features/player/application/player_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_session_feedback_repository.dart';
import '../data/supabase_session_runs_repository.dart';
import '../data/supabase_session_step_events_repository.dart';
import '../domain/session_feedback_models.dart';
import '../domain/session_feedback_repository.dart';
import '../domain/session_runs_repository.dart';
import '../domain/session_step_events_repository.dart';
import 'session_player_controller.dart';

final playerSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sessionRunsRepositoryProvider = Provider<SessionRunsRepository>((ref) {
  final client = ref.watch(playerSupabaseClientProvider);
  return SupabaseSessionRunsRepository(client);
});

final sessionFeedbackRepositoryProvider =
    Provider<SessionFeedbackRepository>((ref) {
  final client = ref.watch(playerSupabaseClientProvider);
  return SupabaseSessionFeedbackRepository(client);
});

final sessionStepEventsRepositoryProvider =
    Provider<SessionStepEventsRepository>((ref) {
  final client = ref.watch(playerSupabaseClientProvider);
  return SupabaseSessionStepEventsRepository(client);
});

class SessionPlayerArgs {
  const SessionPlayerArgs({
    required this.sessionId,
    this.entrySource = SessionEntrySource.sessionDetail,
  });

  final String sessionId;
  final SessionEntrySource entrySource;

  @override
  bool operator ==(Object other) {
    return other is SessionPlayerArgs &&
        other.sessionId == sessionId &&
        other.entrySource == entrySource;
  }

  @override
  int get hashCode => Object.hash(sessionId, entrySource);
}

final sessionPlayerControllerProvider = ChangeNotifierProvider.autoDispose
    .family<SessionPlayerController, SessionPlayerArgs>((
  ref,
  args,
) {
  final runsRepository = ref.watch(sessionRunsRepositoryProvider);
  final feedbackRepository = ref.watch(sessionFeedbackRepositoryProvider);
  final stepEventsRepository = ref.watch(sessionStepEventsRepositoryProvider);

  return SessionPlayerController(
    ref: ref,
    sessionId: args.sessionId,
    runsRepository: runsRepository,
    feedbackRepository: feedbackRepository,
    stepEventsRepository: stepEventsRepository,
    entrySource: args.entrySource,
  );
});