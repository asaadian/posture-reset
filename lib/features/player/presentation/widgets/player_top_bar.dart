// lib/features/player/presentation/widgets/player_top_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({
    super.key,
    required this.sessionTitle,
    required this.stepLabel,
    required this.onClosePressed,
    this.isCompleted = false,
  });

  final String sessionTitle;
  final String stepLabel;
  final VoidCallback onClosePressed;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onClosePressed,
              tooltip: t.get('player_close_tooltip', fallback: 'Close player'),
              icon: const Icon(Icons.close),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    sessionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted
                        ? t.get(
                            'player_status_completed',
                            fallback: 'Completed',
                          )
                        : stepLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}