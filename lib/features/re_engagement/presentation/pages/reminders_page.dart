// lib/features/re_engagement/presentation/pages/reminders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../application/re_engagement_providers.dart';
import '../../domain/re_engagement_models.dart';
import '../widgets/re_engagement_card.dart';
import '../widgets/re_engagement_empty_state.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  String? _lastShownCandidateKey;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final snapshotAsync = ref.watch(reEngagementSnapshotProvider);

    return ResponsivePageScaffold(
      title: Text(
        t.get('re_engagement_page_title', fallback: 'Reminders'),
      ),
      bodyBuilder: (context, pageInfo) {
        return snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.get(
                  're_engagement_error',
                  fallback: 'Could not load reminders.',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (snapshot) {
            _markTopCandidateShown(snapshot);

            if (!snapshot.hasContent) {
              return const ReEngagementEmptyState();
            }

            return ListView.separated(
              padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 24 : 32),
              itemCount: snapshot.candidates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final candidate = snapshot.candidates[index];

                return ReEngagementCard(
                  candidate: candidate,
                  compact: index > 0,
                  onPrimaryTap: () async {
                    await ref
                        .read(reEngagementRepositoryProvider)
                        .markActed(candidate);
                    if (!context.mounted) return;
                    _openCandidate(context, candidate);
                  },
                  onDismissTap: () async {
                    await ref
                        .read(reEngagementRepositoryProvider)
                        .markDismissed(candidate);
                    ref.invalidate(reEngagementSnapshotProvider);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _markTopCandidateShown(ReEngagementSnapshot snapshot) {
    final top = snapshot.topCandidate;
    if (top == null) return;
    if (_lastShownCandidateKey == top.candidateKey) return;

    _lastShownCandidateKey = top.candidateKey;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(reEngagementRepositoryProvider).markShown(top);
    });
  }

  void _openCandidate(BuildContext context, ReEngagementCandidate candidate) {
    switch (candidate.type) {
      case ReEngagementType.continueSession:
        if (candidate.sessionId != null) {
          context.pushNamed(
            'session-player',
            pathParameters: {'id': candidate.sessionId!},
            queryParameters: const {'source': 'reminders'},
          );
        }
        break;
      case ReEngagementType.returnToSaved:
        context.pushNamed('saved-sessions');
        break;
      case ReEngagementType.quickRelief:
        context.goNamed('quick-fix');
        break;
      case ReEngagementType.consistencyRecovery:
        context.goNamed('sessions');
        break;
    }
  }
}