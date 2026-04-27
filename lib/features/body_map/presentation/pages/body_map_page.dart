import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/body_map_providers.dart';
import '../../domain/body_map_models.dart';
import '../widgets/body_map_canvas_card.dart';
import '../widgets/body_map_recommendation_list.dart';
import '../widgets/body_map_toggle_card.dart';
import '../widgets/body_zone_trend_card.dart';
import 'package:go_router/go_router.dart';

import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';

class BodyMapPage extends ConsumerStatefulWidget {
  const BodyMapPage({super.key});

  @override
  ConsumerState<BodyMapPage> createState() => _BodyMapPageState();
}

class _BodyMapPageState extends ConsumerState<BodyMapPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _recommendationsKey = GlobalKey();

  Future<void> _refresh() async {
    ref.invalidate(bodyMapSnapshotProvider);
    await ref.read(bodyMapSnapshotProvider.future);
  }

  Future<void> _scrollToKey(GlobalKey key, {double alignment = 0.08}) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: alignment,
    );
  }

  Future<void> _focusZoneOnBody(BodyMapZoneSnapshot zone) async {
    ref.read(bodyMapSelectedZoneProvider.notifier).select(zone.code);
    ref.read(bodyMapSideProvider.notifier).setSide(zone.side);
    await WidgetsBinding.instance.endOfFrame;
    await _scrollToKey(_canvasKey, alignment: 0.12);
  }

  Future<void> _openRecommendationsForZone(BodyMapZoneSnapshot zone) async {
    ref.read(bodyMapSelectedZoneProvider.notifier).select(zone.code);
    ref.read(bodyMapSideProvider.notifier).setSide(zone.side);
    await WidgetsBinding.instance.endOfFrame;
    await _scrollToKey(_recommendationsKey, alignment: 0.08);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final side = ref.watch(bodyMapSideProvider);
    final selectedZoneCode = ref.watch(bodyMapSelectedZoneProvider);
    final snapshotAsync = ref.watch(bodyMapSnapshotProvider);
final accessAsync = ref.watch(accessSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('body_map_title', fallback: 'Body Map')),
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(bodyMapSnapshotProvider),
          tooltip: t.get(
            'body_map_filters_tooltip',
            fallback: 'Refresh body map',
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final recommendationAccessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.bodyMapRecommendations,
        );

        final recommendationsLocked =
            accessAsync.isLoading || !recommendationAccessDecision.allowed;

        return snapshotAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => _BodyMapErrorState(
            message: '$error',
            onRetry: () => ref.invalidate(bodyMapSnapshotProvider),
          ),
          data: (snapshot) {
            final effectiveZoneCode =
                selectedZoneCode ?? snapshot.dominantZoneCodeForSide(side);

            final selectedZone = effectiveZoneCode == null
                ? null
                : snapshot.zoneByCode(effectiveZoneCode);

            final recommendations =
                snapshot.recommendationsForZone(effectiveZoneCode);

            final topZones = snapshot.zonesForSide(side)
                .where((zone) => zone.isActive)
                .take(3)
                .toList();

            final isWide = pageInfo.isMedium || pageInfo.isExpanded;
            final gap = pageInfo.isCompact ? 18.0 : 22.0;

            final leftColumn = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    BodyMapToggleCard(
      side: side,
      onChanged: (value) {
        ref.read(bodyMapSideProvider.notifier).setSide(value);
      },
    ),
    const SizedBox(height: 12),
    _InlineHintText(
      label: t.get(
        'body_map_canvas_hint',
        fallback: 'Tap a glowing zone to inspect details.',
      ),
    ),
    const SizedBox(height: 10),
    KeyedSubtree(
      key: _canvasKey,
      child: BodyMapCanvasCard(
        side: side,
        snapshot: snapshot,
        selectedZoneCode: effectiveZoneCode,
        onZoneTap: (code) {
          ref.read(bodyMapSelectedZoneProvider.notifier).select(code);
        },
      ),
    ),
  ],
);

            final rightColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectedZoneCard(
                  zone: selectedZone,
                  onFocusZone: selectedZone == null
                      ? null
                      : () => _focusZoneOnBody(selectedZone),
                  onOpenRecommendations: selectedZone == null
                      ? null
                      : () => _openRecommendationsForZone(selectedZone),
                ),
                const SizedBox(height: 12),
                _CompactSectionTitle(
                  title: t.get(
                    'body_map_zone_trends_title',
                    fallback: 'Hot Zones',
                  ),
                ),
                const SizedBox(height: 10),
                if (topZones.isEmpty)
                  _InlineEmptyState(
                    label: t.get(
                      'body_map_empty_zones',
                      fallback: 'No active zone data yet.',
                    ),
                  )
                else
                  ...topZones.map(
                    (zone) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BodyZoneTrendCard(zone: zone),
                    ),
                  ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: _recommendationsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompactSectionTitle(
                        title: t.get(
                          'body_map_recommendations_title',
                          fallback: 'Best Sessions',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (recommendationsLocked)
                      LockedFeatureCard(
                        title: t.get(
                          'body_map_recommendations_locked_title',
                          fallback: 'Body-map recommendations are part of Core Access',
                        ),
                        message: t.get(
                          'body_map_recommendations_locked_message',
                          fallback:
                              'You can inspect body zones for free. Unlock Core once to turn selected zones into best-fit recovery session recommendations.',
                        ),
                        icon: Icons.accessibility_new_rounded,
                        compact: true,
                        onUpgrade: () => context.pushNamed('premium'),
                      )
                    else
                      BodyMapRecommendationList(
                        zoneCode: effectiveZoneCode,
                        items: recommendations,
                      ),
                    ],
                  ),
                ),
              ],
            );

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
                children: [
                  _BodyMapHero(
                    side: side,
                    activeZoneCount: snapshot.activeZoneCountForSide(side),
                    dominantZoneCode: snapshot.dominantZoneCodeForSide(side),
                    selectedZone: selectedZone,
                  ),
                  SizedBox(height: gap),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 11, child: leftColumn),
                        const SizedBox(width: 20),
                        Expanded(flex: 9, child: rightColumn),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftColumn,
                        const SizedBox(height: 12),
                        rightColumn,
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

