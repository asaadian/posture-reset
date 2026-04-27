// lib/features/insights/presentation/pages/heatmap_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';
import '../../application/insights_providers.dart';
import '../../domain/insights_snapshot.dart';
import '../widgets/insights_heatmap_preview_card.dart';

class HeatmapPage extends ConsumerWidget {
  const HeatmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(
      insightsSnapshotProvider(InsightsRange.last28Days),
    );
    final accessAsync = ref.watch(accessSnapshotProvider);
    final t = AppText.of(context);

    return ResponsivePageScaffold(
      title: Text(t.get('heatmap_page_title', fallback: 'Heatmap')),
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.insightsHeatmap,
        );

        if (accessAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              LockedFeatureCard(
                title: t.get(
                  'heatmap_locked_title',
                  fallback: 'Recovery Heatmap is part of Core Access',
                ),
                message: t.get(
                  'heatmap_locked_message',
                  fallback:
                      'Unlock Core once to map recovery intensity, active days, and consistency patterns over time.',
                ),
                icon: Icons.grid_on_rounded,
                onUpgrade: () => context.pushNamed('premium'),
              ),
            ],
          );
        }

        return snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (snapshot) {
            final totalMinutes = snapshot.heatmapCells.fold<int>(
              0,
              (sum, cell) => sum + cell.minutes,
            );
            final activeDays = snapshot.heatmapCells.where((cell) {
              return cell.minutes > 0;
            }).length;

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.get(
                          'heatmap_hero_title',
                          fallback: 'Monthly recovery intensity',
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.get(
                          'heatmap_hero_body',
                          fallback:
                              'This view maps the last 35 days of recovery activity based on completed minutes from real session runs.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeatmapStatPill(
                            label: t.get(
                              'heatmap_total_minutes',
                              fallback: 'Total minutes',
                            ),
                            value: '$totalMinutes',
                          ),
                          _HeatmapStatPill(
                            label: t.get(
                              'heatmap_active_days',
                              fallback: 'Active days',
                            ),
                            value: '$activeDays',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InsightsHeatmapPreviewCard(
                  cells: snapshot.heatmapCells,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeatmapStatPill extends StatelessWidget {
  const _HeatmapStatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.10),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '$label • $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
            ),
      ),
    );
  }
}