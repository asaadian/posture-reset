// lib/features/insights/presentation/pages/insights_page.dart

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_event.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/app_data/app_data_reset_signal.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../../shared/widgets/modern_progress_track.dart';
import '../../../../shared/onboarding/page_onboarding.dart';
import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../programs/application/recovery_program_providers.dart';
import '../../../programs/domain/recovery_program_models.dart';
import '../../application/insights_providers.dart';
import '../../domain/insights_snapshot.dart';


Rect _insightsHeroGuideTarget(Size size, EdgeInsets safePadding) {
  final top = safePadding.top + 108;
  return Rect.fromLTWH(14, top, size.width - 28, 128);
}

Rect _insightsMetricGuideTarget(Size size, EdgeInsets safePadding) {
  final top = safePadding.top + 246;
  return Rect.fromLTWH(14, top, size.width - 28, 170);
}

Rect _insightsChartGuideTarget(Size size, EdgeInsets safePadding) {
  final top = safePadding.top + 430;
  final height = (size.height - top - safePadding.bottom - 154).clamp(170.0, 260.0);
  return Rect.fromLTWH(14, top, size.width - 28, height);
}

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  Future<void> _refresh(WidgetRef ref, InsightsRange range) async {
    ref.invalidate(insightsSnapshotProvider(range));
    await ref.read(insightsSnapshotProvider(range).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(insightsSelectedRangeProvider);
    ref.listen<int>(appDataResetSignalProvider, (previous, next) {
      if (previous == next) return;
      for (final item in InsightsRange.values) {
        ref.invalidate(insightsSnapshotProvider(item));
      }
    });
    final insightsAsync = ref.watch(insightsSnapshotProvider(range));
    final accessAsync = ref.watch(accessSnapshotProvider);
    final activeProgramAsync =
        ref.watch(activeRecoveryProgramDashboardProgressProvider);
    final t = AppText.of(context);

    return ResponsivePageScaffold(
      title: Text(t.get('insights_title', fallback: 'Insights')),
      actions: [
        _RangeMenu(
          selectedRange: range,
          onSelected: (value) {
            ref.read(insightsSelectedRangeProvider.notifier).setRange(value);
          },
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
          return PageOnboarding(
            pageId: 'insights_guide_v2_locked_preview',
            tips: [
              OnboardingTip(
                targetBuilder: _insightsHeroGuideTarget,
                icon: Icons.insights_rounded,
                title: t.get('guide_insights_signal_title', fallback: 'Recovery signal'),
                body: t.get('guide_insights_signal_body', fallback: 'This area summarizes your recent recovery rhythm after you unlock insights.'),
              ),
              OnboardingTip(
                targetBuilder: _insightsMetricGuideTarget,
                icon: Icons.dashboard_customize_rounded,
                title: t.get('guide_insights_metrics_title', fallback: 'Key numbers'),
                body: t.get('guide_insights_metrics_body', fallback: 'Here you will see minutes, consistency, focus zones, and Quick Fix activity.'),
              ),
              OnboardingTip(
                targetBuilder: _insightsChartGuideTarget,
                icon: Icons.auto_graph_rounded,
                title: t.get('guide_insights_patterns_title', fallback: 'Trends and patterns'),
                body: t.get('guide_insights_patterns_body', fallback: 'Charts help you understand what improves and where tension keeps returning.'),
              ),
            ],
            child: _LockedInsightsPreview(
              pageInfo: pageInfo,
              onUpgrade: () {
                unawaited(
                  ref.read(analyticsServiceProvider).track(
                        AnalyticsEvent(
                          eventName: AnalyticsEvents.lockedFeatureCtaTapped,
                          sourceSurface: AnalyticsSurfaces.insights,
                          featureKey: LockedFeature.insightsFullAccess.code,
                          accessTier: AccessTier.coreAccess.code,
                          entitlementKey: Entitlement.coreAccess.key,
                        ),
                      ),
                );

                context.pushNamed('premium');
              },
            ),
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
                children: [
                  _InsightsCompactHero(
                    snapshot: snapshot,
                    pageInfo: pageInfo,
                  ),
                  const SizedBox(height: 10),
                  _JourneyIntelligenceCard(
                    snapshot: snapshot,
                    activeProgram: activeProgramAsync.maybeWhen(
                      data: (value) => value,
                      orElse: () => null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InsightsMetricWrap(snapshot: snapshot),
                  const SizedBox(height: 10),
                  _InsightsPremiumIntelligenceDeck(snapshot: snapshot),
                  const SizedBox(height: 10),
                  _InsightsCompactAnalysisDeck(
                    snapshot: snapshot,
                    pageInfo: pageInfo,
                  ),
                  const SizedBox(height: 10),
                  _InsightsPatternNotesCard(
                    logs: snapshot.logs,
                    onViewAll: () => context.pushNamed('logs'),
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


class _JourneyIntelligenceCard extends StatelessWidget {
  const _JourneyIntelligenceCard({required this.snapshot, required this.activeProgram});
  final InsightsSnapshot snapshot;
  final RecoveryProgramDashboardProgress? activeProgram;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final t = AppText.of(context);
    final program = activeProgram;
    final hasProgram = program != null && !program.isCompleted;
    final helpful = (snapshot.helpRate * 100).round();
    final consistency = (snapshot.consistencyScore * 100).round();
    final completion = (snapshot.completionRate * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF17213A), const Color(0xFF0F172A)] : [colors.tertiary.withValues(alpha: 0.09), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.tertiary.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44,height: 44,decoration: BoxDecoration(borderRadius: BorderRadius.circular(17),gradient: LinearGradient(colors: [colors.primary, colors.tertiary])),child: Icon(Icons.route_rounded,color: colors.onPrimary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
            Text(hasProgram ? t.get('insights_journey_intelligence_title', fallback: 'Journey intelligence') : t.get('insights_journey_intelligence_empty_title', fallback: 'Build a therapy signal'),style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface,fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(hasProgram ? t.get('insights_journey_intelligence_body', fallback: 'Your current journey is building consistency, response, and completion patterns.') : t.get('insights_journey_intelligence_empty_body', fallback: 'Start a therapy journey to connect sessions with long-term recovery progress.'),maxLines: 2,overflow: TextOverflow.ellipsis,style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant,fontWeight: FontWeight.w700,height: 1.15)),
          ])),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _JourneyIntelMetric(label: t.get('insights_focus_completion_title', fallback: 'Completion'), value: '$completion%', icon: Icons.task_alt_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _JourneyIntelMetric(label: t.get('insights_focus_helpful_title', fallback: 'Helpful'), value: '$helpful%', icon: Icons.favorite_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _JourneyIntelMetric(label: t.get('insights_summary_consistency_title', fallback: 'Rhythm'), value: '$consistency%', icon: Icons.auto_graph_rounded)),
        ]),
        if (hasProgram) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Text(program.currentDayTitleFallback?.trim().isNotEmpty == true ? program.currentDayTitleFallback! : 'Mission ${program.currentDay}',maxLines: 1,overflow: TextOverflow.ellipsis,style: theme.textTheme.labelLarge?.copyWith(color: colors.onSurface,fontWeight: FontWeight.w900))),
            const SizedBox(width: 10),
            Text('${program.completedDayCount}/${program.durationDays}',style: theme.textTheme.labelMedium?.copyWith(color: colors.primary,fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          ModernProgressTrack(value: program.progressFraction, height: 10),
        ],
      ]),
    );
  }
}

class _JourneyIntelMetric extends StatelessWidget {
  const _JourneyIntelMetric({required this.label, required this.value, required this.icon});
  final String label; final String value; final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context); final colors=theme.colorScheme;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 11),decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),color: colors.surface.withValues(alpha: 0.70),border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.46))),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Icon(icon,size:17,color:colors.primary),const SizedBox(height:7),Text(value,style:theme.textTheme.titleMedium?.copyWith(color:colors.onSurface,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(label,maxLines:1,overflow:TextOverflow.ellipsis,style:theme.textTheme.labelSmall?.copyWith(color:colors.onSurfaceVariant,fontWeight:FontWeight.w700))]));
  }
}

