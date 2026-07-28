// lib/core/notifications/notification_history_repository.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_context_repository.dart';

class AppNotificationHistoryItem {
  const AppNotificationHistoryItem({
    required this.id,
    required this.notificationId,
    required this.kind,
    required this.title,
    required this.body,
    required this.payload,
    required this.createdAt,
    required this.scheduledFor,
    required this.userId,
    required this.openedAt,
  });

  final String id;
  final int notificationId;
  final String kind;
  final String title;
  final String body;
  final String payload;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String? userId;
  final DateTime? openedAt;

  bool get isOpened => openedAt != null;

  bool get isUpcoming {
    final scheduled = scheduledFor;
    if (scheduled == null) return false;
    return scheduled.toLocal().isAfter(DateTime.now());
  }

  bool get isDue => !isUpcoming;

  bool get isUnread => !isOpened && isDue;

  AppNotificationHistoryItem copyWith({
    String? title,
    String? body,
    String? payload,
    DateTime? createdAt,
    DateTime? scheduledFor,
    Object? userId = _sentinel,
    Object? openedAt = _sentinel,
  }) {
    return AppNotificationHistoryItem(
      id: id,
      notificationId: notificationId,
      kind: kind,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      userId: identical(userId, _sentinel) ? this.userId : userId as String?,
      openedAt:
          identical(openedAt, _sentinel) ? this.openedAt : openedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'kind': kind,
      'title': title,
      'body': body,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'user_id': userId,
      'opened_at': openedAt?.toIso8601String(),
    };
  }

  factory AppNotificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationHistoryItem(
      id: json['id']?.toString() ?? '',
      notificationId: _intOrDefault(json['notification_id'], 0),
      kind: json['kind']?.toString() ?? 'dailyReset',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      createdAt: _date(json['created_at']) ?? DateTime.now().toUtc(),
      scheduledFor: _date(json['scheduled_for']),
      userId: _nullableString(json['user_id']),
      openedAt: _date(json['opened_at']),
    );
  }

  static const Object _sentinel = Object();
}

class NotificationHistoryRepository {
  const NotificationHistoryRepository();

  static const String _storageKey = 'notifications.history.v1';
  static const int _maxItems = 60;

