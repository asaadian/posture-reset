// lib/features/player/presentation/widgets/player_feedback_sheet.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_feedback_models.dart';

class PlayerPreSessionStateSheet extends StatefulWidget {
  const PlayerPreSessionStateSheet({
    super.key,
    required this.onSubmit,
    required this.initialEntrySource,
  });

  final Future<void> Function(SessionStateSnapshotInput input) onSubmit;
  final SessionEntrySource initialEntrySource;

  @override
  State<PlayerPreSessionStateSheet> createState() =>
      _PlayerPreSessionStateSheetState();
}

class _PlayerPreSessionStateSheetState extends State<PlayerPreSessionStateSheet> {
  SessionStateLevel _energy = SessionStateLevel.medium;
  SessionStateLevel _stress = SessionStateLevel.medium;
  SessionStateLevel _focus = SessionStateLevel.medium;
  SessionIntentCode _intent = SessionIntentCode.relief;
  final List<String> _painAreas = <String>['neck'];
  bool _isSubmitting = false;

  bool _expandSignals = true;
  bool _expandIntent = false;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.get(
                    'player_pre_state_title',
                    fallback: 'Quick check-in before you start',
                  ),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  t.get(
                    'player_pre_state_subtitle',
                    fallback:
                        'Capture a few signals before this session so progress and outcomes can be tracked better.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _ExpandableSheetSection(
                  title: t.get(
                    'player_pre_state_signals_section',
                    fallback: 'Current signals',
                  ),
                  expanded: _expandSignals,
                  onTap: () =>
                      setState(() => _expandSignals = !_expandSignals),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_energy_title',
                          fallback: 'Energy',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _energy,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) => setState(() => _energy = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_stress_title',
                          fallback: 'Stress',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _stress,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) => setState(() => _stress = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_focus_title',
                          fallback: 'Focus',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _focus,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) => setState(() => _focus = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ExpandableSheetSection(
                  title: t.get(
                    'player_pre_state_intent_section',
                    fallback: 'Intent & pain areas',
                  ),
                  expanded: _expandIntent,
                  onTap: () => setState(() => _expandIntent = !_expandIntent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_intent_title',
                          fallback: 'Intent',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SessionIntentCode.values.map((intent) {
                          final selected = _intent == intent;
                          return ChoiceChip(
                            selected: selected,
                            label: Text(_intentLabel(context, intent)),
                            onSelected: (_) => setState(() => _intent = intent),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_pain_areas_title',
                          fallback: 'Pain areas',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _painOptions(context).map((item) {
                          final selected = _painAreas.contains(item.$1);
                          return FilterChip(
                            selected: selected,
                            label: Text(item.$2),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  if (!_painAreas.contains(item.$1)) {
                                    _painAreas.add(item.$1);
                                  }
                                } else {
                                  _painAreas.remove(item.$1);
                                }

                                if (_painAreas.isEmpty) {
                                  _painAreas.add('neck');
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          t.get(
                            'player_pre_state_skip',
                            fallback: 'Skip for now',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
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
                              },
                        child: Text(
                          t.get(
                            'player_pre_state_start_cta',
                            fallback: 'Start session',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  });

  final String sessionTitle;
  final int totalSteps;
  final int totalElapsedSeconds;
  final bool isAbandoned;
  final Future<void> Function(PlayerPostSessionResult result) onSubmit;
  final SessionEntrySource initialEntrySource;

  @override
  State<PlayerPostSessionFeedbackSheet> createState() =>
      _PlayerPostSessionFeedbackSheetState();
}

class _PlayerPostSessionFeedbackSheetState
    extends State<PlayerPostSessionFeedbackSheet> {
  bool _helped = true;
  bool _wouldRepeat = true;
  SessionDelta _tension = SessionDelta.better;
  SessionDelta _pain = SessionDelta.better;
  SessionDelta _energyDelta = SessionDelta.better;
  SessionPerceivedFit _fit = SessionPerceivedFit.great;

  SessionStateLevel _afterEnergy = SessionStateLevel.medium;
  SessionStateLevel _afterStress = SessionStateLevel.medium;
  SessionStateLevel _afterFocus = SessionStateLevel.medium;
  final List<String> _afterPainAreas = <String>['neck'];

  bool _isSubmitting = false;

  bool _expandQuickFeedback = true;
  bool _expandSessionFit = false;
  bool _expandAfterState = false;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  sessionTitle: widget.sessionTitle,
                  totalSteps: widget.totalSteps,
                  totalElapsedSeconds: widget.totalElapsedSeconds,
                  isAbandoned: widget.isAbandoned,
                ),
                const SizedBox(height: 16),
                Text(
                  t.get(
                    widget.isAbandoned
                        ? 'player_feedback_abandoned_title'
                        : 'player_feedback_title',
                    fallback: widget.isAbandoned
                        ? 'Before you leave, how did this session feel?'
                        : 'How did this session feel?',
                  ),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 14),

                _ExpandableSheetSection(
                  title: t.get(
                    'player_feedback_quick_section',
                    fallback: 'Quick feedback',
                  ),
                  expanded: _expandQuickFeedback,
                  onTap: () => setState(
                    () => _expandQuickFeedback = !_expandQuickFeedback,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_helped_title',
                          fallback: 'Did this help?',
                        ),
                      ),
                      _BoolSelector(
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
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_tension_title',
                          fallback: 'Tension',
                        ),
                      ),
                      _DeltaSelector(
                        value: _tension,
                        onChanged: (value) => setState(() => _tension = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_pain_title',
                          fallback: 'Pain',
                        ),
                      ),
                      _DeltaSelector(
                        value: _pain,
                        onChanged: (value) => setState(() => _pain = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_energy_title',
                          fallback: 'Energy',
                        ),
                      ),
                      _DeltaSelector(
                        value: _energyDelta,
                        onChanged: (value) =>
                            setState(() => _energyDelta = value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _ExpandableSheetSection(
                  title: t.get(
                    'player_feedback_fit_section',
                    fallback: 'Session fit',
                  ),
                  expanded: _expandSessionFit,
                  onTap: () =>
                      setState(() => _expandSessionFit = !_expandSessionFit),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_fit_title',
                          fallback: 'Session fit',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SessionPerceivedFit.values.map((fit) {
                          return ChoiceChip(
                            selected: _fit == fit,
                            label: Text(_fitLabel(context, fit)),
                            onSelected: (_) => setState(() => _fit = fit),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_feedback_repeat_title',
                          fallback: 'Would you repeat this session?',
                        ),
                      ),
                      _BoolSelector(
                        value: _wouldRepeat,
                        trueLabel: t.get(
                          'player_feedback_repeat_yes',
                          fallback: 'Would repeat',
                        ),
                        falseLabel: t.get(
                          'player_feedback_repeat_no',
                          fallback: 'Not likely',
                        ),
                        onChanged: (value) =>
                            setState(() => _wouldRepeat = value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _ExpandableSheetSection(
                  title: t.get(
                    'player_after_state_title',
                    fallback: 'How do you feel now?',
                  ),
                  expanded: _expandAfterState,
                  onTap: () =>
                      setState(() => _expandAfterState = !_expandAfterState),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_energy_title',
                          fallback: 'Energy',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _afterEnergy,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) =>
                            setState(() => _afterEnergy = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_stress_title',
                          fallback: 'Stress',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _afterStress,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) =>
                            setState(() => _afterStress = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_pre_state_focus_title',
                          fallback: 'Focus',
                        ),
                      ),
                      _LevelSelector<SessionStateLevel>(
                        value: _afterFocus,
                        items: SessionStateLevel.values,
                        labelBuilder: (value) => _stateLevelLabel(context, value),
                        onChanged: (value) =>
                            setState(() => _afterFocus = value),
                      ),
                      const SizedBox(height: 14),
                      _SectionTitle(
                        title: t.get(
                          'player_after_state_pain_areas_title',
                          fallback: 'Pain areas now',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _painOptions(context).map((item) {
                          final selected = _afterPainAreas.contains(item.$1);
                          return FilterChip(
                            selected: selected,
                            label: Text(item.$2),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  if (!_afterPainAreas.contains(item.$1)) {
                                    _afterPainAreas.add(item.$1);
                                  }
                                } else {
                                  _afterPainAreas.remove(item.$1);
                                }

                                if (_afterPainAreas.isEmpty) {
                                  _afterPainAreas.add('neck');
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          t.get(
                            'player_feedback_close',
                            fallback: 'Close',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                setState(() => _isSubmitting = true);
                                try {
                                  final navigator = Navigator.of(context);

                                  final feedback = SessionFeedbackInput(
                                    completionStatus: widget.isAbandoned
                                        ? SessionFeedbackCompletionStatus
                                            .abandoned
                                        : SessionFeedbackCompletionStatus
                                            .completed,
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
                                  navigator.pop();
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                }
                              },
                        child: Text(
                          t.get(
                            'player_feedback_submit',
                            fallback: 'Save feedback',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableSheetSection extends StatelessWidget {
  const _ExpandableSheetSection({
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.sessionTitle,
    required this.totalSteps,
    required this.totalElapsedSeconds,
    required this.isAbandoned,
  });

  final String sessionTitle;
  final int totalSteps;
  final int totalElapsedSeconds;
  final bool isAbandoned;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                isAbandoned
                    ? Icons.exit_to_app_rounded
                    : Icons.check_circle_outline_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAbandoned
                        ? t.get(
                            'player_feedback_abandoned_summary_title',
                            fallback: 'Session ended early',
                          )
                        : t.get(
                            'player_feedback_summary_title',
                            fallback: 'Session summary',
                          ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sessionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalSteps ${t.get('player_completion_steps', fallback: 'Steps')} • ${_formatDuration(totalElapsedSeconds)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _BoolSelector extends StatelessWidget {
  const _BoolSelector({
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: value,
          label: Text(trueLabel),
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          selected: !value,
          label: Text(falseLabel),
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}

class _DeltaSelector extends StatelessWidget {
  const _DeltaSelector({
    required this.value,
    required this.onChanged,
  });

  final SessionDelta value;
  final ValueChanged<SessionDelta> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SessionDelta.values.map((delta) {
        return ChoiceChip(
          selected: value == delta,
          label: Text(_deltaLabel(context, delta)),
          onSelected: (_) => onChanged(delta),
        );
      }).toList(),
    );
  }
}

class _LevelSelector<T> extends StatelessWidget {
  const _LevelSelector({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return ChoiceChip(
          selected: value == item,
          label: Text(labelBuilder(item)),
          onSelected: (_) => onChanged(item),
        );
      }).toList(),
    );
  }
}

List<(String, String)> _painOptions(BuildContext context) {
  return [
    ('neck', AppText.get(context, key: 'pain_neck', fallback: 'Neck')),
    ('shoulders', AppText.get(context, key: 'pain_shoulders', fallback: 'Shoulders')),
    ('upper_back', AppText.get(context, key: 'pain_upper_back', fallback: 'Upper back')),
    ('lower_back', AppText.get(context, key: 'pain_lower_back', fallback: 'Lower back')),
    ('wrists', AppText.get(context, key: 'pain_wrists', fallback: 'Wrists')),
  ];
}

String _stateLevelLabel(BuildContext context, SessionStateLevel value) {
  switch (value) {
    case SessionStateLevel.low:
      return AppText.get(context, key: 'common_level_low', fallback: 'Low');
    case SessionStateLevel.medium:
      return AppText.get(context, key: 'common_level_medium', fallback: 'Medium');
    case SessionStateLevel.high:
      return AppText.get(context, key: 'common_level_high', fallback: 'High');
  }
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
      return AppText.get(context, key: 'common_delta_better', fallback: 'Better');
  }
}

String _fitLabel(BuildContext context, SessionPerceivedFit value) {
  switch (value) {
    case SessionPerceivedFit.poor:
      return AppText.get(context, key: 'common_fit_poor', fallback: 'Poor');
    case SessionPerceivedFit.okay:
      return AppText.get(context, key: 'common_fit_okay', fallback: 'Okay');
    case SessionPerceivedFit.great:
      return AppText.get(context, key: 'common_fit_great', fallback: 'Great');
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}