class _LockedInsightsPreview extends StatelessWidget {
  const _LockedInsightsPreview({
    required this.pageInfo,
    required this.onUpgrade,
  });

  final ResponsivePageInfo pageInfo;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 120 : 48),
          children: const [
            _InsightsLockedViewedTracker(),
            _PreviewHeroCard(),
            SizedBox(height: 10),
            _PreviewMetricGrid(),
            SizedBox(height: 10),
            _PreviewChartDeck(),
            SizedBox(height: 10),
            _PreviewNotesCard(),
          ],
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.8, sigmaY: 3.8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: MediaQuery.of(context).padding.top + 138,
          child: _InsightsUnlockMiniCard(
            title: t.get('insights_locked_preview_title', fallback: 'Unlock Insights'),
            body: t.get('insights_locked_preview_body', fallback: 'Core Access shows your real trends.'),
            onUpgrade: onUpgrade,
          ),
        ),
      ],
    );
  }
}

class _InsightsUnlockMiniCard extends StatelessWidget {
  const _InsightsUnlockMiniCard({
    required this.title,
    required this.body,
    required this.onUpgrade,
  });

  final String title;
  final String body;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [colors.surfaceContainerHigh.withValues(alpha: 0.94), colors.surface.withValues(alpha: 0.98)]
              : [colors.surfaceContainerLowest.withValues(alpha: 0.96), colors.surface.withValues(alpha: 0.98)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.26) : const Color(0xFF263B57).withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          final ctaLabel = AppText.get(
            context,
            key: 'access_unlock_core_cta',
            fallback: 'Unlock',
          );

