// lib/features/body_map/application/body_map_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/body_map_repository_impl.dart';
import '../domain/body_map_models.dart';
import '../domain/body_map_repository.dart';

final bodyMapRepositoryProvider = Provider<BodyMapRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BodyMapRepositoryImpl(client);
});

final bodyMapSnapshotProvider = FutureProvider.autoDispose<BodyMapSnapshot>((ref) async {
  final repository = ref.watch(bodyMapRepositoryProvider);
  return repository.getBodyMapSnapshot();
});

final bodyMapSideProvider =
    NotifierProvider<BodyMapSideController, BodyMapSide>(BodyMapSideController.new);

class BodyMapSideController extends Notifier<BodyMapSide> {
  @override
  BodyMapSide build() => BodyMapSide.front;

  void setSide(BodyMapSide side) {
    state = side;
  }
}

final bodyMapSelectedZoneProvider =
    NotifierProvider<BodyMapSelectedZoneController, String?>(BodyMapSelectedZoneController.new);

class BodyMapSelectedZoneController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String code) {
    state = code;
  }

  void clear() {
    state = null;
  }
}