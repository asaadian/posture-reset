// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_data/app_data_reset_signal.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/notifications/notification_history_repository.dart';
import '../../../../shared/onboarding/page_onboarding.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/modern_progress_track.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../auth/application/auth_providers.dart';
import '../../domain/dashboard_snapshot.dart';
import '../controllers/dashboard_controller.dart';
import '../../../profile/application/profile_providers.dart';
import '../../../profile/domain/profile_models.dart';
import '../../../programs/application/recovery_program_providers.dart';
import '../../../programs/domain/recovery_program_models.dart';
import '../../../sessions/application/sessions_providers.dart';
import '../../../sessions/domain/session_models.dart';

final _dashboardSavedSessionsProvider =
    FutureProvider.autoDispose<List<SessionSummary>>((ref) async {
  final savedRepository = ref.watch(savedSessionsRepositoryProvider);
  final sessionRepository = ref.watch(sessionsRepositoryProvider);

  final savedIds = await savedRepository.getRecentlySavedSessionIds(limit: 3);
  if (savedIds.isEmpty) return const <SessionSummary>[];

  return sessionRepository.getSessionsByIds(savedIds);
});


Rect _dashboardBodyTarget(Size size, EdgeInsets safePadding) {
  final top = safePadding.top + 118;
  final bottom = size.height - safePadding.bottom - 158;
  return Rect.fromLTRB(
    14,
    top,
    size.width - 14,
    bottom.clamp(top + 160, size.height - safePadding.bottom - 48).toDouble(),
  );
}

/// PageOnboarding is mounted inside the scaffold body, while the header/actions
/// are slightly above the scroll content. Use a tall negative rect so the clipped
/// visible area still frames the full top bar instead of becoming a thin line.
Rect _dashboardTopBarGuideTarget(Size size, EdgeInsets safePadding) {
  const visibleHeight = 78.0;
  final top = -(safePadding.top + 68.0);
  final height = safePadding.top + 68.0 + visibleHeight;

  return Rect.fromLTWH(
    14,
    top,
    size.width - 28,
    height,
  );
}

