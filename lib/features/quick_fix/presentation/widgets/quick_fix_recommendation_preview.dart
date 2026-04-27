// lib/features/quick_fix/presentation/widgets/quick_fix_recommendation_preview.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/domain/session_feedback_models.dart';
import '../../domain/quick_fix_models.dart';
import '../controllers/quick_fix_controller.dart';
import 'quick_fix_signal_strip.dart';

class QuickFixRecommendationPreview extends ConsumerWidget {
  const QuickFixRecommendationPreview({
    super.key,
    required this.recommendation,
    required this.alternatives,
    required this.emphasize,
    this.compact = false,
  });

  final QuickFixRecommendation? recommendation;
  final List<QuickFixRecommendation> alternatives;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (recommendation == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
          gradient: LinearGradient(
            colors: [AppTheme.surface, AppTheme.surfaceAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get(
                'quick_fix_recommendation_missing',
                fallback: 'No recommendation available yet.',
              ),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              t.get(
                'quick_fix_empty_body',
                fallback:
                    'Adjust your current context to generate a live recommendation.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final session = recommendation!.session;
    final quickFixSource = SessionEntrySource.quickFix.dbValue;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey('${session.id}-$emphasize-$compact'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: emphasize ? 0.14 : 0.07),
              AppTheme.surfaceElevated,
              AppTheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: emphasize
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: emphasize ? 0.16 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        t.get(
                          recommendation!.reasoningTitleKey,
                          fallback: recommendation!.reasoningTitleFallback,
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${session.durationMinutes} min',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t.get(session.titleKey, fallback: session.titleFallback),
                style: compact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                t.get(session.subtitleKey, fallback: session.subtitleFallback),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                t.get(
                  recommendation!.reasoningBodyKey,
                  fallback: recommendation!.reasoningBodyFallback,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              QuickFixSignalStrip(signals: recommendation!.signals),
              if (!compact) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    t.get(
                      session.shortDescriptionKey,
                      fallback: session.shortDescriptionFallback,
                    ),
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(quickFixControllerProvider.notifier)
                            .trackAction(QuickFixActionType.startSession);
                        if (context.mounted) {
                          context.push(
                            '/app/sessions/player/${session.id}?source=$quickFixSource',
                          );
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        t.get(
                          'quick_fix_start_now_cta',
                          fallback: 'Start Now',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(quickFixControllerProvider.notifier)
                            .trackAction(QuickFixActionType.viewDetail);
                        if (context.mounted) {
                          context.pushNamed(
                            'session-detail',
                            pathParameters: {'id': session.id},
                          );
                        }
                      },
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: Text(
                        t.get(
                          'quick_fix_view_details_cta',
                          fallback: 'Details',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (alternatives.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  t.get(
                    'quick_fix_more_matches_title',
                    fallback: 'Similar matches',
                  ),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (compact)
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: alternatives.take(3).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final items = alternatives.take(3).toList();
                        final alt = items[index];
                        return _AlternativePill(recommendation: alt);
                      },
                    ),
                  )
                else
                  Column(
                    children: alternatives
                        .take(3)
                        .map(
                          (alt) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _AlternativeCard(recommendation: alt),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlternativePill extends ConsumerWidget {
  const _AlternativePill({
    required this.recommendation,
  });

  final QuickFixRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final session = recommendation.session;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () async {
          await ref
              .read(quickFixControllerProvider.notifier)
              .setAlternativeRecommendation(session.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.surface.withValues(alpha: 0.60),
            border: Border.all(color: AppTheme.border),
          ),
          child: Center(
            child: Text(
              '${t.get(session.titleKey, fallback: session.titleFallback)} • ${session.durationMinutes}m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _AlternativeCard extends ConsumerWidget {
  const _AlternativeCard({
    required this.recommendation,
  });

  final QuickFixRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final session = recommendation.session;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await ref
                .read(quickFixControllerProvider.notifier)
                .setAlternativeRecommendation(session.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.get(session.titleKey, fallback: session.titleFallback)} • ${session.durationMinutes}m',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}