class _BodyMapHero extends StatelessWidget {
  const _BodyMapHero({
    required this.side,
    required this.activeZoneCount,
    required this.dominantZoneCode,
    required this.selectedZone,
  });

  final BodyMapSide side;
  final int activeZoneCount;
  final String? dominantZoneCode;
  final BodyMapZoneSnapshot? selectedZone;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            const Color(0xFF62E6D9).withValues(alpha: 0.10),
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get(
                'body_map_intro_title',
                fallback: 'Body Intelligence',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroChip(
                  icon: Icons.flip_rounded,
                  label: side == BodyMapSide.front
                      ? t.get('body_map_front', fallback: 'Front')
                      : t.get('body_map_back', fallback: 'Back'),
                ),
                _HeroChip(
                  icon: Icons.radio_button_checked_rounded,
                  label:
                      '$activeZoneCount ${t.get('body_map_active', fallback: 'active')}',
                ),
                _HeroChip(
                  icon: Icons.auto_graph_rounded,
                  label: _zoneLabel(context, dominantZoneCode),
                ),
                _HeroChip(
                  icon: Icons.touch_app_rounded,
                  label: selectedZone == null
                      ? t.get('body_map_select_zone', fallback: 'Select zone')
                      : _zoneLabel(context, selectedZone!.code),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineHintText extends StatelessWidget {
  const _InlineHintText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedZoneCard extends StatelessWidget {
  const _SelectedZoneCard({
    required this.zone,
    required this.onFocusZone,
    required this.onOpenRecommendations,
  });

  final BodyMapZoneSnapshot? zone;
  final VoidCallback? onFocusZone;
  final VoidCallback? onOpenRecommendations;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: zone == null
          ? Text(
              t.get(
                'body_map_select_zone_hint',
                fallback: 'Tap a zone to inspect strain and session fit.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _zoneLabel(context, zone!.code),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    _SignalBadge(
                      label: _trendLabel(context, zone!.trend),
                      severity: zone!.severity,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: t.get(
                          'body_map_metric_severity',
                          fallback: 'Severity',
                        ),
                        value: _severityLabel(context, zone!.severity),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: t.get(
                          'body_map_metric_recent_hits',
                          fallback: 'Recent hits',
                        ),
                        value: '${zone!.recentHits}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: t.get(
                          'body_map_metric_previous',
                          fallback: 'Previous',
                        ),
                        value: '${zone!.previousHits}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: t.get(
                          'body_map_metric_relief',
                          fallback: 'Relief',
                        ),
                        value: '${zone!.reliefScore.round()}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onFocusZone,
                        icon: const Icon(Icons.center_focus_strong_rounded),
                        label: Text(
                          t.get(
                            'body_map_focus_zone',
                            fallback: 'Focus Zone',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenRecommendations,
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: Text(
                          t.get(
                            'body_map_best_sessions_short',
                            fallback: 'Sessions',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({
    required this.label,
    required this.severity,
  });

  final String label;
  final BodyZoneSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      BodyZoneSeverity.low => Theme.of(context).colorScheme.secondary,
      BodyZoneSeverity.medium => const Color(0xFF62E6D9),
      BodyZoneSeverity.high => Theme.of(context).colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
            ),
      ),
    );
  }
}

class _CompactSectionTitle extends StatelessWidget {
  const _CompactSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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

class _BodyMapErrorState extends StatelessWidget {
  const _BodyMapErrorState({
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load body map',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
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

String _zoneLabel(BuildContext context, String? code) {
  switch (code) {
    case 'neck':
      return AppText.get(context, key: 'pain_neck', fallback: 'Neck');
    case 'shoulders':
      return AppText.get(context, key: 'pain_shoulders', fallback: 'Shoulders');
    case 'upper_back':
      return AppText.get(context, key: 'pain_upper_back', fallback: 'Upper back');
    case 'lower_back':
      return AppText.get(context, key: 'pain_lower_back', fallback: 'Lower back');
    case 'wrists':
      return AppText.get(context, key: 'pain_wrists', fallback: 'Wrists');
    default:
      return AppText.get(
        context,
        key: 'body_map_zone_unknown',
        fallback: 'No clear zone',
      );
  }
}

String _severityLabel(BuildContext context, BodyZoneSeverity severity) {
  switch (severity) {
    case BodyZoneSeverity.low:
      return AppText.get(context, key: 'body_map_severity_low', fallback: 'Low');
    case BodyZoneSeverity.medium:
      return AppText.get(
        context,
        key: 'body_map_severity_medium',
        fallback: 'Medium',
      );
    case BodyZoneSeverity.high:
      return AppText.get(context, key: 'body_map_severity_high', fallback: 'High');
  }
}

String _trendLabel(BuildContext context, BodyZoneTrend trend) {
  switch (trend) {
    case BodyZoneTrend.rising:
      return AppText.get(context, key: 'body_map_trend_rising', fallback: 'Rising');
    case BodyZoneTrend.stable:
      return AppText.get(context, key: 'body_map_trend_stable', fallback: 'Stable');
    case BodyZoneTrend.improving:
      return AppText.get(
        context,
        key: 'body_map_trend_improving',
        fallback: 'Improving',
      );
  }
}