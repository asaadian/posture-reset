import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/localization/app_text.dart';

/// Decorative sample avatars. They do not represent actual participants.
/// Only display next to a verified aggregate participant count.
class ProgramAvatarStack extends StatefulWidget {
  const ProgramAvatarStack({super.key, required this.programId});
  final String programId;

  @override
  State<ProgramAvatarStack> createState() => _ProgramAvatarStackState();
}

class _ProgramAvatarStackState extends State<ProgramAvatarStack> {
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _frame = (_frame + 1) % 6);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seed = widget.programId.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return ExcludeSemantics(
      child: SizedBox(
        width: 53,
        height: 25,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(3, (index) {
            final number = ((seed + index * 5 + _frame) % 20) + 1;
            return Positioned(
              left: index * 14.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: Container(
                  key: ValueKey(number),
                  width: 25,
                  height: 25,
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatars/$number.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF3A6772),
                        child: Icon(Icons.person, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ProgramJoinSocialProof extends StatelessWidget {
  const ProgramJoinSocialProof({
    super.key,
    required this.programId,
    required this.count,
    this.compact = false,
  });
  final String programId;
  final int count;
  final bool compact;

  String get countLabel {
    if (count < 1000) return '$count';
    if (count < 10000) return '${(count / 100).floor() / 10}K';
    if (count < 1000000) return '${count ~/ 1000}K';
    return '${(count / 100000).floor() / 10}M';
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0) ...[
            ProgramAvatarStack(programId: programId),
            const SizedBox(width: 5),
          ],
          Text((count == 1
              ? AppText.get(context, key: 'program_user_joined_one', fallback: '1 person joined')
              : AppText.get(context, key: 'program_users_joined', fallback: '{count} people joined').replaceAll('{count}', countLabel)),
            style: TextStyle(color: Colors.white,
              fontSize: compact ? 9 : 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
