// lib/features/sessions/presentation/widgets/saved_session_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../player/domain/session_continuity_models.dart';

class SavedSessionCard extends StatelessWidget {
  const SavedSessionCard({
    super.key,
    required this.item,
  });

  final SavedSessionContinuityItem item;

  @override
  Widget build(BuildContext context) {
    final title = AppText.get(
      context,
      key: item.session.titleKey,
      fallback: item.session.titleFallback,
    );
    final subtitle = AppText.get(
      context,
      key: item.session.shortDescriptionKey,
      fallback: item.session.shortDescriptionFallback,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;

            final actionRow = compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            'session-player',
                            pathParameters: {'id': item.session.id},
                            queryParameters: const {'source': 'dashboard'},
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(_cta(context, item.action)),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            'session-detail',
                            pathParameters: {'id': item.session.id},
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(
                          AppText.get(
                            context,
                            key: 'continuity_open_detail',
                            fallback: 'Open Detail',
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            context.pushNamed(
                              'session-player',
                              pathParameters: {'id': item.session.id},
                              queryParameters: const {'source': 'dashboard'},
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(_cta(context, item.action)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            'session-detail',
                            pathParameters: {'id': item.session.id},
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(
                          AppText.get(
                            context,
                            key: 'continuity_open_detail',
                            fallback: 'Open Detail',
                          ),
                        ),
                      ),
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(
                      label: '${item.session.durationMinutes}m',
                    ),
                    if (item.latestRun != null)
                      _Tag(
                        label: _actionLabel(context, item.action),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                actionRow,
              ],
            );
          },
        ),
      ),
    );
  }

  String _cta(BuildContext context, ContinuityActionType action) {
    switch (action) {
      case ContinuityActionType.continueSession:
        return AppText.get(
          context,
          key: 'continuity_continue_cta',
          fallback: 'Continue',
        );
      case ContinuityActionType.resumeSession:
        return AppText.get(
          context,
          key: 'continuity_resume_cta',
          fallback: 'Resume',
        );
      case ContinuityActionType.repeatSession:
        return AppText.get(
          context,
          key: 'continuity_repeat_cta',
          fallback: 'Do Again',
        );
      case ContinuityActionType.startSession:
        return AppText.get(
          context,
          key: 'continuity_start_cta',
          fallback: 'Start',
        );
    }
  }

  String _actionLabel(BuildContext context, ContinuityActionType action) {
    switch (action) {
      case ContinuityActionType.continueSession:
        return AppText.get(
          context,
          key: 'continuity_label_active',
          fallback: 'Active run',
        );
      case ContinuityActionType.resumeSession:
        return AppText.get(
          context,
          key: 'continuity_label_resumable',
          fallback: 'Unfinished',
        );
      case ContinuityActionType.repeatSession:
        return AppText.get(
          context,
          key: 'continuity_label_repeatable',
          fallback: 'Played before',
        );
      case ContinuityActionType.startSession:
        return AppText.get(
          context,
          key: 'continuity_label_saved',
          fallback: 'Saved',
        );
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(label),
    );
  }
}