// lib/features/player/presentation/pages/session_history_page.dart

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
import '../../application/session_continuity_providers.dart';
import '../widgets/continue_session_card.dart';
import '../widgets/session_history_card.dart';

class SessionHistoryPage extends ConsumerWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final historyAsync = ref.watch(sessionHistoryItemsProvider);
    final candidateAsync = ref.watch(continueSessionCandidateProvider);
    final accessAsync = ref.watch(accessSnapshotProvider);

    void goBackSafely() {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go('/app/profile');
    }

    return ResponsivePageScaffold(
      title: Text(
        t.get('session_history_title', fallback: 'Session History'),
      ),
      actions: [
        IconButton(
          onPressed: goBackSafely,
          tooltip: t.get('common_back', fallback: 'Back'),
          icon: const Icon(Icons.arrow_back),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        final accessSnapshot = accessAsync.maybeWhen(
          data: (value) => value,
          orElse: () => AccessSnapshot.guest,
        );

        final accessDecision = AccessPolicy.canAccessFeature(
          snapshot: accessSnapshot,
          feature: LockedFeature.sessionHistory,
        );

        if (accessAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!accessDecision.allowed) {
          return ListView(
            padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
            children: [
              ResponsiveContentSection(
                spacing: pageInfo.sectionSpacing,
                children: [
                  LockedFeatureCard(
                    title: t.get(
                      'session_history_locked_title',
                      fallback: 'Session History is part of Core Access',
                    ),
                    message: t.get(
                      'session_history_locked_message',
                      fallback:
                          'Unlock Core once to review completed runs, unfinished sessions, resume paths, and repeatable recovery patterns.',
                    ),
                    icon: Icons.history_rounded,
                    onUpgrade: () => context.pushNamed('premium'),
                  ),
                ],
              ),
            ],
          );
        }

        return historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.get(
                  'session_history_error',
                  fallback: 'Could not load session history.',
                ),
              ),
            ),
          ),
          data: (items) {
            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
                  children: [
                    candidateAsync.maybeWhen(
                      data: (candidate) => candidate == null
                          ? const SizedBox.shrink()
                          : ContinueSessionCard(candidate: candidate),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    if (items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.history_rounded, size: 34),
                              const SizedBox(height: 12),
                              Text(
                                t.get(
                                  'session_history_empty_title',
                                  fallback: 'No session history yet',
                                ),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.get(
                                  'session_history_empty_body',
                                  fallback:
                                      'Your completed and unfinished session runs will appear here.',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => SessionHistoryCard(item: item),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}