// lib/features/programs/application/recovery_program_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/supabase_recovery_programs_repository.dart';
import '../domain/recovery_program_models.dart';

final recoveryProgramsRepositoryProvider =
    Provider<RecoveryProgramsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRecoveryProgramsRepository(client);
});

final recoveryProgramSummariesProvider =
    FutureProvider<List<RecoveryProgramSummary>>((ref) async {
  final repository = ref.watch(recoveryProgramsRepositoryProvider);
  return repository.getProgramSummaries();
});

final recoveryProgramDetailProvider =
    FutureProvider.family<RecoveryProgramDetail?, String>((ref, programId) async {
  final repository = ref.watch(recoveryProgramsRepositoryProvider);
  return repository.getProgramDetailById(programId);
});

final recoveryProgramProgressProvider =
    FutureProvider.family<RecoveryProgramProgress?, String>((ref, programId) async {
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  if (userId == null) return null;

  final repository = ref.watch(recoveryProgramsRepositoryProvider);
  return repository.getProgramProgress(programId);
});

final recoveryProgramDayProgressMapProvider = FutureProvider.family<
    Map<int, RecoveryProgramDayProgress>, String>((ref, programId) async {
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  if (userId == null) return const <int, RecoveryProgramDayProgress>{};

  final repository = ref.watch(recoveryProgramsRepositoryProvider);
  return repository.getProgramDayProgressMap(programId);
});

final activeRecoveryProgramDashboardProgressProvider =
    FutureProvider<RecoveryProgramDashboardProgress?>((ref) async {
  // Making the authenticated user part of this provider's dependency graph is
  // essential. Without it, Riverpod can keep the previous account's cached
  // program progress until a manual refresh occurs.
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  if (userId == null) return null;

  final repository = ref.watch(recoveryProgramsRepositoryProvider);
  return repository.getActiveDashboardProgress();
});

final recoveryProgramActionControllerProvider =
    AsyncNotifierProvider<RecoveryProgramActionController, void>(
  RecoveryProgramActionController.new,
);

class RecoveryProgramActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<bool> startProgram(String programId) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(recoveryProgramsRepositoryProvider);
      await repository.startProgram(programId);

      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(recoveryProgramDetailProvider(programId));
      ref.invalidate(recoveryProgramProgressProvider(programId));
      ref.invalidate(recoveryProgramDayProgressMapProvider(programId));
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);

      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> startProgramDay({
    required String programId,
    required int dayNumber,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(recoveryProgramsRepositoryProvider);
      await repository.startProgramDay(
        programId: programId,
        dayNumber: dayNumber,
      );

      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(recoveryProgramDetailProvider(programId));
      ref.invalidate(recoveryProgramProgressProvider(programId));
      ref.invalidate(recoveryProgramDayProgressMapProvider(programId));
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);

      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> completeProgramDay({
    required String programId,
    required int dayNumber,
    String? sessionRunId,
    int minutesCompleted = 0,
    bool? helped,
    int? difficultyRating,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(recoveryProgramsRepositoryProvider);
      await repository.completeProgramDay(
        programId: programId,
        dayNumber: dayNumber,
        sessionRunId: sessionRunId,
        minutesCompleted: minutesCompleted,
        helped: helped,
        difficultyRating: difficultyRating,
      );

      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(recoveryProgramDetailProvider(programId));
      ref.invalidate(recoveryProgramProgressProvider(programId));
      ref.invalidate(recoveryProgramDayProgressMapProvider(programId));
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);

      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
