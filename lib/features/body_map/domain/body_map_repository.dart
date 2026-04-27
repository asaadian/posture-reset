// lib/features/body_map/domain/body_map_repository.dart

import 'body_map_models.dart';

abstract class BodyMapRepository {
  Future<BodyMapSnapshot> getBodyMapSnapshot();
}