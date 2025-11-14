import 'package:flutter/foundation.dart';
import 'dart:async';
import '../network/socket_service.dart';

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
  final SocketService _socket = SocketService();
  final List<NotificationItem> _notifications = [];
  String? _myId;
  bool _loadingPage = false;
  bool _hasMore = true;
  int _unreadCount = 0;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get connected => _socket.isConnected;
  bool get loadingPage => _loadingPage;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;
  String? get myId => _myId;

  Future<void> connect({
    required String baseUrl,
    required String userId,
    required String token,
  }) async {
    if (connected && _myId == userId) return;
    _myId = userId;
    await _socket.connect(baseUrl: baseUrl, token: token);

    // Listen for new notifications
    _socket.on('notification:new', (data) {
      final notification = _parseNotification(data);
      if (notification != null) {
        // Add to beginning of list
        _notifications.insert(0, notification);
        if (!notification.isRead) {
          _unreadCount++;
        }
        notifyListeners();
      }
    });

    // Get initial unread count
    _socket.emitAck('notifications:getUnreadCount', null, (count) {
      _unreadCount = count as int? ?? 0;
      notifyListeners();
    });
  }

  NotificationItem? _parseNotification(dynamic data) {
    try {
      return NotificationItem(
        notificationId: data['notificationId'] as String,
        userId: data['userId'] as String,
        title: data['title'] as String,
        content: data['content'] as String?,
        relatedUrl: data['relatedUrl'] as String?,
        isRead: (data['isRead'] as bool?) ?? false,
        createdAt: DateTime.parse(data['createdAt'] as String),
      );
    } catch (e) {
      print('Error parsing notification: $e');
      return null;
    }
  }

  /// Load the first page of notifications
  Future<void> loadInitialPage({int limit = 20}) async {
    if (!connected) return;
    _loadingPage = true;
    _hasMore = true;
    notifyListeners();

    _socket.emitAck('notifications:getPage', {'limit': limit}, (resp) {
      try {
        final list = (resp as List)
            .map((n) => _parseNotification(n))
            .whereType<NotificationItem>()
            .toList();

        _notifications.clear();
        _notifications.addAll(list);

        // If we got fewer than requested, no more pages
        _hasMore = list.length >= limit;
      } catch (e) {
        print('Error loading notifications: $e');
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
    _loadingPage = true;
    notifyListeners();

    final completer = Completer<int>();

    _socket.emitAck(
      'notifications:getPage',
      {'before': before.toIso8601String(), 'limit': limit},
      (resp) {
        try {
          final newNotifications = (resp as List)
              .map((n) => _parseNotification(n))
              .whereType<NotificationItem>()
              .toList();

          _notifications.addAll(newNotifications);

          // If we got fewer than limit, we've reached the end
          _hasMore = newNotifications.length >= limit;

          completer.complete(newNotifications.length);
        } catch (e) {
          print('Error loading more notifications: $e');
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

    _socket.emitAck('notifications:markRead', notificationId, (resp) {
      if (resp['success'] == true) {
        final index = _notifications.indexWhere(
          (n) => n.notificationId == notificationId,
        );
        if (index != -1) {
          final notification = _notifications[index];
          if (!notification.isRead) {
            _notifications[index] = notification.copyWith(isRead: true);
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
            notifyListeners();
          }
        }
      }
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (!connected) return;

    _socket.emitAck('notifications:markAllRead', null, (resp) {
      if (resp['success'] == true) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        _unreadCount = 0;
        notifyListeners();
      }
    });
  }

  /// Delete all notifications
  Future<void> deleteAll() async {
    if (!connected) return;

    _socket.emitAck('notifications:deleteAll', null, (resp) {
      if (resp['success'] == true) {
        _notifications.clear();
        _unreadCount = 0;
        _hasMore = false;
        notifyListeners();
      }
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
