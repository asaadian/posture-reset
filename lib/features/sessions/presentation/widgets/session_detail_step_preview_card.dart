// lib/features/sessions/presentation/widgets/session_detail_step_preview_card.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_models.dart';

class SessionDetailStepPreviewCard extends StatelessWidget {
  const SessionDetailStepPreviewCard({
    super.key,
    required this.steps,
  });

  final List<SessionStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    if (steps.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.get(
              'session_detail_steps_empty',
              fallback: 'No step preview is available for this session yet.',
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            final stepLabel = t.get(
              'session_detail_step_label',
              fallback: 'Step',
            );

            final stepTitle = AppText.get(
              context,
              key: step.titleKey,
              fallback: step.titleFallback,
            );

            final stepInstruction = AppText.get(
              context,
              key: step.instructionKey,
              fallback: step.instructionFallback,
            );

            final durationLabel = '${step.durationSeconds} ${t.get(
              'session_detail_seconds_unit',
              fallback: 'sec',
            )}';

            final typeLabel = _stepTypeLabel(context, step.stepType);
            final targetSummary = _targetSummary(step.bodyTargetCodes);

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text('${step.order}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$stepLabel ${step.order} • $stepTitle',
                            style: theme.textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _CompactMetaChip(label: typeLabel),
                              _CompactMetaChip(label: durationLabel),
                              if (step.isSkippable)
                                _CompactMetaChip(
                                  label: t.get(
                                    'session_detail_step_skippable',
                                    fallback: 'Skippable',
                                  ),
                                ),
                              if (targetSummary != null)
                                _CompactMetaChip(label: targetSummary),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            stepInstruction,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CompactMetaChip extends StatelessWidget {
  const _CompactMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String? _targetSummary(List<String> codes) {
  if (codes.isEmpty) return null;

  final labels = codes
      .map(_humanizeCode)
      .where((e) => e.trim().isNotEmpty)
      .toList(growable: false);

  if (labels.isEmpty) return null;
  if (labels.length == 1) return labels.first;

  return labels.take(2).join(', ');
}

String _humanizeCode(String raw) {
  final value = raw.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  if (value.isEmpty) return raw;

  return value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _stepTypeLabel(BuildContext context, SessionStepType type) {
  final t = AppText.of(context);

  switch (type) {
    case SessionStepType.setup:
      return t.get('session_step_type_setup', fallback: 'Setup');
    case SessionStepType.movement:
      return t.get('session_step_type_movement', fallback: 'Movement');
    case SessionStepType.hold:
      return t.get('session_step_type_hold', fallback: 'Hold');
    case SessionStepType.breath:
      return t.get('session_step_type_breath', fallback: 'Breath');
    case SessionStepType.transition:
      return t.get('session_step_type_transition', fallback: 'Transition');
    case SessionStepType.cooldown:
      return t.get('session_step_type_cooldown', fallback: 'Cooldown');
  }
}