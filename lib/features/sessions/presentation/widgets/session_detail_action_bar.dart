// lib/features/sessions/presentation/widgets/session_detail_action_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class SessionDetailActionBar extends StatelessWidget {
  const SessionDetailActionBar({
    super.key,
    required this.onStartPressed,
    this.onSavePressed,
    this.isSaved = false,
    this.isSaving = false,
    this.requiresSignInHint = false,
    this.isLocked = false,
    this.startLabel,
  });

  final VoidCallback onStartPressed;
  final VoidCallback? onSavePressed;
  final bool isSaved;
  final bool isSaving;
  final bool requiresSignInHint;
  final bool isLocked;
  final String? startLabel;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 560;

            final startButton = FilledButton.icon(
              onPressed: onStartPressed,
              icon: Icon(isLocked ? Icons.lock_outline : Icons.play_arrow),
              label: Text(
                startLabel ??
                    t.get('session_detail_start_cta', fallback: 'Start Session'),
              ),
            );

            final saveButton = OutlinedButton.icon(
              onPressed: isSaving ? null : onSavePressed,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
              label: Text(
                isSaving
                    ? t.get('session_detail_saving_cta', fallback: 'Saving...')
                    : isSaved
                        ? t.get('session_detail_saved_cta', fallback: 'Saved')
                        : t.get('session_detail_save_cta', fallback: 'Save'),
              ),
            );

            final buttons = isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      startButton,
                      const SizedBox(height: 12),
                      saveButton,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: startButton),
                      const SizedBox(width: 12),
                      saveButton,
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buttons,
                if (requiresSignInHint) ...[
                  const SizedBox(height: 12),
                  Text(
                    t.get(
                      'session_detail_save_requires_account_hint',
                      fallback: 'Saving requires sign-in.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}