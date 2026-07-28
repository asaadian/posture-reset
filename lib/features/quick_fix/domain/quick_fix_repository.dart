import 'quick_fix_state.dart';

abstract class QuickFixRepository {
  Future<QuickFixState> getInitialState();
}
