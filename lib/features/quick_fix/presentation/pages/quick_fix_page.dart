// lib/features/quick_fix/presentation/pages/quick_fix_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../shared/layout/responsive_page_scaffold.dart';
import '../../domain/quick_fix_state.dart';
import '../controllers/quick_fix_controller.dart';
import '../widgets/quick_fix_body_selector_card.dart';
import '../widgets/quick_fix_filter_field.dart';
import '../widgets/quick_fix_option_sheet.dart';
import '../widgets/quick_fix_recommendation_preview.dart';
import 'package:go_router/go_router.dart';

import '../../../access/application/access_providers.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import '../../../access/presentation/widgets/locked_feature_card.dart';

class QuickFixPage extends ConsumerWidget {
  const QuickFixPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(quickFixControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final quickFixAsync = ref.watch(quickFixControllerProvider);

    return ResponsivePageScaffold(
      title: Text(t.get('quick_fix_title', fallback: 'Quick Fix')),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: t.get(
            'quick_fix_history_tooltip',
            fallback: 'Recent quick fixes',
          ),
          icon: const Icon(Icons.history),
        ),
      ],
      bodyBuilder: (context, pageInfo) {
        return quickFixAsync.when(
          loading: () => const _QuickFixLoadingState(),
          error: (_, __) => _QuickFixErrorState(
            onRetry: () => ref.invalidate(quickFixControllerProvider),
          ),
          data: (state) {
            final isWide = pageInfo.isMedium || pageInfo.isExpanded;

            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: pageInfo.isCompact ? 20 : 28),
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 11,
                          child: _QuickFixMainColumn(state: state),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 9,
                          child: _QuickFixRecommendationColumn(state: state),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuickFixMainColumn(state: state),
                        const SizedBox(height: 14),
                        _QuickFixRecommendationColumn(state: state),
                      ],
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

class _QuickFixMainColumn extends StatelessWidget {
  const _QuickFixMainColumn({required this.state});

  final QuickFixState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PainAndFiltersSurface(state: state),
      ],
    );
  }
}

class _PainAndFiltersSurface extends ConsumerWidget {
  const _PainAndFiltersSurface({required this.state});

  final QuickFixState state;

  String _singleSummary(
    BuildContext context,
    List<QuickFixOption> options,
    String selectedId,
    String emptyFallback,
  ) {
    final t = AppText.of(context);

    final match = options.cast<QuickFixOption?>().firstWhere(
          (item) => item?.id == selectedId,
          orElse: () => null,
        );

    if (match == null) {
      return t.get(
        'quick_fix_none_selected',
        fallback: emptyFallback,
      );
    }

    return t.get(match.labelKey, fallback: match.labelFallback);
  }

