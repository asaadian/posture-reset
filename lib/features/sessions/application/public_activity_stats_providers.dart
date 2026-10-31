import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';

/// Public, aggregated statistics only. The SQL RPCs must return no user IDs,
/// email addresses, or raw activity records.
final globalPopularSessionIdsProvider = FutureProvider<List<String>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client.rpc('public_top_sessions');
    final rows = result as List<dynamic>;
    return rows
        .map((row) => (row as Map)['session_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .take(10)
        .toList(growable: false);
  } catch (error) {
    debugPrint('[PublicStats] Global session ranking unavailable: $error');
    return const <String>[];
  }
});

final publicProgramJoinCountsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client.rpc('public_program_join_counts');
    final rows = result as List<dynamic>;
    final counts = <String, int>{};
    for (final row in rows) {
      final values = row as Map;
      final id = values['program_id']?.toString() ?? '';
      final count = values['joined_count'];
      if (id.isEmpty || count is! num) continue;
      counts[id] = count.toInt();
    }
    return counts;
  } catch (error) {
    debugPrint('[PublicStats] Program join counts unavailable: $error');
    return const <String, int>{};
  }
});
