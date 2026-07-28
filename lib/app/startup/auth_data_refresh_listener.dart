import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/insights/domain/insights_snapshot.dart';
import '../../features/access/application/access_providers.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/insights/application/insights_providers.dart';
import '../../features/player/application/session_continuity_providers.dart';
import '../../features/profile/application/profile_providers.dart';
import '../../features/programs/application/recovery_program_providers.dart';
import '../../features/sessions/application/sessions_providers.dart';

class AuthDataRefreshListener extends ConsumerWidget {
  const AuthDataRefreshListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentUserProvider, (previous, next) {
      final previousUserId = previous?.id;
      final nextUserId = next?.id;

      if (previousUserId == nextUserId) {
        return;
      }

      _invalidateUserScopedData(ref);
    });

    return child;
  }

  void _invalidateUserScopedData(WidgetRef ref) {
    ref.invalidate(accessSnapshotProvider);

    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(userPreferencesControllerProvider);

    ref.invalidate(savedSessionIdsProvider);
    ref.invalidate(savedSessionContinuityItemsProvider);

    ref.invalidate(recentSessionRunsProvider);
    ref.invalidate(continueSessionCandidateProvider);

    ref.invalidate(dashboardControllerProvider);

    ref.invalidate(recoveryProgramSummariesProvider);
    ref.invalidate(recoveryProgramDetailProvider);
    ref.invalidate(recoveryProgramProgressProvider);
    ref.invalidate(recoveryProgramDayProgressMapProvider);
    ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
    ref.invalidate(recoveryProgramActionControllerProvider);

    ref.invalidate(insightsSnapshotProvider(InsightsRange.last7Days));
    ref.invalidate(insightsSnapshotProvider(InsightsRange.last14Days));
    ref.invalidate(insightsSnapshotProvider(InsightsRange.last28Days));
  }
}