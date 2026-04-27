// lib/features/profile/presentation/widgets/profile_account_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/profile_providers.dart';

class ProfileAccountCard extends ConsumerWidget {
  const ProfileAccountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppText.of(context);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final preferencesAsync = ref.watch(userPreferencesControllerProvider);
    final auth = ref.read(authServiceProvider);

    final isSignedIn = user != null;
    final email = user?.email?.trim() ?? '';

    final profileName = profileAsync.maybeWhen(
      data: (profile) => profile?.displayName?.trim(),
      orElse: () => null,
    );

    final displayName = isSignedIn
        ? ((profileName != null && profileName.isNotEmpty)
            ? profileName
            : (email.isNotEmpty
                ? email.split('@').first
                : t.get(
                    'profile_account_signed_in_name',
                    fallback: 'Account',
                  )))
        : t.get(
            'profile_account_guest_name',
            fallback: 'Guest',
          );

    final subtitle = isSignedIn
        ? (email.isNotEmpty
            ? email
            : t.get(
                'profile_account_signed_in_subtitle',
                fallback: 'Signed in successfully.',
              ))
        : t.get(
            'profile_account_guest_subtitle',
            fallback:
                'Sign in to save sessions, sync your preferences, and keep your recovery data connected.',
          );

    final avatarText = displayName.trim().isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : t.get('profile_account_guest_initial', fallback: 'G');

    final silentDefault = preferencesAsync.maybeWhen(
      data: (prefs) => prefs?.preferredSilentMode == true,
      orElse: () => false,
    );

    final localeCode = preferencesAsync.maybeWhen(
      data: (prefs) => prefs?.preferredLocale.toUpperCase() ?? 'EN',
      orElse: () => 'EN',
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.tertiary.withValues(alpha: 0.07),
            colorScheme.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;

            final content = [
              Expanded(
                flex: isCompact ? 0 : 12,
                child: _AccountIdentityBlock(
                  displayName: displayName,
                  subtitle: subtitle,
                  avatarText: avatarText,
                  isSignedIn: isSignedIn,
                ),
              ),
              if (!isCompact) const SizedBox(width: 16),
              Expanded(
                flex: isCompact ? 0 : 10,
                child: _ProfileHeroStats(
                  isSignedIn: isSignedIn,
                  localeCode: localeCode,
                  silentDefault: silentDefault,
                ),
              ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCompact) ...[
                  _AccountIdentityBlock(
                    displayName: displayName,
                    subtitle: subtitle,
                    avatarText: avatarText,
                    isSignedIn: isSignedIn,
                  ),
                  const SizedBox(height: 16),
                  _ProfileHeroStats(
                    isSignedIn: isSignedIn,
                    localeCode: localeCode,
                    silentDefault: silentDefault,
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content,
                  ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: isSignedIn
                      ? [
                          _ProfileTag(
                            icon: Icons.verified_user_outlined,
                            label: t.get(
                              'profile_account_tag_signed_in',
                              fallback: 'Signed In',
                            ),
                          ),
                          _ProfileTag(
                            icon: Icons.sync_rounded,
                            label: t.get(
                              'profile_account_tag_cloud_synced',
                              fallback: 'Cloud Preferences',
                            ),
                          ),
                          _ProfileTag(
                            icon: Icons.bookmark_added_outlined,
                            label: t.get(
                              'profile_account_tag_session_save',
                              fallback: 'Session Saving Enabled',
                            ),
                          ),
                        ]
                      : [
                          _ProfileTag(
                            icon: Icons.person_outline,
                            label: t.get(
                              'profile_account_tag_guest',
                              fallback: 'Guest',
                            ),
                          ),
                          _ProfileTag(
                            icon: Icons.login,
                            label: t.get(
                              'profile_account_tag_sign_in_needed',
                              fallback: 'Sign In Required for Save',
                            ),
                          ),
                        ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (!isSignedIn)
                      FilledButton.icon(
                        onPressed: () {
                          context.push('/auth?mode=signin&redirect=/app/profile');
                        },
                        icon: const Icon(Icons.login),
                        label: Text(
                          t.get(
                            'profile_account_sign_in_button',
                            fallback: 'Sign in',
                          ),
                        ),
                      ),
                    if (!isSignedIn)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/auth?mode=signup&redirect=/app/profile');
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(
                          t.get(
                            'profile_account_create_button',
                            fallback: 'Create account',
                          ),
                        ),
                      ),
                    if (isSignedIn)
                      OutlinedButton.icon(
                        onPressed: () async {
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
                        },
                        icon: const Icon(Icons.logout_outlined),
                        label: Text(
                          t.get(
                            'profile_account_sign_out_button',
                            fallback: 'Sign out',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountIdentityBlock extends StatelessWidget {
  const _AccountIdentityBlock({
    required this.displayName,
    required this.subtitle,
    required this.avatarText,
    required this.isSignedIn,
  });

  final String displayName;
  final String subtitle;
  final String avatarText;
  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.26),
                colorScheme.primaryContainer,
              ],
            ),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Text(
              avatarText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                isSignedIn ? 'Recovery profile active' : 'Guest mode active',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroStats extends StatelessWidget {
  const _ProfileHeroStats({
    required this.isSignedIn,
    required this.localeCode,
    required this.silentDefault,
  });

  final bool isSignedIn;
  final String localeCode;
  final bool silentDefault;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroStatTile(
          icon: Icons.language_rounded,
          label: AppText.get(
            context,
            key: 'profile_hero_language',
            fallback: 'Language',
          ),
          value: localeCode,
        ),
        const SizedBox(height: 10),
        _HeroStatTile(
          icon: Icons.volume_off_outlined,
          label: AppText.get(
            context,
            key: 'profile_hero_silent_default',
            fallback: 'Silent Default',
          ),
          value: silentDefault ? 'On' : 'Off',
        ),
        const SizedBox(height: 10),
        _HeroStatTile(
          icon: Icons.cloud_done_outlined,
          label: AppText.get(
            context,
            key: 'profile_hero_sync_state',
            fallback: 'Sync State',
          ),
          value: isSignedIn ? 'Connected' : 'Local',
        ),
      ],
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}