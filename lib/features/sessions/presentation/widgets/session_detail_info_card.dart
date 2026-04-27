// lib/features/sessions/presentation/widgets/session_detail_info_card.dart
import 'package:flutter/material.dart';

class SessionDetailInfoCard extends StatelessWidget {
  const SessionDetailInfoCard({
    super.key,
    required this.title,
    required this.lines,
    this.icon,
  });

  final String title;
  final List<String> lines;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleLines = lines.where((line) => line.trim().isNotEmpty).toList();

    if (visibleLines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...visibleLines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              final isLast = index == visibleLines.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(line)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}