// lib/features/profile/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/notification_schedule_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/profile_providers.dart';
import '../../domain/profile_models.dart';

const String _privacyPolicyUrl = 'https://weglabs.com/privacy-policy/';
const String _termsOfUseUrl = 'https://weglabs.com/terms-of-use/';
const String _accountDataDeletionUrl =
    'https://weglabs.com/account-data-deletion-weglabs-apps/';
const String _supportEmail = 'contact@weglabs.com';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final prefsAsync = ref.watch(userPreferencesControllerProvider);
    final themeMode = ref.watch(appThemeModeControllerProvider);

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
      title: Text(t.get('settings_title', fallback: 'Settings')),
      bodyBuilder: (context, pageInfo) {
        final isWide = pageInfo.isMedium || pageInfo.isExpanded;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, 2, 0, pageInfo.isCompact ? 128 : 40),
          children: [
            _SettingsHero(
              title: t.get('settings_hero_title', fallback: 'App controls'),
              subtitle: t.get(
                'settings_hero_subtitle',
                fallback: 'Language, theme, support, and legal information.',
              ),
            ),
            const SizedBox(height: 14),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _PreferencesSection(
                          currentLocale: currentLocale.languageCode,
                          themeMode: themeMode,
                          prefsAsync: prefsAsync,
                          onLanguage: (value) async {
                            await ref
                                .read(appLocaleControllerProvider.notifier)
                                .setLanguageCode(value);
                            await ref
                                .read(userPreferencesControllerProvider.notifier)
                                .setPreferredLocale(value);
                          },
                          onTheme: (value) async {
                            await ref
                                .read(appThemeModeControllerProvider.notifier)
                                .setThemeMode(value);
                          },
                        ),
                        const SizedBox(height: 14),
                        _NotificationsSection(prefsAsync: prefsAsync),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _SupportLegalSection()),
                ],
              )
            else ...[
              _PreferencesSection(
                currentLocale: currentLocale.languageCode,
                themeMode: themeMode,
                prefsAsync: prefsAsync,
                onLanguage: (value) async {
                  await ref
                      .read(appLocaleControllerProvider.notifier)
                      .setLanguageCode(value);
                  await ref
                      .read(userPreferencesControllerProvider.notifier)
                      .setPreferredLocale(value);
                },
                onTheme: (value) async {
                  await ref
                      .read(appThemeModeControllerProvider.notifier)
                      .setThemeMode(value);
                },
              ),
              const SizedBox(height: 14),
              _NotificationsSection(prefsAsync: prefsAsync),
              const SizedBox(height: 14),
              _SupportLegalSection(),
            ],
          ],
        );
      },
    ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: context.actionCardGradient,
        border: Border.all(color: context.subtleBorderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.20)
                : colors.primary.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.95),
                  colors.tertiary.withValues(alpha: 0.82),
                ],
              ),
            ),
            child: Icon(Icons.tune_rounded, color: colors.onPrimary, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.22,
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

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.currentLocale,
    required this.themeMode,
    required this.prefsAsync,
    required this.onLanguage,
    required this.onTheme,
  });

  final String currentLocale;
  final AppThemeMode themeMode;
  final AsyncValue<UserPreferences?> prefsAsync;
  final ValueChanged<String> onLanguage;
  final ValueChanged<AppThemeMode> onTheme;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return _SettingsSection(
      icon: Icons.dashboard_customize_rounded,
      accent: Theme.of(context).colorScheme.primary,
      title: t.get('settings_preferences_compact_title', fallback: 'Preferences'),
      subtitle: t.get(
        'settings_preferences_compact_subtitle',
        fallback: 'Language, theme, and sync.',
      ),
      children: [
        _SettingLabel(label: t.get('settings_language_section_title', fallback: 'Language')),
        const SizedBox(height: 8),
        _LanguageSegmentedControl(currentValue: currentLocale, onSelected: onLanguage),
        const SizedBox(height: 16),
        _SettingLabel(label: t.get('settings_appearance_section_title', fallback: 'Appearance')),
        const SizedBox(height: 8),
        _ThemeSegmentedControl(currentValue: themeMode, onSelected: onTheme),
        const SizedBox(height: 14),
        _SyncStatusRow(prefsAsync: prefsAsync),
      ],
    );
  }
}


