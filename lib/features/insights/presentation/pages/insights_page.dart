// lib/features/insights/presentation/pages/insights_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/adaptive_section_title.dart';
import '../../application/insights_providers.dart';
import '../../domain/insights_snapshot.dart';
import '../widgets/insight_summary_card.dart';
import '../widgets/insights_chart_preview_card.dart';
import '../widgets/insights_heatmap_preview_card.dart';
import '../widgets/insights_logs_preview_card.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  Future<void> _refresh(WidgetRef ref, InsightsRange range) async {
    ref.invalidate(insightsSnapshotProvider(range));
    await ref.read(insightsSnapshotProvider(range).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(insightsSelectedRangeProvider);
    final insightsAsync = ref.watch(insightsSnapshotProvider(range));
    final accessAsync = ref.watch(accessSnapshotProvider);
    final t = AppText.of(context);

    return ResponsivePageScaffold(
      title: Text(t.get('insights_title', fallback: 'Insights')),
      actions: [
        PopupMenuButton<InsightsRange>(
          tooltip: t.get(
            'insights_date_range_tooltip',
            fallback: 'Change date range',
          ),
          icon: const Icon(Icons.calendar_today_outlined),
          onSelected: (value) {
            ref.read(insightsSelectedRangeProvider.notifier).setRange(value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: InsightsRange.last7Days,
              child: Text('Last 7 days'),
            ),
            PopupMenuItem(
              value: InsightsRange.last14Days,
              child: Text('Last 14 days'),
            ),
            PopupMenuItem(
              value: InsightsRange.last28Days,
              child: Text('Last 28 days'),
            ),
          ],
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.insightsFullAccess,
        );

        if (accessAsync.isLoading) {
          return const _InsightsLoadingState();
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              LockedFeatureCard(
                title: t.get(
                  'insights_locked_title',
                  fallback: 'Full Insights are part of Core Access',
                ),
                message: t.get(
                  'insights_locked_message',
                  fallback:
                      'Unlock Core once to open recovery trends, heatmap, logs, body intelligence, and deeper pattern analysis.',
                ),
                icon: Icons.insights_rounded,
                onUpgrade: () => context.pushNamed('premium'),
              ),
            ],
          );
        }

        return insightsAsync.when(
          loading: () => const _InsightsLoadingState(),
          error: (error, stackTrace) => _InsightsErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(insightsSnapshotProvider(range)),
          ),
          data: (snapshot) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref, range),
              child: ListView(
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
                children: [
                  _InsightsHero(
                    snapshot: snapshot,
                    pageInfo: pageInfo,
                  ),
                  SizedBox(height: pageInfo.isCompact ? 20 : 24),

                  const AdaptiveSectionTitle(
                    titleKey: 'insights_what_works_title',
                    titleFallback: 'What Works Best',
                  ),
                  const SizedBox(height: 12),
                  _InsightsSummaryGrid(snapshot: snapshot),
                  SizedBox(height: pageInfo.isCompact ? 20 : 24),

                  const AdaptiveSectionTitle(
                    titleKey: 'insights_recovery_trends_title',
                    titleFallback: 'Recovery Trends',
                  ),
                  const SizedBox(height: 12),
                  InsightsChartPreviewCard(
                    title: AppText.get(
                      context,
                      key: 'insights_recovery_minutes_title',
                      fallback: 'Recovery Minutes',
                    ),
                    subtitle: AppText.get(
                      context,
                      key: 'insights_recovery_minutes_subtitle',
                      fallback: 'Completed minutes by day',
                    ),
                    points: snapshot.recoveryMinutesSeries,
                    accent: Theme.of(context).colorScheme.primary,
                    valueSuffix: 'm',
                  ),
                  const SizedBox(height: 12),
                  InsightsChartPreviewCard(
                    title: AppText.get(
                      context,
                      key: 'insights_relief_trend_title',
                      fallback: 'Relief Trend',
                    ),
                    subtitle: AppText.get(
                      context,
                      key: 'insights_relief_trend_subtitle',
                      fallback: 'Average relief signal from feedback',
                    ),
                    points: snapshot.reliefSeries,
                    accent: const Color(0xFF62E6D9),
                    valueSuffix: '',
                  ),
                  SizedBox(height: pageInfo.isCompact ? 20 : 24),

                  const AdaptiveSectionTitle(
                    titleKey: 'insights_body_intelligence_title',
                    titleFallback: 'Body Intelligence',
                  ),
                  const SizedBox(height: 12),
                  InsightsHeatmapPreviewCard(
                    cells: snapshot.heatmapCells,
                    compact: true,
                  ),
                  SizedBox(height: pageInfo.isCompact ? 20 : 24),

                  AdaptiveSectionTitle(
                    titleKey: 'insights_patterns_title',
                    titleFallback: 'Recovery Patterns',
                    actionLabelKey: 'insights_logs_action',
                    actionLabelFallback: 'View All',
                    onActionTap: () => context.pushNamed('logs'),
                  ),
                  const SizedBox(height: 12),
                  InsightsLogsPreviewCard(
                    logs: snapshot.logs,
                    limit: 4,
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

class _InsightsHero extends StatelessWidget {
  const _InsightsHero({
    required this.snapshot,
    required this.pageInfo,
  });

  final InsightsSnapshot snapshot;
  final ResponsivePageInfo pageInfo;

  @override
  Widget build(BuildContext context) {
    final isWide = pageInfo.isMedium || pageInfo.isExpanded;
    final dominantZone = _painAreaLabel(context, snapshot.dominantPainAreaCode);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            const Color(0xFF62E6D9).withValues(alpha: 0.08),
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: _HeroOverview(snapshot: snapshot),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 10,
                    child: _HeroInsightPanel(
                      dominantZone: dominantZone,
                      snapshot: snapshot,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _HeroOverview(snapshot: snapshot),
                  const SizedBox(height: 14),
                  _HeroInsightPanel(
                    dominantZone: dominantZone,
                    snapshot: snapshot,
                  ),
                ],
              ),
      ),
    );
  }
}

