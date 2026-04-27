// lib/features/sessions/presentation/widgets/session_detail_hero_card.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import 'session_detail_tag_wrap.dart';

class SessionDetailHeroCard extends StatelessWidget {
  const SessionDetailHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.durationMinutes,
    required this.isSilentFriendly,
    required this.isBeginnerFriendly,
    required this.metaTags,
  });

  final String title;
  final String subtitle;
  final String description;
  final int durationMinutes;
  final bool isSilentFriendly;
  final bool isBeginnerFriendly;
  final List<String> metaTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppText.of(context);

    final uniqueTags = {
      '$durationMinutes ${t.get('session_detail_minutes_unit', fallback: 'min')}',
      if (subtitle.trim().isNotEmpty) subtitle,
      if (isSilentFriendly)
        t.get('session_detail_tag_silent', fallback: 'Silent Friendly'),
      if (isBeginnerFriendly)
        t.get('session_detail_tag_beginner', fallback: 'Beginner Friendly'),
      ...metaTags.where((tag) => tag.trim().isNotEmpty),
    };

    final compactTags = uniqueTags.take(4).toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get('session_detail_label', fallback: 'Session Detail'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.headlineSmall),
            if (subtitle.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            if (compactTags.isNotEmpty) ...[
              const SizedBox(height: 14),
              SessionDetailTagWrap(tags: compactTags),
            ],
          ],
        ),
      ),
    );
  }
}