class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection({required this.prefsAsync});

  final AsyncValue<UserPreferences?> prefsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final reminderTimeAsync = ref.watch(notificationReminderTimeProvider);

    return _SettingsSection(
      icon: Icons.notifications_active_rounded,
      accent: colors.tertiary,
      title: t.get('notification_settings_title_compact', fallback: 'Notifications'),
      subtitle: t.get(
        'notification_settings_inline_subtitle',
        fallback: 'Recovery reminders and haptics.',
      ),
      children: [
        prefsAsync.when(
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (_, __) => _InlineStatus(
            icon: Icons.error_outline_rounded,
            text: t.get(
              'notification_settings_error',
              fallback: 'Could not load notification settings.',
            ),
          ),
          data: (prefs) {
            if (prefs == null) {
              return _InlineStatus(
                icon: Icons.cloud_off_rounded,
                text: t.get(
                  'notification_settings_guest_hint',
                  fallback: 'Sign in to save notification preferences.',
                ),
              );
            }

            return Column(
              children: [
                _SwitchSettingRow(
                  icon: Icons.notifications_active_outlined,
                  title: t.get(
                    'notification_settings_enable_title',
                    fallback: 'Recovery reminders',
                  ),
                  subtitle: prefs.notificationsEnabled
                      ? t.get(
                          'notification_settings_enabled_short',
                          fallback: 'Daily reminder is active.',
                        )
                      : t.get(
                          'notification_settings_disabled_short',
                          fallback: 'Off by default. Enable when you want reminders.',
                        ),
                  value: prefs.notificationsEnabled,
                  onChanged: (value) async {
                    final service = ref.read(localNotificationServiceProvider);
                    final controller = ref.read(userPreferencesControllerProvider.notifier);

                    if (value) {
                      final granted = await service.requestPermissions();
                      if (!granted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                t.get(
                                  'notification_permission_denied',
                                  fallback: 'Notification permission was not granted.',
                                ),
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      await controller.setNotificationsEnabled(true);
                      await ref
                          .read(notificationReminderSyncControllerProvider)
                          .syncForCurrentUser();
                      return;
                    }

                    await controller.setNotificationsEnabled(false);
                    await ref
                        .read(notificationReminderSyncControllerProvider)
                        .cancelForCurrentUser();
                  },
                ),
                if (prefs.notificationsEnabled) ...[
                  const SizedBox(height: 10),
                  _SettingLabel(
                    label: t.get(
                      'notification_settings_time_title',
                      fallback: 'Reminder time',
                    ),
                  ),
                  const SizedBox(height: 8),
                  reminderTimeAsync.when(
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (_, __) => _InlineStatus(
                      icon: Icons.error_outline_rounded,
                      text: t.get(
                        'notification_settings_time_error',
                        fallback: 'Could not load reminder time.',
                      ),
                    ),
                    data: (reminderTime) => _ReminderTimeSegmentedControl(
                      currentValue: reminderTime,
                      onSelected: (value) async {
                        await ref
                            .read(notificationSchedulePreferencesStoreProvider)
                            .setReminderTime(value);
                        ref.invalidate(notificationReminderTimeProvider);
                        await ref
                            .read(notificationReminderSyncControllerProvider)
                            .syncForCurrentUser();
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _SwitchSettingRow(
                  icon: Icons.vibration_rounded,
                  title: t.get(
                    'notification_settings_haptics_title',
                    fallback: 'Haptics',
                  ),
                  subtitle: t.get(
                    'notification_settings_haptics_short',
                    fallback: 'Tactile confirmation where supported.',
                  ),
                  value: prefs.hapticsEnabled,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesControllerProvider.notifier)
                        .setHapticsEnabled(value);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}


class _ReminderTimeSegmentedControl extends StatelessWidget {
  const _ReminderTimeSegmentedControl({
    required this.currentValue,
    required this.onSelected,
  });

  final NotificationReminderTime currentValue;
  final ValueChanged<NotificationReminderTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            selected: currentValue == NotificationReminderTime.morning,
            label: t.get('notification_time_morning', fallback: 'Morning'),
            shortLabel: '09:30',
            icon: Icons.wb_sunny_outlined,
            onTap: () => onSelected(NotificationReminderTime.morning),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            selected: currentValue == NotificationReminderTime.afternoon,
            label: t.get('notification_time_afternoon', fallback: 'Afternoon'),
            shortLabel: '14:30',
            icon: Icons.light_mode_outlined,
            onTap: () => onSelected(NotificationReminderTime.afternoon),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            selected: currentValue == NotificationReminderTime.evening,
            label: t.get('notification_time_evening', fallback: 'Evening'),
            shortLabel: '18:30',
            icon: Icons.nights_stay_outlined,
            onTap: () => onSelected(NotificationReminderTime.evening),
          ),
        ),
      ],
    );
  }
}

class _SupportLegalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return _SettingsSection(
      icon: Icons.support_agent_rounded,
      accent: colors.secondary,
      title: t.get('settings_support_legal_title', fallback: 'Support & legal'),
      subtitle: t.get(
        'settings_support_legal_subtitle',
        fallback: 'Help, policies, and account information.',
      ),
      children: [
        _ActionRow(
          icon: Icons.mail_outline_rounded,
          title: t.get('settings_contact_email_label', fallback: 'Email support'),
          subtitle: _supportEmail,
          onTap: () => _openSupportEmail(context, _supportEmail),
        ),
        const SizedBox(height: 8),
        _ActionRow(
          icon: Icons.privacy_tip_outlined,
          title: t.get('settings_privacy_policy_title', fallback: 'Privacy Policy'),
          subtitle: t.get('settings_external_link_subtitle', fallback: 'Open in browser'),
          onTap: () => _openExternalLink(context, _privacyPolicyUrl),
        ),
        const SizedBox(height: 8),
        _ActionRow(
          icon: Icons.description_outlined,
          title: t.get('settings_terms_title', fallback: 'Terms of Use'),
          subtitle: t.get('settings_external_link_subtitle', fallback: 'Open in browser'),
          onTap: () => _openExternalLink(context, _termsOfUseUrl),
        ),
        const SizedBox(height: 8),
        _ActionRow(
          icon: Icons.delete_sweep_outlined,
          title: t.get('settings_account_data_deletion_info_title', fallback: 'Data deletion policy'),
          subtitle: t.get('settings_external_link_subtitle', fallback: 'Open in browser'),
          onTap: () => _openExternalLink(context, _accountDataDeletionUrl),
        ),
        const SizedBox(height: 8),
        const _AppVersionRow(),
      ],
    );
  }
}

class _AppVersionRow extends StatelessWidget {
  const _AppVersionRow();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final versionText = info == null
            ? t.get('settings_app_version_loading', fallback: 'Loading version...')
            : t
                .get(
                  'settings_app_version_format',
                  fallback: 'Version {version} ({build})',
                )
                .replaceAll('{version}', info.version)
                .replaceAll('{build}', info.buildNumber);

        return _InfoRow(
          icon: Icons.info_outline_rounded,
          title: t.get('settings_app_version_title', fallback: 'App version'),
          subtitle: versionText,
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
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
            color: isDark
                ? Colors.black.withValues(alpha: 0.14)
                : accent.withValues(alpha: 0.045),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.11),
                ),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
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

class _LanguageSegmentedControl extends StatelessWidget {
  const _LanguageSegmentedControl({required this.currentValue, required this.onSelected});

  final String currentValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            selected: currentValue == 'en',
            label: AppText.get(context, key: 'settings_language_english', fallback: 'English'),
            shortLabel: 'EN',
            icon: Icons.language_rounded,
            onTap: () => onSelected('en'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            selected: currentValue == 'de',
            label: AppText.get(context, key: 'settings_language_german', fallback: 'German'),
            shortLabel: 'DE',
            icon: Icons.translate_rounded,
            onTap: () => onSelected('de'),
          ),
        ),
      ],
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl({required this.currentValue, required this.onSelected});

  final AppThemeMode currentValue;
  final ValueChanged<AppThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            selected: currentValue == AppThemeMode.system,
            label: AppText.get(context, key: 'settings_theme_system_title', fallback: 'System'),
            shortLabel: AppText.get(context, key: 'settings_theme_system_short', fallback: 'Auto'),
            icon: Icons.phone_android_rounded,
            onTap: () => onSelected(AppThemeMode.system),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            selected: currentValue == AppThemeMode.light,
            label: AppText.get(context, key: 'settings_theme_light_title', fallback: 'Light'),
            shortLabel: AppText.get(context, key: 'settings_theme_light_short', fallback: 'Light'),
            icon: Icons.light_mode_rounded,
            onTap: () => onSelected(AppThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            selected: currentValue == AppThemeMode.dark,
            label: AppText.get(context, key: 'settings_theme_dark_title', fallback: 'Dark'),
            shortLabel: AppText.get(context, key: 'settings_theme_dark_short', fallback: 'Dark'),
            icon: Icons.dark_mode_rounded,
            onTap: () => onSelected(AppThemeMode.dark),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.selected,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final String shortLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: selected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? colors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
                : isDark
                    ? colors.surfaceContainerHighest.withValues(alpha: 0.34)
                    : colors.surface.withValues(alpha: 0.64),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: isDark ? 0.38 : 0.26)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.60 : 0.44),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? Icons.check_circle_rounded : icon, size: 17, color: selected ? colors.primary : colors.onSurfaceVariant),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  shortLabel.isNotEmpty ? shortLabel : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
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

