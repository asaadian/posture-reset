// lib/features/body_map/presentation/widgets/body_map_toggle_card.dart

import 'package:flutter/material.dart';

import '../../domain/body_map_models.dart';

class BodyMapToggleCard extends StatelessWidget {
  const BodyMapToggleCard({
    super.key,
    required this.side,
    required this.onChanged,
  });

  final BodyMapSide side;
  final ValueChanged<BodyMapSide> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: SegmentedButton<BodyMapSide>(
        segments: const [
          ButtonSegment<BodyMapSide>(
            value: BodyMapSide.front,
            icon: Icon(Icons.person_outline_rounded),
            label: Text('Front'),
          ),
          ButtonSegment<BodyMapSide>(
            value: BodyMapSide.back,
            icon: Icon(Icons.accessibility_new_rounded),
            label: Text('Back'),
          ),
        ],
        selected: {side},
        onSelectionChanged: (selection) {
          onChanged(selection.first);
        },
      ),
    );
  }
}