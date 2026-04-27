// lib/features/dashboard/domain/dashboard_repository.dart

import 'dashboard_snapshot.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> getDashboardSnapshot();
}