class _SyncStatusRow extends StatelessWidget {
  const _SyncStatusRow({required this.prefsAsync});

  final AsyncValue<UserPreferences?> prefsAsync;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return prefsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => _InlineStatus(
        icon: Icons.error_outline_rounded,
        text: t.get('settings_preferences_error_short', fallback: 'Could not load cloud preferences.'),
      ),
      data: (prefs) => _InlineStatus(
        icon: prefs == null ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
        text: prefs == null
            ? t.get('settings_preferences_guest_hint', fallback: 'Sign in to sync preferences across devices.')
            : t.get('settings_preferences_synced_short', fallback: 'Preferences are synced.'),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = colors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? colors.surfaceContainerHighest.withValues(alpha: 0.32)
                : Colors.white.withValues(alpha: 0.62),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.42)),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.20),
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



class _SwitchSettingRow extends StatelessWidget {
  const _SwitchSettingRow({
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
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = colors.tertiary;

    return Ink(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.62),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.42),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: accent.withValues(alpha: 0.12),
            ),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = colors.primary;

    return Ink(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.62),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.42),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: accent.withValues(alpha: 0.12),
            ),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.20,
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

class _SettingLabel extends StatelessWidget {
  const _SettingLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  const _InlineStatus({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: isDark ? colors.surfaceContainerHighest.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.56),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: isDark ? 0.56 : 0.42)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openExternalLink(BuildContext context, String rawUrl) async {
  final launched = await launchUrl(Uri.parse(rawUrl), mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.get(context, key: 'settings_link_open_failed', fallback: 'Could not open the link.'))),
    );
  }
}

Future<void> _openSupportEmail(BuildContext context, String email) async {
  final subject = Uri.encodeComponent('Posture Reset Support');
  final body = Uri.encodeComponent('Hi WEG Labs,\n\nI need help with Posture Reset.\n\n');
  final launched = await launchUrl(Uri.parse('mailto:$email?subject=$subject&body=$body'), mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.get(context, key: 'settings_email_open_failed', fallback: 'Could not open your email app.'))),
    );
  }
}