          final icon = Container(
            width: compact ? 42 : 48,
            height: compact ? 42 : 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 16 : 18),
              gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
            ),
            child: Icon(Icons.lock_open_rounded, color: colors.onPrimary),
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Expanded(child: copy),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onUpgrade,
                  child: Text(ctaLabel),
                ),
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(child: copy),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: onUpgrade,
                child: Text(ctaLabel),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PreviewHeroCard extends StatelessWidget {
  const _PreviewHeroCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 128,
      padding: const EdgeInsets.all(14),
      decoration: _previewDecoration(context, colors.primary),
      child: Row(
        children: [
          _PreviewIconBox(icon: Icons.insights_rounded, accent: colors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewLine(widthFactor: 0.58, height: 18),
                SizedBox(height: 10),
                _PreviewLine(widthFactor: 0.88, height: 12),
                SizedBox(height: 7),
                _PreviewLine(widthFactor: 0.66, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetricGrid extends StatelessWidget {
  const _PreviewMetricGrid();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accents = [colors.primary, colors.secondary, colors.tertiary, colors.primary];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(4, (index) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                height: 78,
                padding: const EdgeInsets.all(10),
                decoration: _previewDecoration(context, accents[index]),
                child: Row(
                  children: [
                    _PreviewIconBox(icon: Icons.auto_graph_rounded, accent: accents[index], size: 34),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PreviewLine(widthFactor: 0.62, height: 10),
                          SizedBox(height: 7),
                          _PreviewLine(widthFactor: 0.40, height: 18),
                          SizedBox(height: 7),
                          _PreviewLine(widthFactor: 0.72, height: 9),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PreviewChartDeck extends StatelessWidget {
  const _PreviewChartDeck();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          height: 214,
          padding: const EdgeInsets.all(14),
          decoration: _previewDecoration(context, colors.primary),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewLine(widthFactor: 0.52, height: 17),
              SizedBox(height: 14),
              Expanded(child: _PreviewChartShape()),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 154,
          padding: const EdgeInsets.all(14),
          decoration: _previewDecoration(context, colors.tertiary),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewLine(widthFactor: 0.48, height: 17),
              SizedBox(height: 16),
              Expanded(child: _PreviewBars()),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewNotesCard extends StatelessWidget {
  const _PreviewNotesCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: _previewDecoration(context, colors.secondary),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewLine(widthFactor: 0.42, height: 17),
          SizedBox(height: 14),
          _PreviewLine(widthFactor: 0.88, height: 12),
          SizedBox(height: 8),
          _PreviewLine(widthFactor: 0.72, height: 12),
        ],
      ),
    );
  }
}

class _PreviewIconBox extends StatelessWidget {
  const _PreviewIconBox({required this.icon, required this.accent, this.size = 42});

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.38),
        color: accent.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: accent, size: size * 0.52),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: colors.onSurface.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _PreviewChartShape extends StatelessWidget {
  const _PreviewChartShape();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PreviewChartPainter(color: Theme.of(context).colorScheme.primary),
      child: const SizedBox.expand(),
    );
  }
}

class _PreviewChartPainter extends CustomPainter {
  const _PreviewChartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.18, size.height * 0.70)
      ..lineTo(size.width * 0.35, size.height * 0.52)
      ..lineTo(size.width * 0.52, size.height * 0.62)
      ..lineTo(size.width * 0.72, size.height * 0.34)
      ..lineTo(size.width, size.height * 0.44);
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PreviewChartPainter oldDelegate) => oldDelegate.color != color;
}

class _PreviewBars extends StatelessWidget {
  const _PreviewBars();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const heights = [0.28, 0.54, 0.38, 0.72, 0.46, 0.84, 0.34, 0.58];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          Expanded(
            child: FractionallySizedBox(
              heightFactor: heights[i],
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: colors.primary.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
          if (i != heights.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

BoxDecoration _previewDecoration(BuildContext context, Color accent) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    gradient: LinearGradient(
      colors: isDark
          ? [colors.surfaceContainerHigh.withValues(alpha: 0.74), colors.surface.withValues(alpha: 0.96)]
          : [colors.surface.withValues(alpha: 0.96), colors.surfaceContainerLow.withValues(alpha: 0.90)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: accent.withValues(alpha: isDark ? 0.25 : 0.17)),
  );
}

class _InsightsLockedViewedTracker extends ConsumerStatefulWidget {
  const _InsightsLockedViewedTracker();

  @override
  ConsumerState<_InsightsLockedViewedTracker> createState() =>
      _InsightsLockedViewedTrackerState();
}

class _InsightsLockedViewedTrackerState
    extends ConsumerState<_InsightsLockedViewedTracker> {
  bool _tracked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_tracked) return;
    _tracked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(
        ref.read(analyticsServiceProvider).track(
              AnalyticsEvent(
                eventName: AnalyticsEvents.lockedFeatureViewed,
                sourceSurface: AnalyticsSurfaces.insights,
                featureKey: LockedFeature.insightsFullAccess.code,
                accessTier: AccessTier.coreAccess.code,
                entitlementKey: Entitlement.coreAccess.key,
              ),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _RangeMenu extends StatelessWidget {
  const _RangeMenu({
    required this.selectedRange,
    required this.onSelected,
  });

  final InsightsRange selectedRange;
  final ValueChanged<InsightsRange> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return PopupMenuButton<InsightsRange>(
      tooltip: t.get(
        'insights_date_range_tooltip',
        fallback: 'Change date range',
      ),
      icon: const Icon(Icons.tune_rounded),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: InsightsRange.last7Days,
          child: Text(
            t.get(
              'insights_range_7_days',
              fallback: 'Last 7 days',
            ),
          ),
        ),
        PopupMenuItem(
          value: InsightsRange.last14Days,
          child: Text(
            t.get(
              'insights_range_14_days',
              fallback: 'Last 14 days',
            ),
          ),
        ),
        PopupMenuItem(
          value: InsightsRange.last28Days,
          child: Text(
            t.get(
              'insights_range_28_days',
              fallback: 'Last 28 days',
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightsCompactHero extends StatelessWidget {
  const _InsightsCompactHero({
    required this.snapshot,
    required this.pageInfo,
  });

  final InsightsSnapshot snapshot;
  final ResponsivePageInfo pageInfo;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final zone = _painAreaLabel(context, snapshot.dominantPainAreaCode);
    final consistency = (snapshot.consistencyScore * 100).round();
    final helpful = (snapshot.helpRate * 100).round();
    final completion = (snapshot.completionRate * 100).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pageInfo.isCompact ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.74 : 0.58),
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.13),
                  colors.surfaceContainerHigh.withValues(alpha: 0.90),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  colors.primary.withValues(alpha: 0.065),
                  colors.surface.withValues(alpha: 0.98),
                  colors.surfaceContainerLow.withValues(alpha: 0.95),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : colors.primary.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;

          final titleBlock = Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.11),
                  border: Border.all(
                    color: colors.primary.withValues(
                      alpha: isDark ? 0.24 : 0.16,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get(
                        'insights_intro_title',
                        fallback: 'Recovery signal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.get(
                        'insights_intro_body_short',
                        fallback: 'Patterns from your recent recovery work.',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final signalBlock = _HeroSignalRail(
            zone: zone,
            days: snapshot.range.days,
            streakDays: snapshot.currentStreakDays,
            completion: completion,
            helpful: helpful,
            consistency: consistency,
          );

          if (wide) {
            return Row(
              children: [
                Expanded(flex: 9, child: titleBlock),
                const SizedBox(width: 14),
                Expanded(flex: 11, child: signalBlock),
              ],
            );
          }

          return Column(
            children: [
              titleBlock,
              const SizedBox(height: 12),
              signalBlock,
            ],
          );
        },
      ),
    );
  }
}

class _HeroSignalRail extends StatelessWidget {
  const _HeroSignalRail({
    required this.zone,
    required this.days,
    required this.streakDays,
    required this.completion,
    required this.helpful,
    required this.consistency,
  });

  final String zone;
  final int days;
  final int streakDays;
  final int completion;
  final int helpful;
  final int consistency;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    final items = [
      _HeroSignalChip(
        icon: Icons.accessibility_new_rounded,
        label: t.get('insights_focus_zone_title', fallback: 'Focus'),
        value: zone,
      ),
      _HeroSignalChip(
        icon: Icons.calendar_month_rounded,
        label: t.get('insights_range_compact', fallback: 'Range'),
        value: '$days d',
      ),
      _HeroSignalChip(
        icon: Icons.local_fire_department_outlined,
        label: t.get('insights_streak_compact', fallback: 'Streak'),
        value: '$streakDays d',
      ),
      _HeroSignalChip(
        icon: Icons.task_alt_rounded,
        label: t.get('insights_focus_completion_title', fallback: 'Done'),
        value: '$completion%',
      ),
      _HeroSignalChip(
        icon: Icons.favorite_border_rounded,
        label: t.get('insights_focus_helpful_title', fallback: 'Helpful'),
        value: '$helpful%',
      ),
      _HeroSignalChip(
        icon: Icons.check_circle_outline_rounded,
        label: t.get('insights_summary_consistency_title', fallback: 'Rhythm'),
        value: '$consistency%',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        const gap = 7.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _HeroSignalChip extends StatelessWidget {
  const _HeroSignalChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.58)
            : Colors.white.withValues(alpha: 0.72),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.62 : 0.48),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: colors.primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsMetricWrap extends StatelessWidget {
  const _InsightsMetricWrap({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final helpful = (snapshot.helpRate * 100).round();
    final relief = snapshot.averageReliefScore.round();

    final items = [
      _CompactMetricCard(
        title: t.get(
          'insights_summary_minutes_title',
          fallback: 'Minutes',
        ),
        value: '${snapshot.recoveryMinutes}',
        subtitle: t.get(
          'insights_summary_minutes_subtitle',
          fallback: 'Completed',
        ),
        icon: Icons.timer_outlined,
        accent: colors.secondary,
      ),
      _CompactMetricCard(
        title: t.get(
          'insights_active_days_title',
          fallback: 'Active days',
        ),
        value: '${snapshot.activeDaysCount}',
        subtitle: '${snapshot.range.days} day window',
        icon: Icons.calendar_today_rounded,
        accent: colors.primary,
      ),
      _CompactMetricCard(
        title: t.get(
          'insights_helpful_title',
          fallback: 'Helpful',
        ),
        value: '$helpful%',
        subtitle: t.get(
          'insights_helpful_subtitle',
          fallback: 'From feedback',
        ),
        icon: Icons.thumb_up_alt_outlined,
        accent: colors.tertiary,
      ),
      _CompactMetricCard(
        title: t.get(
          'insights_relief_title',
          fallback: 'Relief',
        ),
        value: '$relief',
        subtitle: t.get(
          'insights_relief_subtitle',
          fallback: 'Average score',
        ),
        icon: Icons.trending_up_rounded,
        accent: colors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 780 ? 4 : 2;
        const gap = 8.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  const _CompactMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.72),
                  colors.surface.withValues(alpha: 0.94),
                ]
              : [
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.90),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.25 : 0.17),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.13)
                : accent.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsCompactAnalysisDeck extends StatelessWidget {
  const _InsightsCompactAnalysisDeck({
    required this.snapshot,
    required this.pageInfo,
  });

  final InsightsSnapshot snapshot;
  final ResponsivePageInfo pageInfo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chart = _InsightsMiniChartCard(
      title: AppText.get(
        context,
        key: 'insights_recovery_minutes_title',
        fallback: 'Recovery Trend',
      ),
      subtitle: AppText.get(
        context,
        key: 'insights_recovery_minutes_subtitle_short',
        fallback: 'Minutes over time',
      ),
      points: snapshot.recoveryMinutesSeries,
      accent: colors.primary,
      valueSuffix: 'm',
    );

    final rhythm = _RecoveryRhythmCompactCard(cells: snapshot.heatmapCells);
    final isWide = pageInfo.isMedium || pageInfo.isExpanded;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 11, child: chart),
          const SizedBox(width: 10),
          Expanded(flex: 9, child: rhythm),
        ],
      );
    }

    return Column(
      children: [
        chart,
        const SizedBox(height: 10),
        rhythm,
      ],
    );
  }
}

class _InsightsMiniChartCard extends StatelessWidget {
  const _InsightsMiniChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.accent,
    required this.valueSuffix,
  });

  final String title;
  final String subtitle;
  final List<InsightsSeriesPoint> points;
  final Color accent;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.74),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.90),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.14)
                : accent.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          _CompactCardHeader(
            icon: Icons.auto_graph_rounded,
            title: title,
            subtitle: subtitle,
            accent: accent,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 118,
            width: double.infinity,
            child: CustomPaint(
              painter: _InsightsLinePainter(
                points: points.map((e) => e.value).toList(growable: false),
                accent: accent,
                gridColor: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.32 : 0.24,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      children: points.map((point) {
                        return Expanded(
                          child: Text(
                            point.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStatPill(
                  label: t.get('insights_chart_peak', fallback: 'Peak'),
                  value: '${_max(points).round()}$valueSuffix',
                  accent: accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatPill(
                  label: t.get('insights_chart_average', fallback: 'Avg'),
                  value: '${_average(points).round()}$valueSuffix',
                  accent: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _max(List<InsightsSeriesPoint> values) {
    if (values.isEmpty) return 0;
    return values.map((e) => e.value).reduce(math.max);
  }

  double _average(List<InsightsSeriesPoint> values) {
    if (values.isEmpty) return 0;
    return values.map((e) => e.value).reduce((a, b) => a + b) / values.length;
  }
}

class _RecoveryRhythmCompactCard extends StatelessWidget {
  const _RecoveryRhythmCompactCard({required this.cells});

  final List<InsightsHeatmapCell> cells;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final visibleCells = cells.length > 14 ? cells.sublist(cells.length - 14) : cells;
    final activeDays = visibleCells.where((cell) => cell.minutes > 0).length;
    final totalMinutes = visibleCells.fold<int>(
      0,
      (sum, cell) => sum + cell.minutes,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.09),
                  colors.surfaceContainerHigh.withValues(alpha: 0.74),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.primary.withValues(alpha: 0.05),
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.90),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.14)
                : colors.primary.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          _CompactCardHeader(
            icon: Icons.waves_rounded,
            title: t.get(
              'insights_rhythm_title',
              fallback: 'Recovery Rhythm',
            ),
            subtitle: t.get(
              'insights_rhythm_subtitle_short',
              fallback: 'Recent active days',
            ),
            accent: colors.primary,
          ),
          const SizedBox(height: 10),
          _RhythmBars(cells: visibleCells),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RhythmStat(
                  label: t.get(
                    'insights_rhythm_active_days',
                    fallback: 'Active',
                  ),
                  value: '$activeDays',
                  icon: Icons.event_available_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RhythmStat(
                  label: t.get(
                    'insights_rhythm_minutes',
                    fallback: 'Minutes',
                  ),
                  value: '$totalMinutes',
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactCardHeader extends StatelessWidget {
  const _CompactCardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
            ),
          ),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              if (subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: isDark ? 0.13 : 0.09),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.24 : 0.17),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$label • $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _InsightsLinePainter extends CustomPainter {
  _InsightsLinePainter({
    required this.points,
    required this.accent,
    required this.gridColor,
  });

  final List<double> points;
  final Color accent;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (points.isEmpty) return;

    final safeMax = points.fold<double>(0, math.max);
    final maxY = safeMax <= 0 ? 1.0 : safeMax;
    final dx = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y = size.height -
          ((points[i] / maxY).clamp(0.0, 1.0) * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0.20),
          accent.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = accent;

    final dotPaint = Paint()..color = accent;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);

    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y = size.height -
          ((points[i] / maxY).clamp(0.0, 1.0) * size.height);

      if (!x.isNaN && !y.isNaN) {
        canvas.drawCircle(Offset(x, y), 3.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InsightsLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor;
  }
}

class _RhythmBars extends StatelessWidget {
  const _RhythmBars({required this.cells});

  final List<InsightsHeatmapCell> cells;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) {
      return const SizedBox(height: 96);
    }

    final maxMinutes = cells.fold<int>(
      0,
      (max, cell) => cell.minutes > max ? cell.minutes : max,
    );

    return SizedBox(
      height: 104,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            Expanded(
              child: _RhythmBar(
                cell: cells[i],
                maxMinutes: maxMinutes,
              ),
            ),
            if (i != cells.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class _RhythmBar extends StatelessWidget {
  const _RhythmBar({
    required this.cell,
    required this.maxMinutes,
  });

  final InsightsHeatmapCell cell;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasActivity = cell.minutes > 0;
    final normalized = maxMinutes <= 0
        ? 0.0
        : (cell.minutes / maxMinutes).clamp(0.0, 1.0);

    final height = hasActivity ? 24.0 + (normalized * 54.0) : 12.0;

    return Tooltip(
      message: '${cell.date.day}.${cell.date.month} • ${cell.minutes} min',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: hasActivity
                  ? LinearGradient(
                      colors: [
                        colors.primary,
                        colors.secondary,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )
                  : null,
              color: hasActivity
                  ? null
                  : isDark
                      ? colors.surfaceContainerHighest.withValues(alpha: 0.64)
                      : colors.surfaceContainerHighest.withValues(alpha: 0.86),
              border: Border.all(
                color: hasActivity
                    ? colors.primary.withValues(alpha: isDark ? 0.28 : 0.22)
                    : colors.outlineVariant.withValues(
                        alpha: isDark ? 0.68 : 0.54,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${cell.date.day}',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RhythmStat extends StatelessWidget {
  const _RhythmStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.62)
            : colors.surface.withValues(alpha: 0.76),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.70 : 0.56),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: colors.primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsPatternNotesCard extends StatelessWidget {
  const _InsightsPatternNotesCard({
    required this.logs,
    required this.onViewAll,
  });

  final List<InsightLogItem> logs;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final visibleLogs = logs.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.74),
                  colors.surface.withValues(alpha: 0.96),
                ]
              : [
                  colors.surface.withValues(alpha: 0.96),
                  colors.surfaceContainerLow.withValues(alpha: 0.90),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.14)
                : colors.primary.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactCardHeader(
                  icon: Icons.notes_rounded,
                  title: t.get(
                    'insights_patterns_title',
                    fallback: 'Pattern Notes',
                  ),
                  subtitle: t.get(
                    'insights_patterns_subtitle_short',
                    fallback: 'Recent signals',
                  ),
                  accent: colors.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  t.get(
                    'insights_logs_action',
                    fallback: 'View all',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (visibleLogs.isEmpty)
            _EmptyLogs(
              message: t.get(
                'insights_logs_empty',
                fallback: 'Complete a few sessions to generate recovery notes.',
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < visibleLogs.length; i++) ...[
                  _InsightLogTile(log: visibleLogs[i]),
                  if (i != visibleLogs.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 54,
      child: Row(
        children: [
          Icon(
            Icons.insights_outlined,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightLogTile extends StatelessWidget {
  const _InsightLogTile({required this.log});

  final InsightLogItem log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accent = switch (log.tone) {
      InsightLogTone.positive => colors.secondary,
      InsightLogTone.warning => colors.error,
      InsightLogTone.neutral => colors.primary,
    };

    final icon = switch (log.tone) {
      InsightLogTone.positive => Icons.trending_up_rounded,
      InsightLogTone.warning => Icons.warning_amber_rounded,
      InsightLogTone.neutral => Icons.insights_outlined,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? accent.withValues(alpha: 0.08)
            : accent.withValues(alpha: 0.055),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.20 : 0.13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _InsightsPremiumIntelligenceDeck extends StatelessWidget {
  const _InsightsPremiumIntelligenceDeck({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    final score = _RecoveryScorePremiumCard(snapshot: snapshot);
    final anatomy = _BodyZoneAnatomyCard(snapshot: snapshot);
    if (isWide) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 9, child: score),
              const SizedBox(width: 10),
              Expanded(flex: 11, child: anatomy),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        score,
        const SizedBox(height: 10),
        anatomy,
      ],
    );
  }
}

class _RecoveryScorePremiumCard extends StatelessWidget {
  const _RecoveryScorePremiumCard({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final score = snapshot.recoveryScore.clamp(0, 100);
    final ringSize = MediaQuery.sizeOf(context).width < 380 ? 124.0 : 140.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.22),
                  colors.surfaceContainerHigh.withValues(alpha: 0.82),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  colors.primary.withValues(alpha: 0.13),
                  colors.surface.withValues(alpha: 0.98),
                  colors.tertiaryContainer.withValues(alpha: 0.18),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;

          final ring = _LargeRecoveryRing(
            score: score,
            size: ringSize,
          );

          final copy = Column(
            crossAxisAlignment:
                wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text(
                snapshot.recoveryScoreTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: wide ? TextAlign.start : TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _focusedRecoveryLine(snapshot),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: wide ? TextAlign.start : TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 7,
                runSpacing: 7,
                children: [
                  _InsightMiniPill(label: '${snapshot.recoveryMinutes} min'),
                  _InsightMiniPill(label: '${snapshot.activeDaysCount} active'),
                  if (snapshot.bestDayLabel != null &&
                      snapshot.bestDayMinutes > 0)
                    _InsightMiniPill(
                      label:
                          '${snapshot.bestDayLabel}: ${snapshot.bestDayMinutes}m',
                    ),
                ],
              ),
            ],
          );

          if (wide) {
            return Row(
              children: [
                ring,
                const SizedBox(width: 18),
                Expanded(child: copy),
              ],
            );
          }

          return Column(
            children: [
              ring,
              const SizedBox(height: 14),
              copy,
            ],
          );
        },
      ),
    );
  }
}

class _LargeRecoveryRing extends StatelessWidget {
  const _LargeRecoveryRing({
    required this.score,
    required this.size,
  });

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.20),
                  colors.primary.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(
            width: size - 10,
            height: size - 10,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor:
                  colors.surfaceContainerHighest.withValues(alpha: 0.38),
            ),
          ),
          Container(
            width: size - 42,
            height: size - 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.86),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 0.88,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Recovery',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyZoneAnatomyCard extends StatelessWidget {
  const _BodyZoneAnatomyCard({required this.snapshot});

  final InsightsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final zones = snapshot.bodyZones.take(7).toList(growable: false);
    final dominant = zones.isEmpty ? null : zones.first;
    final undertrained = snapshot.undertrainedBodyZoneCodes
        .map((code) => _painAreaLabel(context, code))
        .take(2)
        .join(' • ');

    return _InsightGlassPanel(
      icon: Icons.accessibility_new_rounded,
      title: AppText.get(
        context,
        key: 'insights_body_intelligence_title',
        fallback: 'Body map',
      ),
      subtitle: dominant == null
          ? AppText.get(
              context,
              key: 'insights_body_intelligence_empty',
              fallback: 'Complete sessions to reveal your map.',
            )
          : '${_painAreaLabel(context, dominant.painAreaCode)} ${(dominant.share * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightsBodyMap(
            zones: zones,
            dominantCode: dominant?.painAreaCode,
          ),
          const SizedBox(height: 10),
          _BodyZoneChipRow(zones: zones),
          if (undertrained.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InsightCoachNote(
              icon: Icons.balance_rounded,
              text: 'Undertrained: $undertrained',
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightsBodyMap extends StatelessWidget {
  const _InsightsBodyMap({
    required this.zones,
    required this.dominantCode,
  });

  final List<InsightsBodyZoneStat> zones;
  final String? dominantCode;

  @override
  Widget build(BuildContext context) {
    final zoneShares = {
      for (final zone in zones) zone.painAreaCode: zone.share,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        final mapHeight = narrow ? 292.0 : 330.0;

        return SizedBox(
          height: mapHeight,
          child: Row(
            children: [
              Expanded(
                child: _InsightBodySilhouette(
                  label: AppText.get(context, key: 'body_map_front', fallback: 'Front'),
                  imagePath: 'assets/images/body_map/front.png',
                  side: _InsightBodySide.front,
                  zoneShares: zoneShares,
                  dominantCode: dominantCode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InsightBodySilhouette(
                  label: AppText.get(context, key: 'body_map_back', fallback: 'Back'),
                  imagePath: 'assets/images/body_map/back.png',
                  side: _InsightBodySide.back,
                  zoneShares: zoneShares,
                  dominantCode: dominantCode,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _InsightBodySide { front, back }

class _InsightBodySilhouette extends StatelessWidget {
  const _InsightBodySilhouette({
    required this.label,
    required this.imagePath,
    required this.side,
    required this.zoneShares,
    required this.dominantCode,
  });

  final String label;
  final String imagePath;
  final _InsightBodySide side;
  final Map<String, double> zoneShares;
  final String? dominantCode;

  static const double _imageAspectRatio = 654 / 1080;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = _insightHotspotsForSide(side, zoneShares);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              colors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
              colors.surfaceContainerHighest.withValues(alpha: isDark ? 0.20 : 0.34),
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: isDark ? 0.36 : 0.28),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            var artboardHeight = constraints.maxHeight - 32;
            var artboardWidth = artboardHeight * _imageAspectRatio;

            if (artboardWidth > constraints.maxWidth * 0.98) {
              artboardWidth = constraints.maxWidth * 0.98;
              artboardHeight = artboardWidth / _imageAspectRatio;
            }

            return Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _InsightMiniPill(label: label),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: artboardWidth,
                      height: artboardHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.accessibility_new_rounded,
                                size: 92,
                                color: colors.primary.withValues(alpha: 0.42),
                              ),
                            ),
                          ),
                          ...entries.map((entry) {
                            final dominant = entry.code == dominantCode;
                            return Positioned(
                              left: (artboardWidth * entry.x) - 18,
                              top: (artboardHeight * entry.y) - 18,
                              child: _InsightBodyGlowNode(
                                share: entry.share,
                                dominant: dominant,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InsightBodyGlowNode extends StatelessWidget {
  const _InsightBodyGlowNode({
    required this.share,
    required this.dominant,
  });

  final double share;
  final bool dominant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final nodeSize = dominant ? 34.0 : 24.0 + (share.clamp(0.0, 0.35) * 28);
    final coreSize = dominant ? 15.0 : 9.0 + (share.clamp(0.0, 0.35) * 18);

    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: nodeSize.clamp(20.0, 36.0),
            height: nodeSize.clamp(20.0, 36.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: dominant ? 0.20 : 0.12),
              border: Border.all(
                color: colors.primary.withValues(alpha: dominant ? 0.55 : 0.34),
                width: dominant ? 1.7 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: dominant ? 0.38 : 0.22),
                  blurRadius: dominant ? 22 : 14,
                  spreadRadius: dominant ? 3 : 1,
                ),
              ],
            ),
          ),
          Container(
            width: coreSize.clamp(9.0, 17.0),
            height: coreSize.clamp(9.0, 17.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyZoneChipRow extends StatelessWidget {
  const _BodyZoneChipRow({required this.zones});

  final List<InsightsBodyZoneStat> zones;

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) {
      return const _EmptyInsightLine(message: 'No body-zone signal yet.');
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: zones.take(4).map((zone) {
        return _InsightMiniPill(
          label:
              '${_painAreaLabel(context, zone.painAreaCode)} ${(zone.share * 100).round()}%',
        );
      }).toList(growable: false),
    );
  }
}

List<({String code, double x, double y, double share})> _insightHotspotsForSide(
  _InsightBodySide side,
  Map<String, double> shares,
) {
  final result = <({String code, double x, double y, double share})>[];

  void add(String code, List<({double x, double y})> points) {
    final share = shares[code] ?? 0;
    if (share <= 0) return;

    for (final point in points) {
      result.add((code: code, x: point.x, y: point.y, share: share));
    }
  }

  if (side == _InsightBodySide.back) {
    add('neck', const [(x: 0.50, y: 0.145)]);
    add('shoulders', const [(x: 0.34, y: 0.235), (x: 0.66, y: 0.235)]);
    add('upper_back', const [(x: 0.50, y: 0.275)]);
    add('lower_back', const [(x: 0.50, y: 0.445)]);
    add('hips_glutes', const [(x: 0.42, y: 0.565), (x: 0.58, y: 0.565)]);
    add('hamstrings', const [(x: 0.41, y: 0.735), (x: 0.59, y: 0.735)]);
  } else {
    add('eyes', const [(x: 0.50, y: 0.078)]);
    add('neck', const [(x: 0.50, y: 0.165)]);
    add('shoulders', const [(x: 0.34, y: 0.235), (x: 0.66, y: 0.235)]);
    add('upper_back', const [(x: 0.50, y: 0.305)]);
    add('lower_back', const [(x: 0.50, y: 0.455)]);
    add('hips_glutes', const [(x: 0.42, y: 0.575), (x: 0.58, y: 0.575)]);
    add('forearms', const [(x: 0.20, y: 0.465), (x: 0.80, y: 0.465)]);
    add('wrists', const [(x: 0.16, y: 0.535), (x: 0.84, y: 0.535)]);
    add('hands', const [(x: 0.12, y: 0.595), (x: 0.88, y: 0.595)]);
  }

  return result;
}

String _focusedRecoveryLine(InsightsSnapshot snapshot) {
  if (snapshot.totalRuns <= 0) {
    return 'Start a few sessions to build your recovery baseline.';
  }

  final helpful = (snapshot.helpRate * 100).round();
  if (helpful >= 75 && snapshot.recoveryMinutes > 0) {
    return '${snapshot.recoveryMinutes} minutes logged with strong helpful feedback.';
  }

  if (snapshot.recoveryMinutes > 0) {
    return '${snapshot.recoveryMinutes} minutes logged across ${snapshot.activeDaysCount} active days.';
  }

  return 'Complete a short session to create your first signal.';
}

class _InsightGlassPanel extends StatelessWidget {
  const _InsightGlassPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.62)
            : colors.surface.withValues(alpha: 0.94),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: isDark ? 0.68 : 0.54)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactCardHeader(
            icon: icon,
            title: title,
            subtitle: subtitle,
            accent: colors.primary,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InsightMiniPill extends StatelessWidget {
  const _InsightMiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: 0.10),
        border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _InsightCoachNote extends StatelessWidget {
  const _InsightCoachNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.primary.withValues(alpha: 0.075),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInsightLine extends StatelessWidget {
  const _EmptyInsightLine({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
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
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                  Icon(
                    Icons.error_outline_rounded,
                    size: 34,
                    color: colors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.get(
                      'insights_error_title',
                      fallback: 'Unable to load insights',
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(
                      t.get(
                        'common_retry',
                        fallback: 'Retry',
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
}

String _painAreaLabel(BuildContext context, String? code) {
  switch ((code ?? '').trim().toLowerCase()) {
    case 'neck':
    case 'cervical':
      return AppText.get(context, key: 'pain_neck', fallback: 'Neck');
    case 'shoulder':
    case 'shoulders':
    case 'scapula':
    case 'scapular':
      return AppText.get(
        context,
        key: 'pain_shoulders',
        fallback: 'Shoulders',
      );
    case 'upper_back':
    case 'upper back':
    case 'mid_back':
    case 'mid back':
    case 'thoracic':
    case 'chest':
      return AppText.get(
        context,
        key: 'pain_upper_back',
        fallback: 'Upper back',
      );
    case 'lower_back':
    case 'low_back':
    case 'lower back':
    case 'lumbar':
    case 'back':
    case 'core':
      return AppText.get(
        context,
        key: 'pain_lower_back',
        fallback: 'Lower back',
      );
    case 'wrists':
    case 'wrist':
      return AppText.get(context, key: 'pain_wrists', fallback: 'Wrists');
    case 'forearms':
    case 'forearm':
    case 'mouse_arm':
    case 'mouse arm':
      return AppText.get(context, key: 'pain_forearms', fallback: 'Forearms');
    case 'hands':
    case 'hand':
    case 'finger':
    case 'fingers':
      return AppText.get(context, key: 'pain_hands', fallback: 'Hands');
    case 'hips':
    case 'hip':
    case 'glutes':
    case 'glute':
    case 'hips_glutes':
    case 'hamstring':
    case 'hamstrings':
      return AppText.get(context, key: 'pain_hips_glutes', fallback: 'Hips & glutes');
    case 'eyes':
    case 'eye':
    case 'screen':
    case 'screen_strain':
    case 'eye_strain':
      return AppText.get(context, key: 'pain_eyes', fallback: 'Eyes');
    case '':
      return AppText.get(
        context,
        key: 'dashboard_zone_unknown',
        fallback: 'No clear zone yet',
      );
    default:
      return code!.replaceAll('_', ' ');
  }
}
