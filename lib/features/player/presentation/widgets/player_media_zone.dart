// lib/features/player/presentation/widgets/player_media_zone.dart

import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';

class PlayerMediaZone extends StatelessWidget {
  const PlayerMediaZone({
    super.key,
    required this.stepTitle,
    required this.stepTypeLabel,
    this.mediaUrl,
    this.posterUrl,
    this.isVideo = false,
  });

  final String stepTitle;
  final String stepTypeLabel;
  final String? mediaUrl;
  final String? posterUrl;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppText.of(context);

    final hasMedia = mediaUrl != null && mediaUrl!.trim().isNotEmpty;
    final hasPoster = posterUrl != null && posterUrl!.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;
        final aspectRatio = isCompact ? 16 / 9 : 16 / 8.8;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainerLow,
                      ],
                    ),
                  ),
                ),
                if (hasPoster)
                  Image.network(
                    posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: hasPoster ? 0.12 : 0.0),
                        Colors.black.withValues(alpha: hasPoster ? 0.20 : 0.0),
                        Colors.black.withValues(alpha: 0.48),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _OverlayChip(
                    icon: isVideo
                        ? Icons.play_circle_outline_rounded
                        : Icons.motion_photos_on_outlined,
                    label: hasMedia
                        ? stepTypeLabel
                        : t.get(
                            'player_media_placeholder_chip',
                            fallback: 'Movement Preview',
                          ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Icon(
                      hasMedia
                          ? (isVideo
                              ? Icons.play_arrow_rounded
                              : Icons.gif_box_outlined)
                          : Icons.ondemand_video_outlined,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: _BottomOverlay(
                    title: stepTitle,
                    subtitle: !hasMedia
                        ? t.get(
                            'player_media_placeholder_body_short',
                            fallback:
                                'Video or GIF guidance will appear here for this step.',
                          )
                        : stepTypeLabel,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomOverlay extends StatelessWidget {
  const _BottomOverlay({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}