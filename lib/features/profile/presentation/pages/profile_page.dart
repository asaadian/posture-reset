// lib/features/profile/presentation/pages/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/app_data/app_data_reset_signal.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/notifications/notification_history_repository.dart';
import '../../../../core/supabase/supabase_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/domain/access_models.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../player/application/session_continuity_providers.dart';
import '../../../player/domain/session_continuity_models.dart';
import '../../../programs/application/recovery_program_providers.dart';
import '../../../sessions/application/sessions_providers.dart';
import '../../application/profile_providers.dart';
import '../../domain/profile_models.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final user = ref.watch(currentUserProvider);
    final auth = ref.read(authServiceProvider);

    final profileAsync = ref.watch(currentUserProfileProvider);
    final savedIdsAsync = ref.watch(savedSessionIdsProvider);
    final recentRunsAsync = ref.watch(recentSessionRunsProvider);
    final continueCandidateAsync = ref.watch(continueSessionCandidateProvider);

    Future<void> refreshProfile() async {
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(savedSessionIdsProvider);
      ref.invalidate(recentSessionRunsProvider);
      ref.invalidate(continueSessionCandidateProvider);
      await Future.wait([
        ref.read(currentUserProfileProvider.future),
        ref.read(savedSessionIdsProvider.future),
        ref.read(recentSessionRunsProvider.future),
        ref.read(continueSessionCandidateProvider.future),
      ]);
    }

    return WillPopScope(
      onWillPop: () async {
        context.goNamed('dashboard');
        return false;
      },
      child: ResponsivePageScaffold(
      leading: IconButton(
        onPressed: () => context.goNamed('dashboard'),
        tooltip: t.get('common_back', fallback: 'Back to dashboard'),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(t.get('profile_title', fallback: 'Profile')),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed('settings'),
          tooltip: t.get('profile_settings_tooltip', fallback: 'Open settings'),
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        final profile = profileAsync.maybeWhen(data: (v) => v, orElse: () => null);
        final savedCount = savedIdsAsync.maybeWhen(data: (ids) => ids.length, orElse: () => 0);
        final recentRunsCount = recentRunsAsync.maybeWhen(data: (runs) => runs.length, orElse: () => 0);
        final continueCandidate = continueCandidateAsync.maybeWhen(data: (value) => value, orElse: () => null);
        final isWide = pageInfo.isMedium || pageInfo.isExpanded;

        return RefreshIndicator(
          onRefresh: refreshProfile,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 128 : 42),
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: _ProfileHeroCard(
                        userEmail: user?.email,
                        isAuthenticated: user != null,
                        profile: profile,
                        savedCount: savedCount,
                        recentRunsCount: recentRunsCount,
                        continueCandidate: continueCandidate,
                        onEditProfile: user == null
                            ? null
                            : () => _showEditProfileSheet(context, profile),
                        onPrimaryAction: () => _handlePrimaryAction(
                          context: context,
                          userSignedIn: user != null,
                          continueCandidate: continueCandidate,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          _ProfileActionGrid(
                            onSaved: () => context.pushNamed('saved-sessions'),
                            onHistory: () => context.pushNamed('session-history'),
                            onPrograms: () => context.pushNamed('recovery-programs'),
                            onPremium: () => _openPremium(context, ref),
                          ),
                          const SizedBox(height: 14),
                          _AccountPanel(
                            isAuthenticated: user != null,
                            onEditProfile: user == null ? null : () => _showEditProfileSheet(context, profile),
                            onSettings: () => context.pushNamed('settings'),
                            onSignOutOrCreate: user != null
                                ? () => _signOut(context, auth)
                                : () => context.push('/auth?mode=signup&redirect=/app/profile'),
                          ),
                          const SizedBox(height: 14),
                          const _ProfileDangerZone(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _ProfileHeroCard(
                  userEmail: user?.email,
                  isAuthenticated: user != null,
                  profile: profile,
                  savedCount: savedCount,
                  recentRunsCount: recentRunsCount,
                  continueCandidate: continueCandidate,
                  onEditProfile: user == null ? null : () => _showEditProfileSheet(context, profile),
                  onPrimaryAction: () => _handlePrimaryAction(
                    context: context,
                    userSignedIn: user != null,
                    continueCandidate: continueCandidate,
                  ),
                ),
                const SizedBox(height: 14),
                _ProfileActionGrid(
                  onSaved: () => context.pushNamed('saved-sessions'),
                  onHistory: () => context.pushNamed('session-history'),
                  onPrograms: () => context.pushNamed('recovery-programs'),
                  onPremium: () => _openPremium(context, ref),
                ),
                const SizedBox(height: 14),
                _AccountPanel(
                  isAuthenticated: user != null,
                  onEditProfile: user == null ? null : () => _showEditProfileSheet(context, profile),
                  onSettings: () => context.pushNamed('settings'),
                  onSignOutOrCreate: user != null
                      ? () => _signOut(context, auth)
                      : () => context.push('/auth?mode=signup&redirect=/app/profile'),
                ),
                const SizedBox(height: 14),
                const _ProfileDangerZone(),
              ],
            ],
          ),
        );
      },
    ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserProfile? profile) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => _EditProfileSheet(
        initialDisplayName: profile?.displayName ?? '',
        avatarUrl: profile?.avatarUrl,
      ),
    );
  }

  void _handlePrimaryAction({
    required BuildContext context,
    required bool userSignedIn,
    required dynamic continueCandidate,
  }) {
    if (continueCandidate != null) {
      final canOpenPlayerDirectly =
          continueCandidate.reason == ContinuityReason.activeRun ||
          continueCandidate.reason == ContinuityReason.resumableRun ||
          continueCandidate.action == ContinuityActionType.continueSession ||
          continueCandidate.action == ContinuityActionType.resumeSession;

      if (canOpenPlayerDirectly) {
        context.pushNamed(
          'session-player',
          pathParameters: {'id': continueCandidate.sessionId},
          queryParameters: const {'source': 'profile'},
        );
        return;
      }

      context.pushNamed('session-detail', pathParameters: {'id': continueCandidate.sessionId});
      return;
    }

    if (userSignedIn) {
      context.goNamed('sessions');
      return;
    }

    context.push('/auth?mode=signin&redirect=/app/profile');
  }

  void _openPremium(BuildContext context, WidgetRef ref) {
    unawaited(
      ref.read(analyticsServiceProvider).track(
            AnalyticsEvent(
              eventName: AnalyticsEvents.lockedFeatureCtaTapped,
              sourceSurface: AnalyticsSurfaces.profile,
              featureKey: 'core_access_paywall_entry',
              accessTier: AccessTier.coreAccess.code,
              entitlementKey: Entitlement.coreAccess.key,
            ),
          ),
    );
    context.pushNamed('premium');
  }

  Future<void> _signOut(BuildContext context, dynamic auth) async {
    final t = AppText.of(context);
    await auth.signOut();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.get('auth_signed_out_success', fallback: 'Signed out successfully.'))),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.userEmail,
    required this.isAuthenticated,
    required this.profile,
    required this.savedCount,
    required this.recentRunsCount,
    required this.continueCandidate,
    required this.onEditProfile,
    required this.onPrimaryAction,
  });

  final String? userEmail;
  final bool isAuthenticated;
  final UserProfile? profile;
  final int savedCount;
  final int recentRunsCount;
  final dynamic continueCandidate;
  final VoidCallback? onEditProfile;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final displayName = _profileDisplayName(context, profile, userEmail, isAuthenticated);
    final email = (userEmail ?? '').trim();
    final initials = displayName.trim().isEmpty ? 'P' : displayName.characters.first.toUpperCase();
    final primaryLabel = isAuthenticated
        ? continueCandidate != null
            ? t.get('profile_primary_continue', fallback: 'Continue recovery')
            : t.get('profile_primary_open_sessions', fallback: 'Start training')
        : t.get('profile_sign_in_cta', fallback: 'Sign in');

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [Color(0xFF07101F), Color(0xFF101B32), Color(0xFF182642)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(right: -96, top: -96, child: _ProfileGlow(size: 260, color: Color(0xFF5B6CFF), alpha: 0.32)),
          const Positioned(left: -110, bottom: -130, child: _ProfileGlow(size: 280, color: Color(0xFF13C6C1), alpha: 0.22)),
          Column(
            children: [
              const SizedBox(height: 2),
              _PremiumAvatar(initials: initials, avatarUrl: profile?.avatarUrl, onEdit: onEditProfile),
              const SizedBox(height: 14),
              _StatusBadge(
                label: isAuthenticated
                    ? t.get('profile_sync_connected', fallback: 'Synced')
                    : t.get('profile_sync_local', fallback: 'Local'),
                icon: isAuthenticated ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              ),
              const SizedBox(height: 10),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.55,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email.isNotEmpty
                    ? email
                    : t.get('profile_guest_subtitle', fallback: 'Guest profile'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: t.get('profile_metric_saved', fallback: 'Saved'),
                      value: '$savedCount',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroMetric(
                      label: t.get('profile_metric_runs', fallback: 'Runs'),
                      value: '$recentRunsCount',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroMetric(
                      label: t.get('profile_metric_status', fallback: 'Status'),
                      value: isAuthenticated ? 'On' : 'Off',
                    ),
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }

  String _profileDisplayName(
    BuildContext context,
    UserProfile? profile,
    String? email,
    bool isAuthenticated,
  ) {
    final profileName = profile?.displayName?.trim();
    if (profileName != null && profileName.isNotEmpty) return profileName;
    final cleanEmail = email?.trim() ?? '';
    if (cleanEmail.contains('@')) return cleanEmail.split('@').first;
    return isAuthenticated
        ? AppText.get(context, key: 'profile_account_signed_in_name', fallback: 'Account')
        : AppText.get(context, key: 'profile_account_guest_name', fallback: 'Guest');
  }
}

class _ProfileActionGrid extends StatelessWidget {
  const _ProfileActionGrid({
    required this.onSaved,
    required this.onHistory,
    required this.onPrograms,
    required this.onPremium,
  });

  final VoidCallback onSaved;
  final VoidCallback onHistory;
  final VoidCallback onPrograms;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    final premium = _ProfileActionData(
      icon: Icons.workspace_premium_rounded,
      title: t.get('profile_action_premium', fallback: 'Core Access'),
      subtitle: t.get(
        'profile_action_premium_subtitle_large',
        fallback: 'Unlock all sessions, programs, Quick Fix, and insights.',
      ),
      accent: const Color(0xFF8B5CF6),
      onTap: onPremium,
    );

    final actions = [
      _ProfileActionData(
        icon: Icons.bookmark_border_rounded,
        title: t.get('profile_action_saved_short', fallback: 'Saved'),
        subtitle: t.get('profile_action_saved_subtitle_short', fallback: 'Sessions'),
        accent: colors.primary,
        onTap: onSaved,
      ),
      _ProfileActionData(
        icon: Icons.history_rounded,
        title: t.get('session_history_title_compact', fallback: 'History'),
        subtitle: t.get('profile_action_history_subtitle_short', fallback: 'Runs'),
        accent: colors.secondary,
        onTap: onHistory,
      ),
      _ProfileActionData(
        icon: Icons.route_rounded,
        title: t.get('profile_action_programs', fallback: 'Programs'),
        subtitle: t.get('profile_action_programs_subtitle_short', fallback: 'Plans'),
        accent: colors.tertiary,
        onTap: onPrograms,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 360 ? 8.0 : 10.0;
        final compact = constraints.maxWidth < 430;
        final columns = constraints.maxWidth >= 720 ? 3 : 3;
        final width = (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfilePremiumActionTile(data: premium),
            SizedBox(height: compact ? 8 : 10),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: actions
                  .map(
                    (item) => SizedBox(
                      width: width,
                      child: _ProfileCompactActionTile(data: item),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.isAuthenticated,
    required this.onEditProfile,
    required this.onSettings,
    required this.onSignOutOrCreate,
  });

  final bool isAuthenticated;
  final VoidCallback? onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onSignOutOrCreate;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return _ProfileSection(
      icon: Icons.person_outline_rounded,
      accent: colors.primary,
      title: t.get('profile_account_section_title', fallback: 'Account'),
      subtitle: t.get('profile_account_section_subtitle', fallback: 'Profile and app controls.'),
      children: [
        _ProfileActionRow(
          icon: Icons.edit_outlined,
          title: t.get('profile_edit_title', fallback: 'Edit profile'),
          subtitle: t.get('profile_edit_subtitle', fallback: 'Name and photo'),
          onTap: onEditProfile,
        ),
        const SizedBox(height: 8),
        _ProfileActionRow(
          icon: Icons.settings_outlined,
          title: t.get('profile_action_settings', fallback: 'Settings'),
          subtitle: t.get('profile_action_settings_subtitle_compact', fallback: 'App'),
          onTap: onSettings,
        ),
        const SizedBox(height: 8),
        _ProfileActionRow(
          icon: isAuthenticated ? Icons.logout_rounded : Icons.person_add_alt_1_rounded,
          title: isAuthenticated
              ? t.get('profile_sign_out_cta', fallback: 'Sign out')
              : t.get('profile_create_account_cta', fallback: 'Create account'),
          subtitle: isAuthenticated
              ? t.get('profile_sign_out_subtitle', fallback: 'Leave this device')
              : t.get('profile_create_account_subtitle', fallback: 'Sync your progress'),
          onTap: onSignOutOrCreate,
        ),
      ],
    );
  }
}

class _ProfileDangerZone extends ConsumerStatefulWidget {
  const _ProfileDangerZone();

  @override
  ConsumerState<_ProfileDangerZone> createState() => _ProfileDangerZoneState();
}

class _ProfileDangerZoneState extends ConsumerState<_ProfileDangerZone> {
  bool _isResetting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return _ProfileSection(
      icon: Icons.warning_amber_rounded,
      accent: colors.error,
      title: t.get('profile_danger_zone_title', fallback: 'Danger Zone'),
      subtitle: t.get('profile_danger_zone_subtitle', fallback: 'Account and data removal.'),
      children: [
        _ProfileActionRow(
          icon: Icons.restart_alt_rounded,
          title: t.get('settings_reset_app_data_title', fallback: 'Reset app data'),
          subtitle: _isResetting
              ? t.get('settings_reset_app_data_loading', fallback: 'Deleting your app data...')
              : t.get('settings_reset_app_data_subtitle_short', fallback: 'Clear progress, saved items, and history.'),
          danger: true,
          onTap: _isResetting ? null : _confirmAndResetAppData,
        ),
        const SizedBox(height: 8),
        _ProfileActionRow(
          icon: Icons.no_accounts_rounded,
          title: t.get('settings_delete_account_section_title', fallback: 'Delete account'),
          subtitle: _isDeleting
              ? t.get('settings_delete_account_loading', fallback: 'Deleting account...')
              : t.get('settings_delete_account_section_subtitle', fallback: 'Permanently remove your account and app data.'),
          danger: true,
          onTap: _isDeleting ? null : _confirmAndDeleteAccount,
        ),
      ],
    );
  }

  Future<void> _confirmAndResetAppData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(AppText.get(dialogContext, key: 'settings_reset_app_data_dialog_title', fallback: 'Reset app data?')),
          content: Text(
            AppText.get(
              dialogContext,
              key: 'settings_reset_app_data_dialog_body',
              fallback: 'This removes your training history, saved sessions, program progress, quick-fix history, feedback, profile, and preferences. Your sign-in account stays active. This cannot be undone.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppText.get(dialogContext, key: 'common_cancel', fallback: 'Cancel')),
            ),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(foregroundColor: colors.onErrorContainer, backgroundColor: colors.errorContainer),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(AppText.get(dialogContext, key: 'settings_reset_app_data_confirm', fallback: 'Reset data')),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) await _resetAppData();
  }

  Future<void> _resetAppData() async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      _showSnack(AppText.get(context, key: 'settings_reset_app_data_sign_in_required', fallback: 'Sign in first to reset your app data.'));
      return;
    }

    setState(() => _isResetting = true);
    try {
      final response = await client.functions.invoke('reset_app_data');
      final data = response.data;
      if (data is Map && data['ok'] == false) {
        final error = data['error']?.toString() ?? 'reset_app_data_failed';
        final table = data['table']?.toString();
        final code = data['code']?.toString();
        final message = data['message']?.toString();
        throw Exception([
          error,
          if (table != null && table.isNotEmpty) 'table: $table',
          if (code != null && code.isNotEmpty) 'code: $code',
          if (message != null && message.isNotEmpty) message,
        ].join(' | '));
      }
      await _invalidateUserData(userId: user.id);
      if (!mounted) return;
      _showSnack(AppText.get(context, key: 'settings_reset_app_data_success', fallback: 'Your app data has been reset.'));
      context.go('/app/dashboard');
    } catch (error) {
      if (!mounted) return;
      _showSnack('${AppText.get(context, key: 'settings_reset_app_data_failed', fallback: 'Could not reset app data.')} ${error.toString()}');
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(AppText.get(dialogContext, key: 'settings_delete_account_dialog_title', fallback: 'Delete account?')),
          content: Text(
            AppText.get(
              dialogContext,
              key: 'settings_delete_account_dialog_body',
              fallback: 'Your profile, preferences, saved sessions, history, purchase access, and account data will be removed. This cannot be undone.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppText.get(dialogContext, key: 'common_cancel', fallback: 'Cancel')),
            ),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(foregroundColor: colors.onErrorContainer, backgroundColor: colors.errorContainer),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(AppText.get(dialogContext, key: 'settings_delete_account_confirm', fallback: 'Delete')),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      _showSnack(AppText.get(context, key: 'settings_delete_account_sign_in_required', fallback: 'Sign in first to delete your account.'));
      return;
    }

    setState(() => _isDeleting = true);
    try {
      final response = await client.functions.invoke('delete_account');
      final data = response.data;
      if (data is Map && data['ok'] == false) {
        throw Exception(data['error'] ?? 'delete_account_failed');
      }
      await _clearLocalNotificationState(userId: user.id);
      await client.auth.signOut();
      if (!mounted) return;
      _showSnack(AppText.get(context, key: 'settings_delete_account_success', fallback: 'Your account has been deleted.'));
      context.go('/app/dashboard');
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppText.get(context, key: 'settings_delete_account_failed', fallback: 'Could not delete your account. Please contact support.'));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _invalidateUserData({required String userId}) async {
    await _clearLocalNotificationState(userId: userId);

    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(userPreferencesControllerProvider);
    ref.invalidate(savedSessionIdsProvider);
    ref.invalidate(recoveryProgramSummariesProvider);
    ref.invalidate(activeRecoveryProgramDashboardProgressProvider);
    notifyAppDataReset(ref);
    ref.invalidate(recentSessionRunsProvider);
    ref.invalidate(continueSessionCandidateProvider);

    try {
      final summaries = await ref.read(recoveryProgramSummariesProvider.future);
      for (final program in summaries) {
        ref.invalidate(recoveryProgramDetailProvider(program.id));
        ref.invalidate(recoveryProgramProgressProvider(program.id));
        ref.invalidate(recoveryProgramDayProgressMapProvider(program.id));
      }
    } catch (_) {}
  }

  Future<void> _clearLocalNotificationState({required String userId}) async {
    await LocalNotificationService.instance.cancelRecoveryReminders();
    await ref
        .read(notificationHistoryRepositoryProvider)
        .clearForUser(userId, includeLegacyUserlessItems: true);

    ref.invalidate(notificationHistoryItemsProvider(userId));
    ref.invalidate(notificationHistoryUnreadCountProvider(userId));
    ref.invalidate(notificationHistoryItemsProvider(null));
    ref.invalidate(notificationHistoryUnreadCountProvider(null));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: context.accentCardGradient,
        border: Border.all(color: context.subtleBorderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.14) : accent.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: accent.withValues(alpha: isDark ? 0.16 : 0.11)),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w900, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = danger ? colors.error : colors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: danger
                ? colors.errorContainer.withValues(alpha: isDark ? 0.18 : 0.26)
                : isDark
                    ? colors.surfaceContainerHighest.withValues(alpha: 0.32)
                    : Colors.white.withValues(alpha: 0.62),
            border: Border.all(
              color: danger
                  ? colors.error.withValues(alpha: 0.24)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.42),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: accent.withValues(alpha: 0.12)),
                child: Icon(icon, size: 21, color: accent),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w900, height: 1.05),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: danger ? colors.error : colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileActionData {
  const _ProfileActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
}

class _ProfilePremiumActionTile extends StatelessWidget {
  const _ProfilePremiumActionTile({required this.data});

  final _ProfileActionData data;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final foreground = isDark ? Colors.white : const Color(0xFF101827);
    final mutedForeground = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: data.onTap,
        child: Ink(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isDark
                  ? const [
                      Color(0xFF321B5F),
                      Color(0xFF193A63),
                      Color(0xFF073B3F),
                    ]
                  : const [
                      Color(0xFFF1E9FF),
                      Color(0xFFE6F1FF),
                      Color(0xFFE0FBF5),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: data.accent.withValues(alpha: isDark ? 0.52 : 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: data.accent.withValues(alpha: isDark ? 0.30 : 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -36,
                top: -44,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
                  ),
                ),
              ),
              Positioned(
                left: -34,
                bottom: -56,
                child: Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF12B8C7)
                        .withValues(alpha: isDark ? 0.12 : 0.10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          data.accent,
                          const Color(0xFF12B8C7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.accent.withValues(alpha: 0.34),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : colors.primary.withValues(alpha: 0.10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : colors.primary.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            t.get(
                              'profile_core_access_badge',
                              fallback: 'CORE ACCESS',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? Colors.white : colors.primary,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: mutedForeground,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.13)
                              : colors.primary.withValues(alpha: 0.12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : colors.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark ? Colors.white : colors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.get(
                          'profile_core_access_cta_short',
                          fallback: 'Open',
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: mutedForeground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCompactActionTile extends StatelessWidget {
  const _ProfileCompactActionTile({required this.data});

  final _ProfileActionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: data.onTap,
        child: Ink(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: context.premiumCardGradient,
            border: Border.all(color: context.subtleBorderColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.10)
                    : data.accent.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: data.accent.withValues(alpha: isDark ? 0.16 : 0.11),
                ),
                child: Icon(data.icon, color: data.accent, size: 17),
              ),
              const Spacer(),
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.085),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.70), fontWeight: FontWeight.w800, height: 1),
          ),
        ],
      ),
    );
  }
}

