// lib/features/notifications/presentation/pages/notification_center_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/notifications/notification_history_repository.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../core/notifications/notification_payload_router.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../auth/application/auth_providers.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage> {
  bool _syncQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAndReload());
  }

  Future<void> _syncAndReload() async {
    if (!mounted || _syncQueued) return;
    _syncQueued = true;

    final userId = ref.read(currentUserProvider)?.id;

    try {
      await ref.read(notificationReminderSyncControllerProvider).syncForCurrentUser();
    } finally {
      if (mounted) {
        ref.invalidate(notificationHistoryItemsProvider(userId));
        ref.invalidate(notificationHistoryUnreadCountProvider(userId));
      }
      _syncQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;
    final itemsAsync = ref.watch(notificationHistoryItemsProvider(userId));

    return ResponsivePageScaffold(
      title: Text(t.get('notification_center_title', fallback: 'Notifications')),
      actions: [
        IconButton(
          tooltip: t.get('notification_center_refresh', fallback: 'Refresh reminders'),
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _syncAndReload,
        ),
        IconButton(
          tooltip: t.get('notification_center_mark_all_read', fallback: 'Mark all read'),
          icon: const Icon(Icons.done_all_rounded),
          onPressed: () async {
            await ref
                .read(notificationHistoryRepositoryProvider)
                .markAllOpenedForUser(userId);
            ref.invalidate(notificationHistoryItemsProvider(userId));
            ref.invalidate(notificationHistoryUnreadCountProvider(userId));
          },
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        return RefreshIndicator(
          onRefresh: () async {
            await _syncAndReload();
            await ref.read(notificationHistoryItemsProvider(userId).future);
          },
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 128 : 40),
              children: [
                _EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: t.get(
                    'notification_center_error_title',
                    fallback: 'Could not load notifications',
                  ),
                  body: error.toString(),
                ),
              ],
            ),
            data: (items) {
              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 128 : 40),
                  children: [
                    _EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: t.get(
                        'notification_center_empty_title',
                        fallback: 'No reminders scheduled',
                      ),
                      body: t.get(
                        'notification_center_empty_body',
                        fallback: 'Turn Recovery reminders on in Settings, then pull down here to refresh.',
                      ),
                    ),
                  ],
                );
              }

              final unreadCount = items.where((item) => item.isUnread).length;
              final upcomingCount = items.where((item) => item.isUpcoming).length;

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  0,
                  4,
                  0,
                  pageInfo.isCompact ? 128 : 40,
                ),
                itemCount: items.length + 1,
                separatorBuilder: (_, index) => index == 0
                    ? const SizedBox(height: 12)
                    : const SizedBox(height: 9),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _NotificationCenterHeader(
                      totalCount: items.length,
                      unreadCount: unreadCount,
                      upcomingCount: upcomingCount,
                    );
                  }

                  final item = items[index - 1];
                  return _NotificationHistoryTile(
                    item: item,
                    onTap: () async {
                      if (!item.isUpcoming) {
                        await ref
                            .read(notificationHistoryRepositoryProvider)
                            .markPayloadOpened(item.payload);
                        ref.invalidate(notificationHistoryItemsProvider(userId));
                        ref.invalidate(notificationHistoryUnreadCountProvider(userId));
                      }

                      final route = NotificationPayloadRouteMapper.toAppRoute(item.payload);
                      if (route == null || !context.mounted) return;
                      context.go(route);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationCenterHeader extends StatelessWidget {
  const _NotificationCenterHeader({
    required this.totalCount,
    required this.unreadCount,
    required this.upcomingCount,
  });

  final int totalCount;
  final int unreadCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.16),
            colors.tertiary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.primary.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.notifications_active_rounded, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.get('notification_center_header_title', fallback: 'Recovery reminders'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t
                      .get(
                        'notification_center_header_body_v2',
                        fallback: '{unread} unread, {upcoming} upcoming, {total} total reminders.',
                      )
                      .replaceAll('{unread}', unreadCount.toString())
                      .replaceAll('{upcoming}', upcomingCount.toString())
                      .replaceAll('{total}', totalCount.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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

class _NotificationHistoryTile extends StatelessWidget {
  const _NotificationHistoryTile({required this.item, required this.onTap});

  final AppNotificationHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isUnread = item.isUnread;
    final isUpcoming = item.isUpcoming;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF101827) : Colors.white,
            border: Border.all(
              color: isUnread
                  ? colors.primary.withValues(alpha: isDark ? 0.44 : 0.30)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.46),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: colors.primary.withValues(alpha: isUnread ? 0.08 : 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colors.primary.withValues(alpha: isUnread ? 0.16 : 0.10),
                    ),
                    child: Icon(_iconForKind(item.kind), color: colors.primary, size: 22),
                  ),
                  if (isUnread)
                    PositionedDirectional(
                      top: -2,
                      end: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.tertiary,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: isUnread ? FontWeight.w900 : FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _MetaPill(
                          icon: Icons.schedule_rounded,
                          label: _scheduledLabel(context, item.scheduledFor),
                        ),
                        _MetaPill(
                          icon: isUpcoming
                              ? Icons.event_available_rounded
                              : item.isOpened
                                  ? Icons.mark_email_read_rounded
                                  : Icons.fiber_new_rounded,
                          label: _statusLabel(context, item),
                        ),
                      ],
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

  IconData _iconForKind(String kind) {
    switch (kind) {
      case 'continueProgram':
        return Icons.route_rounded;
      case 'continueSession':
        return Icons.play_circle_outline_rounded;
      case 'returnToRecovery':
        return Icons.restart_alt_rounded;
      case 'featureNudge':
        return Icons.workspace_premium_rounded;
      case 'dailyReset':
      default:
        return Icons.self_improvement_rounded;
    }
  }

  String _statusLabel(BuildContext context, AppNotificationHistoryItem item) {
    final t = AppText.of(context);
    if (item.isUpcoming) {
      return t.get('notification_center_status_upcoming', fallback: 'Upcoming');
    }
    if (item.isOpened) {
      return t.get('notification_center_status_opened', fallback: 'Opened');
    }
    return t.get('notification_center_status_new', fallback: 'New');
  }

  String _scheduledLabel(BuildContext context, DateTime? value) {
    final t = AppText.of(context);
    if (value == null) {
      return t.get('notification_center_status_scheduled', fallback: 'Scheduled');
    }

    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);
    final deltaDays = date.difference(today).inDays;

    if (deltaDays == 0) {
      return t
          .get('notification_center_time_today', fallback: 'Today {time}')
          .replaceAll('{time}', time);
    }
    if (deltaDays == 1) {
      return t
          .get('notification_center_time_tomorrow', fallback: 'Tomorrow {time}')
          .replaceAll('{time}', time);
    }
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')} $time';
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.62),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 42),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.34),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.52)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
