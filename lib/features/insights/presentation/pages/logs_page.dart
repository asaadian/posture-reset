// lib/features/insights/presentation/pages/logs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_content_section.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';
import '../../application/insights_providers.dart';
import '../../domain/insights_snapshot.dart';

class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(insightsSnapshotProvider(InsightsRange.last28Days));
    await ref.read(insightsSnapshotProvider(InsightsRange.last28Days).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(
      insightsSnapshotProvider(InsightsRange.last28Days),
    );
    final accessAsync = ref.watch(accessSnapshotProvider);
    final t = AppText.of(context);

    return ResponsivePageScaffold(
      title: Text(t.get('logs_page_title', fallback: 'Logs')),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.insightsLogs,
        );

        if (accessAsync.isLoading) {
          return const _LogsLoadingState();
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
            children: [
              ResponsiveContentSection(
                spacing: 14,
                children: [
                  LockedFeatureCard(
                    title: t.get(
                      'logs_locked_title',
                      fallback: 'Behavior Logs are part of Core Access',
                    ),
                    message: t.get(
                      'logs_locked_message',
                      fallback:
                          'Unlock Core once to inspect recovery logs generated from runs, feedback, quick-fix activity, state snapshots, and player events.',
                    ),
                    icon: Icons.receipt_long_rounded,
                    onUpgrade: () => context.pushNamed('premium'),
                  ),
                ],
              ),
            ],
          );
        }

        return snapshotAsync.when(
          loading: () => const _LogsLoadingState(),
          error: (error, _) => _LogsErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(
              insightsSnapshotProvider(InsightsRange.last28Days),
            ),
          ),
          data: (snapshot) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
                children: [
                  ResponsiveContentSection(
                    spacing: 14,
                    children: [
                      _LogsHeroCard(snapshot: snapshot),
                      _LogsSummaryStrip(logs: snapshot.logs),
                      _InsightsLogsPreviewCard(logs: snapshot.logs),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LogsHeroCard extends StatelessWidget {
  const _LogsHeroCard({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final totalLogs = snapshot.logs.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.12),
                  colors.surfaceContainerHigh.withValues(alpha: 0.86),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  colors.primary.withValues(alpha: 0.07),
                  colors.surface.withValues(alpha: 0.98),
                  colors.surfaceContainerLow.withValues(alpha: 0.92),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.74 : 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.16)
                : colors.primary.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.11),
              border: Border.all(
                color: colors.primary.withValues(alpha: isDark ? 0.26 : 0.17),
              ),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.get('logs_hero_title', fallback: 'Recovery logs'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  t.get(
                    'logs_hero_body_short',
                    fallback: 'Recent signals from sessions and Quick Fix.',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _LogsCountBadge(count: totalLogs),
        ],
      ),
    );
  }
}

class _LogsCountBadge extends StatelessWidget {
  const _LogsCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: 0.10),
        border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        t
            .get('logs_count_badge', fallback: '{count} logs')
            .replaceAll('{count}', count.toString()),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
      ),
    );
  }
}

class _LogsSummaryStrip extends StatelessWidget {
  const _LogsSummaryStrip({required this.logs});

  final List<InsightLogItem> logs;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final positive = logs.where((log) => log.tone == InsightLogTone.positive).length;
    final warnings = logs.where((log) => log.tone == InsightLogTone.warning).length;
    final neutral = logs.where((log) => log.tone == InsightLogTone.neutral).length;

    final items = [
      _LogSummaryTile(
        icon: Icons.trending_up_rounded,
        label: t.get('logs_positive_label', fallback: 'Positive'),
        value: positive.toString(),
        tone: InsightLogTone.positive,
      ),
      _LogSummaryTile(
        icon: Icons.warning_amber_rounded,
        label: t.get('logs_warning_label', fallback: 'Warnings'),
        value: warnings.toString(),
        tone: InsightLogTone.warning,
      ),
      _LogSummaryTile(
        icon: Icons.insights_outlined,
        label: t.get('logs_neutral_label', fallback: 'Neutral'),
        value: neutral.toString(),
        tone: InsightLogTone.neutral,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        const gap = 8.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _LogSummaryTile extends StatelessWidget {
  const _LogSummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final InsightLogTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _toneColor(colors, tone);

    return Container(
      height: 62,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.60)
            : colors.surface.withValues(alpha: 0.92),
        border: Border.all(color: accent.withValues(alpha: isDark ? 0.24 : 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsLogsPreviewCard extends StatelessWidget {
  const _InsightsLogsPreviewCard({
    required this.logs,
  });

  final List<InsightLogItem> logs;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final visibleLogs = logs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.74),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.88),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.76 : 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.14)
                : colors.primary.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.get('logs_recent_title', fallback: 'Recent log entries'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (visibleLogs.isEmpty)
            _EmptyLogs(
              message: t.get(
                'insights_logs_empty',
                fallback: 'Complete a few sessions to generate recovery notes.',
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < visibleLogs.length; i++) ...[
                  _InsightLogTile(log: visibleLogs[i]),
                  if (i != visibleLogs.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.48),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insights_outlined,
            color: colors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightLogTile extends StatelessWidget {
  const _InsightLogTile({required this.log});

  final InsightLogItem log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _toneColor(colors, log.tone);
    final icon = _toneIcon(log.tone);

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? accent.withValues(alpha: 0.08)
            : accent.withValues(alpha: 0.055),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.20 : 0.13),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  log.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.22,
                    fontWeight: FontWeight.w600,
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

class _LogsLoadingState extends StatelessWidget {
  const _LogsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _LogsErrorState extends StatelessWidget {
  const _LogsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 34, color: colors.error),
                  const SizedBox(height: 12),
                  Text(
                    t.get('logs_error_title', fallback: 'Unable to load logs'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(t.get('common_retry', fallback: 'Retry')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _toneColor(ColorScheme colors, InsightLogTone tone) {
  return switch (tone) {
    InsightLogTone.positive => colors.secondary,
    InsightLogTone.warning => colors.error,
    InsightLogTone.neutral => colors.primary,
  };
}

IconData _toneIcon(InsightLogTone tone) {
  return switch (tone) {
    InsightLogTone.positive => Icons.trending_up_rounded,
    InsightLogTone.warning => Icons.warning_amber_rounded,
    InsightLogTone.neutral => Icons.insights_outlined,
  };
}
