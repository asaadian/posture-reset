// lib/core/notifications/notification_payload_router.dart

class NotificationPayloadRouteMapper {
  const NotificationPayloadRouteMapper._();

  static String? toAppRoute(String payload) {
    final uri = Uri.tryParse(payload.trim());
    if (uri == null) return null;

    if (uri.scheme == 'posture_reset') {
      return _fromPostureResetUri(uri);
    }

    if (uri.scheme.isEmpty) {
      return _fromRelativePath(payload.trim());
    }

    return null;
  }

  static String? _fromPostureResetUri(Uri uri) {
    final action = uri.host.trim().isNotEmpty
        ? uri.host.trim()
        : (uri.pathSegments.isNotEmpty ? uri.pathSegments.first.trim() : '');

    final segments = uri.host.trim().isNotEmpty
        ? uri.pathSegments
        : uri.pathSegments.skip(1).toList(growable: false);

    switch (action) {
      case 'quick_fix':
      case 'quick-fix':
        return '/app/quick-fix';

      case 'session':
        if (segments.isEmpty || segments.first.trim().isEmpty) {
          return '/app/sessions';
        }
        final sessionId = Uri.encodeComponent(segments.first.trim());
        return '/app/sessions/player/$sessionId?source=notification';

      case 'program':
        if (segments.isEmpty || segments.first.trim().isEmpty) {
          return '/app/programs';
        }
        final programId = Uri.encodeComponent(segments.first.trim());
        final day = _readDayNumber(segments);
        if (day == null) return '/app/programs/$programId';
        return '/app/programs/$programId?day=$day';

      case 'programs':
        return '/app/programs';

      case 'premium':
        return '/app/profile/premium';

      case 'settings':
        return '/app/profile/settings';

      case 'notifications':
        return '/app/notifications';

      case 'dashboard':
        return '/app/dashboard';

      default:
        return '/app/dashboard';
    }
  }

  static String? _fromRelativePath(String payload) {
    if (payload.startsWith('/app/')) return payload;

    switch (payload) {
      case 'quick_fix':
      case 'quick-fix':
        return '/app/quick-fix';
      case 'programs':
        return '/app/programs';
      case 'premium':
        return '/app/profile/premium';
      case 'settings':
        return '/app/profile/settings';
      case 'notifications':
        return '/app/notifications';
      default:
        return null;
    }
  }

  static int? _readDayNumber(List<String> segments) {
    for (var index = 0; index < segments.length; index++) {
      final current = segments[index].trim();
      if (current == 'day' && index + 1 < segments.length) {
        return int.tryParse(segments[index + 1].trim());
      }
    }
    return null;
  }
}
