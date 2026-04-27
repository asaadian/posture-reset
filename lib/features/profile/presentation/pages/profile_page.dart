// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../player/domain/session_continuity_models.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../player/application/session_continuity_providers.dart';
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
    final preferencesAsync = ref.watch(userPreferencesControllerProvider);
    final savedIdsAsync = ref.watch(savedSessionIdsProvider);
    final recentRunsAsync = ref.watch(recentSessionRunsProvider);
    final continueCandidateAsync = ref.watch(continueSessionCandidateProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('profile_title', fallback: 'Profile')),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed('settings'),
          tooltip: t.get('profile_settings_tooltip', fallback: 'Open settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        final spacing = pageInfo.isCompact ? 16.0 : 20.0;
        final isWide = pageInfo.isMedium || pageInfo.isExpanded;

        final savedCount = savedIdsAsync.maybeWhen(
          data: (ids) => ids.length,
          orElse: () => 0,
        );

        final recentRunsCount = recentRunsAsync.maybeWhen(
          data: (runs) => runs.length,
          orElse: () => 0,
        );

        final continueCandidate = continueCandidateAsync.maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

        return ListView(
          padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
          children: [
            _ProfileOverviewCard(
              isAuthenticated: user != null,
              email: user?.email,
              profileAsync: profileAsync,
              preferencesAsync: preferencesAsync,
              savedCount: savedCount,
              recentRunsCount: recentRunsCount,
              hasContinueCandidate: continueCandidate != null,
              onPrimaryAction: () {
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

                  context.pushNamed(
                    'session-detail',
                    pathParameters: {'id': continueCandidate.sessionId},
                  );
                  return;
                }

                context.goNamed('sessions');
              },
              onSecondaryAction: user != null
                  ? () async {
                      await auth.signOut();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            t.get(
                              'auth_signed_out_success',
                              fallback: 'Signed out successfully.',
                            ),
                          ),
                        ),
                      );
                    }
                  : () {
                      context.push('/auth?mode=signin&redirect=/app/profile');
                    },
              onCreateAccount: () {
                context.push('/auth?mode=signup&redirect=/app/profile');
              },
            ),
            SizedBox(height: spacing),
            _ContinuityShortcuts(
              onSaved: () => context.pushNamed('saved-sessions'),
              onHistory: () => context.pushNamed('session-history'),
            ),
            SizedBox(height: spacing),
            _CompactControlCenter(
              isWide: isWide,
              onModeSettings: () => context.pushNamed('mode-settings'),
              onNotifications: () =>
                  context.pushNamed('notification-settings'),
              onAudio: () => context.pushNamed('audio-settings'),
              onSettings: () => context.pushNamed('settings'),
              onIntegrations: () => context.pushNamed('integrations'),
              onPremium: () => context.pushNamed('premium'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileOverviewCard extends StatelessWidget {
  const _ProfileOverviewCard({
    required this.isAuthenticated,
    required this.email,
    required this.profileAsync,
    required this.preferencesAsync,
    required this.savedCount,
    required this.recentRunsCount,
    required this.hasContinueCandidate,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onCreateAccount,
  });

  final bool isAuthenticated;
  final String? email;
  final AsyncValue<UserProfile?> profileAsync;
  final AsyncValue<UserPreferences?> preferencesAsync;
  final int savedCount;
  final int recentRunsCount;
  final bool hasContinueCandidate;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);
    final colorScheme = theme.colorScheme;

    final profile = profileAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    final prefs = preferencesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    final displayName = _resolveDisplayName(
      profile: profile,
      email: email,
      isAuthenticated: isAuthenticated,
      t: t,
    );
    final emailText = (email ?? '').trim();
    final initials = displayName.isEmpty
        ? t
            .get(
              isAuthenticated
                  ? 'profile_initial_signed_in'
                  : 'profile_initial_guest',
              fallback: isAuthenticated ? 'A' : 'G',
            )
            .characters
            .first
            .toUpperCase()
        : displayName.characters.first.toUpperCase();

    final localeCode = (prefs?.preferredLocale ?? 'en').toUpperCase();
    final silentEnabled = prefs?.preferredSilentMode ?? false;
    final notificationsEnabled = prefs?.notificationsEnabled ?? true;
    final syncState = isAuthenticated
        ? t.get('profile_sync_connected', fallback: 'Connected')
        : t.get('profile_sync_local', fallback: 'Local');

    final primaryLabel = hasContinueCandidate
        ? t.get('profile_primary_continue', fallback: 'Continue')
        : t.get('profile_primary_open_sessions', fallback: 'Sessions');
    final primaryIcon = hasContinueCandidate
        ? Icons.play_arrow_rounded
        : Icons.grid_view_rounded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.18),
            const Color(0xFF63E4D7).withValues(alpha: 0.12),
            colorScheme.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 780;

            final identity = _IdentityBlock(
              initials: initials,
              displayName: displayName,
              email: emailText,
              isAuthenticated: isAuthenticated,
            );

            final compactInfo = Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CompactInfoChip(
                      icon: Icons.language_rounded,
                      label: t.get('settings_pref_locale', fallback: 'Language'),
                      value: localeCode,
                    ),
                    _CompactInfoChip(
                      icon: Icons.volume_off_rounded,
                      label: t.get('profile_chip_silent', fallback: 'Silent'),
                      value: silentEnabled
                          ? t.get('common_on', fallback: 'On')
                          : t.get('common_off', fallback: 'Off'),
                    ),
                    _CompactInfoChip(
                      icon: Icons.cloud_done_outlined,
                      label: t.get('profile_chip_sync', fallback: 'Sync'),
                      value: syncState,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.bookmark_added_outlined,
                        label: t.get('profile_stat_saved', fallback: 'Saved'),
                        value: '$savedCount',
                        tone: const Color(0xFF63E4D7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.history_rounded,
                        label: t.get('profile_stat_runs', fallback: 'Runs'),
                        value: '$recentRunsCount',
                        tone: const Color(0xFF89A3FF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.notifications_none_rounded,
                        label: t.get('profile_stat_alerts', fallback: 'Alerts'),
                        value: notificationsEnabled
                            ? t.get('common_on', fallback: 'On')
                            : t.get('common_off', fallback: 'Off'),
                        tone: const Color(0xFFA88BFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isAuthenticated)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onPrimaryAction,
                          icon: Icon(primaryIcon),
                          label: Text(primaryLabel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSecondaryAction,
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(
                            t.get(
                              'profile_sign_out_cta',
                              fallback: 'Sign out',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onSecondaryAction,
                          icon: const Icon(Icons.login_rounded),
                          label: Text(
                            t.get(
                              'profile_sign_in_cta',
                              fallback: 'Sign in',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCreateAccount,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(
                            t.get(
                              'profile_create_account_cta',
                              fallback: 'Create',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: identity),
                  const SizedBox(width: 18),
                  Expanded(flex: 14, child: compactInfo),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 16),
                compactInfo,
              ],
            );
          },
        ),
      ),
    );
  }

  String _resolveDisplayName({
    required UserProfile? profile,
    required String? email,
    required bool isAuthenticated,
    required AppTextReader t,
  }) {
    if ((profile?.displayName ?? '').trim().isNotEmpty) {
      return profile!.displayName!.trim();
    }

    final cleanEmail = (email ?? '').trim();
    if (cleanEmail.isNotEmpty && cleanEmail.contains('@')) {
      return cleanEmail.split('@').first;
    }

    if (isAuthenticated) {
      return t.get('profile_account_signed_in_name', fallback: 'Account');
    }

    return t.get('profile_account_guest_name', fallback: 'Guest');
  }
}

class _ContinuityShortcuts extends StatelessWidget {
  const _ContinuityShortcuts({
    required this.onSaved,
    required this.onHistory,
  });

  final VoidCallback onSaved;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSaved,
            icon: const Icon(Icons.bookmark_border_rounded),
            label: Text(
              AppText.get(
                context,
                key: 'saved_sessions_title',
                fallback: 'Saved Sessions',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onHistory,
            icon: const Icon(Icons.history_rounded),
            label: Text(
              AppText.get(
                context,
                key: 'session_history_title',
                fallback: 'Session History',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({
    required this.initials,
    required this.displayName,
    required this.email,
    required this.isAuthenticated,
  });

  final String initials;
  final String displayName;
  final String email;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);
    final subtitle = isAuthenticated
        ? t.get(
            'profile_identity_signed_in',
            fallback: 'Recovery profile active',
          )
        : t.get(
            'profile_identity_guest',
            fallback: 'Sign in to sync your recovery system',
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF84A1FF),
                Color(0xFFAAB8FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF84A1FF).withValues(alpha: 0.22),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            subtitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactInfoChip extends StatelessWidget {
  const _CompactInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surface.withValues(alpha: 0.68),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF89A3FF),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surface.withValues(alpha: 0.68),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactControlCenter extends StatelessWidget {
  const _CompactControlCenter({
    required this.isWide,
    required this.onModeSettings,
    required this.onNotifications,
    required this.onAudio,
    required this.onSettings,
    required this.onIntegrations,
    required this.onPremium,
  });

  final bool isWide;
  final VoidCallback onModeSettings;
  final VoidCallback onNotifications;
  final VoidCallback onAudio;
  final VoidCallback onSettings;
  final VoidCallback onIntegrations;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final items = <_QuickActionItem>[
      _QuickActionItem(
        title: t.get('profile_action_modes', fallback: 'Modes'),
        icon: Icons.tune_rounded,
        tone: const Color(0xFF89A3FF),
        onTap: onModeSettings,
      ),
      _QuickActionItem(
        title: t.get('profile_action_notifications', fallback: 'Notifications'),
        icon: Icons.notifications_active_outlined,
        tone: const Color(0xFF63E4D7),
        onTap: onNotifications,
      ),
      _QuickActionItem(
        title: t.get('profile_action_audio', fallback: 'Audio'),
        icon: Icons.graphic_eq_rounded,
        tone: const Color(0xFF63E4D7),
        onTap: onAudio,
      ),
      _QuickActionItem(
        title: t.get('profile_action_settings', fallback: 'Settings'),
        icon: Icons.settings_outlined,
        tone: const Color(0xFF89A3FF),
        onTap: onSettings,
      ),
      _QuickActionItem(
        title: t.get('profile_action_integrations', fallback: 'Integrations'),
        icon: Icons.hub_outlined,
        tone: const Color(0xFF63E4D7),
        onTap: onIntegrations,
      ),
      _QuickActionItem(
        title: t.get('profile_action_premium', fallback: 'Premium'),
        icon: Icons.workspace_premium_outlined,
        tone: const Color(0xFFA88BFF),
        onTap: onPremium,
      ),

    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get('profile_control_center_title', fallback: 'Control Center'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 1.55 : 1.28,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CompactActionCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactActionCard extends StatelessWidget {
  const _CompactActionCard({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: theme.colorScheme.surface.withValues(alpha: 0.68),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: item.tone.withValues(alpha: 0.10),
                        border: Border.all(
                          color: item.tone.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: item.tone,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
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

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;
}