import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../domain/session_models.dart';
import '../../../access/domain/access_models.dart';
import '../../../access/domain/access_policy.dart';
import 'session_card.dart';

class SessionHorizontalList extends StatelessWidget {
  const SessionHorizontalList({
    super.key,
    required this.sessions,
    required this.accessSnapshot,
  });

  final List<SessionSummary> sessions;
  final AccessSnapshot accessSnapshot;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final t = AppText.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 600 ? screenWidth * 0.84 : 340.0;

    return SizedBox(
      height: 268,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: sessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final isLocked = !AccessPolicy.canAccessTier(
            snapshot: accessSnapshot,
            tier: session.accessTier,
          ).allowed;

          return SizedBox(
            width: cardWidth,
            child: SessionCard.fromSummary(
              session: session,
              t: t,
              isFeatured: true,
              isLocked: isLocked,
            ),
          );
        },
      ),
    );
  }
}