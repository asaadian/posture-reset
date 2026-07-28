import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/onboarding/page_onboarding.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../../player/domain/session_feedback_models.dart';
import '../../../sessions/domain/session_models.dart';
import '../../domain/quick_fix_models.dart';
import '../../domain/quick_fix_state.dart';
import '../controllers/quick_fix_controller.dart';
import '../utils/quick_fix_icon_resolver.dart';

class QuickFixPage extends ConsumerStatefulWidget {
  const QuickFixPage({super.key});

  @override
  ConsumerState<QuickFixPage> createState() => _QuickFixPageState();
}


class _QuickFixPageTitle extends StatelessWidget {
  const _QuickFixPageTitle({required this.t});

  final AppTextReader t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.get('quick_fix_title', fallback: 'Quick Fix'),
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
            'quick_fix_page_step_hint',
            fallback: 'Tap body point → set filters',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _QuickFixPageState extends ConsumerState<QuickFixPage> {
  String _lastSelectionSignature = '';

  Future<void> _refresh() async {
    await ref.read(quickFixControllerProvider.notifier).refresh();
  }

  String _selectionSignature(QuickFixState state) {
    final equipment = state.selectedEquipmentIds.toList()..sort();
    final modes = state.selectedModeIds.toList()..sort();

    return [
      state.selectedProblemId,
      state.selectedTimeId,
      state.selectedEnergyId,
      equipment.join(','),
      modes.join(','),
    ].join('|');
  }

  void _syncRevealStateFor(QuickFixState state) {
    final signature = _selectionSignature(state);
    if (_lastSelectionSignature == signature) return;

    _lastSelectionSignature = signature;
  }

  Future<void> _showRecommendationOverlay(
    BuildContext context,
    QuickFixState state,
  ) async {
    final revealState =
        await ref.read(quickFixControllerProvider.notifier).prepareRecommendationReveal() ??
            state;

    if (!context.mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _QuickFixRecommendationOverlay(state: revealState);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final raw = animation.value.clamp(0.0, 1.0).toDouble();
            final fade = Curves.easeOutCubic.transform(raw);
            final slide = Curves.easeOutCubic.transform(raw);
            final scale = Tween<double>(begin: 0.995, end: 1.0).transform(
              Curves.easeOutCubic.transform(raw),
            );

            return Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(0, lerpDouble(12, 0, slide)!),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final quickFixAsync = ref.watch(quickFixControllerProvider);

    return ResponsivePageScaffold(
      title: _QuickFixPageTitle(t: t),
      bodyBuilder: (context, pageInfo) {
        return quickFixAsync.when(
          loading: () => const _QuickFixLoadingState(),
          error: (_, __) => _QuickFixErrorState(
            onRetry: () => ref.invalidate(quickFixControllerProvider),
          ),
          data: (state) {
            _syncRevealStateFor(state);

            final isWide = pageInfo.isMedium || pageInfo.isExpanded;
            final quickFixBodyGuideKey = GlobalKey(debugLabel: 'quick_fix_body_guide');
            final quickFixFiltersGuideKey = GlobalKey(debugLabel: 'quick_fix_filters_guide');
            final quickFixMatchGuideKey = GlobalKey(debugLabel: 'quick_fix_match_guide');

            return PageOnboarding(
              pageId: 'quick_fix_guide_v2',
              tips: [
                OnboardingTip(
                  targetKey: quickFixBodyGuideKey,
                  icon: Icons.touch_app_rounded,
                  title: t.get('guide_quick_fix_body_title', fallback: 'Tap the body'),
                  body: t.get('guide_quick_fix_body_body', fallback: 'Pick the area that feels tight. The app will focus the recommendation there.'),
                ),
                OnboardingTip(
                  targetKey: quickFixFiltersGuideKey,
                  icon: Icons.tune_rounded,
                  title: t.get('guide_quick_fix_filters_title', fallback: 'Set simple filters'),
                  body: t.get('guide_quick_fix_filters_body', fallback: 'Choose time and available equipment. Keep it simple.'),
                ),
                OnboardingTip(
                  targetKey: quickFixMatchGuideKey,
                  icon: Icons.auto_awesome_rounded,
                  title: t.get('guide_quick_fix_match_title', fallback: 'Get a match'),
                  body: t.get('guide_quick_fix_match_body', fallback: 'Tap Find Match to get one session that fits your current situation.'),
                ),
              ],
              child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: pageInfo.isCompact ? 30 : 40,
                ),
                children: [
                  _QuickFixSelectionSurface(
                    state: state,
                    isWide: isWide,
                    bodyGuideKey: quickFixBodyGuideKey,
                    filtersGuideKey: quickFixFiltersGuideKey,
                  ),
                  const SizedBox(height: 10),
                  KeyedSubtree(
                    key: quickFixMatchGuideKey,
                    child: _QuickFixRevealButton(
                      hasUserInteracted: state.hasUserInteracted,
                      onPressed: () => _showRecommendationOverlay(context, state),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
}

class _QuickFixSelectionSurface extends ConsumerWidget {
  const _QuickFixSelectionSurface({
    required this.state,
    required this.isWide,
    required this.bodyGuideKey,
    required this.filtersGuideKey,
  });

  final QuickFixState state;
  final bool isWide;
  final GlobalKey bodyGuideKey;
  final GlobalKey filtersGuideKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodySelector = KeyedSubtree(
      key: bodyGuideKey,
      child: _QuickFixBodySelectorCard(
        options: state.problems,
        selectedProblemId: state.selectedProblemId,
        onProblemSelected:
            ref.read(quickFixControllerProvider.notifier).selectProblem,
      ),
    );

    final filters = KeyedSubtree(
      key: filtersGuideKey,
      child: _QuickFixFiltersPanel(state: state),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 11,
            child: bodySelector,
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 9,
            child: filters,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bodySelector,
        const SizedBox(height: 8),
        filters,
      ],
    );
  }
}

class _QuickFixRevealButton extends StatelessWidget {
  const _QuickFixRevealButton({
    required this.hasUserInteracted,
    required this.onPressed,
  });

  final bool hasUserInteracted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: isDark ? 0.96 : 0.92),
              colors.tertiary.withValues(alpha: isDark ? 0.88 : 0.84),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.14),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasUserInteracted
                        ? Icons.auto_awesome_rounded
                        : Icons.bolt_rounded,
                    size: 19,
                    color: colors.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.get(
                      'quick_fix_match_session_cta',
                      fallback: 'Find Match',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.1,
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



class _QuickFixRecommendationOverlay extends StatelessWidget {
  const _QuickFixRecommendationOverlay({required this.state});

  final QuickFixState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final target = state.problems.cast<QuickFixOption?>().firstWhere(
          (item) => item?.id == state.selectedProblemId,
          orElse: () => null,
        );

    final targetLabel = target == null
        ? AppText.get(
            context,
            key: 'quick_fix_selected_target_empty',
            fallback: 'Selected body',
          )
        : AppText.get(
            context,
            key: target.labelKey,
            fallback: target.labelFallback,
          );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.42)
                      : const Color(0xFFEAF1F8).withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _MatchedSessionSheetFrame(
                      targetLabel: targetLabel,
                      onClose: () => Navigator.of(context).pop(),
                      child: _QuickFixRecommendationResult(state: state),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _MatchedSessionSheetFrame extends StatefulWidget {
  const _MatchedSessionSheetFrame({
    required this.targetLabel,
    required this.onClose,
    required this.child,
  });

  final String targetLabel;
  final VoidCallback onClose;
  final Widget child;

  @override
  State<_MatchedSessionSheetFrame> createState() =>
      _MatchedSessionSheetFrameState();
}

class _MatchedSessionSheetFrameState extends State<_MatchedSessionSheetFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();

    _scanAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.62, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matched => _controller.value >= 0.62;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.surfaceContainerHigh.withValues(alpha: 0.98),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  colors.surface.withValues(alpha: 0.98),
                  colors.surfaceContainerLow.withValues(alpha: 0.96),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: isDark ? 0.30 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.34)
                : const Color(0xFF263B57).withValues(alpha: 0.18),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, _) {
                  final value = _scanAnimation.value;

                  return Align(
                    alignment: Alignment(0, -1 + (value * 2.2)),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            colors.primary.withValues(
                              alpha: isDark ? 0.12 : 0.08,
                            ),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: colors.outlineVariant.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  colors.primary,
                                  colors.tertiary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colors.primary.withValues(alpha: 0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _matched
                                  ? Icons.check_rounded
                                  : Icons.auto_awesome_rounded,
                              color: colors.onPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(
                                    _matched
                                        ? AppText.get(
                                            context,
                                            key: 'quick_fix_matched_title',
                                            fallback: 'Matched session',
                                          )
                                        : AppText.get(
                                            context,
                                            key: 'quick_fix_matching_title',
                                            fallback: 'Matching your reset…',
                                          ),
                                    key: ValueKey(_matched),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.targetLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .closeButtonTooltip,
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final reveal = Curves.easeOutCubic.transform(
                        ((_controller.value - 0.30) / 0.70).clamp(0.0, 1.0),
                      );

                      return Opacity(
                        opacity: reveal,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - reveal)),
                          child: child,
                        ),
                      );
                    },
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RecommendationRevealFrame extends StatefulWidget {
  const _RecommendationRevealFrame({required this.child});

  final Widget child;

  @override
  State<_RecommendationRevealFrame> createState() => _RecommendationRevealFrameState();
}

class _RecommendationRevealFrameState extends State<_RecommendationRevealFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = 0.14 + (_controller.value * 0.10);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: colors.tertiary.withValues(alpha: isDark ? 0.30 + glow : 0.20 + glow),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: isDark ? 0.20 + glow : 0.10 + glow),
                blurRadius: 38 + (_controller.value * 14),
                spreadRadius: 1,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.42)
                    : const Color(0xFF24364C).withValues(alpha: 0.16),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}


class _QuickFixFiltersPanel extends ConsumerWidget {
  const _QuickFixFiltersPanel({required this.state});

  final QuickFixState state;

  String _singleSummary(
    BuildContext context,
    List<QuickFixOption> options,
    String selectedId,
    String emptyFallback,
  ) {
    final match = options.cast<QuickFixOption?>().firstWhere(
          (item) => item?.id == selectedId,
          orElse: () => null,
        );

    if (match == null) {
      return AppText.get(
        context,
        key: 'quick_fix_none_selected',
        fallback: emptyFallback,
      );
    }

    return AppText.get(
      context,
      key: match.labelKey,
      fallback: match.labelFallback,
    );
  }

  String _multiSummary(
    BuildContext context,
    List<QuickFixOption> options,
    Set<String> selectedIds,
    String emptyFallback,
  ) {
    if (selectedIds.isEmpty) {
      return AppText.get(
        context,
        key: 'quick_fix_none_selected',
        fallback: emptyFallback,
      );
    }

    final selected = options.where((item) => selectedIds.contains(item.id)).toList();
    if (selected.isEmpty) {
      return AppText.get(
        context,
        key: 'quick_fix_none_selected',
        fallback: emptyFallback,
      );
    }

    if (selected.length == 1) {
      final item = selected.first;
      return AppText.get(
        context,
        key: item.labelKey,
        fallback: item.labelFallback,
      );
    }

    return '${selected.length} ${AppText.get(
      context,
      key: 'quick_fix_selected_count_suffix',
      fallback: 'selected',
    )}';
  }

  Future<void> _showSinglePicker({
    required BuildContext context,
    required String title,
    required List<QuickFixOption> options,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await _showQuickFixCompactPicker(
      context: context,
      title: title,
      options: options,
      selectedIds: {selectedId},
      multiSelect: false,
    );

    if (result == null || result.isEmpty) return;
    onSelected(result.first);
  }

  Future<void> _showMultiPicker({
    required BuildContext context,
    required String title,
    required List<QuickFixOption> options,
    required Set<String> selectedIds,
    required String fallbackId,
    required bool exclusiveFallback,
    required ValueChanged<Set<String>> onChanged,
  }) async {
    final result = await _showQuickFixCompactPicker(
      context: context,
      title: title,
      options: options,
      selectedIds: selectedIds,
      multiSelect: true,
      fallbackId: fallbackId,
      exclusiveFallback: exclusiveFallback,
    );

    if (result == null) return;
    onChanged(result.isEmpty ? {fallbackId} : result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final controller = ref.read(quickFixControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timeTitle = t.get('quick_fix_time_title', fallback: 'Time');
    final equipmentTitle = t.get('quick_fix_equipment_title', fallback: 'Equipment');

    final items = [
      _QuickFixCompactFilterTile(
        icon: Icons.timer_outlined,
        label: timeTitle,
        value: _singleSummary(context, state.timeOptions, state.selectedTimeId, 'Any'),
        emphasizedValue: true,
        onTap: () => _showSinglePicker(
          context: context,
          title: timeTitle,
          options: state.timeOptions,
          selectedId: state.selectedTimeId,
          onSelected: controller.selectTime,
        ),
      ),
      _QuickFixCompactFilterTile(
        icon: Icons.construction_rounded,
        label: equipmentTitle,
        value: _multiSummary(
          context,
          state.equipmentOptions,
          state.selectedEquipmentIds.toSet(),
          'None',
        ),
        onTap: () => _showMultiPicker(
          context: context,
          title: equipmentTitle,
          options: state.equipmentOptions,
          selectedIds: state.selectedEquipmentIds.toSet(),
          fallbackId: 'none',
          exclusiveFallback: true,
          onChanged: controller.setEquipment,
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.38)
            : colors.surface.withValues(alpha: 0.74),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.62 : 0.48),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: items[0]),
          const SizedBox(width: 7),
          Expanded(child: items[1]),
        ],
      ),
    );
  }
}

Future<Set<String>?> _showQuickFixCompactPicker({
  required BuildContext context,
  required String title,
  required List<QuickFixOption> options,
  required Set<String> selectedIds,
  required bool multiSelect,
  String? fallbackId,
  bool exclusiveFallback = false,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (context) {
      return _QuickFixCompactPickerSheet(
        title: title,
        options: options,
        selectedIds: selectedIds,
        multiSelect: multiSelect,
        fallbackId: fallbackId,
        exclusiveFallback: exclusiveFallback,
      );
    },
  );
}

class _QuickFixCompactPickerSheet extends StatefulWidget {
  const _QuickFixCompactPickerSheet({
    required this.title,
    required this.options,
    required this.selectedIds,
    required this.multiSelect,
    required this.fallbackId,
    required this.exclusiveFallback,
  });

  final String title;
  final List<QuickFixOption> options;
  final Set<String> selectedIds;
  final bool multiSelect;
  final String? fallbackId;
  final bool exclusiveFallback;

  @override
  State<_QuickFixCompactPickerSheet> createState() =>
      _QuickFixCompactPickerSheetState();
}

class _QuickFixCompactPickerSheetState
    extends State<_QuickFixCompactPickerSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedIds};
    if (_selected.isEmpty && widget.fallbackId != null) {
      _selected.add(widget.fallbackId!);
    }
  }

  void _toggle(String id) {
    if (!widget.multiSelect) {
      Navigator.of(context).pop({id});
      return;
    }

    setState(() {
      if (widget.exclusiveFallback && id == widget.fallbackId) {
        _selected = {id};
        return;
      }

      final next = {..._selected};
      if (next.contains(id)) {
        next.remove(id);
      } else {
        next.add(id);
        if (widget.exclusiveFallback && widget.fallbackId != null) {
          next.remove(widget.fallbackId);
        }
      }

      if (next.isEmpty && widget.fallbackId != null) {
        next.add(widget.fallbackId!);
      }

      _selected = next;
    });
  }

  void _apply() {
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: media.viewInsets.bottom + 12,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: media.size.height * 0.58,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          colors.surfaceContainerHigh.withValues(alpha: 0.98),
                          colors.surface.withValues(alpha: 0.98),
                        ]
                      : [
                          colors.surface.withValues(alpha: 0.99),
                          colors.surfaceContainerLow.withValues(alpha: 0.97),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(
                    alpha: isDark ? 0.78 : 0.62,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.32)
                        : const Color(0xFF263B57).withValues(alpha: 0.16),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colors.outlineVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: colors.primary.withValues(
                                alpha: isDark ? 0.15 : 0.10,
                              ),
                            ),
                            child: Icon(
                              widget.multiSelect
                                  ? Icons.checklist_rounded
                                  : Icons.radio_button_checked_rounded,
                              color: colors.primary,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final useGrid = constraints.maxWidth >= 420;
                            final width = useGrid
                                ? (constraints.maxWidth - 8) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.options.map((option) {
                                return SizedBox(
                                  width: width,
                                  child: _PickerOptionTile(
                                    option: option,
                                    selected: _selected.contains(option.id),
                                    multiSelect: widget.multiSelect,
                                    onTap: () => _toggle(option.id),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    if (widget.multiSelect)
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colors.outlineVariant.withValues(
                                alpha: isDark ? 0.72 : 0.58,
                              ),
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _apply,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppText.get(
                                context,
                                key: 'common_apply',
                                fallback: 'Apply',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerOptionTile extends StatelessWidget {
  const _PickerOptionTile({
    required this.option,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final QuickFixOption option;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: selected
                ? colors.primary.withValues(alpha: isDark ? 0.18 : 0.11)
                : isDark
                    ? colors.surfaceContainerHigh.withValues(alpha: 0.62)
                    : colors.surface.withValues(alpha: 0.78),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: isDark ? 0.58 : 0.44)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.68 : 0.54),
              width: selected ? 1.25 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                multiSelect
                    ? (selected ? Icons.check_circle_rounded : Icons.circle_outlined)
                    : (selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded),
                size: 19,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  AppText.get(
                    context,
                    key: option.labelKey,
                    fallback: option.labelFallback,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                QuickFixIconResolver.resolve(option.iconName),
                size: 17,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFixCompactFilterTile extends StatelessWidget {
  const _QuickFixCompactFilterTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.emphasizedValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool emphasizedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final active = emphasizedValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? colors.surface.withValues(alpha: active ? 0.56 : 0.38)
                : colors.surface.withValues(alpha: active ? 0.96 : 0.78),
            border: Border.all(
              color: active
                  ? colors.primary.withValues(alpha: isDark ? 0.46 : 0.36)
                  : colors.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.46),
              width: active ? 1.15 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
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
                        height: 1.0,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _QuickFixRecommendationResult extends ConsumerWidget {
  const _QuickFixRecommendationResult({required this.state});

  final QuickFixState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(quickFixControllerProvider).value ?? state;

    return _QuickFixRecommendationPreview(
      recommendation: liveState.primaryRecommendation,
      alternatives: liveState.alternativeRecommendations,
      emphasize: true,
      compact: true,
    );
  }
}

class _QuickFixBodySelectorCard extends StatefulWidget {
  const _QuickFixBodySelectorCard({
    required this.options,
    required this.selectedProblemId,
    required this.onProblemSelected,
  });

  final List<QuickFixOption> options;
  final String selectedProblemId;
  final ValueChanged<String> onProblemSelected;

  @override
  State<_QuickFixBodySelectorCard> createState() =>
      _QuickFixBodySelectorCardState();
}

class _QuickFixBodySelectorCardState extends State<_QuickFixBodySelectorCard> {
  late _QuickFixBodySide _side;

  @override
  void initState() {
    super.initState();
    _side = _sideForProblem(widget.selectedProblemId);
  }

  @override
  void didUpdateWidget(covariant _QuickFixBodySelectorCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedProblemId != widget.selectedProblemId) {
      _side = _sideForProblem(widget.selectedProblemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedOption = widget.options.cast<QuickFixOption?>().firstWhere(
          (option) => option?.id == widget.selectedProblemId,
          orElse: () => null,
        );

    final imagePath = _side == _QuickFixBodySide.front
        ? 'assets/images/body_map/front.png'
        : 'assets/images/body_map/back.png';

    final visibleHotspots = widget.options
        .expand(
          (option) => _placementsForOption(option.id, _side)
              .map((placement) => (option: option, placement: placement)),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.74 : 0.58),
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colors.primary.withValues(alpha: 0.08),
                  colors.surfaceContainerHigh.withValues(alpha: 0.88),
                  colors.surface.withValues(alpha: 0.98),
                ]
              : [
                  colors.primary.withValues(alpha: 0.045),
                  colors.surface.withValues(alpha: 0.98),
                  colors.surfaceContainerLow.withValues(alpha: 0.96),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 360;
          final wide = constraints.maxWidth >= 620;
          final bodyHeight = wide ? 520.0 : narrow ? 410.0 : 480.0;

          return Stack(
            children: [
              _BodyStage(
                imagePath: imagePath,
                height: bodyHeight,
                visibleHotspots: visibleHotspots,
                selectedProblemId: widget.selectedProblemId,
                onHotspotTap: _selectOption,
              ),
              Positioned(
                left: 8,
                top: 8,
                child: _SideGlassToggle(
                  side: _side,
                  onChanged: _changeSide,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: wide ? 190 : narrow ? 138 : 166,
                  ),
                  child: _SelectedTargetGlass(option: selectedOption),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: _BodyHintPill(
                    label: AppText.get(
                      context,
                      key: 'quick_fix_body_map_hint_step',
                      fallback: 'Tap body point',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _changeSide(_QuickFixBodySide value) {
    setState(() {
      _side = value;
    });
  }

  void _selectOption(String id) {
    widget.onProblemSelected(id);

    final nextSide = _sideForProblem(id);
    if (nextSide != _side) {
      setState(() {
        _side = nextSide;
      });
    }
  }

  _QuickFixBodySide _sideForProblem(String optionId) {
    switch (optionId) {
      case 'eye':
      case 'eyes':
      case 'wrist':
      case 'wrists':
      case 'forearm':
      case 'forearms':
      case 'hand':
      case 'hands':
      case 'finger':
      case 'fingers':
      case 'stress':
        return _QuickFixBodySide.front;
      case 'hips':
      case 'glutes':
      case 'hips_glutes':
        return _QuickFixBodySide.back;
      default:
        return _QuickFixBodySide.back;
    }
  }

  List<_HotspotPlacement> _placementsForOption(
    String optionId,
    _QuickFixBodySide side,
  ) {
    switch (optionId) {
      case 'neck':
        return side == _QuickFixBodySide.back
            ? const [_HotspotPlacement(x: 0.50, y: 0.145)]
            : const [];

      case 'shoulder':
      case 'shoulders':
        return side == _QuickFixBodySide.back
            ? const [
                _HotspotPlacement(x: 0.34, y: 0.235),
                _HotspotPlacement(x: 0.66, y: 0.235),
              ]
            : const [];

      case 'upper_back':
        return side == _QuickFixBodySide.back
            ? const [_HotspotPlacement(x: 0.50, y: 0.275)]
            : const [];

      case 'back':
      case 'lower_back':
        return side == _QuickFixBodySide.back
            ? const [_HotspotPlacement(x: 0.50, y: 0.445)]
            : const [];

      case 'wrist':
      case 'wrists':
        return side == _QuickFixBodySide.front
            ? const [
                _HotspotPlacement(x: 0.16, y: 0.535),
                _HotspotPlacement(x: 0.84, y: 0.535),
              ]
            : const [];

      case 'forearm':
      case 'forearms':
        return side == _QuickFixBodySide.front
            ? const [
                _HotspotPlacement(x: 0.20, y: 0.465),
                _HotspotPlacement(x: 0.80, y: 0.465),
              ]
            : const [];

      case 'hand':
      case 'hands':
      case 'finger':
      case 'fingers':
        return side == _QuickFixBodySide.front
            ? const [
                _HotspotPlacement(x: 0.12, y: 0.595),
                _HotspotPlacement(x: 0.88, y: 0.595),
              ]
            : const [];

      case 'eye':
      case 'eyes':
        return side == _QuickFixBodySide.front
            ? const [_HotspotPlacement(x: 0.50, y: 0.078)]
            : const [];

      case 'hips':
      case 'glutes':
      case 'hips_glutes':
        return side == _QuickFixBodySide.back
            ? const [
                _HotspotPlacement(x: 0.42, y: 0.565),
                _HotspotPlacement(x: 0.58, y: 0.565),
              ]
            : const [];

      case 'stress':
        return side == _QuickFixBodySide.front
            ? const [_HotspotPlacement(x: 0.50, y: 0.300)]
            : const [];

      default:
        return const [];
    }
  }
}

class _SelectedTargetGlass extends StatelessWidget {
  const _SelectedTargetGlass({required this.option});

  final QuickFixOption? option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final label = option == null
        ? AppText.get(
            context,
            key: 'quick_fix_selected_target_empty',
            fallback: 'No target',
          )
        : AppText.get(
            context,
            key: option!.labelKey,
            fallback: option!.labelFallback,
          );
    final icon = option == null
        ? Icons.radio_button_unchecked_rounded
        : QuickFixIconResolver.resolve(option!.iconName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark
                ? colors.surface.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.72),
            border: Border.all(
              color: colors.tertiary.withValues(alpha: isDark ? 0.34 : 0.26),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isDark ? colors.tertiary : colors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideGlassToggle extends StatelessWidget {
  const _SideGlassToggle({required this.side, required this.onChanged});

  final _QuickFixBodySide side;
  final ValueChanged<_QuickFixBodySide> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark
                ? colors.surface.withValues(alpha: 0.48)
                : Colors.white.withValues(alpha: 0.72),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: isDark ? 0.56 : 0.44),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SideGlassSegment(
                label: AppText.get(context, key: 'body_map_front', fallback: 'Front'),
                selected: side == _QuickFixBodySide.front,
                onTap: () => onChanged(_QuickFixBodySide.front),
              ),
              _SideGlassSegment(
                label: AppText.get(context, key: 'body_map_back', fallback: 'Back'),
                selected: side == _QuickFixBodySide.back,
                onTap: () => onChanged(_QuickFixBodySide.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideGlassSegment extends StatelessWidget {
  const _SideGlassSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.94),
                      colors.tertiary.withValues(alpha: 0.84),
                    ],
                  )
                : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyHintPill extends StatelessWidget {
  const _BodyHintPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark
                ? colors.surface.withValues(alpha: 0.34)
                : Colors.white.withValues(alpha: 0.58),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: isDark ? 0.42 : 0.34),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyStage extends StatelessWidget {
  const _BodyStage({
    required this.imagePath,
    required this.height,
    required this.visibleHotspots,
    required this.selectedProblemId,
    required this.onHotspotTap,
  });

  final String imagePath;
  final double height;
  final List<({QuickFixOption option, _HotspotPlacement placement})>
      visibleHotspots;
  final String selectedProblemId;
  final ValueChanged<String> onHotspotTap;

  // The body-map artwork was cropped from the knees down, so the rendered
  // artboard is wider/shorter than the original full-body asset. Keep this
  // ratio aligned with the cropped PNGs; hotspots are normalized against
  // this same artboard so the dots stay locked to the anatomy.
  static const double _imageAspectRatio = 654 / 1080;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: RadialGradient(
              colors: [
                colors.tertiary.withValues(alpha: isDark ? 0.13 : 0.09),
                colors.primary.withValues(alpha: isDark ? 0.07 : 0.055),
                Colors.transparent,
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              var artboardHeight = constraints.maxHeight;
              var artboardWidth = artboardHeight * _imageAspectRatio;

              if (artboardWidth > constraints.maxWidth * 0.96) {
                artboardWidth = constraints.maxWidth * 0.96;
                artboardHeight = artboardWidth / _imageAspectRatio;
              }

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Center(
                    child: Container(
                      width: artboardWidth * 1.80,
                      height: artboardWidth * 1.80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary.withValues(
                            alpha: isDark ? 0.12 : 0.10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: artboardWidth,
                      height: artboardHeight,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                          ...visibleHotspots.map((entry) {
                            final selected =
                                entry.option.id == selectedProblemId;

                            return Positioned(
                              left: (artboardWidth * entry.placement.x) - 20,
                              top: (artboardHeight * entry.placement.y) - 20,
                              child: _LightNode(
                                selected: selected,
                                onTap: () => onHotspotTap(entry.option.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LightNode extends StatefulWidget {
  const _LightNode({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LightNode> createState() => _LightNodeState();
}

class _LightNodeState extends State<_LightNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF69F5E5) : colors.primary;
    final idleColor = isDark ? const Color(0xFF47DCEB) : const Color(0xFF008A96);
    final color = widget.selected ? activeColor : idleColor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = Curves.easeInOut.transform(_controller.value);
            final selectedPulse = widget.selected ? 1.0 + (pulse * 0.10) : 1.0;
            final idlePulse = 1.0 + (pulse * 0.12);

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                  scale: widget.selected ? selectedPulse : idlePulse,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: widget.selected ? 46 : 34,
                    height: widget.selected ? 46 : 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(
                        alpha: widget.selected
                            ? isDark
                                ? 0.20
                                : 0.18
                            : isDark
                                ? 0.09
                                : 0.12,
                      ),
                      border: Border.all(
                        color: color.withValues(
                          alpha: widget.selected
                              ? isDark
                                  ? 0.38
                                  : 0.30
                              : isDark
                                  ? 0.18
                                  : 0.16,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(
                            alpha: widget.selected
                                ? isDark
                                    ? 0.36
                                    : 0.18
                                : isDark
                                    ? 0.18
                                    : 0.10,
                          ),
                          blurRadius: widget.selected ? 24 : 14,
                          spreadRadius: widget.selected ? 2 : 0,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: widget.selected ? 34 : 25,
                  height: widget.selected ? 34 : 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.selected
                        ? RadialGradient(
                            colors: [
                              color.withValues(alpha: isDark ? 0.38 : 0.28),
                              color.withValues(alpha: isDark ? 0.10 : 0.08),
                            ],
                          )
                        : null,
                    color: widget.selected
                        ? null
                        : isDark
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.32),
                    border: Border.all(
                      color: color.withValues(
                        alpha: widget.selected
                            ? isDark
                                ? 0.92
                                : 0.86
                            : isDark
                                ? 0.56
                                : 0.70,
                      ),
                      width: widget.selected ? 2.0 : 1.25,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: widget.selected ? 17 : 10,
                  height: widget.selected ? 17 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: widget.selected ? 0.82 : 0.0)
                          : Colors.white.withValues(alpha: 0.92),
                      width: widget.selected ? 1.7 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: isDark ? 0.62 : 0.26),
                        blurRadius: widget.selected ? 16 : 10,
                      ),
                    ],
                  ),
                  child: widget.selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: isDark ? const Color(0xFF041316) : Colors.white,
                        )
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickFixRecommendationPreview extends ConsumerWidget {
  const _QuickFixRecommendationPreview({
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
    final colors = theme.colorScheme;

    if (recommendation == null) {
      return _SimpleRecommendationShell(
        child: Text(
          t.get(
            'quick_fix_recommendation_missing',
            fallback: 'No recommendation available yet.',
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    final selected = recommendation!;
    final session = selected.session;
    final quickFixSource = SessionEntrySource.quickFix.dbValue;
    final title = t.get(session.titleKey, fallback: session.titleFallback);
    final subtitle = t.get(session.subtitleKey, fallback: session.subtitleFallback);
    final signals = selected.signals.take(3).toList(growable: false);

    Future<void> openMainDetails() async {
      await ref
          .read(quickFixControllerProvider.notifier)
          .trackAction(QuickFixActionType.viewDetail);

      if (context.mounted) {
        context.pushNamed(
          'session-detail',
          pathParameters: {'id': session.id},
        );
      }
    }

    final equipmentLabel = _equipmentSummaryLabel(session);
    final intensityLabel = _intensityDisplayLabel(session.intensity.name);
    final heroSpec = _resolveSessionHeroSpec(session.coverVariant, colors);

    return _SimpleRecommendationShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _RecommendationHeroCard(
            sessionId: session.id,
            badgeLabel: t.get('quick_fix_recommended_badge', fallback: 'Best match'),
            title: title,
            subtitle: subtitle,
            minutes: session.durationMinutes,
            equipmentLabel: equipmentLabel,
            intensityLabel: intensityLabel,
            heroSpec: heroSpec,
            signals: signals,
            compact: compact,
          ),
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
                      context.push('/app/sessions/player/${session.id}?source=$quickFixSource');
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(t.get('quick_fix_start_now_cta', fallback: 'Start now')),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(compact ? 44 : 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: openMainDetails,
                  icon: const Icon(Icons.info_outline_rounded, size: 19),
                  label: Text(t.get('quick_fix_view_details_cta', fallback: 'View detail')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(compact ? 44 : 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 18),
            _AlternativeHeader(
              title: t.get('quick_fix_alternatives_title', fallback: 'More good matches'),
              subtitle: '',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: alternatives.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = alternatives[index];
                  return _AlternativeRecommendationTile(
                    recommendation: item,
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      router.pushNamed(
                        'session-detail',
                        pathParameters: {'id': item.session.id},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlternativeHeader extends StatelessWidget {
  const _AlternativeHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
        if (subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ],
    );
  }
}

class _AlternativeRecommendationTile extends StatelessWidget {
  const _AlternativeRecommendationTile({
    required this.recommendation,
    required this.onTap,
  });

  final QuickFixRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final session = recommendation.session;
    final title = AppText.get(
      context,
      key: session.titleKey,
      fallback: session.titleFallback,
    );

    return SizedBox(
      width: 178,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? colors.surface.withValues(alpha: 0.46)
                  : colors.surface.withValues(alpha: 0.72),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: isDark ? 0.44 : 0.34),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuickFixSessionImage(
                    sessionId: session.id,
                    height: 72,
                    borderRadius: 0,
                    durationMinutes: session.durationMinutes,
                    showDuration: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w900,
                            height: 1.06,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${session.durationMinutes} min',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ],
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

class _SimpleRecommendationShell extends StatelessWidget {
  const _SimpleRecommendationShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: child,
    );
  }
}

class _RecommendationHeroCard extends StatelessWidget {
  const _RecommendationHeroCard({
    required this.sessionId,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.equipmentLabel,
    required this.intensityLabel,
    required this.heroSpec,
    required this.signals,
    this.compact = false,
  });

  final String sessionId;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final int minutes;
  final String equipmentLabel;
  final String intensityLabel;
  final _SessionHeroSpec heroSpec;
  final List<QuickFixSignal> signals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuickFixSessionImage(
          sessionId: sessionId,
          height: compact ? 112 : 178,
          borderRadius: compact ? 20 : 26,
          durationMinutes: minutes,
          showDuration: true,
        ),
        SizedBox(height: compact ? 10 : 14),
        Row(
          children: [
            _SoftBadge(label: badgeLabel),
            const SizedBox(width: 8),
            _SessionMetaChip(
              icon: Icons.schedule_rounded,
              label: '$minutes min',
            ),
          ],
        ),
        SizedBox(height: compact ? 8 : 11),
        Text(
          title,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: (compact ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall)?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            height: 1.02,
            letterSpacing: -0.35,
          ),
        ),
      ],
    );
  }
}

class _QuickFixSessionImage extends StatelessWidget {
  const _QuickFixSessionImage({
    required this.sessionId,
    required this.height,
    required this.borderRadius,
    required this.durationMinutes,
    required this.showDuration,
  });

  final String sessionId;
  final double height;
  final double borderRadius;
  final int durationMinutes;
  final bool showDuration;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/sessions/$sessionId.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.18),
                      colors.tertiary.withValues(alpha: 0.10),
                      colors.surfaceContainerLow.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.self_improvement_rounded,
                  color: colors.primary,
                  size: height > 100 ? 42 : 26,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.00),
                    Colors.black.withValues(alpha: 0.22),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (showDuration)
              Positioned(
                right: 10,
                top: 10,
                child: _ImageDurationBadge(minutes: durationMinutes),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImageDurationBadge extends StatelessWidget {
  const _ImageDurationBadge({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 14,
            color: Color(0xFF5364F6),
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes}m',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF5364F6),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}



class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.primary.withValues(alpha: 0.10),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _SessionMetaChip extends StatelessWidget {
  const _SessionMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDark
            ? colors.surface.withValues(alpha: 0.34)
            : colors.surface.withValues(alpha: 0.80),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.54 : 0.42),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHeroSpec {
  const _SessionHeroSpec({
    required this.metaIcon,
  });

  final IconData metaIcon;
}

_SessionHeroSpec _resolveSessionHeroSpec(String coverVariant, ColorScheme colors) {
  switch (coverVariant) {
    case 'neck':
      return const _SessionHeroSpec(metaIcon: Icons.accessibility_new_rounded);
    case 'shoulder':
      return const _SessionHeroSpec(metaIcon: Icons.fitness_center_rounded);
    case 'upper_back':
      return const _SessionHeroSpec(metaIcon: Icons.straighten_rounded);
    case 'lower_back':
      return const _SessionHeroSpec(metaIcon: Icons.air_rounded);
    default:
      return const _SessionHeroSpec(metaIcon: Icons.auto_awesome_rounded);
  }
}

String _equipmentSummaryLabel(SessionSummary session) {
  final normalized = session.requiredEquipment
      .map(_equipmentCodeName)
      .where((item) => item.isNotEmpty && item != 'none')
      .toSet()
      .toList();

  if (normalized.isEmpty) return 'No equipment';

  final names = normalized.map(_equipmentDisplayName).toList();
  if (names.length == 1) return names.first;

  return '${names.first} +${names.length - 1}';
}

String _equipmentCodeName(Object? equipment) {
  if (equipment == null) return '';

  final raw = equipment.toString();
  if (raw.contains('.')) {
    return raw.split('.').last;
  }

  return raw;
}

String _equipmentDisplayName(String equipmentCode) {
  switch (equipmentCode) {
    case 'chair':
      return 'Chair';
    case 'desk':
      return 'Desk';
    case 'wall':
      return 'Wall';
    case 'towel':
      return 'Towel';
    case 'miniBand':
    case 'mini_band':
      return 'Mini band';
    case 'foamRoller':
    case 'foam_roller':
      return 'Foam roller';
    case 'massageBall':
    case 'massage_ball':
      return 'Massage ball';
    case 'yogaMat':
    case 'yoga_mat':
      return 'Yoga mat';
    case 'smallCushion':
    case 'small_cushion':
      return 'Small cushion';
    case 'lumbarRoll':
    case 'lumbar_roll':
      return 'Lumbar roll';
    default:
      return 'Equipment';
  }
}

String _intensityDisplayLabel(String intensityName) {
  switch (intensityName) {
    case 'gentle':
      return 'Gentle';
    case 'light':
      return 'Light';
    case 'moderate':
      return 'Moderate';
    case 'strong':
      return 'Strong';
    default:
      return 'Balanced';
  }
}


class _QuickFixLoadingState extends StatelessWidget {
  const _QuickFixLoadingState();

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            Text(
              t.get(
                'quick_fix_loading_title',
                fallback: 'Preparing Quick Fix…',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFixErrorState extends StatelessWidget {
  const _QuickFixErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    colors.outlineVariant.withValues(alpha: isDark ? 0.78 : 0.66),
              ),
              color: isDark
                  ? colors.surfaceContainerHigh.withValues(alpha: 0.78)
                  : colors.surface.withValues(alpha: 0.92),
            ),
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
                      'quick_fix_error_title',
                      fallback: 'Unable to load Quick Fix',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.get(
                      'quick_fix_error_body',
                      fallback: 'Please try again.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(t.commonRetry),
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

class _HotspotPlacement {
  const _HotspotPlacement({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;
}

enum _QuickFixBodySide {
  front,
  back,
}
