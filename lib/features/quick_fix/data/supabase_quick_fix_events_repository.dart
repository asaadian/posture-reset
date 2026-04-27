// lib/features/quick_fix/data/supabase_quick_fix_events_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/quick_fix_events_repository.dart';
import '../domain/quick_fix_models.dart';
import '../domain/quick_fix_state.dart';

class SupabaseQuickFixEventsRepository implements QuickFixEventsRepository {
  SupabaseQuickFixEventsRepository(this._client);

  final SupabaseClient _client;

  List<String> _normalizedCodes(List<String> values) {
    final unique = values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return unique;
  }

  @override
  Future<void> trackEvent({
    required QuickFixActionType actionType,
    required QuickFixState state,
    required String recommendedSessionId,
    Map<String, Object?> metadata = const {},
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final timeMinutes = int.tryParse(state.selectedTimeId) ?? 4;

    await _client.from('quick_fix_events').insert({
      'user_id': user.id,
      'selected_problem_code': state.selectedProblemId,
      'selected_time_minutes': timeMinutes,
      'selected_energy_code': state.selectedEnergyId,
      'selected_location_codes': _normalizedCodes(state.selectedLocationIds),
      'selected_mode_codes': _normalizedCodes(state.selectedModeIds),
      'silent_mode_enabled': state.silentModeEnabled,
      'recommended_session_id': recommendedSessionId,
      'action_type': actionType.dbValue,
      'metadata': metadata,
    });
  }
}