/// The custom bottom navigation sits outside the scrollable dashboard content.
/// This target is anchored to the real bottom edge so it frames the nav bar,
/// not the last dashboard card.
Rect _dashboardBottomNavGuideTarget(Size size, EdgeInsets safePadding) {
  const height = 112.0;
  final top = size.height - safePadding.bottom - height + 6;
  return Rect.fromLTWH(
    14,
    top,
    size.width - 28,
    height,
  );
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);


    ref.listen<int>(appDataResetSignalProvider, (previous, next) {
      if (previous == next) return;
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(accessSnapshotProvider);
      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
      ref.invalidate(sessionSummariesProvider);
      ref.invalidate(savedSessionIdsProvider);
      ref.invalidate(_dashboardSavedSessionsProvider);
      ref.invalidate(dashboardControllerProvider);
    });

    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.id == next?.id) return;

      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(accessSnapshotProvider);
      ref.invalidate(recoveryProgramSummariesProvider);
      ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
      ref.invalidate(sessionSummariesProvider);
      ref.invalidate(savedSessionIdsProvider);
      ref.invalidate(_dashboardSavedSessionsProvider);
      ref.invalidate(dashboardControllerProvider);
    });

    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);
    final programsAsync = ref.watch(recoveryProgramSummariesProvider);
    final activeProgramAsync =
        ref.watch(activeRecoveryProgramDashboardProgressProvider);
    final savedSessionsAsync = ref.watch(_dashboardSavedSessionsProvider);
    final savedIdsAsync = ref.watch(savedSessionIdsProvider);
    final sessionSummariesAsync = ref.watch(sessionSummariesProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    final profile = profileAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final accessSnapshot = accessAsync.maybeWhen(
      data: (value) => value,
      orElse: () => AccessSnapshot.guest,
    );
    final programs = programsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <RecoveryProgramSummary>[],
    );
    final activeProgram = activeProgramAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final savedSessions = savedSessionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <SessionSummary>[],
    );
    final savedIds = savedIdsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <String>{},
    );
    final allSessions = sessionSummariesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <SessionSummary>[],
    );

    final recommendedSessions = _recommendedTodaySessions(
      allSessions: allSessions,
      savedSessions: savedSessions,
    );
    return ResponsivePageScaffold(
      title: Text(_dashboardGreeting(t: t, profile: profile, email: user?.email)),
      actions: [
        _DashboardNotificationAction(userId: user?.id),
        _DashboardAccountAction(
          userEmail: user?.email,
          profile: profile,
          hasCoreAccess: accessSnapshot.hasCoreAccess,
          onProfileTap: () => context.goNamed('profile'),
          onPremiumTap: () => context.pushNamed('premium'),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        return PageOnboarding(
          pageId: 'dashboard_guide_v2',
          tips: [
            OnboardingTip(
              targetBuilder: _dashboardTopBarGuideTarget,
              targetBorderRadius: 24,
              icon: Icons.tune_rounded,
              title: t.get('guide_dashboard_topbar_title', fallback: 'Top bar'),
              body: t.get('guide_dashboard_topbar_body', fallback: 'Use the top bar for notifications and your account. Free members can upgrade directly from the account badge.'),
            ),
            OnboardingTip(
              targetBuilder: _dashboardBodyTarget,
              targetBorderRadius: 28,
              icon: Icons.dashboard_customize_rounded,
              title: t.get('guide_dashboard_home_title', fallback: 'Your recovery home'),
              body: t.get('guide_dashboard_home_body', fallback: 'Start with the smart next action, then check your recovery status, program progress, and recent activity.'),
            ),
            OnboardingTip(
              targetBuilder: _dashboardBottomNavGuideTarget,
              targetBorderRadius: 32,
              icon: Icons.space_dashboard_rounded,
              title: t.get('guide_dashboard_bottom_nav_title', fallback: 'Bottom navigation'),
              body: t.get('guide_dashboard_bottom_nav_body', fallback: 'Use the bottom tabs to open Training, Quick Fix, Insights, and Programs when you need deeper details.'),
            ),
          ],
          child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProfileProvider);
            ref.invalidate(accessSnapshotProvider);
            ref.invalidate(recoveryProgramSummariesProvider);
            ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
            ref.invalidate(sessionSummariesProvider);
            ref.invalidate(savedSessionIdsProvider);
            ref.invalidate(_dashboardSavedSessionsProvider);
            ref.invalidate(dashboardControllerProvider);
            await Future.wait([
              ref.read(recoveryProgramSummariesProvider.future),
              ref.read(sessionSummariesProvider.future),
              ref.read(dashboardControllerProvider.future),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
            children: [
              ResponsiveContentSection(
                spacing: 16,
                children: [
                  _ProgramHeroSection(
                    programs: programs,
                    activeProgram: activeProgram,
                  ),
                  dashboardAsync.maybeWhen(
                    data: (snapshot) => _RecoveryCommandDeck(
                      snapshot: snapshot,
                      activeProgram: activeProgram,
                    ),
                    orElse: () => _DashboardSnapshotBlock(
                      dashboardAsync: dashboardAsync,
                      activeProgram: activeProgram,
                      accessSnapshot: accessSnapshot,
                    ),
                  ),
                  _MomentumSection(
                    activeProgram: activeProgram,
                    savedSessionCount: savedIds.length,
                  ),
                  _RecommendedTodaySection(sessions: recommendedSessions),
                  dashboardAsync.maybeWhen(
                    data: (snapshot) => _RecentRunsSection(runs: snapshot.recentRuns),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  _BodyFocusCard(),
                  if (savedSessions.isNotEmpty)
                    _SavedSessionsSection(sessions: savedSessions),
                  if (!accessSnapshot.hasCoreAccess)
                    const _PremiumCompactCard(),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  List<SessionSummary> _recommendedTodaySessions({
    required List<SessionSummary> allSessions,
    required List<SessionSummary> savedSessions,
  }) {
    if (allSessions.isEmpty) return const <SessionSummary>[];

    final savedIds = savedSessions.map((item) => item.id).toSet();

    final candidates = allSessions
        .where((session) => !savedIds.contains(session.id))
        .toList(growable: true);

    candidates.sort((a, b) {
      final aScore = _todayScore(a);
      final bScore = _todayScore(b);
      if (aScore != bScore) return bScore.compareTo(aScore);
      return a.durationMinutes.compareTo(b.durationMinutes);
    });

    return candidates.take(3).toList(growable: false);
  }

  int _todayScore(SessionSummary session) {
    var score = 0;

    // V2 sessions are intentionally more therapy-like. Prefer true therapy
    // sessions over the small free starter previews on the dashboard.
    switch (session.sessionLevelTag) {
      case SessionLevelTag.freeStarter:
        score += 0;
        break;
      case SessionLevelTag.therapy:
        score += 6;
        break;
      case SessionLevelTag.advancedTherapy:
        score += 8;
        break;
      case SessionLevelTag.flagship:
        score += 10;
        break;
    }

    if (session.durationMinutes <= 7) score += 5;
    if (session.durationMinutes > 7 && session.durationMinutes <= 9) score += 4;
    if (session.durationMinutes > 9 && session.durationMinutes <= 12) score += 2;
    if (session.environmentCompatibility.deskFriendly) score += 4;
    if (session.environmentCompatibility.quietFriendly) score += 2;
    if (session.isBeginnerFriendly) score += 1;
    if (session.goals.contains(SessionGoal.painRelief)) score += 3;
    if (session.goals.contains(SessionGoal.recovery)) score += 2;
    if (session.goals.contains(SessionGoal.postureReset)) score += 2;
    if (session.accessTier == AccessTier.coreAccess) score += 1;

    return score;
  }
}


String _dashboardGreeting({
  required AppTextReader t,
  required UserProfile? profile,
  required String? email,
}) {
  final displayName = profile?.displayName?.trim();
  final emailName = email?.split('@').first.trim();
  final name = displayName?.isNotEmpty == true
      ? displayName!
      : (emailName?.isNotEmpty == true ? emailName! : '');
  final greeting = t.get('dashboard_greeting', fallback: 'Hello');
  return name.isEmpty ? greeting : '$greeting, $name';
}


class _DashboardNotificationAction extends ConsumerWidget {
  const _DashboardNotificationAction({required this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final unreadAsync = ref.watch(notificationHistoryUnreadCountProvider(userId));
    final unreadCount = unreadAsync.maybeWhen(
      data: (value) => value,
      orElse: () => 0,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => context.pushNamed('notification-center'),
            tooltip: t.get('profile_action_notifications', fallback: 'Notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          if (unreadCount > 0)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecoveryCommandDeck extends StatelessWidget {
  const _RecoveryCommandDeck({
    required this.snapshot,
    required this.activeProgram,
  });

  final DashboardSnapshot snapshot;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final t = AppText.of(context);
    final program = activeProgram;
    final hasProgram = program != null && !program.isCompleted;
    final helpful = (snapshot.helpRate * 100).round();
    final rhythm = (snapshot.consistencyScore * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF101A2D), const Color(0xFF111827)]
              : [colors.primary.withValues(alpha: 0.08), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.tertiary],
                  ),
                ),
                child: Icon(Icons.monitor_heart_rounded, color: colors.onPrimary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('dashboard_command_title', fallback: 'Recovery command center'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasProgram
                          ? t.get('dashboard_command_active_body', fallback: 'Your journey, recovery signal, and next action in one place.')
                          : t.get('dashboard_command_empty_body', fallback: 'Start a therapy journey to build a clear recovery signal.'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final tiles = [
                _CommandMetric(
                  icon: Icons.speed_rounded,
                  label: t.get('dashboard_readiness_label', fallback: 'Readiness'),
                  value: '${snapshot.readinessScore}',
                  accent: colors.primary,
                ),
                _CommandMetric(
                  icon: Icons.favorite_rounded,
                  label: t.get('dashboard_helpful_label', fallback: 'Helpful'),
                  value: '$helpful%',
                  accent: colors.tertiary,
                ),
                _CommandMetric(
                  icon: Icons.route_rounded,
                  label: t.get('dashboard_rhythm_label', fallback: 'Rhythm'),
                  value: '$rhythm%',
                  accent: colors.secondary,
                ),
              ];
              if (compact) {
                return Row(
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      Expanded(child: tiles[i]),
                      if (i != tiles.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    Expanded(child: tiles[i]),
                    if (i != tiles.length - 1) const SizedBox(width: 10),
                  ],
                ],
              );
            },
          ),
          if (hasProgram) ...[
            const SizedBox(height: 14),
            _JourneyMiniProgress(program: program),
          ],
        ],
      ),
    );
  }
}

class _CommandMetric extends StatelessWidget {
  const _CommandMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surface.withValues(alpha: 0.72),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 7),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyMiniProgress extends StatelessWidget {
  const _JourneyMiniProgress({required this.program});

  final RecoveryProgramDashboardProgress program;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = program.currentDayTitleFallback?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                current?.isNotEmpty == true ? current! : 'Mission ${program.currentDay}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${program.completedDayCount}/${program.durationDays}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ModernProgressTrack(
          value: program.progressFraction,
          height: 10,
        ),
      ],
    );
  }
}

class _DashboardSnapshotBlock extends StatelessWidget {
  const _DashboardSnapshotBlock({
    required this.dashboardAsync,
    required this.activeProgram,
    required this.accessSnapshot,
  });

  final AsyncValue<DashboardSnapshot> dashboardAsync;
  final RecoveryProgramDashboardProgress? activeProgram;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    return dashboardAsync.when(
      loading: () => const _DashboardSnapshotSkeleton(),
      error: (error, _) => _DashboardInlineStatus(
        icon: Icons.error_outline_rounded,
        title: AppText.get(
          context,
          key: 'dashboard_snapshot_error_title',
          fallback: 'Dashboard data is unavailable',
        ),
        body: error.toString(),
      ),
      data: (snapshot) {
        if (!snapshot.hasContent && activeProgram == null) {
          return const _DashboardStarterCard();
        }

        return _RecoveryStatusStrip(snapshot: snapshot);
      },
    );
  }
}

class _RecoveryStatusStrip extends StatelessWidget {
  const _RecoveryStatusStrip({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Row(
      children: [
        Expanded(
          child: _MomentumTile(
            icon: Icons.speed_rounded,
            value: snapshot.readinessScore.toString(),
            label: t.get('dashboard_readiness_label', fallback: 'readiness'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MomentumTile(
            icon: Icons.timer_rounded,
            value: snapshot.weeklyMinutes.toString(),
            label: t.get('dashboard_weekly_minutes_label', fallback: 'min week'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MomentumTile(
            icon: Icons.check_circle_rounded,
            value: snapshot.completedSessionsThisWeek.toString(),
            label: t.get('dashboard_completed_week_label', fallback: 'sessions'),
          ),
        ),
      ],
    );
  }
}

class _RecentRunsSection extends StatelessWidget {
  const _RecentRunsSection({required this.runs});

  final List<DashboardRecentRun> runs;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    if (runs.isEmpty) return const SizedBox.shrink();

    final visibleRuns = runs.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: t.get('dashboard_recent_runs_title', fallback: 'Recent activity'),
          actionLabel: t.get('insights_title', fallback: 'Insights'),
          onAction: () => context.goNamed('insights'),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final run in visibleRuns) ...[
              _RecentRunTile(run: run),
              if (run != visibleRuns.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecentRunTile extends StatelessWidget {
  const _RecentRunTile({required this.run});

  final DashboardRecentRun run;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': run.sessionId},
        ),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(_runStatusIcon(run.status), color: colors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(run.titleKey, fallback: run.titleFallback),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_runStatusLabel(context, run.status)} • ${run.elapsedMinutes} ${t.get('session_duration_unit_min', fallback: 'min')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (run.helped != null)
                Icon(
                  run.helped == true
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumbs_up_down_rounded,
                  color: colors.onSurfaceVariant,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStarterCard extends StatelessWidget {
  const _DashboardStarterCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => context.goNamed('quick-fix'),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.16),
                colors.tertiary.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(Icons.self_improvement_rounded, color: colors.primary, size: 34),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('dashboard_empty_title', fallback: 'Build your recovery baseline'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.get(
                        'dashboard_empty_body',
                        fallback: 'Start with a quick reset or choose a therapy path. Your progress appears here after your first session.',
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSnapshotSkeleton extends StatelessWidget {
  const _DashboardSnapshotSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
      ),
    );
  }
}

class _DashboardInlineStatus extends StatelessWidget {
  const _DashboardInlineStatus({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF101827) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
}

IconData _runStatusIcon(DashboardRunStatus status) {
  switch (status) {
    case DashboardRunStatus.completed:
      return Icons.check_circle_rounded;
    case DashboardRunStatus.abandoned:
      return Icons.pause_circle_filled_rounded;
    case DashboardRunStatus.started:
      return Icons.play_circle_fill_rounded;
  }
}

String _runStatusLabel(BuildContext context, DashboardRunStatus status) {
  final t = AppText.of(context);
  switch (status) {
    case DashboardRunStatus.completed:
      return t.get('dashboard_run_completed', fallback: 'Completed');
    case DashboardRunStatus.abandoned:
      return t.get('dashboard_run_abandoned', fallback: 'Paused');
    case DashboardRunStatus.started:
      return t.get('dashboard_run_started', fallback: 'Started');
  }
}

class _ProgramHeroSection extends StatelessWidget {
  const _ProgramHeroSection({
    required this.programs,
    required this.activeProgram,
  });

  final List<RecoveryProgramSummary> programs;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final hasActive = activeProgram != null && !activeProgram!.isCompleted;
    final activeSummary = hasActive
        ? _activeProgramSummary(programs, activeProgram!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: hasActive
              ? t.get('dashboard_programs_active_title', fallback: 'Continue your journey')
              : t.get('dashboard_programs_title', fallback: 'Therapy journeys'),
          actionLabel: t.get('common_view_all', fallback: 'View all'),
          onAction: () => context.pushNamed('recovery-programs'),
        ),
        const SizedBox(height: 10),
        if (hasActive && activeSummary != null)
          SizedBox(
            height: 218,
            width: double.infinity,
            child: _ProgramPosterCard(
              program: activeSummary,
              activeProgram: activeProgram,
            ),
          )
        else if (hasActive)
          const _ProgramHeroSkeleton()
        else
          _ProgramDiscoveryCard(
            featuredProgram: programs.isEmpty ? null : programs.first,
            programCount: programs.length,
            onTap: () => context.pushNamed('recovery-programs'),
          ),
      ],
    );
  }

  RecoveryProgramSummary? _activeProgramSummary(
    List<RecoveryProgramSummary> programs,
    RecoveryProgramDashboardProgress active,
  ) {
    for (final program in programs) {
      if (program.id == active.programId) return program;
    }
    return null;
  }
}

class _ProgramDiscoveryCard extends StatelessWidget {
  const _ProgramDiscoveryCard({
    required this.featuredProgram,
    required this.programCount,
    required this.onTap,
  });

  final RecoveryProgramSummary? featuredProgram;
  final int programCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final program = featuredProgram;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          height: 184,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: _programGradient(program?.id ?? ''),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFDCE5F0),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.16)
                    : const Color(0xFF3E5874).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (program != null)
                  _RemoteProgramCoverImage(
                    programId: program.id,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    fallbackBuilder: (_) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.78),
                        Colors.black.withValues(alpha: 0.34),
                        Colors.black.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WhitePill(
                          label: programCount > 0
                              ? t
                                  .get(
                                    'dashboard_program_discovery_pill_count',
                                    fallback: '{count} plans',
                                  )
                                  .replaceAll('{count}', programCount.toString())
                              : t.get(
                                  'dashboard_program_discovery_pill_guided',
                                  fallback: 'Guided',
                                ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 210,
                          child: Text(
                            t.get(
                              'dashboard_program_discovery_title',
                              fallback: 'Choose a therapy path',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 0.96,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.route_rounded,
                                color: colors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.get(
                                  'dashboard_program_discovery_cta',
                                  fallback: 'View paths',
                                ),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
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

class _ProgramPosterCard extends StatelessWidget {
  const _ProgramPosterCard({
    required this.program,
    required this.activeProgram,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    final isActive = activeProgram?.programId == program.id &&
        activeProgram?.isCompleted == false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isActive ? 26 : 24),
        onTap: () {
          context.pushNamed(
            'recovery-program-detail',
            pathParameters: {'id': program.id},
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isActive ? 26 : 24),
            gradient: LinearGradient(
              colors: _programGradient(program.id),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isActive ? 26 : 24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _RemoteProgramCoverImage(
                    programId: program.id,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    fallbackBuilder: (_) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              Colors.black.withValues(alpha: 0.78),
                              Colors.black.withValues(alpha: 0.40),
                              Colors.black.withValues(alpha: 0.06),
                            ]
                          : [
                              Colors.black.withValues(alpha: 0.72),
                              Colors.black.withValues(alpha: 0.30),
                              Colors.black.withValues(alpha: 0.04),
                            ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                if (isActive)
                  _ActiveDashboardProgramContent(
                    program: program,
                    activeProgram: activeProgram!,
                  )
                else
                  _InactiveDashboardProgramContent(program: program),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveDashboardProgramContent extends StatelessWidget {
  const _ActiveDashboardProgramContent({
    required this.program,
    required this.activeProgram,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDashboardProgress activeProgram;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WhitePill(label: t.get('program_active_badge', fallback: 'Active')),
          const Spacer(),
          Text(
            'MISSION ${activeProgram.currentDay}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 0.86,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 190,
            child: Text(
              t.get(program.titleKey, fallback: program.titleFallback),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _WhiteProgress(
            completed: activeProgram.completedDayCount,
            total: activeProgram.durationDays,
          ),
          const SizedBox(height: 10),
          _WhiteButton(
            label: t.get('dashboard_programs_continue_cta', fallback: 'Continue'),
          ),
        ],
      ),
    );
  }
}

class _InactiveDashboardProgramContent extends StatelessWidget {
  const _InactiveDashboardProgramContent({required this.program});

  final RecoveryProgramSummary program;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WhitePill(
            label:
                '${program.durationDays} ${t.get('program_day_unit', fallback: 'missions')}',
          ),
          const Spacer(),
          SizedBox(
            width: 160,
            child: Text(
              t.get(program.titleKey, fallback: program.titleFallback),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            t.get('program_start_cta', fallback: 'Start'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSessionsSection extends StatelessWidget {
  const _SavedSessionsSection({
    required this.sessions,
  });

  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: t.get('dashboard_saved_title', fallback: 'Saved for later'),
          actionLabel: t.get('common_view_all', fallback: 'View all'),
          onAction: () => context.pushNamed('saved-sessions'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 250,
                child: _SavedSessionTile(session: sessions[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SavedSessionTile extends StatelessWidget {
  const _SavedSessionTile({
    required this.session,
  });

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': session.id},
        ),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              _SessionThumb(sessionId: session.id, size: 78),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(session.titleKey, fallback: session.titleFallback),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SoftMetaRow(
                      icon: Icons.bookmark_rounded,
                      label:
                          '${session.durationMinutes} ${t.get('session_duration_unit_min', fallback: 'min')}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedTodaySection extends StatelessWidget {
  const _RecommendedTodaySection({
    required this.sessions,
  });

  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: t.get('dashboard_recommended_title', fallback: 'Recommended today'),
          actionLabel: t.get('sessions_title', fallback: 'Training'),
          onAction: () => context.goNamed('sessions'),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final session in sessions) ...[
              _RecommendedSessionRow(session: session),
              if (session != sessions.last) const SizedBox(height: 9),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecommendedSessionRow extends StatelessWidget {
  const _RecommendedSessionRow({
    required this.session,
  });

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.pushNamed(
          'session-detail',
          pathParameters: {'id': session.id},
        ),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              _SessionThumb(sessionId: session.id, size: 70),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(session.titleKey, fallback: session.titleFallback),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TinyPill(
                          label:
                              '${session.durationMinutes} ${t.get('session_duration_unit_min', fallback: 'min')}',
                        ),
                        _TinyPill(label: _intensityLabel(context, session.intensity)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentumSection extends StatelessWidget {
  const _MomentumSection({
    required this.activeProgram,
    required this.savedSessionCount,
  });

  final RecoveryProgramDashboardProgress? activeProgram;
  final int savedSessionCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final hasProgram = activeProgram != null && !activeProgram!.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: t.get('dashboard_momentum_title', fallback: 'Your momentum'),
          actionLabel: t.get('insights_title', fallback: 'Insights'),
          onAction: () => context.goNamed('insights'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MomentumTile(
                icon: Icons.route_rounded,
                value: hasProgram
                    ? '${activeProgram!.completedDayCount}/${activeProgram!.durationDays}'
                    : '0',
                label: t.get('dashboard_program_days_label', fallback: 'program missions'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MomentumTile(
                icon: Icons.local_fire_department_rounded,
                value: hasProgram ? activeProgram!.streakCount.toString() : '0',
                label: t.get('dashboard_streak_label', fallback: 'streak'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MomentumTile(
                icon: Icons.bookmark_rounded,
                value: savedSessionCount.toString(),
                label: t.get('dashboard_saved_count_label', fallback: 'saved'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MomentumTile extends StatelessWidget {
  const _MomentumTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF101827) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 19),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyFocusCard extends StatelessWidget {
  const _BodyFocusCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => context.goNamed('quick-fix'),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0xFF26324A) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: colors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('dashboard_body_focus_title', fallback: 'Need relief now?'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t.get(
                        'dashboard_body_focus_body',
                        fallback: 'Use Quick Fix to choose the body zone that needs attention.',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCompactCard extends StatelessWidget {
  const _PremiumCompactCard();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => context.pushNamed('premium'),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.16),
                colors.tertiary.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('dashboard_premium_title', fallback: 'Unlock full recovery'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t.get(
                        'dashboard_premium_body',
                        fallback: 'All programs, saved recovery paths, and advanced progress tools.',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PRO',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionThumb extends StatelessWidget {
  const _SessionThumb({
    required this.sessionId,
    required this.size,
  });

  final String sessionId;
  final double size;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: size,
        height: size,
        child: _RemoteSessionCoverImage(
          sessionId: sessionId,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          fallbackBuilder: (_) => const _SessionCoverFallback(iconSize: 28),
        ),
      ),
    );
  }
}

class _SoftMetaRow extends StatelessWidget {
  const _SoftMetaRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: colors.primary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.62),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _WhiteProgress extends StatelessWidget {
  const _WhiteProgress({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total;
    final value = (completed / safeTotal).clamp(0.0, 1.0);

    return SizedBox(
      width: 170,
      child: ModernProgressTrack(
        value: value,
        height: 8,
        light: true,
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, size: 16, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgramHeroSkeleton extends StatelessWidget {
  const _ProgramHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
      ),
    );
  }
}

class _DashboardAccountAction extends StatelessWidget {
  const _DashboardAccountAction({
    required this.userEmail,
    required this.profile,
    required this.hasCoreAccess,
    required this.onProfileTap,
    required this.onPremiumTap,
  });

  final String? userEmail;
  final UserProfile? profile;
  final bool hasCoreAccess;
  final VoidCallback onProfileTap;
  final VoidCallback onPremiumTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = profile?.avatarUrl?.trim() ?? '';
    final displayName =
        _displayName(profile: profile, email: userEmail, context: context);
    final initial = displayName.trim().isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : 'P';

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 42,
            padding: const EdgeInsetsDirectional.fromSTEB(5, 4, 7, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.surfaceContainerHighest.withValues(alpha: 0.58),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.62),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: avatarUrl.isEmpty
                        ? LinearGradient(
                            colors: [colors.primary, colors.tertiary],
                          )
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarInitial(initial: initial),
                        )
                      : _AvatarInitial(initial: initial),
                ),
                const SizedBox(width: 7),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasCoreAccess ? onProfileTap : onPremiumTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: hasCoreAccess
                          ? LinearGradient(
                              colors: [
                                colors.primary.withValues(alpha: 0.16),
                                colors.tertiary.withValues(alpha: 0.14),
                              ],
                            )
                          : null,
                      color: hasCoreAccess
                          ? null
                          : colors.surface.withValues(alpha: 0.82),
                      border: Border.all(
                        color: hasCoreAccess
                            ? colors.primary.withValues(alpha: 0.30)
                            : colors.outlineVariant.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasCoreAccess
                              ? Icons.workspace_premium_rounded
                              : Icons.lock_open_rounded,
                          size: 14,
                          color: hasCoreAccess
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasCoreAccess ? 'Premium' : 'Free',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: hasCoreAccess
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        if (!hasCoreAccess) ...[
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: colors.primary,
                          ),
                        ],
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

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({
    required this.initial,
  });

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
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
    case 'prog_neck_shoulder_therapy_14':
      return const [Color(0xFF0891B2), Color(0xFF1D4ED8)];
    case 'prog_wrist_forearm_mouse_10':
      return const [Color(0xFF0F766E), Color(0xFF0F172A)];
    case 'prog_lower_back_hip_stability_14':
      return const [Color(0xFF6D28D9), Color(0xFF1E1B4B)];
    case 'prog_full_desk_worker_21':
      return const [Color(0xFF0EA5E9), Color(0xFF0F172A)];
    case 'prog_office_toolkit_14':
      return const [Color(0xFF2563EB), Color(0xFF312E81)];
    default:
      return const [Color(0xFF2563EB), Color(0xFF0F172A)];
  }
}

String _displayName({
  required UserProfile? profile,
  required String? email,
  required BuildContext context,
}) {
  final profileName = profile?.displayName?.trim();
  if (profileName != null && profileName.isNotEmpty) return profileName;

  final cleanEmail = email?.trim() ?? '';
  if (cleanEmail.contains('@')) return cleanEmail.split('@').first;

  return AppText.get(
    context,
    key: 'profile_account_guest_name',
    fallback: 'Guest',
  );
}

String _intensityLabel(BuildContext context, SessionIntensity intensity) {
  final t = AppText.of(context);

  switch (intensity) {
    case SessionIntensity.gentle:
      return t.get('session_intensity_gentle', fallback: 'Gentle');
    case SessionIntensity.light:
      return t.get('session_intensity_light', fallback: 'Light');
    case SessionIntensity.moderate:
      return t.get('session_intensity_moderate', fallback: 'Moderate');
    case SessionIntensity.strong:
      return t.get('session_intensity_strong', fallback: 'Strong');
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
      errorBuilder: (context, error, stackTrace) => Image.asset(
        ProgramPosterAsset.pathForProgramId(programId),
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallbackBuilder(context),
      ),
    );
  }
}


const String _remoteSessionCoverBaseUrl =
    'https://weglabs.com/data/desk-workout/covers/sessions';

String _remoteSessionCoverUrl(String sessionId) =>
    '$_remoteSessionCoverBaseUrl/$sessionId.webp';

class _RemoteSessionCoverImage extends StatelessWidget {
  const _RemoteSessionCoverImage({
    required this.sessionId,
    required this.fit,
    required this.alignment,
    required this.fallbackBuilder,
  });

  final String sessionId;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final WidgetBuilder fallbackBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _remoteSessionCoverUrl(sessionId),
      fit: fit,
      alignment: alignment,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallbackBuilder(context);
      },
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/sessions/$sessionId.png',
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallbackBuilder(context),
      ),
    );
  }
}

class _SessionCoverFallback extends StatelessWidget {
  const _SessionCoverFallback({
    this.iconSize = 34,
    this.dark = false,
  });

  final double iconSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
                  colors.primary.withValues(alpha: 0.30),
                  colors.tertiary.withValues(alpha: 0.16),
                  const Color(0xFF0F172A),
                ]
              : [
                  colors.primary.withValues(alpha: 0.16),
                  colors.tertiary.withValues(alpha: 0.10),
                  const Color(0xFFF7FAFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.self_improvement_rounded,
        color: dark ? Colors.white.withValues(alpha: 0.80) : colors.primary,
        size: iconSize,
      ),
    );
  }
}
