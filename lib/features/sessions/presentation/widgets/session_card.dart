import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_models.dart';
import '../../../access/presentation/widgets/premium_lock_badge.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.tags,
    required this.sessionId,
    required this.intensityLabel,
    this.width,
    this.isFeatured = false,
    this.isLocked = false,
  });

  factory SessionCard.fromSummary({
    Key? key,
    required SessionSummary session,
    required dynamic t,
    double? width,
    bool isFeatured = false,
    bool isLocked = false,
  }) {
    return SessionCard(
      key: key,
      title: session.titleFallback,
      subtitle: session.shortDescriptionFallback,
      durationMinutes: session.durationMinutes,
      tags: _buildTags(session, t),
      sessionId: session.id,
      intensityLabel: _intensityLabel(session.intensity, t),
      width: width,
      isFeatured: isFeatured,
      isLocked: isLocked,
    );
  }

  final String title;
  final String subtitle;
  final int durationMinutes;
  final List<String> tags;
  final String sessionId;
  final String intensityLabel;
  final double? width;
  final bool isFeatured;
  final bool isLocked;

  static const double _regularReservedTagsHeight = 52;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppText.of(context);
    final visibleTags = tags.take(3).toList(growable: false);

    final cardChild = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: isFeatured
          ? _FeaturedCardContent(
              title: title,
              subtitle: subtitle,
              durationMinutes: durationMinutes,
              intensityLabel: intensityLabel,
              visibleTags: visibleTags,
              sessionId: sessionId,
              isLocked: isLocked,
              t: t,
            )
          : _RegularCardContent(
              title: title,
              subtitle: subtitle,
              durationMinutes: durationMinutes,
              intensityLabel: intensityLabel,
              visibleTags: visibleTags,
              sessionId: sessionId,
              isLocked: isLocked,
              t: t,
            ),
    );

    return SizedBox(
      width: width ?? 300,
      child: isFeatured
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.primary.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.38),
                ),
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                margin: EdgeInsets.zero,
                child: cardChild,
              ),
            )
          : Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: cardChild,
            ),
    );
  }

  static List<String> _buildTags(SessionSummary session, dynamic t) {
    final result = <String>[];

    for (final tag in session.tags) {
      if (result.length >= 3) break;
      result.add(tag.labelFallback);
    }

    for (final target in session.painTargets) {
      if (result.length >= 3) break;
      if (!result.contains(target.labelFallback)) {
        result.add(target.labelFallback);
      }
    }

    if (session.isSilentFriendly && result.length < 3) {
      final label = t.get('sessions_tag_silent', fallback: 'Silent');
      if (!result.contains(label)) {
        result.add(label);
      }
    }

    if (session.isBeginnerFriendly && result.length < 3) {
      final label = t.get('sessions_tag_beginner', fallback: 'Beginner');
      if (!result.contains(label)) {
        result.add(label);
      }
    }

    return result;
  }

  static String _intensityLabel(SessionIntensity intensity, dynamic t) {
    switch (intensity) {
      case SessionIntensity.gentle:
        return t.get('sessions_intensity_gentle', fallback: 'Gentle');
      case SessionIntensity.light:
        return t.get('sessions_intensity_light', fallback: 'Light');
      case SessionIntensity.moderate:
        return t.get('sessions_intensity_moderate', fallback: 'Moderate');
      case SessionIntensity.strong:
        return t.get('sessions_intensity_strong', fallback: 'Strong');
    }
  }
}

class _RegularCardContent extends StatelessWidget {
  const _RegularCardContent({
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.intensityLabel,
    required this.visibleTags,
    required this.sessionId,
    required this.isLocked,
    required this.t,
  });

  final String title;
  final String subtitle;
  final int durationMinutes;
  final String intensityLabel;
  final List<String> visibleTags;
  final String sessionId;
  final bool isLocked;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(
              label: t
                  .get(
                    'sessions_duration_minutes_format',
                    fallback: '{minutes} min',
                  )
                  .replaceAll('{minutes}', durationMinutes.toString()),
              isFeatured: false,
            ),
            _MetaChip(
              label: intensityLabel,
              isFeatured: false,
            ),
            if (isLocked) const PremiumLockBadge(compact: true),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        SizedBox(
          height: SessionCard._regularReservedTagsHeight,
          child: Align(
            alignment: Alignment.topLeft,
            child: visibleTags.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: visibleTags
                        .map(
                          (tag) => _TagChip(
                            label: tag,
                            isFeatured: false,
                          ),
                        )
                        .toList(growable: false),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.pushNamed(
              'session-detail',
              pathParameters: {'id': sessionId},
            ),
            child: Text(
              isLocked
                  ? t.get(
                      'session_card_preview_locked_cta',
                      fallback: 'Preview',
                    )
                  : t.get(
                      'session_card_view_details_cta',
                      fallback: 'View Details',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCardContent extends StatelessWidget {
  const _FeaturedCardContent({
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.intensityLabel,
    required this.visibleTags,
    required this.sessionId,
    required this.isLocked,
    required this.t,
  });

  final String title;
  final String subtitle;
  final int durationMinutes;
  final String intensityLabel;
  final List<String> visibleTags;
  final String sessionId;
  final bool isLocked;
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(
              label: t
                  .get(
                    'sessions_duration_minutes_format',
                    fallback: '{minutes} min',
                  )
                  .replaceAll('{minutes}', durationMinutes.toString()),
              isFeatured: true,
            ),
            _MetaChip(
              label: intensityLabel,
              isFeatured: true,
            ),
            _MetaChip(
              label: t.get('sessions_featured_badge', fallback: 'Featured'),
              isFeatured: true,
              emphasize: true,
            ),
            if (isLocked) const PremiumLockBadge(compact: true),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (visibleTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleTags
                .map(
                  (tag) => _TagChip(
                    label: tag,
                    isFeatured: true,
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.pushNamed(
              'session-detail',
              pathParameters: {'id': sessionId},
            ),
            child: Text(
              isLocked
                  ? t.get(
                      'session_card_preview_locked_cta',
                      fallback: 'Preview',
                    )
                  : t.get(
                      'session_card_view_details_cta',
                      fallback: 'View Details',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.isFeatured,
    this.emphasize = false,
  });

  final String label;
  final bool isFeatured;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = emphasize
        ? colorScheme.secondary.withValues(alpha: 0.92)
        : (isFeatured
            ? colorScheme.primary.withValues(alpha: 0.18)
            : colorScheme.secondaryContainer);

    final foreground = emphasize
        ? colorScheme.onSecondary
        : (isFeatured
            ? colorScheme.primary
            : colorScheme.onSecondaryContainer);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.isFeatured,
  });

  final String label;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isFeatured
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isFeatured
              ? colorScheme.primary.withValues(alpha: 0.28)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}