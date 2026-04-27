// lib/features/quick_fix/domain/quick_fix_events_repository.dart

import 'quick_fix_models.dart';
import 'quick_fix_state.dart';

abstract class QuickFixEventsRepository {
  Future<void> trackEvent({
    required QuickFixActionType actionType,
    required QuickFixState state,
    required String recommendedSessionId,
    Map<String, Object?> metadata,
  });
}