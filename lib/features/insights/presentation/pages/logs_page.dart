// lib/features/insights/presentation/pages/logs_page.dart

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
import '../widgets/insights_logs_preview_card.dart';

class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

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
          return const Center(child: CircularProgressIndicator());
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
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
                          'logs_hero_title',
                          fallback: 'Behavior logs',
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.get(
                          'logs_hero_body',
                          fallback:
                              'These logs are generated from recent runs, feedback, quick-fix activity, state snapshots, and step-level player events.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InsightsLogsPreviewCard(logs: snapshot.logs),
              ],
            );
          },
        );
      },
    );
  }
}