class _HeroOverview extends StatelessWidget {
  const _HeroOverview({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final chips = [
      _HeroChip(
        icon: Icons.event_available_rounded,
        label: '${snapshot.range.days}d',
      ),
      _HeroChip(
        icon: Icons.local_fire_department_outlined,
        label: '${snapshot.currentStreakDays}d streak',
      ),
      _HeroChip(
        icon: Icons.favorite_border_rounded,
        label: '${(snapshot.helpRate * 100).round()}% helpful',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppText.get(
            context,
            key: 'insights_intro_title',
            fallback: 'Behavior patterns, not just metrics.',
          ),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }
}

class _HeroInsightPanel extends StatelessWidget {
  const _HeroInsightPanel({
    required this.dominantZone,
    required this.snapshot,
  });

  final String dominantZone;
  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.74),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          _InsightFocusTile(
            icon: Icons.accessibility_new_rounded,
            title: AppText.get(
              context,
              key: 'insights_focus_zone_title',
              fallback: 'Top zone',
            ),
            value: dominantZone,
          ),
          const SizedBox(height: 10),
          _InsightFocusTile(
            icon: Icons.check_circle_outline_rounded,
            title: AppText.get(
              context,
              key: 'insights_focus_completion_title',
              fallback: 'Completion',
            ),
            value: '${(snapshot.completionRate * 100).round()}%',
          ),
          const SizedBox(height: 10),
          _InsightFocusTile(
            icon: Icons.auto_graph_rounded,
            title: AppText.get(
              context,
              key: 'insights_focus_relief_title',
              fallback: 'Relief',
            ),
            value: '${snapshot.averageReliefScore.round()}',
          ),
        ],
      ),
    );
  }
}

class _InsightFocusTile extends StatelessWidget {
  const _InsightFocusTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.10),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                ),
          ),
        ],
      ),
    );
  }
}

class _InsightsSummaryGrid extends StatelessWidget {
  const _InsightsSummaryGrid({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final dominantZone = _painAreaLabel(context, snapshot.dominantPainAreaCode);
    final consistency = (snapshot.consistencyScore * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 4
            : width >= 760
                ? 2
                : 2;
        final childAspectRatio = width >= 1100
            ? 1.45
            : width >= 760
                ? 1.6
                : 1.08;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            InsightSummaryCard(
              title: 'Consistency',
              value: '$consistency%',
              subtitle: 'Active days',
              icon: Icons.check_circle_outline,
              accent: Theme.of(context).colorScheme.primary,
            ),
            InsightSummaryCard(
              title: 'Minutes',
              value: '${snapshot.recoveryMinutes}',
              subtitle: 'Completed',
              icon: Icons.timer_outlined,
              accent: const Color(0xFF62E6D9),
            ),
            InsightSummaryCard(
              title: 'Dominant',
              value: dominantZone,
              subtitle: 'Top zone',
              icon: Icons.accessibility_new_rounded,
              accent: Theme.of(context).colorScheme.tertiary,
            ),
            InsightSummaryCard(
              title: 'Quick Fix',
              value: '${snapshot.quickFixStarts}',
              subtitle: 'Starts',
              icon: Icons.flash_on_outlined,
              accent: Theme.of(context).colorScheme.secondary,
            ),
          ],
        );
      },
    );
  }
}

class _InsightsLoadingState extends StatelessWidget {
  const _InsightsLoadingState();

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

class _InsightsErrorState extends StatelessWidget {
  const _InsightsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.error_outline_rounded, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load insights',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
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

String _painAreaLabel(BuildContext context, String? code) {
  switch (code) {
    case 'neck':
      return AppText.get(context, key: 'pain_neck', fallback: 'Neck');
    case 'shoulders':
      return AppText.get(
        context,
        key: 'pain_shoulders',
        fallback: 'Shoulders',
      );
    case 'upper_back':
      return AppText.get(
        context,
        key: 'pain_upper_back',
        fallback: 'Upper back',
      );
    case 'lower_back':
      return AppText.get(
        context,
        key: 'pain_lower_back',
        fallback: 'Lower back',
      );
    case 'wrists':
      return AppText.get(context, key: 'pain_wrists', fallback: 'Wrists');
    case null:
      return AppText.get(
        context,
        key: 'dashboard_zone_unknown',
        fallback: 'No clear zone yet',
      );
    default:
      return code.replaceAll('_', ' ');
  }
}