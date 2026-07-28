// lib/features/player/presentation/widgets/player_feedback_sheet.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_feedback_models.dart';

class PlayerPreSessionStateSheet extends StatefulWidget {
  const PlayerPreSessionStateSheet({
    super.key,
    required this.onSubmit,
    required this.initialEntrySource,
    this.initialPainAreaCodes = const <String>[],
  });

  final Future<void> Function(SessionStateSnapshotInput input) onSubmit;
  final SessionEntrySource initialEntrySource;
  final List<String> initialPainAreaCodes;

  @override
  State<PlayerPreSessionStateSheet> createState() =>
      _PlayerPreSessionStateSheetState();
}

class _PlayerPreSessionStateSheetState extends State<PlayerPreSessionStateSheet> {
  final SessionStateLevel _energy = SessionStateLevel.medium;
  final SessionStateLevel _stress = SessionStateLevel.medium;
  final SessionStateLevel _focus = SessionStateLevel.medium;
  SessionIntentCode _intent = SessionIntentCode.relief;
  late List<String> _painAreas;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _painAreas = _safePainAreaCodes(widget.initialPainAreaCodes);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return _FeedbackSheetScaffold(
      title: t.get(
        'player_pre_state_title',
        fallback: 'Quick check-in',
      ),
      subtitle: t.get(
        'player_pre_state_subtitle_compact',
        fallback: 'Set your starting point. This takes a few seconds.',
      ),
      icon: Icons.tune_rounded,
      primaryLabel: t.get(
        'player_pre_state_start_cta',
        fallback: 'Start session',
      ),
      secondaryLabel: t.get(
        'player_pre_state_skip',
        fallback: 'Skip',
      ),
      isSubmitting: _isSubmitting,
      onSecondaryPressed: () => Navigator.of(context).pop(),
      onPrimaryPressed: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactSectionLabel(
            label: t.get(
              'player_pre_state_pain_areas_title',
              fallback: 'Focus area',
            ),
          ),
          const SizedBox(height: 8),
          _PainAreaRail(
            selected: _painAreas,
            onChanged: _togglePainArea,
          ),
          const SizedBox(height: 12),
          _CompactSectionLabel(
            label: t.get(
              'player_pre_state_intent_title',
              fallback: 'Intent',
            ),
          ),
          const SizedBox(height: 8),
          _HorizontalChoiceRail<SessionIntentCode>(
            value: _intent,
            values: SessionIntentCode.values,
            labelBuilder: (value) => _intentLabel(context, value),
            onChanged: (value) => setState(() => _intent = value),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final navigator = Navigator.of(context);

      await widget.onSubmit(
        SessionStateSnapshotInput(
          energyLevel: _energy,
          stressLevel: _stress,
          focusLevel: _focus,
          painAreaCodes: _painAreas,
          intentCode: _intent,
          entrySource: widget.initialEntrySource,
        ),
      );

      if (!mounted) return;
      navigator.pop();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _togglePainArea(String code, bool selected) {
    setState(() {
      if (selected) {
        if (!_painAreas.contains(code)) {
          _painAreas.add(code);
        }
      } else {
        _painAreas.remove(code);
      }

      if (_painAreas.isEmpty) {
        _painAreas.add(_fallbackPainAreaCode);
      }
    });
  }
}

class PlayerPostSessionFeedbackSheet extends StatefulWidget {
  const PlayerPostSessionFeedbackSheet({
    super.key,
    required this.sessionTitle,
    required this.totalSteps,
    required this.totalElapsedSeconds,
    required this.isAbandoned,
    required this.onSubmit,
    required this.initialEntrySource,
    this.initialPainAreaCodes = const <String>[],
  });

  final String sessionTitle;
  final int totalSteps;
  final int totalElapsedSeconds;
  final bool isAbandoned;
  final Future<void> Function(PlayerPostSessionResult result) onSubmit;
  final SessionEntrySource initialEntrySource;
  final List<String> initialPainAreaCodes;

  @override
  State<PlayerPostSessionFeedbackSheet> createState() =>
      _PlayerPostSessionFeedbackSheetState();
}

class _PlayerPostSessionFeedbackSheetState
    extends State<PlayerPostSessionFeedbackSheet> {
  bool _helped = true;
  final bool _wouldRepeat = true;

  SessionDelta _tension = SessionDelta.better;
  SessionDelta _pain = SessionDelta.better;
  final SessionDelta _energyDelta = SessionDelta.better;
  final SessionPerceivedFit _fit = SessionPerceivedFit.great;

  final SessionStateLevel _afterEnergy = SessionStateLevel.medium;
  final SessionStateLevel _afterStress = SessionStateLevel.medium;
  final SessionStateLevel _afterFocus = SessionStateLevel.medium;
  late final List<String> _afterPainAreas;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _afterPainAreas = _safePainAreaCodes(widget.initialPainAreaCodes);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return _FeedbackSheetScaffold(
      title: t.get(
        widget.isAbandoned
            ? 'player_feedback_abandoned_title'
            : 'player_feedback_title_compact',
        fallback: widget.isAbandoned
            ? 'Before you leave'
            : 'How did it feel?',
      ),
      subtitle: t.get(
        'player_feedback_subtitle_compact',
        fallback: 'One quick tap helps tune your next recommendation.',
      ),
      icon: widget.isAbandoned
          ? Icons.exit_to_app_rounded
          : Icons.check_circle_outline_rounded,
      primaryLabel: t.get(
        'player_feedback_submit',
        fallback: 'Save feedback',
      ),
      secondaryLabel: t.get(
        'player_feedback_close',
        fallback: 'Close',
      ),
      isSubmitting: _isSubmitting,
      onSecondaryPressed: () => Navigator.of(context).pop(),
      onPrimaryPressed: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _MiniQuestionCard(
            icon: Icons.favorite_border_rounded,
            title: t.get(
              'player_feedback_helped_title',
              fallback: 'Did this help?',
            ),
            child: _BoolSegment(
              value: _helped,
              trueLabel: t.get(
                'player_feedback_yes',
                fallback: 'Yes',
              ),
              falseLabel: t.get(
                'player_feedback_no',
                fallback: 'No',
              ),
              onChanged: (value) => setState(() => _helped = value),
            ),
          ),
          const SizedBox(height: 8),
          _DeltaRow(
            icon: Icons.compress_rounded,
            title: t.get(
              'player_feedback_tension_title',
              fallback: 'Tension',
            ),
            value: _tension,
            onChanged: (value) => setState(() => _tension = value),
          ),
          const SizedBox(height: 8),
          _DeltaRow(
            icon: Icons.healing_outlined,
            title: t.get(
              'player_feedback_pain_title',
              fallback: 'Pain',
            ),
            value: _pain,
            onChanged: (value) => setState(() => _pain = value),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final navigator = Navigator.of(context);

      final feedback = SessionFeedbackInput(
        completionStatus: widget.isAbandoned
            ? SessionFeedbackCompletionStatus.abandoned
            : SessionFeedbackCompletionStatus.completed,
        helped: _helped,
        tensionDelta: _tension,
        painDelta: _pain,
        energyDelta: _energyDelta,
        perceivedFit: _fit,
        wouldRepeat: _wouldRepeat,
        entrySource: widget.initialEntrySource,
      );

      final afterState = SessionStateSnapshotInput(
        energyLevel: _afterEnergy,
        stressLevel: _afterStress,
        focusLevel: _afterFocus,
        painAreaCodes: _afterPainAreas,
        intentCode: SessionIntentCode.relief,
        entrySource: widget.initialEntrySource,
      );

      await widget.onSubmit(
        PlayerPostSessionResult(
          feedback: feedback,
          afterState: afterState,
        ),
      );

      if (!mounted) return;
      navigator.pop(true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _FeedbackSheetScaffold extends StatelessWidget {
  const _FeedbackSheetScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isSubmitting,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final String primaryLabel;
  final String secondaryLabel;
  final bool isSubmitting;
  final Future<void> Function() onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SheetHandle(),
                    const SizedBox(height: 10),
                    _CompactHeader(
                      icon: icon,
                      title: title,
                      subtitle: subtitle,
                    ),
                    const SizedBox(height: 12),
                    child,
                    const SizedBox(height: 14),
                    _SheetActionRow(
                      primaryLabel: primaryLabel,
                      secondaryLabel: secondaryLabel,
                      isSubmitting: isSubmitting,
                      onPrimaryPressed: onPrimaryPressed,
                      onSecondaryPressed: onSecondaryPressed,
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.outlineVariant.withValues(alpha: 0.70),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.72)
            : colors.surfaceContainerLow.withValues(alpha: 0.92),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.70 : 0.56),
        ),
      ),
      child: Row(
        children: [
          _RoundIconBadge(
            icon: icon,
            color: colors.primary,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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

class _CompactSectionLabel extends StatelessWidget {
  const _CompactSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _MiniQuestionCard extends StatelessWidget {
  const _MiniQuestionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? colors.surfaceContainerHigh.withValues(alpha: 0.54)
            : Colors.white.withValues(alpha: 0.92),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.66 : 0.54),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colors.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final SessionDelta value;
  final ValueChanged<SessionDelta> onChanged;

  @override
  Widget build(BuildContext context) {
    return _MiniQuestionCard(
      icon: icon,
      title: title,
      child: _SegmentedSelector<SessionDelta>(
        value: value,
        values: SessionDelta.values,
        labelBuilder: (delta) => _deltaLabel(context, delta),
        onChanged: onChanged,
      ),
    );
  }
}

class _BoolSegment extends StatelessWidget {
  const _BoolSegment({
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  final bool value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SegmentedSelector<bool>(
      value: value,
      values: const [true, false],
      labelBuilder: (item) => item ? trueLabel : falseLabel,
      onChanged: onChanged,
    );
  }
}

class _SegmentedSelector<T> extends StatelessWidget {
  const _SegmentedSelector({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.surfaceContainerLow.withValues(alpha: 0.72),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.50),
        ),
      ),
      child: Row(
        children: values.map((item) {
          final selected = value == item;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected ? colors.primary : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: colors.onPrimary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        labelBuilder(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: selected
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                              fontWeight:
                                  selected ? FontWeight.w900 : FontWeight.w700,
                              height: 1.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HorizontalChoiceRail<T> extends StatelessWidget {
  const _HorizontalChoiceRail({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = values[index];
          final selected = value == item;

          return _CompactChoicePill(
            label: labelBuilder(item),
            selected: selected,
            onTap: () => onChanged(item),
          );
        },
      ),
    );
  }
}

class _PainAreaRail extends StatelessWidget {
  const _PainAreaRail({
    required this.selected,
    required this.onChanged,
  });

  final List<String> selected;
  final void Function(String code, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final items = _painOptions(context);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected.contains(item.$1);

          return _CompactChoicePill(
            label: item.$2,
            selected: isSelected,
            onTap: () => onChanged(item.$1, !isSelected),
          );
        },
      ),
    );
  }
}

class _CompactChoicePill extends StatelessWidget {
  const _CompactChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? colors.primary
              : colors.surfaceContainerLow.withValues(alpha: 0.74),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.64)
                : colors.outlineVariant.withValues(alpha: 0.56),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check_rounded,
                size: 15,
                color: colors.onPrimary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconBadge extends StatelessWidget {
  const _RoundIconBadge({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.24 : 0.16),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.48,
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isSubmitting,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final bool isSubmitting;
  final Future<void> Function() onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        TextButton(
          onPressed: isSubmitting ? null : onSecondaryPressed,
          child: Text(
            secondaryLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: isSubmitting ? null : onPrimaryPressed,
            child: isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : Text(primaryLabel),
          ),
        ),
      ],
    );
  }
}


const String _fallbackPainAreaCode = 'neck';

List<String> _safePainAreaCodes(List<String> rawCodes) {
  final normalized = <String>[];
  for (final raw in rawCodes) {
    final code = _canonicalPainAreaCode(raw);
    if (code.isEmpty) continue;
    if (!normalized.contains(code)) normalized.add(code);
  }
  if (normalized.isEmpty) normalized.add(_fallbackPainAreaCode);
  return normalized;
}

String _canonicalPainAreaCode(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'neck':
    case 'cervical':
      return 'neck';
    case 'shoulder':
    case 'shoulders':
    case 'scapula':
    case 'scapular':
      return 'shoulders';
    case 'upper_back':
    case 'upper back':
    case 'thoracic':
    case 'chest':
      return 'upper_back';
    case 'back':
    case 'lower_back':
    case 'low_back':
    case 'lower back':
    case 'lumbar':
    case 'core':
      return 'lower_back';
    case 'hip':
    case 'hips':
    case 'glute':
    case 'glutes':
    case 'hips_glutes':
    case 'hamstring':
    case 'hamstrings':
      return 'hips_glutes';
    case 'forearm':
    case 'forearms':
    case 'mouse_arm':
      return 'forearms';
    case 'wrist':
    case 'wrists':
      return 'wrists';
    case 'hand':
    case 'hands':
    case 'finger':
    case 'fingers':
      return 'hands';
    case 'eye':
    case 'eyes':
      return 'eyes';
    default:
      return raw.trim().toLowerCase();
  }
}

List<(String, String)> _painOptions(BuildContext context) {
  return [
    ('neck', AppText.get(context, key: 'pain_neck', fallback: 'Neck')),
    (
      'shoulders',
      AppText.get(context, key: 'pain_shoulders', fallback: 'Shoulders'),
    ),
    (
      'upper_back',
      AppText.get(context, key: 'pain_upper_back', fallback: 'Upper back'),
    ),
    (
      'lower_back',
      AppText.get(context, key: 'pain_lower_back', fallback: 'Lower back'),
    ),
    (
      'hips_glutes',
      AppText.get(context, key: 'pain_hips_glutes', fallback: 'Hips & Glutes'),
    ),
    (
      'forearms',
      AppText.get(context, key: 'pain_forearms', fallback: 'Forearms'),
    ),
    (
      'hands',
      AppText.get(context, key: 'pain_hands', fallback: 'Hands'),
    ),
    ('wrists', AppText.get(context, key: 'pain_wrists', fallback: 'Wrists')),
    ('eyes', AppText.get(context, key: 'pain_eyes', fallback: 'Eyes')),
  ];
}

String _intentLabel(BuildContext context, SessionIntentCode value) {
  switch (value) {
    case SessionIntentCode.relief:
      return AppText.get(context, key: 'intent_relief', fallback: 'Relief');
    case SessionIntentCode.reset:
      return AppText.get(context, key: 'intent_reset', fallback: 'Reset');
    case SessionIntentCode.focus:
      return AppText.get(context, key: 'intent_focus', fallback: 'Focus');
    case SessionIntentCode.unwind:
      return AppText.get(context, key: 'intent_unwind', fallback: 'Unwind');
  }
}

String _deltaLabel(BuildContext context, SessionDelta value) {
  switch (value) {
    case SessionDelta.worse:
      return AppText.get(context, key: 'common_delta_worse', fallback: 'Worse');
    case SessionDelta.same:
      return AppText.get(context, key: 'common_delta_same', fallback: 'Same');
    case SessionDelta.better:
      return AppText.get(
        context,
        key: 'common_delta_better',
        fallback: 'Better',
      );
  }
}

