import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDataResetSignalProvider =
    NotifierProvider<AppDataResetSignalNotifier, int>(
  AppDataResetSignalNotifier.new,
);

class AppDataResetSignalNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notifyReset() {
    state = state + 1;
  }
}

void notifyAppDataReset(WidgetRef ref) {
  ref.read(appDataResetSignalProvider.notifier).notifyReset();
}
