// lib/features/sessions/presentation/pages/saved_sessions_page.dart

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
import '../../../player/application/session_continuity_providers.dart';
import '../widgets/saved_session_card.dart';

class SavedSessionsPage extends ConsumerWidget {
  const SavedSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final savedAsync = ref.watch(savedSessionContinuityItemsProvider);
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
        t.get('saved_sessions_title', fallback: 'Saved Sessions'),
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
          feature: LockedFeature.savedSessions,
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
                      'saved_sessions_locked_title',
                      fallback: 'Saved Sessions are part of Core Access',
                    ),
                    message: t.get(
                      'saved_sessions_locked_message',
                      fallback:
                          'Unlock Core once to keep a full recovery continuity list with saved sessions, history, and resume paths.',
                    ),
                    icon: Icons.bookmark_added_outlined,
                    onUpgrade: () => context.pushNamed('premium'),
                  ),
                ],
              ),
            ],
          );
        }

        return savedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.get(
                  'saved_sessions_error',
                  fallback: 'Could not load saved sessions.',
                ),
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
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
                            const Icon(Icons.bookmark_border_rounded, size: 34),
                            const SizedBox(height: 12),
                            Text(
                              t.get(
                                'saved_sessions_empty_title',
                                fallback: 'No saved sessions yet',
                              ),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.get(
                                'saved_sessions_empty_body',
                                fallback:
                                    'Save sessions from the library or detail page to build your continuity list.',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => context.goNamed('sessions'),
                              icon: const Icon(Icons.grid_view_rounded),
                              label: Text(
                                t.get(
                                  'saved_sessions_browse_cta',
                                  fallback: 'Browse Sessions',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              children: [
                ResponsiveContentSection(
                  spacing: pageInfo.sectionSpacing,
                  children: [
                    ...items.map(
                      (item) => SavedSessionCard(item: item),
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