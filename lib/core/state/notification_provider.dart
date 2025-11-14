import 'package:flutter/foundation.dart';
import 'dart:async';
import '../network/realtime_gateway.dart';

class NotificationItem {
  final String notificationId;
  final String userId;
  final String title;
  final String? content;
  final String? relatedUrl;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.notificationId,
    required this.userId,
    required this.title,
    this.content,
    this.relatedUrl,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItem copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? content,
    String? relatedUrl,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      relatedUrl: relatedUrl ?? this.relatedUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final RealtimeGateway _gateway;
  final List<NotificationItem> _notifications = [];
  String? _myId;
  bool _loadingPage = false;
  bool _hasMore = true;
  int _unreadCount = 0;
  bool _listenersBound = false;

  NotificationProvider(this._gateway);

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get connected =>
      _gateway.isConnected && _myId != null && _listenersBound;
  bool get loadingPage => _loadingPage;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;
  String? get myId => _myId;

  void _handleNotificationNew(dynamic data) {
    debugPrint('NotificationProvider: notification:new received -> $data');
    final notification = _parseNotification(data);
    if (notification == null) return;

    final dupIndex = _notifications.indexWhere(
      (n) => n.notificationId == notification.notificationId,
    );
    if (dupIndex != -1) {
      _notifications.removeAt(dupIndex);
    }
    _notifications.insert(0, notification);
    final previous = _unreadCount;
    final next = _countUnreadLocally();
    _updateUnreadCount(next);
    if (next == previous) {
      notifyListeners();
    }
  }

  void _handleSocketReconnect(dynamic _) {
    debugPrint('NotificationProvider: socket reconnect event');
    if (_notifications.isEmpty && !_loadingPage) {
      unawaited(loadInitialPage());
    }
    unawaited(
      refreshUnreadCount(fallbackDelay: const Duration(milliseconds: 500)),
    );
  }

  Future<void> connect({
    required String baseUrl,
    required String userId,
    required String token,
  }) async {
    debugPrint('NotificationProvider: connect requested for $userId');
    if (token.isEmpty) return;
    if (connected && _myId != userId) {
      _gateway.disconnectModule('notification');
      _listenersBound = false;
    }

    if (connected && _myId == userId) {
      if (_notifications.isEmpty && !_loadingPage) {
        unawaited(loadInitialPage());
      }
      unawaited(
        refreshUnreadCount(fallbackDelay: const Duration(milliseconds: 500)),
      );
      debugPrint('NotificationProvider: already connected, refreshed state');
      return;
    }

    if (_myId != userId) {
      _notifications.clear();
      _unreadCount = 0;
      _hasMore = true;
      notifyListeners();
    }

    _myId = userId;
    await _gateway.connectModule(
      module: 'notification',
      baseUrl: baseUrl,
      userId: userId,
      token: token,
    );
    debugPrint('NotificationProvider: connection ready for $userId');

    // Listen for new notifications
    if (!_listenersBound) {
      _listenersBound = true;
      _gateway.client.on('notification:new', _handleNotificationNew);
      _gateway.client.on('connect', _handleSocketReconnect);
    }

    if (_notifications.isEmpty && !_loadingPage) {
      await loadInitialPage();
    }
    await refreshUnreadCount(fallbackDelay: const Duration(milliseconds: 500));
  }

  NotificationItem? _parseNotification(dynamic data) {
    try {
      final map = _normalizeNotificationPayload(data);
      if (map == null) {
        debugPrint('NotificationProvider: payload is not a Map: $data');
        return null;
      }

      final createdAt = _parseDate(map['createdAt']);
      if (createdAt == null) {
        debugPrint('NotificationProvider: unable to parse createdAt in $map');
        return null;
      }

      final idRaw = map['notificationId'] ?? map['id'];
      if (idRaw == null) {
        debugPrint('NotificationProvider: missing notification id in $map');
        return null;
      }
      final ownerRaw = map['userId'] ?? map['ownerId'];
      if (ownerRaw == null) {
        debugPrint('NotificationProvider: missing user id in $map');
        return null;
      }

      return NotificationItem(
        notificationId: '$idRaw',
        userId: '$ownerRaw',
        title: '${map['title'] ?? ''}',
        content: map['content'] as String?,
        relatedUrl: map['relatedUrl'] as String?,
        isRead: _parseBool(map['isRead']),
        createdAt: createdAt,
      );
    } catch (e, stack) {
      debugPrint(
        'NotificationProvider: error parsing notification: $e\n$stack',
      );
      return null;
    }
  }

