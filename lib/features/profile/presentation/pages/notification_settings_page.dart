// lib/features/profile/presentation/pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/profile_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    return ResponsivePageScaffold(
      title: Text(
        AppText.get(
          context,
          key: 'notification_settings_title',
          fallback: 'Notification Settings',
        ),
      ),
      bodyBuilder: (context, pageInfo) {
        return prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppText.get(
                  context,
                  key: 'notification_settings_error',
                  fallback: 'Could not load notification settings.',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (prefs) {
            if (prefs == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppText.get(
                      context,
                      key: 'notification_settings_guest_hint',
                      fallback: 'Sign in to save notification preferences.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                _PreferenceSurface(
                  child: _PreferenceTile(
                    icon: Icons.notifications_active_outlined,
                    title: t.get(
                      'notification_settings_enable_title',
                      fallback: 'Enable Notifications',
                    ),
                    subtitle: t.get(
                      'notification_settings_enable_short',
                      fallback:
                          'Controls app reminders and re-engagement prompts.',
                    ),
                    value: prefs.notificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(userPreferencesControllerProvider.notifier)
                          .setNotificationsEnabled(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _PreferenceSurface(
                  child: _PreferenceTile(
                    icon: Icons.vibration_rounded,
                    title: t.get(
                      'notification_settings_haptics_title',
                      fallback: 'Haptics',
                    ),
                    subtitle: t.get(
                      'notification_settings_haptics_short',
                      fallback: 'Use tactile confirmation where supported.',
                    ),
                    value: prefs.hapticsEnabled,
                    onChanged: (value) {
                      ref
                          .read(userPreferencesControllerProvider.notifier)
                          .setHapticsEnabled(value);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PreferenceSurface extends StatelessWidget {
  const _PreferenceSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}