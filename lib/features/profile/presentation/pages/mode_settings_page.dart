// lib/features/profile/presentation/pages/mode_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/profile_providers.dart';

class ModeSettingsPage extends ConsumerWidget {
  const ModeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    final modeOptions = [
      (
        'dad',
        AppText.get(
          context,
          key: 'quick_fix_mode_dad',
          fallback: 'Dad Mode',
        ),
        Icons.family_restroom_outlined,
      ),
      (
        'night',
        AppText.get(
          context,
          key: 'quick_fix_mode_night',
          fallback: 'Night Coder',
        ),
        Icons.dark_mode_outlined,
      ),
      (
        'focus',
        AppText.get(
          context,
          key: 'quick_fix_mode_focus',
          fallback: 'Focus Mode',
        ),
        Icons.center_focus_strong_outlined,
      ),
      (
        'pain_relief',
        AppText.get(
          context,
          key: 'quick_fix_mode_pain_relief',
          fallback: 'Pain Relief',
        ),
        Icons.healing_outlined,
      ),
    ];

    return ResponsivePageScaffold(
      title: Text(
        t.get('mode_settings_title', fallback: 'Mode Settings'),
      ),
      bodyBuilder: (context, pageInfo) {
        return prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.get(
                  'mode_settings_error',
                  fallback: 'Could not load mode settings.',
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
                    t.get(
                      'mode_settings_guest_hint',
                      fallback: 'Sign in to save mode preferences.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final selectedModes = prefs.defaultModeCodes.toSet();

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                _ModeHeroCard(
                  title: t.get(
                    'mode_settings_default_modes_title',
                    fallback: 'Default Modes',
                  ),
                  subtitle: t.get(
                    'mode_settings_baseline_hint',
                    fallback: 'Used as your Quick Fix baseline.',
                  ),
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  itemCount: modeOptions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (pageInfo.isMedium || pageInfo.isExpanded) ? 2 : 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        (pageInfo.isMedium || pageInfo.isExpanded) ? 2.0 : 2.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = modeOptions[index];
                    final isSelected = selectedModes.contains(item.$1);

                    return _ModeTile(
                      title: item.$2,
                      icon: item.$3,
                      selected: isSelected,
                      onTap: () {
                        ref
                            .read(userPreferencesControllerProvider.notifier)
                            .toggleDefaultMode(item.$1);
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                _SilentModeCard(
                  value: prefs.preferredSilentMode,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesControllerProvider.notifier)
                        .setPreferredSilentMode(value);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ModeHeroCard extends StatelessWidget {
  const _ModeHeroCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.10)
                : theme.colorScheme.surfaceContainerHigh,
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: selected
                        ? theme.colorScheme.primary.withValues(alpha: 0.14)
                        : theme.colorScheme.surface,
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SilentModeCard extends StatelessWidget {
  const _SilentModeCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        secondary: Icon(
          value ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          t.get(
            'mode_settings_silent_default_title',
            fallback: 'Default to Silent Sessions',
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          t.get(
            'mode_settings_silent_default_short',
            fallback: 'Applied as your default Quick Fix context.',
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}