class _PrimaryProfileButton extends StatelessWidget {
  const _PrimaryProfileButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [Color(0xFF5B6CFF), Color(0xFF12B8C7)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B6CFF).withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 23),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, height: 1),
          ),
        ],
      ),
    );
  }
}

class _PremiumAvatar extends StatelessWidget {
  const _PremiumAvatar({required this.initials, required this.avatarUrl, required this.onEdit});
  final String initials;
  final String? avatarUrl;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (avatarUrl ?? '').trim().isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasAvatar ? null : const LinearGradient(colors: [Color(0xFF5B6CFF), Color(0xFF12B8C7)]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B6CFF).withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: hasAvatar
              ? Image.network(avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _AvatarInitials(initials: initials))
              : _AvatarInitials(initials: initials),
        ),
        if (onEdit != null)
          Positioned(
            right: -4,
            bottom: 4,
            child: Material(
              color: const Color(0xFF5B6CFF),
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.camera_alt_rounded, size: 17, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});
  final String initials;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ProfileGlow extends StatelessWidget {
  const _ProfileGlow({required this.size, required this.color, required this.alpha});
  final double size;
  final Color color;
  final double alpha;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.initialDisplayName, required this.avatarUrl});
  final String initialDisplayName;
  final String? avatarUrl;
  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDisplayName);
    _avatarUrl = widget.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileActionsControllerProvider).updateDisplayName(_nameController.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.get(context, key: 'profile_edit_saved', fallback: 'Profile updated.'))),
      );
    } catch (_) {
      if (!mounted) return;
      _showError();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 900, imageQuality: 82);
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await picked.readAsBytes();
      final extension = picked.name.contains('.') ? picked.name.split('.').last : 'jpg';
      final contentType = switch (extension.toLowerCase()) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      final updated = await ref.read(profileActionsControllerProvider).uploadAvatar(bytes: bytes, extension: extension, contentType: contentType);
      if (!mounted) return;
      setState(() => _avatarUrl = updated?.avatarUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.get(context, key: 'profile_avatar_updated', fallback: 'Profile photo updated.'))),
      );
    } catch (_) {
      if (!mounted) return;
      _showError();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileActionsControllerProvider).removeAvatar();
      if (!mounted) return;
      setState(() => _avatarUrl = null);
    } catch (_) {
      if (!mounted) return;
      _showError();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.get(context, key: 'profile_edit_error', fallback: 'Profile could not be updated. Please try again.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomSafe = mediaQuery.viewPadding.bottom;
    final hasAvatar = (_avatarUrl ?? '').trim().isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              gradient: isDark ? context.premiumCardGradient : context.accentCardGradient,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.74 : 0.60))),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.86),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + bottomSafe),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 42, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: theme.colorScheme.outlineVariant)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          t.get('profile_edit_title', fallback: 'Edit profile'),
                          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        IconButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                      backgroundImage: hasAvatar ? NetworkImage(_avatarUrl!) : null,
                      child: hasAvatar ? null : Icon(Icons.person_rounded, size: 38, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _changePhoto,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(t.get('profile_change_photo_cta', fallback: 'Change photo')),
                        ),
                        if (hasAvatar)
                          OutlinedButton.icon(
                            onPressed: _saving ? null : _removePhoto,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(t.get('profile_remove_photo_cta', fallback: 'Remove')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nameController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: t.get('profile_display_name_label', fallback: 'Display name'), border: const OutlineInputBorder()),
                      onSubmitted: (_) {
                        if (!_saving) unawaited(_saveName());
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveName,
                        icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
                        label: Text(t.get('profile_save_cta', fallback: 'Save')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