  Map<String, dynamic>? _normalizeNotificationPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }
    try {
      final json = (data as dynamic).toJson?.call();
      if (json is Map<String, dynamic>) return json;
      if (json is Map) {
        return json.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {}
    return null;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (value is String) {
      try {
        return DateTime.parse(value).toUtc();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Load the first page of notifications
  Future<void> loadInitialPage({int limit = 20}) async {
    if (!connected) return;
    if (_loadingPage) return;
    _loadingPage = true;
    _hasMore = true;
    notifyListeners();

    _gateway.client.emitAck('notifications:getPage', {'limit': limit}, (resp) {
      try {
        debugPrint('NotificationProvider: getPage ack -> $resp');
        final list = (resp as List)
            .map((n) => _parseNotification(n))
            .whereType<NotificationItem>()
            .toList();

        _notifications.clear();
        _notifications.addAll(list);

        final localUnread = _countUnreadLocally();
        _updateUnreadCount(localUnread);

        // If we got fewer than requested, no more pages
        _hasMore = list.length >= limit;
      } catch (e) {
        debugPrint('NotificationProvider: error loading notifications: $e');
        _notifications.clear();
        _hasMore = false;
      } finally {
        _loadingPage = false;
        notifyListeners();
      }
    });
  }

  /// Load more notifications for infinite scroll (returns count loaded)
  Future<int> loadMoreNotifications({
    required DateTime before,
    int limit = 20,
  }) async {
    if (!connected || !_hasMore) return 0;
    if (_loadingPage) return 0;
    _loadingPage = true;
    notifyListeners();

    final completer = Completer<int>();

    _gateway.client.emitAck(
      'notifications:getPage',
      {'before': before.toIso8601String(), 'limit': limit},
      (resp) {
        try {
          debugPrint('NotificationProvider: getPage more ack -> $resp');
          final newNotifications = (resp as List)
              .map((n) => _parseNotification(n))
              .whereType<NotificationItem>()
              .toList();

          _notifications.addAll(newNotifications);

          // If we got fewer than limit, we've reached the end
          _hasMore = newNotifications.length >= limit;
          _updateUnreadCount(_countUnreadLocally());

          completer.complete(newNotifications.length);
        } catch (e) {
          debugPrint(
            'NotificationProvider: error loading more notifications: $e',
          );
          completer.complete(0);
        } finally {
          _loadingPage = false;
          notifyListeners();
        }
      },
    );

    return completer.future;
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    if (!connected) return;

    _gateway.client.emitAck('notifications:markRead', notificationId, (resp) {
      if (resp['success'] == true) {
        final index = _notifications.indexWhere(
          (n) => n.notificationId == notificationId,
        );
        if (index != -1) {
          final notification = _notifications[index];
          if (!notification.isRead) {
            _notifications[index] = notification.copyWith(isRead: true);
            _updateUnreadCount(
              (_unreadCount - 1).clamp(0, double.infinity).toInt(),
            );
          }
        }
      }
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (!connected) return;

    _gateway.client.emitAck('notifications:markAllRead', null, (resp) {
      if (resp['success'] == true) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        _updateUnreadCount(0);
      }
    });
  }

  /// Delete all notifications
  Future<void> deleteAll() async {
    if (!connected) return;

    _gateway.client.emitAck('notifications:deleteAll', null, (resp) {
      if (resp['success'] == true) {
        _notifications.clear();
        _updateUnreadCount(0, notify: false);
        _hasMore = false;
        notifyListeners();
      }
    });
  }

  void disconnect() {
    if (_listenersBound) {
      final raw = _gateway.client.raw;
      raw?.off('notification:new', _handleNotificationNew);
      raw?.off('connect', _handleSocketReconnect);
    }
    _gateway.disconnectModule('notification');
    _listenersBound = false;
    _myId = null;
    _notifications.clear();
    _unreadCount = 0;
    _hasMore = true;
    _loadingPage = false;
    notifyListeners();
  }

  Future<void> refreshUnreadCount({
    Duration fallbackDelay = const Duration(seconds: 3),
  }) async {
    if (!connected) return;

    var acknowledged = false;
    final completer = Completer<void>();

    _gateway.client.emitAck('notifications:getUnreadCount', null, (payload) {
      debugPrint('NotificationProvider: unreadCount ack -> $payload');
      acknowledged = true;
      _updateUnreadCount(_parseUnreadPayload(payload));
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    if (fallbackDelay > Duration.zero) {
      Timer(fallbackDelay, () {
        if (acknowledged) return;
        _updateUnreadCount(_countUnreadLocally());
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    }

    return completer.future;
  }

  int _countUnreadLocally() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void _updateUnreadCount(int next, {bool notify = true}) {
    if (_unreadCount == next) {
      return;
    }
    _unreadCount = next;
    if (notify) {
      notifyListeners();
    }
  }

  int _parseUnreadPayload(dynamic payload) {
    final extracted = _extractCount(payload);
    return extracted ?? _countUnreadLocally();
  }

  int? _extractCount(dynamic payload) {
    if (payload == null) return null;
    if (payload is int) return payload;
    if (payload is num) return payload.toInt();

    if (payload is Map) {
      for (final key in ['count', 'unreadCount', 'total', 'value']) {
        final value = payload[key];
        final extracted = _extractCount(value);
        if (extracted != null) {
          return extracted;
        }
      }
      for (final key in ['data', 'result', 'payload']) {
        final nested = _extractCount(payload[key]);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    if (payload is Iterable) {
      for (final item in payload) {
        final extracted = _extractCount(item);
        if (extracted != null) {
          return extracted;
        }
      }
    }

    return null;
  }
}
