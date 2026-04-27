// lib/features/profile/presentation/pages/audio_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/profile_providers.dart';

class AudioSettingsPage extends ConsumerWidget {
  const AudioSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    return ResponsivePageScaffold(
      title: Text(
        t.get('audio_settings_title', fallback: 'Audio Settings'),
      ),
      bodyBuilder: (context, pageInfo) {
        return prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.get(
                  'audio_settings_error',
                  fallback: 'Could not load audio settings.',
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
                      'audio_settings_guest_hint',
                      fallback: 'Sign in to save audio preferences.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                _AudioHeroCard(
                  title: t.get(
                    'audio_settings_simple_title',
                    fallback: 'Session Sound',
                  ),
                  subtitle: t.get(
                    'audio_settings_simple_subtitle',
                    fallback:
                        'Controls lightweight app and session audio behavior.',
                  ),
                ),
                const SizedBox(height: 14),
                _AudioPreferenceCard(
                  value: prefs.audioEnabled,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesControllerProvider.notifier)
                        .setAudioEnabled(value);
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

class _AudioHeroCard extends StatelessWidget {
  const _AudioHeroCard({
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
              Icons.graphic_eq_rounded,
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

class _AudioPreferenceCard extends StatelessWidget {
  const _AudioPreferenceCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(
          value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          t.get(
            'audio_settings_enable_title',
            fallback: 'Enable Audio',
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          t.get(
            'audio_settings_enable_short',
            fallback: 'Use lightweight app and session sounds where available.',
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}