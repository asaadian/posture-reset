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
import '../../../../shared/widgets/program_join_social_proof.dart';
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
import '../../../sessions/application/public_activity_stats_providers.dart';
import '../../../sessions/domain/session_models.dart';
import '../../../sessions/presentation/widgets/session_visual_asset.dart';

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
    final activeProgramAsync =
        ref.watch(activeRecoveryProgramDashboardProgressProvider);
    final programSummariesAsync = ref.watch(recoveryProgramSummariesProvider);
    final savedSessionsAsync = ref.watch(_dashboardSavedSessionsProvider);
    final sessionSummariesAsync = ref.watch(sessionSummariesProvider);
    final programJoinCountsAsync = ref.watch(publicProgramJoinCountsProvider);
    final dashboardAsync = ref.watch(dashboardControllerProvider);

    final profile = profileAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final accessSnapshot = accessAsync.maybeWhen(
      data: (value) => value,
      orElse: () => AccessSnapshot.guest,
    );
    final activeProgram = activeProgramAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final programs = programSummariesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <RecoveryProgramSummary>[],
    );
    final savedSessions = savedSessionsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <SessionSummary>[],
    );
    final allSessions = sessionSummariesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <SessionSummary>[],
    );

    final recommendedSessions = _recommendedTodaySessions(
      allSessions: allSessions,
      savedSessions: savedSessions,
      hasCoreAccess: accessSnapshot.hasCoreAccess,
    );
    return ResponsivePageScaffold(
      title: Text(_dashboardGreeting(t: t, profile: profile, email: user?.email)),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed('settings'),
          tooltip: 'Settings',
          icon: const Icon(Icons.tune_rounded),
        ),
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
              body: t.get('guide_dashboard_bottom_nav_body', fallback: 'Use the bottom tabs to open Explore, Quick Fix, Insights, and Profile.'),
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
                spacing: 8,
                children: [
                  _DashboardQuickFixDiscovery(
                    title: t.get(
                      'dashboard_new_quick_fix_title',
                      fallback: 'Where do you feel tension?',
                    ),
                    body: t.get(
                      'dashboard_new_quick_fix_body',
                      fallback: 'Find a matching desk reset in seconds.',
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (programs.isNotEmpty) ...[
                    _DashboardProgramCarousel(
                      programs: programs,
                      activeProgram: activeProgram,
                      joinedCounts: programJoinCountsAsync.value ?? const <String, int>{},
                    ),
                    const SizedBox(height: 2),
                  ],
                  dashboardAsync.maybeWhen(
                    data: (snapshot) => _WeeklyGoalCard(
                      completed: snapshot.completedSessionsThisWeek,
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 2),
                  dashboardAsync.maybeWhen(
                    data: (snapshot) {
                      final isNewUser = !snapshot.hasContent &&
                          (activeProgram == null || activeProgram.isCompleted);
                      if (isNewUser) {
                        return _DashboardNewUserHome(
                          programs: programs,
                          sessions: recommendedSessions.take(3).toList(growable: false),
                          showPremium: !accessSnapshot.hasCoreAccess,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DashboardPrimaryAction(
                            dashboardAsync: dashboardAsync,
                            activeProgram: activeProgram,
                            fallbackSession: recommendedSessions.isEmpty
                                ? null
                                : recommendedSessions.first,
                          ),
                          const SizedBox(height: 16),
                          _RecoveryStatusStrip(snapshot: snapshot),

                          if (recommendedSessions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _DashboardVisualSessions(
                              sessions: recommendedSessions.take(3).toList(growable: false),
                            ),
                          ],
                          if (snapshot.recentRuns.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _RecentRunsSection(
                              runs: snapshot.recentRuns.take(1).toList(growable: false),
                            ),
                          ],
                          if (!accessSnapshot.hasCoreAccess) ...[
                            const SizedBox(height: 16),
                            const _DashboardPremiumShowcase(),
                          ],
                        ],
                      );
                    },
                    loading: () => _DashboardPrimaryAction(
                      dashboardAsync: dashboardAsync,
                      activeProgram: activeProgram,
                      fallbackSession: recommendedSessions.isEmpty
                          ? null
                          : recommendedSessions.first,
                    ),
                    error: (_, __) => Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.get('dashboard_load_error_title',
                                  fallback: 'Could not load your activity'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.get('dashboard_load_error_body',
                                  fallback: 'Your workout history is safe. Check your connection and retry.'),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () => ref.invalidate(dashboardControllerProvider),
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(t.commonRetry),
                            ),
                          ],
                        ),
                      ),
                    ),
                    orElse: () => _DashboardPrimaryAction(
                      dashboardAsync: dashboardAsync,
                      activeProgram: activeProgram,
                      fallbackSession: recommendedSessions.isEmpty
                          ? null
                          : recommendedSessions.first,
                    ),
                  ),
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
    required bool hasCoreAccess,
  }) {
    if (allSessions.isEmpty) return const <SessionSummary>[];

    final savedIds = savedSessions.map((item) => item.id).toSet();

    final candidates = allSessions
        .where((session) => hasCoreAccess || session.accessTier == AccessTier.free)
        .where((session) => !savedIds.contains(session.id))
        .toList(growable: true);

    if (candidates.isEmpty) {
      candidates.addAll(allSessions.where(
        (session) => hasCoreAccess || session.accessTier == AccessTier.free,
      ));
    }

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



String _compactPublicCount(int count) {
  if (count < 1000) return '$count';
  if (count < 1000000) {
    if (count < 10000) return '${(count / 100).floor() / 10}K';
    return '${count ~/ 1000}K';
  }
  return '${(count / 100000).floor() / 10}M';
}

class _DashboardProgramCarousel extends StatelessWidget {
  const _DashboardProgramCarousel({
    required this.programs,
    required this.activeProgram,
    required this.joinedCounts,
  });

  final Map<String, int> joinedCounts;
  final List<RecoveryProgramSummary> programs;
  final RecoveryProgramDashboardProgress? activeProgram;

  @override
  Widget build(BuildContext context) {
    final ordered = [...programs]..sort((a, b) {
      if (a.id == activeProgram?.programId) return -1;
      if (b.id == activeProgram?.programId) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Text(
            'Your programs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          )),
          TextButton.icon(
            onPressed: () => context.pushNamed('recovery-programs'),
            label: const Text('View all'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 212,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final program = ordered[index];
              return SizedBox(
                width: 290,
                child: _ProgramPosterCard(
                  program: program,
                  activeProgram: activeProgram,
                  joinedCount: joinedCounts[program.id],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardNewUserHome extends StatelessWidget {
  const _DashboardNewUserHome({
    required this.programs,
    required this.sessions,
    required this.showPremium,
  });

  final List<RecoveryProgramSummary> programs;
  final List<SessionSummary> sessions;
  final bool showPremium;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: 18),
          _DashboardVisualSessions(sessions: sessions),
        ],
        if (showPremium) ...[
          const SizedBox(height: 18),
          const _DashboardPremiumShowcase(),
        ],
      ],
    );
  }
}

class _DashboardQuickFixDiscovery extends StatelessWidget {
  const _DashboardQuickFixDiscovery({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goNamed('quick-fix'),
        borderRadius: BorderRadius.circular(32),
        child: Ink(
          height: 236,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: isDark
                  ? [colors.primaryContainer.withValues(alpha: 0.70), colors.surfaceContainerHigh]
                  : [colors.primaryContainer.withValues(alpha: 0.72), colors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: isDark ? 0.18 : 0.09),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  top: 8,
                  bottom: -16,
                  width: 168,
                  child: Opacity(
                    opacity: isDark ? 0.82 : 0.92,
                    child: Image.asset(
                      'assets/images/body_map/front.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  right: 73,
                  top: 76,
                  child: _QuickFixPulse(color: colors.primary),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.surface.withValues(alpha: isDark ? 0.94 : 0.92),
                          colors.surface.withValues(alpha: 0.58),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.52, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            AppText.of(context).get(
                              'dashboard_quick_fix_badge',
                              fallback: 'QUICK FIX',
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppText.of(context).get(
                                'dashboard_quick_fix_cta',
                                fallback: 'Choose an area',
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.arrow_forward_rounded, color: colors.primary, size: 19),
                          ],
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

class _QuickFixPulse extends StatelessWidget {
  const _QuickFixPulse({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _DashboardPrimaryAction extends StatelessWidget {
  const _DashboardPrimaryAction({
    required this.dashboardAsync,
    required this.activeProgram,
    required this.fallbackSession,
  });

  final AsyncValue<DashboardSnapshot> dashboardAsync;
  final RecoveryProgramDashboardProgress? activeProgram;
  final SessionSummary? fallbackSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppText.of(context);
    final snapshot = dashboardAsync.maybeWhen(data: (value) => value, orElse: () => null);
    final next = snapshot?.nextSession;
    final sessionId = next?.sessionId ??
        (activeProgram?.hasCurrentSession == true ? activeProgram!.currentSessionId : null) ??
        fallbackSession?.id;
    final title = next != null
        ? t.get(next.titleKey, fallback: next.titleFallback)
        : activeProgram?.hasCurrentSession == true
            ? t.get(
                activeProgram!.currentSessionTitleKey ?? '',
                fallback: activeProgram!.currentSessionTitleFallback ?? 'Continue session',
              )
            : fallbackSession != null
                ? t.get(fallbackSession!.titleKey, fallback: fallbackSession!.titleFallback)
                : t.get('dashboard_quick_fix_title', fallback: 'Find your reset');
    final minutes = next?.durationMinutes ??
        activeProgram?.currentSessionDurationMinutes ??
        fallbackSession?.durationMinutes;
    final isResume = next?.isActiveRun == true;

    void open() {
      if (next != null) {
        context.pushNamed(
          isResume ? 'session-player' : 'session-detail',
          pathParameters: {'id': next.sessionId},
          queryParameters: isResume ? {'source': next.entrySource.dbValue} : const {},
        );
      } else if (activeProgram?.hasCurrentSession == true) {
        context.pushNamed(
          'session-detail',
          pathParameters: {'id': activeProgram!.currentSessionId!},
        );
      } else if (fallbackSession != null) {
        context.pushNamed('session-detail', pathParameters: {'id': fallbackSession!.id});
      } else {
        context.goNamed('quick-fix');
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: open,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          height: 232,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: colors.surface,
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (sessionId != null)
                SessionVisualStage(
                  sessionId: sessionId,
                  height: 232,
                  borderRadius: 30,
                  imageAlignment: Alignment.centerRight,
                  imageScale: 1.08,
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [colors.primaryContainer, colors.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      colors.surface.withValues(alpha: 0.98),
                      colors.surface.withValues(alpha: 0.82),
                      colors.surface.withValues(alpha: 0.08),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.get('dashboard_for_you_now', fallback: 'For you now'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                          ),
                        ),
                        if (minutes != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '$minutes ${t.get('session_duration_unit_min', fallback: 'min')}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: open,
                          icon: Icon(isResume ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded),
                          label: Text(
                            isResume
                                ? t.get('dashboard_continue_session', fallback: 'Continue')
                                : t.get('dashboard_start_session', fallback: 'Start'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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



class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.completed});

  final int completed;
  static const int target = 3;

  @override
  Widget build(BuildContext context) {
    final progress = (completed / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(26),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF142943), Color(0xFF175368), Color(0xFF14665E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.track_changes_rounded, color: Color(0xFF85DFC8)),
            const SizedBox(width: 9),
            const Expanded(child: Text(
              'Weekly goal',
              style: TextStyle(color: Colors.white, fontSize: 17,
                fontWeight: FontWeight.w800),
            )),
            Text('$completed / $target', style: const TextStyle(
              color: Color(0xFF85DFC8), fontSize: 16,
              fontWeight: FontWeight.w800,
            )),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              color: const Color(0xFF85DFC8),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            completed >= target
                ? 'Goal reached. Keep your routine going.'
                : '${target - completed} more ${target - completed == 1 ? 'session' : 'sessions'} to reach your goal this week.',
            style: const TextStyle(color: Color(0xFFD3E8EB), fontSize: 12),
          ),
        ],
      ),
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


class _ProgramPosterCard extends StatelessWidget {
  const _ProgramPosterCard({
    required this.program,
    required this.activeProgram,
    this.joinedCount,
  });

  final RecoveryProgramSummary program;
  final RecoveryProgramDashboardProgress? activeProgram;
  final int? joinedCount;

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
                if (joinedCount != null && joinedCount! > 0)
                  Positioned(
                    right: 7,
                    top: 8,
                    child: ProgramJoinSocialProof(
                      programId: program.id,
                      count: joinedCount!,
                      compact: true,
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


class _DashboardVisualSessions extends StatelessWidget {
  const _DashboardVisualSessions({required this.sessions});

  final List<SessionSummary> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final t = AppText.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width >= 760 ? 240.0 : 184.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: t.get('dashboard_recommended_title', fallback: 'Recommended today'),
          actionLabel: t.get('dashboard_see_all', fallback: 'See all'),
          onAction: () => context.goNamed('sessions'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return SizedBox(
                width: cardWidth,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.pushNamed(
                      'session-detail',
                      pathParameters: {'id': session.id},
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SessionVisualStage(
                            sessionId: session.id,
                            height: 132,
                            borderRadius: 24,
                            compact: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.get(session.titleKey, fallback: session.titleFallback),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${session.durationMinutes} ${t.get('session_duration_unit_min', fallback: 'min')}',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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
    final featured = icon == Icons.speed_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: featured ? const LinearGradient(
          colors: [Color(0xFF153C65), Color(0xFF14666B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        color: featured ? null : colors.surfaceContainerLow,
        border: featured ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: featured ? const Color(0xFF83F1D8) : colors.primary, size: 21),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: featured ? Colors.white : colors.onSurface,
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
              color: featured ? const Color(0xFFDAF4F1) : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPremiumShowcase extends StatelessWidget {
  const _DashboardPremiumShowcase();

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
                      t.get('dashboard_premium_title', fallback: 'Your complete recovery system'),
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
                        fallback: 'Guided programs, deeper insights, and every recovery session unlocked.',
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
                t.get('dashboard_premium_cta_short', fallback: 'Explore'),
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Tooltip(
        message: hasCoreAccess ? 'Premium active' : 'Explore Premium',
        child: Material(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onPremiumTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.asset(
                'assets/images/premium-badge.png',
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.workspace_premium_rounded,
                  color: colors.onPrimaryContainer,
                  size: 27,
                ),
              ),
            ),
          ),
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