  Future<List<AppNotificationHistoryItem>> listForUser(String? userId) async {
    final items = await _readAll();
    final filtered = items.where((item) {
      if (userId == null || userId.trim().isEmpty) {
        return item.userId == null;
      }
      return item.userId == null || item.userId == userId;
    }).toList(growable: true)
      ..sort((a, b) {
        final aTime = a.scheduledFor ?? a.createdAt;
        final bTime = b.scheduledFor ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

    return filtered;
  }

  Future<int> unreadCountForUser(String? userId) async {
    final items = await listForUser(userId);
    return items.where((item) => item.isUnread).length;
  }

  Future<void> recordScheduled({
    required int notificationId,
    required RecoveryNotificationPlan plan,
    required DateTime scheduledFor,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _historyId(
      notificationId: notificationId,
      payload: plan.payload,
      scheduledFor: scheduledFor,
    );

    // Critical fix: _readAll() may return an empty list. Always make a
    // growable copy before insert/update. Returning `const []` caused
    // `Unsupported operation: Cannot add to an unmodifiable list` and stopped
    // scheduling/history writes.
    final items = List<AppNotificationHistoryItem>.of(await _readAll(), growable: true);
    final existingIndex = items.indexWhere((item) => item.id == id);
    final nextItem = AppNotificationHistoryItem(
      id: id,
      notificationId: notificationId,
      kind: plan.kind.name,
      title: plan.title,
      body: plan.body,
      payload: plan.payload,
      createdAt: now,
      scheduledFor: scheduledFor.toUtc(),
      userId: plan.userId,
      openedAt: existingIndex >= 0 ? items[existingIndex].openedAt : null,
    );

    if (existingIndex >= 0) {
      items[existingIndex] = nextItem;
    } else {
      items.insert(0, nextItem);
    }

    await _writeAll(_trim(items));
  }

  Future<void> markPayloadOpened(String payload) async {
    final cleanPayload = payload.trim();
    if (cleanPayload.isEmpty) return;

    final items = List<AppNotificationHistoryItem>.of(await _readAll(), growable: true);
    final now = DateTime.now().toUtc();
    var changed = false;

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (item.payload == cleanPayload && item.openedAt == null) {
        items[index] = item.copyWith(openedAt: now);
        changed = true;
        break;
      }
    }

    if (changed) {
      await _writeAll(items);
    }
  }

  Future<void> markAllOpenedForUser(String? userId) async {
    final items = List<AppNotificationHistoryItem>.of(await _readAll(), growable: true);
    final now = DateTime.now().toUtc();
    var changed = false;

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final matchesUser = userId == null || userId.trim().isEmpty
          ? item.userId == null
          : item.userId == null || item.userId == userId;

      // Do not mark future scheduled reminders as read. They should remain
      // visible as Upcoming, but not count as unread until due.
      if (matchesUser && item.isDue && item.openedAt == null) {
        items[index] = item.copyWith(openedAt: now);
        changed = true;
      }
    }

    if (changed) {
      await _writeAll(items);
    }
  }

  Future<void> clearForUser(
    String? userId, {
    bool includeLegacyUserlessItems = false,
  }) async {
    final cleanUserId = userId?.trim() ?? '';
    final items = List<AppNotificationHistoryItem>.of(await _readAll(), growable: true);

    final remaining = items.where((item) {
      if (cleanUserId.isEmpty) {
        return item.userId != null;
      }

      if (item.userId == cleanUserId) {
        return false;
      }

      if (includeLegacyUserlessItems && item.userId == null) {
        return false;
      }

      return true;
    }).toList(growable: true);

    await _writeAll(_trim(remaining));
  }

  Future<List<AppNotificationHistoryItem>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <AppNotificationHistoryItem>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <AppNotificationHistoryItem>[];

      return decoded
          .whereType<Map>()
          .map(
            (item) => AppNotificationHistoryItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList(growable: true);
    } catch (error, stackTrace) {
      debugPrint('[Notifications] history read failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return <AppNotificationHistoryItem>[];
    }
  }

  Future<void> _writeAll(List<AppNotificationHistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList(growable: false)),
    );
  }

  List<AppNotificationHistoryItem> _trim(List<AppNotificationHistoryItem> items) {
    final sorted = List<AppNotificationHistoryItem>.of(items, growable: true)
      ..sort((a, b) {
        final aTime = a.scheduledFor ?? a.createdAt;
        final bTime = b.scheduledFor ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    if (sorted.length <= _maxItems) return sorted;
    return sorted.take(_maxItems).toList(growable: true);
  }

  String _historyId({
    required int notificationId,
    required String payload,
    required DateTime scheduledFor,
  }) {
    final localDay = scheduledFor.toLocal();
    final dayKey = '${localDay.year.toString().padLeft(4, '0')}'
        '-${localDay.month.toString().padLeft(2, '0')}'
        '-${localDay.day.toString().padLeft(2, '0')}';
    final safePayload = payload.trim().isEmpty ? 'empty' : payload.trim();
    return '$notificationId|$safePayload|$dayKey';
  }
}

final notificationHistoryRepositoryProvider =
    Provider<NotificationHistoryRepository>((ref) {
  return const NotificationHistoryRepository();
});

final notificationHistoryItemsProvider = FutureProvider.autoDispose
    .family<List<AppNotificationHistoryItem>, String?>((ref, userId) async {
  final repository = ref.watch(notificationHistoryRepositoryProvider);
  return repository.listForUser(userId);
});

final notificationHistoryUnreadCountProvider =
    FutureProvider.autoDispose.family<int, String?>((ref, userId) async {
  final repository = ref.watch(notificationHistoryRepositoryProvider);
  return repository.unreadCountForUser(userId);
});

String? _nullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value.toUtc();
  if (value is String) return DateTime.tryParse(value)?.toUtc();
  return null;
}

int _intOrDefault(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}
