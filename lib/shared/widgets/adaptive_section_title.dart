import 'package:flutter/material.dart';
import '../../core/localization/app_text.dart';

class AdaptiveSectionTitle extends StatelessWidget {
  const AdaptiveSectionTitle({
    super.key,
    required this.titleKey,
    required this.titleFallback,
    this.subtitleKey,
    this.subtitleFallback,
    this.actionLabelKey,
    this.actionLabelFallback,
    this.onActionTap,
    this.spacing = 6,
  });

  final String titleKey;
  final String titleFallback;
  final String? subtitleKey;
  final String? subtitleFallback;
  final String? actionLabelKey;
  final String? actionLabelFallback;
  final VoidCallback? onActionTap;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = AppText.get(context, key: titleKey, fallback: titleFallback);

    final subtitle = (subtitleKey != null && subtitleFallback != null)
        ? AppText.get(context, key: subtitleKey!, fallback: subtitleFallback!)
        : null;

    final actionLabel = (actionLabelKey != null && actionLabelFallback != null)
        ? AppText.get(
            context,
            key: actionLabelKey!,
            fallback: actionLabelFallback!,
          )
        : null;

    final showAction = actionLabel != null && onActionTap != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final titleWidget = Text(
          title,
          style: theme.textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

        final actionWidget = showAction
            ? TextButton(onPressed: onActionTap, child: Text(actionLabel))
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  if (actionWidget != null) ...[
                    const SizedBox(height: 8),
                    actionWidget,
                  ],
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleWidget),
                  if (actionWidget != null) ...[
                    const SizedBox(width: 12),
                    actionWidget,
                  ],
                ],
              ),
            if (subtitle != null) ...[
              SizedBox(height: spacing),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ],
        );
      },
    );
  }
}