  String _multiSummary(
    BuildContext context,
    List<QuickFixOption> options,
    Set<String> selectedIds,
    String emptyFallback,
  ) {
    final t = AppText.of(context);

    if (selectedIds.isEmpty) {
      return t.get('quick_fix_none_selected', fallback: emptyFallback);
    }

    final selected = options.where((item) => selectedIds.contains(item.id)).toList();

    if (selected.isEmpty) {
      return t.get('quick_fix_none_selected', fallback: emptyFallback);
    }

    if (selected.length == 1) {
      final item = selected.first;
      return t.get(item.labelKey, fallback: item.labelFallback);
    }

    return '${selected.length} ${t.get('quick_fix_selected_count_suffix', fallback: 'selected')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quickFixControllerProvider.notifier);
    final t = AppText.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            Theme.of(context).colorScheme.surfaceContainerHigh,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          QuickFixBodySelectorCard(
            options: state.problems,
            selectedProblemId: state.selectedProblemId,
            onProblemSelected: controller.selectProblem,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              QuickFixFilterField(
                icon: Icons.timer_outlined,
                label: t.get('quick_fix_time_title', fallback: 'Time'),
                value: _singleSummary(
                  context,
                  state.timeOptions,
                  state.selectedTimeId,
                  'Any',
                ),
                onTap: () async {
                  await showQuickFixOptionSheet(
                    context: context,
                    title: t.get('quick_fix_time_title', fallback: 'Time'),
                    options: state.timeOptions,
                    selectedIds: {state.selectedTimeId},
                    multiSelect: false,
                    onApply: (ids) {
                      if (ids.isNotEmpty) {
                        controller.selectTime(ids.first);
                      }
                    },
                  );
                },
              ),
              QuickFixFilterField(
                icon: Icons.place_outlined,
                label: t.get('quick_fix_location_title', fallback: 'Location'),
                value: _multiSummary(
                  context,
                  state.locations,
                  state.selectedLocationIds.toSet(),
                  'Any',
                ),
                onTap: () async {
                  await showQuickFixOptionSheet(
                    context: context,
                    title: t.get('quick_fix_location_title', fallback: 'Location'),
                    options: state.locations,
                    selectedIds: state.selectedLocationIds.toSet(),
                    multiSelect: true,
                    onApply: (ids) {
                      final current = state.selectedLocationIds.toSet();
                      for (final id in current.difference(ids)) {
                        controller.toggleLocation(id);
                      }
                      for (final id in ids.difference(current)) {
                        controller.toggleLocation(id);
                      }
                    },
                  );
                },
              ),
              QuickFixFilterField(
                icon: Icons.battery_charging_full_rounded,
                label: t.get('quick_fix_energy_title', fallback: 'Energy'),
                value: _singleSummary(
                  context,
                  state.energyOptions,
                  state.selectedEnergyId,
                  'Any',
                ),
                onTap: () async {
                  await showQuickFixOptionSheet(
                    context: context,
                    title: t.get('quick_fix_energy_title', fallback: 'Energy'),
                    options: state.energyOptions,
                    selectedIds: {state.selectedEnergyId},
                    multiSelect: false,
                    onApply: (ids) {
                      if (ids.isNotEmpty) {
                        controller.selectEnergy(ids.first);
                      }
                    },
                  );
                },
              ),
              QuickFixFilterField(
                icon: Icons.tune_rounded,
                label: t.get('quick_fix_mode_title', fallback: 'Mode'),
                value: _multiSummary(
                  context,
                  state.modes,
                  state.selectedModeIds.toSet(),
                  'Any',
                ),
                onTap: () async {
                  await showQuickFixOptionSheet(
                    context: context,
                    title: t.get('quick_fix_mode_title', fallback: 'Mode'),
                    options: state.modes,
                    selectedIds: state.selectedModeIds.toSet(),
                    multiSelect: true,
                    onApply: (ids) {
                      final current = state.selectedModeIds.toSet();
                      for (final id in current.difference(ids)) {
                        controller.toggleMode(id);
                      }
                      for (final id in ids.difference(current)) {
                        controller.toggleMode(id);
                      }
                    },
                  );
                },
              ),
              QuickFixFilterField.toggle(
                icon: state.silentModeEnabled
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                label: t.get(
                  'quick_fix_silent_mode_title',
                  fallback: 'Silent Mode',
                ),
                value: state.silentModeEnabled
                    ? t.get('common_on', fallback: 'On')
                    : t.get('common_off', fallback: 'Off'),
                selected: state.silentModeEnabled,
                onTap: () => controller.setSilentMode(!state.silentModeEnabled),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickFixRecommendationColumn extends ConsumerWidget {
  const _QuickFixRecommendationColumn({
    required this.state,
  });

  final QuickFixState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppText.of(context);
    final accessAsync = ref.watch(accessSnapshotProvider);

    final accessSnapshot = accessAsync.maybeWhen(
      data: (value) => value,
      orElse: () => AccessSnapshot.guest,
    );

    final accessDecision = AccessPolicy.canAccessFeature(
      snapshot: accessSnapshot,
      feature: LockedFeature.quickFixFullAccess,
    );

    if (accessAsync.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (!accessDecision.allowed) {
      return LockedFeatureCard(
        title: t.get(
          'quick_fix_locked_title',
          fallback: 'Full Quick Fix recommendations are part of Core Access',
        ),
        message: t.get(
          'quick_fix_locked_message',
          fallback:
              'Use the selector for free, then unlock Core once to open the complete recommendation output, alternatives, and direct recovery flow.',
        ),
        icon: Icons.flash_on_rounded,
        compact: true,
        onUpgrade: () => context.pushNamed('premium'),
      );
    }

    return QuickFixRecommendationPreview(
      recommendation: state.primaryRecommendation,
      alternatives: state.alternativeRecommendations,
      emphasize: state.hasUserInteracted,
      compact: true,
    );
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    t.get(
                      'quick_fix_error_title',
                      fallback: 'Unable to load Quick Fix',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.get(
                      'quick_fix_error_body',
                      fallback: 'Please try again.',
                    ),
                    textAlign: TextAlign.center,
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