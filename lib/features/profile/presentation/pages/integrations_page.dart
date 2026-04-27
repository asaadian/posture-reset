import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/adaptive_section_title.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return ResponsivePageScaffold(
      title: Text(t.get('integrations_title', fallback: 'Integrations')),
      bodyBuilder: (context, pageInfo) {
        final sectionGap = pageInfo.isCompact ? 20.0 : 24.0;

        return ListView(
          padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
          children: [
            _IntegrationsIntroCard(pageInfo: pageInfo),
            SizedBox(height: sectionGap),

            AdaptiveSectionTitle(
              titleKey: 'integrations_connected_section_title',
              titleFallback: 'Connected Services',
              subtitleKey: 'integrations_connected_section_subtitle',
              subtitleFallback:
                  'Review external systems that improve recommendations and tracking.',
            ),
            const SizedBox(height: 12),
            const ResponsiveContentSection(
              spacing: 12,
              children: [
                _IntegrationCard(
                  icon: Icons.favorite_outline,
                  titleKey: 'integrations_health_data_title',
                  titleFallback: 'Health Data',
                  subtitleKey: 'integrations_health_data_subtitle',
                  subtitleFallback:
                      'Use health signals to improve recovery context and summaries.',
                  statusKey: 'integrations_status_not_connected',
                  statusFallback: 'Not connected',
                ),
                _IntegrationCard(
                  icon: Icons.watch_outlined,
                  titleKey: 'integrations_wearables_title',
                  titleFallback: 'Wearables',
                  subtitleKey: 'integrations_wearables_subtitle',
                  subtitleFallback:
                      'Sync supported wearable signals for richer recovery insights.',
                  statusKey: 'integrations_status_not_connected',
                  statusFallback: 'Not connected',
                ),
                _IntegrationCard(
                  icon: Icons.notifications_active_outlined,
                  titleKey: 'integrations_notification_sync_title',
                  titleFallback: 'Notification Sync',
                  subtitleKey: 'integrations_notification_sync_subtitle',
                  subtitleFallback:
                      'Coordinate reminder behavior across connected platforms.',
                  statusKey: 'integrations_status_ready',
                  statusFallback: 'Ready',
                ),
              ],
            ),
            SizedBox(height: sectionGap),

            AdaptiveSectionTitle(
              titleKey: 'integrations_permissions_section_title',
              titleFallback: 'Permissions',
              subtitleKey: 'integrations_permissions_section_subtitle',
              subtitleFallback:
                  'Review access state and user-facing permission guidance.',
            ),
            const SizedBox(height: 12),
            const ResponsiveContentSection(
              spacing: 12,
              children: [
                _IntegrationInfoTile(
                  icon: Icons.lock_open_outlined,
                  titleKey: 'integrations_health_permission_title',
                  titleFallback: 'Health Access',
                  subtitleKey: 'integrations_health_permission_subtitle',
                  subtitleFallback:
                      'Permission is requested only when value is clearly explained.',
                ),
                _IntegrationInfoTile(
                  icon: Icons.notifications_none,
                  titleKey: 'integrations_notifications_permission_title',
                  titleFallback: 'Notifications Access',
                  subtitleKey: 'integrations_notifications_permission_subtitle',
                  subtitleFallback:
                      'Reminders remain optional and should degrade gracefully if denied.',
                ),
              ],
            ),
            SizedBox(height: sectionGap),

            AdaptiveSectionTitle(
              titleKey: 'integrations_sync_section_title',
              titleFallback: 'Sync Behavior',
              subtitleKey: 'integrations_sync_section_subtitle',
              subtitleFallback:
                  'Control how connected systems affect app state and freshness.',
            ),
            const SizedBox(height: 12),
            const ResponsiveContentSection(
              spacing: 12,
              children: [
                _IntegrationInfoTile(
                  icon: Icons.sync_outlined,
                  titleKey: 'integrations_refresh_title',
                  titleFallback: 'Refresh Policy',
                  subtitleKey: 'integrations_refresh_subtitle',
                  subtitleFallback:
                      'Use cached-first behavior with background refresh when possible.',
                ),
                _IntegrationInfoTile(
                  icon: Icons.cloud_off_outlined,
                  titleKey: 'integrations_offline_fallback_title',
                  titleFallback: 'Offline Fallback',
                  subtitleKey: 'integrations_offline_fallback_subtitle',
                  subtitleFallback:
                      'Core UX should remain usable when connected services are unavailable.',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _IntegrationsIntroCard extends StatelessWidget {
  const _IntegrationsIntroCard({required this.pageInfo});

  final ResponsivePageInfo pageInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppText.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(pageInfo.isCompact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.get(
                        'integrations_intro_label',
                        fallback: 'Connected Intelligence',
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.get(
                'integrations_intro_title',
                fallback: 'Extend recovery context with external signals.',
              ),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              t.get(
                'integrations_intro_body',
                fallback:
                    'Integrations can improve context, reminder quality, and insight accuracy without becoming required for core use.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.icon,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.statusKey,
    required this.statusFallback,
  });

  final IconData icon;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;
  final String statusKey;
  final String statusFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppText.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 28, color: colorScheme.primary),
        title: Text(
          t.get(titleKey, fallback: titleFallback),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            t.get(subtitleKey, fallback: subtitleFallback),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.get(statusKey, fallback: statusFallback),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

class _IntegrationInfoTile extends StatelessWidget {
  const _IntegrationInfoTile({
    required this.icon,
    required this.titleKey,
    required this.titleFallback,
    required this.subtitleKey,
    required this.subtitleFallback,
  });

  final IconData icon;
  final String titleKey;
  final String titleFallback;
  final String subtitleKey;
  final String subtitleFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppText.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 28, color: colorScheme.primary),
        title: Text(
          t.get(titleKey, fallback: titleFallback),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            t.get(subtitleKey, fallback: subtitleFallback),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
