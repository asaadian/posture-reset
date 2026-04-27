// lib/features/profile/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('settings_title', fallback: 'Settings')),
      bodyBuilder: (context, pageInfo) {
        return ListView(
          padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
          children: [
            _SettingsSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: AppText.get(
                      context,
                      key: 'settings_language_section_title',
                      fallback: 'Language',
                    ),
                    subtitle: AppText.get(
                      context,
                      key: 'settings_language_section_subtitle_short',
                      fallback: 'Used across the app.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LanguageGroup(
                    currentValue: currentLocale.languageCode,
                    onSelected: (value) async {
                      await ref
                          .read(appLocaleControllerProvider.notifier)
                          .setLanguageCode(value);
                      await ref
                          .read(userPreferencesControllerProvider.notifier)
                          .setPreferredLocale(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SettingsSurface(
              child: prefsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: AppText.get(
                        context,
                        key: 'settings_preferences_section_title',
                        fallback: 'Preference Sync',
                      ),
                      subtitle: AppText.get(
                        context,
                        key: 'settings_preferences_error_short',
                        fallback: 'Could not load cloud preferences.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$error',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ),
                data: (prefs) {
                  final isGuest = prefs == null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: AppText.get(
                          context,
                          key: 'settings_preferences_section_title',
                          fallback: 'Preference Sync',
                        ),
                        subtitle: isGuest
                            ? AppText.get(
                                context,
                                key: 'settings_preferences_guest_hint',
                                fallback:
                                    'Sign in to sync preferences across devices.',
                              )
                            : AppText.get(
                                context,
                                key: 'settings_preferences_synced_short',
                                fallback: 'Cloud-backed preferences are active.',
                              ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _ValueChip(
                            icon: Icons.language_rounded,
                            label: AppText.get(
                              context,
                              key: 'settings_pref_locale',
                              fallback: 'Language',
                            ),
                            value: isGuest
                                ? currentLocale.languageCode.toUpperCase()
                                : prefs.preferredLocale.toUpperCase(),
                          ),
                          if (!isGuest)
                            _ValueChip(
                              icon: Icons.volume_off_rounded,
                              label: AppText.get(
                                context,
                                key: 'settings_pref_silent_mode',
                                fallback: 'Silent',
                              ),
                              value: prefs.preferredSilentMode
                                  ? AppText.get(
                                      context,
                                      key: 'common_on',
                                      fallback: 'On',
                                    )
                                  : AppText.get(
                                      context,
                                      key: 'common_off',
                                      fallback: 'Off',
                                    ),
                            ),
                          if (!isGuest)
                            _ValueChip(
                              icon: Icons.notifications_none_rounded,
                              label: AppText.get(
                                context,
                                key: 'settings_pref_notifications',
                                fallback: 'Alerts',
                              ),
                              value: prefs.notificationsEnabled
                                  ? AppText.get(
                                      context,
                                      key: 'common_on',
                                      fallback: 'On',
                                    )
                                  : AppText.get(
                                      context,
                                      key: 'common_off',
                                      fallback: 'Off',
                                    ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsSurface extends StatelessWidget {
  const _SettingsSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LanguageGroup extends StatelessWidget {
  const _LanguageGroup({
    required this.currentValue,
    required this.onSelected,
  });

  final String currentValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        'en',
        AppText.get(
          context,
          key: 'settings_language_english',
          fallback: 'English',
        ),
      ),
      (
        'de',
        AppText.get(
          context,
          key: 'settings_language_german',
          fallback: 'German',
        ),
      ),
      (
        'fa',
        AppText.get(
          context,
          key: 'settings_language_persian',
          fallback: 'Persian',
        ),
      ),
    ];

    return Column(
      children: options.map((option) {
        final selected = currentValue == option.$1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(option.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.24)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 20,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.$2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
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
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
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