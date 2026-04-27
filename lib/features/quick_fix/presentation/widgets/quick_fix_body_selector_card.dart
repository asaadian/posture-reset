// lib/features/quick_fix/presentation/widgets/quick_fix_body_selector_card.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/quick_fix_state.dart';

class QuickFixBodySelectorCard extends StatefulWidget {
  const QuickFixBodySelectorCard({
    super.key,
    required this.options,
    required this.selectedProblemId,
    required this.onProblemSelected,
  });

  final List<QuickFixOption> options;
  final String selectedProblemId;
  final ValueChanged<String> onProblemSelected;

  @override
  State<QuickFixBodySelectorCard> createState() =>
      _QuickFixBodySelectorCardState();
}

class _QuickFixBodySelectorCardState extends State<QuickFixBodySelectorCard> {
  _QuickFixBodySide _side = _QuickFixBodySide.back;

  static const double _imageAspectRatio = 654 / 1350;
  static const double _globalYOffset = -0.045;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imagePath = _side == _QuickFixBodySide.front
        ? 'assets/images/body_map/front.png'
        : 'assets/images/body_map/back.png';

    final visibleHotspots = widget.options
        .expand(
          (option) => _placementsForOption(option, _side)
              .map((placement) => (option: option, placement: placement)),
        )
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
                child: Text(
                  t.get(
                    'quick_fix_pain_selector_title',
                    fallback: 'Where do you feel it?',
                  ),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              _SideToggle(
                side: _side,
                onChanged: (value) {
                  setState(() {
                    _side = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              t.get(
                'quick_fix_pain_selector_body',
                fallback: 'Tap a glowing point to target the match.',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 360,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final availableHeight = constraints.maxHeight;

                double artboardWidth = availableWidth;
                double artboardHeight = artboardWidth / _imageAspectRatio;

                if (artboardHeight > availableHeight) {
                  artboardHeight = availableHeight;
                  artboardWidth = artboardHeight * _imageAspectRatio;
                }

                return Center(
                  child: SizedBox(
                    width: artboardWidth,
                    height: artboardHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        ...visibleHotspots.map((entry) {
                          final option = entry.option;
                          final placement = entry.placement;
                          final selected = widget.selectedProblemId == option.id;

                          return _QuickFixBodyHotspot(
                            alignment: _alignmentFromNormalized(
                              placement.dotX,
                              placement.dotY + _globalYOffset,
                            ),
                            isSelected: selected,
                            onTap: () => widget.onProblemSelected(option.id),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.options.map((option) {
                final selected = widget.selectedProblemId == option.id;

                return FilterChip(
                  selected: selected,
                  onSelected: (_) {
                    widget.onProblemSelected(option.id);

                    final preferredSide = _preferredSideForOption(option);
                    if (preferredSide != null && preferredSide != _side) {
                      setState(() {
                        _side = preferredSide;
                      });
                    }
                  },
                  label: Text(
                    t.get(option.labelKey, fallback: option.labelFallback),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_QuickFixHotspotPlacement> _placementsForOption(
    QuickFixOption option,
    _QuickFixBodySide side,
  ) {
    final token = _tokenize(option);
    final preferredSide = _preferredSideForOption(option);

    if (preferredSide != side) {
      return const [];
    }

    if (side == _QuickFixBodySide.front) {
      if (_hasAny(token, const ['eye', 'eyes', 'head', 'focus', 'screen'])) {
        return const [
          _QuickFixHotspotPlacement(dotX: 0.50, dotY: 0.045),
        ];
      }

      if (_hasAny(
        token,
        const ['wrist', 'wrists', 'hand', 'hands', 'forearm'],
      )) {
        return const [
          _QuickFixHotspotPlacement(dotX: 0.09, dotY: 0.485),
          _QuickFixHotspotPlacement(dotX: 0.91, dotY: 0.485),
        ];
      }

      return const [];
    }

    if (_hasAny(token, const ['neck', 'cervical'])) {
      return const [
        _QuickFixHotspotPlacement(dotX: 0.50, dotY: 0.090),
      ];
    }

    if (_hasAny(token, const ['shoulder', 'shoulders'])) {
      return const [
        _QuickFixHotspotPlacement(dotX: 0.28, dotY: 0.190),
        _QuickFixHotspotPlacement(dotX: 0.72, dotY: 0.190),
      ];
    }

    if (_hasAny(token, const ['upper_back', 'upper back', 'thoracic'])) {
      return const [
        _QuickFixHotspotPlacement(dotX: 0.50, dotY: 0.245),
      ];
    }

    if (_hasAny(token, const ['lower_back', 'lower back', 'lumbar', 'back'])) {
      return const [
        _QuickFixHotspotPlacement(dotX: 0.50, dotY: 0.425),
      ];
    }

    return const [];
  }

  _QuickFixBodySide? _preferredSideForOption(QuickFixOption option) {
    final token = _tokenize(option);

    if (_hasAny(token, const ['eye', 'eyes', 'head', 'focus', 'screen'])) {
      return _QuickFixBodySide.front;
    }

    if (_hasAny(
      token,
      const ['wrist', 'wrists', 'hand', 'hands', 'forearm'],
    )) {
      return _QuickFixBodySide.front;
    }

    if (_hasAny(token, const ['neck', 'cervical'])) {
      return _QuickFixBodySide.back;
    }

    if (_hasAny(token, const ['shoulder', 'shoulders'])) {
      return _QuickFixBodySide.back;
    }

    if (_hasAny(token, const ['upper_back', 'upper back', 'thoracic'])) {
      return _QuickFixBodySide.back;
    }

    if (_hasAny(token, const ['lower_back', 'lower back', 'lumbar', 'back'])) {
      return _QuickFixBodySide.back;
    }

    return null;
  }

  String _tokenize(QuickFixOption option) {
    return [
      option.id,
      option.labelKey,
      option.labelFallback,
      option.iconName,
    ].join(' ').toLowerCase();
  }

  bool _hasAny(String source, List<String> needles) {
    for (final needle in needles) {
      if (source.contains(needle)) return true;
    }
    return false;
  }
}

class _SideToggle extends StatelessWidget {
  const _SideToggle({
    required this.side,
    required this.onChanged,
  });

  final _QuickFixBodySide side;
  final ValueChanged<_QuickFixBodySide> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);

    return SegmentedButton<_QuickFixBodySide>(
      segments: [
        ButtonSegment<_QuickFixBodySide>(
          value: _QuickFixBodySide.front,
          label: Text(t.get('body_map_front', fallback: 'Front')),
          icon: const Icon(Icons.person_outline_rounded),
        ),
        ButtonSegment<_QuickFixBodySide>(
          value: _QuickFixBodySide.back,
          label: Text(t.get('body_map_back', fallback: 'Back')),
          icon: const Icon(Icons.accessibility_new_rounded),
        ),
      ],
      selected: {side},
      onSelectionChanged: (value) => onChanged(value.first),
      showSelectedIcon: false,
    );
  }
}

class _QuickFixBodyHotspot extends StatelessWidget {
  const _QuickFixBodyHotspot({
    required this.alignment,
    required this.isSelected,
    required this.onTap,
  });

  final Alignment alignment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isSelected ? 24 : 16,
              height: isSelected ? 24 : 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.48),
                    blurRadius: isSelected ? 28 : 18,
                    spreadRadius: isSelected ? 6 : 3,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.92),
                  width: isSelected ? 2.8 : 2.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickFixHotspotPlacement {
  const _QuickFixHotspotPlacement({
    required this.dotX,
    required this.dotY,
  });

  final double dotX;
  final double dotY;
}

enum _QuickFixBodySide {
  front,
  back,
}

Alignment _alignmentFromNormalized(double x, double y) {
  return Alignment((x * 2) - 1, (y * 2) - 1);
}