// lib/features/quick_fix/domain/quick_fix_repository.dart

import 'quick_fix_state.dart';

abstract class QuickFixRepository {
  Future<QuickFixState> getInitialState();
}