// lib/features/sessions/presentation/widgets/session_detail_section_title.dart
import 'package:flutter/material.dart';

import '../../../../shared/widgets/adaptive_section_title.dart';

class SessionDetailSectionTitle extends StatelessWidget {
  const SessionDetailSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveSectionTitle(
      titleKey: '__unused_title_key__',
      titleFallback: title,
      subtitleKey: subtitle != null ? '__unused_subtitle_key__' : null,
      subtitleFallback: subtitle,
      actionLabelKey: actionLabel != null ? '__unused_action_key__' : null,
      actionLabelFallback: actionLabel,
      onActionTap: onActionTap,
    );
  }
}