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
