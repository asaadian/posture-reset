// lib/features/player/presentation/widgets/player_terminal_status_card.dart

import 'package:flutter/material.dart';

class PlayerTerminalStatusCard extends StatelessWidget {
  const PlayerTerminalStatusCard({
    super.key,
    required this.logs,
  });

  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}