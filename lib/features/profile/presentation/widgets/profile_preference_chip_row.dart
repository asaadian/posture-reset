// lib/features/profile/presentation/widgets/profile_preference_chip_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../application/profile_providers.dart';

class ProfilePreferenceChipRow extends ConsumerWidget {
  const ProfilePreferenceChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesControllerProvider);
    final t = AppText.of(context);

    return prefsAsync.when(
      loading: () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          4,
          (_) => Container(
            height: 38,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
      error: (_, __) => Text(
        t.get(
          'profile_preferences_load_error',
          fallback: 'Could not load recovery preferences.',
        ),
      ),
      data: (prefs) {
        if (prefs == null) {
          return Text(
            t.get(
              'profile_preferences_guest_hint',
              fallback: 'Sign in to save your recovery preference baseline.',
            ),
          );
        }

        final items = [
          if (prefs.preferredTimeMinutes != null)
            (
              icon: Icons.timer_outlined,
              label: '${prefs.preferredTimeMinutes} min',
            ),
          (
            icon: Icons.language_rounded,
            label: prefs.preferredLocale.toUpperCase(),
          ),
          (
            icon: Icons.volume_off_outlined,
            label: prefs.preferredSilentMode
                ? t.get(
                    'profile_preference_silent_mode',
                    fallback: 'Silent mode',
                  )
                : t.get(
                    'profile_preference_sound_friendly',
                    fallback: 'Sound enabled',
                  ),
          ),
          if (prefs.preferredEnergyCode != null)
            (
              icon: Icons.bolt_rounded,
              label: prefs.preferredEnergyCode!,
            ),
          ...prefs.defaultModeCodes.take(3).map(
                (mode) => (
                  icon: Icons.auto_awesome_rounded,
                  label: _modeLabel(context, mode),
                ),
              ),
          (
            icon: Icons.notifications_active_outlined,
            label: prefs.notificationsEnabled
                ? t.get(
                    'profile_preference_notifications_on',
                    fallback: 'Notifications on',
                  )
                : t.get(
                    'profile_preference_notifications_off',
                    fallback: 'Notifications off',
                  ),
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => _PreferenceChip(
                  icon: item.icon,
                  label: item.label,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  String _modeLabel(BuildContext context, String code) {
    switch (code) {
      case 'dad':
        return AppText.get(
          context,
          key: 'quick_fix_mode_dad',
          fallback: 'Dad Mode',
        );
      case 'night':
        return AppText.get(
          context,
          key: 'quick_fix_mode_night',
          fallback: 'Night Coder',
        );
      case 'focus':
        return AppText.get(
          context,
          key: 'quick_fix_mode_focus',
          fallback: 'Focus Mode',
        );
      case 'pain_relief':
        return AppText.get(
          context,
          key: 'quick_fix_mode_pain_relief',
          fallback: 'Pain Relief',
        );
      default:
        return code;
    }
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}