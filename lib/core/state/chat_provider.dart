import 'package:flutter/foundation.dart';
import 'dart:async';
import '../network/socket_service.dart';

class ChatUser {
  final String userId;
  final String displayName;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unreadCount;
  final String? profileImageUrl;
  const ChatUser({
    required this.userId,
    required this.displayName,
    this.lastMessage,
    this.lastTime,
    required this.unreadCount,
    this.profileImageUrl,
  });
}

class ChatMessage {
  final String messageId;
  final String senderId;
  final String recipientId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });
}

class ChatProvider extends ChangeNotifier {
  final SocketService _socket = SocketService();
  final List<ChatUser> _peers = [];
  final Map<String, List<ChatMessage>> _messages = {};
  String? _myId;
  String? _currentPeerId;
  String? _authToken;
  bool _loadingPeers = false;
  bool _loadingHistory = false;

  List<ChatUser> get peers => List.unmodifiable(_peers);
  List<ChatMessage> messagesFor(String peerId) => _messages[peerId] ?? const [];
  bool get connected => _socket.isConnected;
  bool get loadingPeers => _loadingPeers;
  bool get loadingHistory => _loadingHistory;
  String? get myId => _myId;
  String? get currentPeerId => _currentPeerId;

  /// Total unread message count across all peers
  int get totalUnreadCount =>
      _peers.fold(0, (sum, peer) => sum + peer.unreadCount);

  /// Number of users with unread messages
  int get unreadUsersCount =>
      _peers.where((peer) => peer.unreadCount > 0).length;

  bool _listenersRegistered = false;
  static final DateTime _minTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  void _sortPeers() {
    _peers.sort((a, b) {
      final aTime = a.lastTime ?? _minTimestamp;
      final bTime = b.lastTime ?? _minTimestamp;
      return bTime.compareTo(aTime);
    });
  }

  Future<void> connect({
    required String baseUrl,
    required String userId,
    required String token,
  }) async {
    if (token.isEmpty) return;

    if (connected) {
      if (_myId == userId && _authToken == token) {
        return;
      }
      _socket.disconnect();
    }

    _myId = userId;
    _authToken = token;
    await _socket.connect(baseUrl: baseUrl, token: token);

    // Register socket event listeners only once
    if (!_listenersRegistered) {
      _listenersRegistered = true;

      _socket.on('connectionStatus', (_) {});

      // Load peers immediately when connected (like Next.js does)
      _socket.raw?.on('connect', (_) {
        print('[ChatProvider] Socket connected, loading peers...');
        loadPeers();
      });

      _socket.on('directMessage', (data) {
        final senderId = data['senderId'] as String;
        final recipientId = data['recipientId'] as String;
        final peerId = senderId == _myId ? recipientId : senderId;
        final isRead = (data['isRead'] as bool?) ?? false;

        final list = _messages.putIfAbsent(peerId, () => []);
        list.add(
          ChatMessage(
            messageId: data['messageId'] as String,
            senderId: senderId,
            recipientId: recipientId,
            content: data['content'] as String,
            isRead: isRead,
            createdAt: _parseTimestamp(data['createdAt'] as String),
          ),
        );

        // Update peer list with new last message and potentially unread count
        final peerIndex = _peers.indexWhere((p) => p.userId == peerId);
        if (peerIndex != -1) {
          final peer = _peers[peerIndex];
          final isIncoming = senderId == peerId;

          // Only increment unread count if:
          // 1. It's an incoming message
          // 2. The message is not read
          // 3. We're NOT currently viewing this chat
          final shouldIncrementUnread =
              isIncoming && !isRead && _currentPeerId != peerId;
          final newUnreadCount = shouldIncrementUnread
              ? peer.unreadCount + 1
              : peer.unreadCount;

          _peers[peerIndex] = ChatUser(
            userId: peer.userId,
            displayName: peer.displayName,
            lastMessage: data['content'] as String,
            lastTime: DateTime.parse(data['createdAt'] as String),
            unreadCount: newUnreadCount,
            profileImageUrl: peer.profileImageUrl,
          );
          _sortPeers();
        } else {
          // New or previously unseen peer: refresh from server to pull metadata
          loadPeers();
        }

        notifyListeners();
      });
    }
  }

  Future<void> loadPeers() async {
    if (!connected) return;
    final completer = Completer<void>();
    final timer = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (_loadingPeers) {
        _loadingPeers = false;
        notifyListeners();
      }
    });

    _loadingPeers = true;
    notifyListeners();
    _socket.emitAck('getChatUsers', null, (resp) {
      try {
        final serverList = (resp as List)
            .map(
              (u) => ChatUser(
                userId: u['userId'] as String,
                displayName: (u['displayName'] as String?) ?? 'Unknown',
                lastMessage: u['lastMessage'] as String?,
                lastTime: u['lastMessageTime'] != null
                    ? _parseTimestamp(u['lastMessageTime'])
                    : null,
                unreadCount: (u['unreadCount'] as int?) ?? 0,
                profileImageUrl: u['profileImageUrl'] as String?,
              ),
            )
            .toList();

        // Update peers list intelligently:
        // - Keep local unread counts if they're higher (from real-time messages)
        // - Only replace if this is the first load or if server has newer data
        if (_peers.isEmpty) {
          _peers.addAll(serverList);
        } else {
          // Merge: prefer local unread counts if higher than server
          for (final serverPeer in serverList) {
            final localIndex = _peers.indexWhere(
              (p) => p.userId == serverPeer.userId,
            );
            if (localIndex != -1) {
              final localPeer = _peers[localIndex];
              // Keep the higher unread count (local or server)
              final unreadCount = localPeer.unreadCount > serverPeer.unreadCount
                  ? localPeer.unreadCount
                  : serverPeer.unreadCount;

              _peers[localIndex] = ChatUser(
                userId: serverPeer.userId,
                displayName: serverPeer.displayName,
                lastMessage: serverPeer.lastMessage,
                lastTime: serverPeer.lastTime,
                unreadCount: unreadCount,
                profileImageUrl: serverPeer.profileImageUrl,
              );
            } else {
              // New peer not in local list, add it
              _peers.add(serverPeer);
            }
          }

          // Remove peers that are no longer in server list
          final serverUserIds = serverList.map((peer) => peer.userId).toSet();
          _peers.removeWhere(
            (localPeer) => !serverUserIds.contains(localPeer.userId),
          );
        }
        _sortPeers();
      } catch (_) {
        _peers.clear();
      } finally {
        _loadingPeers = false;
        notifyListeners();
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    return completer.future;
  }

  Future<void> openPeer(String peerId) async {
    _currentPeerId = peerId;
    notifyListeners();
    await loadHistory(peerId: peerId);
    _socket.emit('markMessagesAsRead', {'peerId': peerId});

    // Update local unread count for this peer to 0
    final peerIndex = _peers.indexWhere((p) => p.userId == peerId);
    if (peerIndex != -1) {
      final peer = _peers[peerIndex];
      _peers[peerIndex] = ChatUser(
        userId: peer.userId,
        displayName: peer.displayName,
        lastMessage: peer.lastMessage,
        lastTime: peer.lastTime,
        unreadCount: 0,
        profileImageUrl: peer.profileImageUrl,
      );
      notifyListeners();
    }
  }

  void closePeer() {
    _currentPeerId = null;
    notifyListeners();
  }

  Future<void> loadHistory({
    required String peerId,
    DateTime? before,
    int limit = 10,
  }) async {
    if (!connected) return;
    _loadingHistory = true;
    notifyListeners();
    _socket.emitAck(
      'getHistory',
      {
        'peerId': peerId,
        if (before != null) 'before': _formatForServer(before),
        'limit': limit,
      },
      (resp) {
        try {
          final list = (resp as List)
              .map(
                (m) => ChatMessage(
                  messageId: m['messageId'] as String,
                  senderId: m['senderId'] as String,
                  recipientId: m['recipientId'] as String,
                  content: m['content'] as String,
                  isRead: (m['isRead'] as bool?) ?? false,
                  createdAt: _parseTimestamp(m['createdAt'] as String),
                ),
              )
              .toList()
              .reversed
              .toList();
          _messages[peerId] = list;
        } catch (_) {
          _messages[peerId] = [];
        } finally {
          _loadingHistory = false;
          notifyListeners();
        }
      },
    );
  }

  Future<int> loadMoreHistory({
    required String peerId,
    required DateTime before,
    int limit = 10,
  }) async {
    if (!connected) return 0;
    _loadingHistory = true;
    notifyListeners();

    final completer = Completer<int>();

    _socket.emitAck(
      'getHistory',
      {'peerId': peerId, 'before': _formatForServer(before), 'limit': limit},
      (resp) {
        try {
          final newMessages = (resp as List)
              .map(
                (m) => ChatMessage(
                  messageId: m['messageId'] as String,
                  senderId: m['senderId'] as String,
                  recipientId: m['recipientId'] as String,
                  content: m['content'] as String,
                  isRead: (m['isRead'] as bool?) ?? false,
                  createdAt: _parseTimestamp(m['createdAt'] as String),
                ),
              )
              .toList()
              .reversed
              .toList();

          // Prepend new messages to existing ones while removing duplicates
          final existingMessages = _messages[peerId] ?? [];
          final combined = [...newMessages, ...existingMessages];
          final seenIds = <String>{};
          final deduped = <ChatMessage>[];
          for (final message in combined) {
            // Combine messageId with timestamp just in case backend reuses ids
            final key =
                '${message.messageId}_${message.createdAt.toIso8601String()}';
            if (seenIds.add(key)) {
              deduped.add(message);
            }
          }
          _messages[peerId] = deduped;

          completer.complete(newMessages.length);
        } catch (_) {
          // Keep existing messages on error
          completer.complete(0);
        } finally {
          _loadingHistory = false;
          notifyListeners();
        }
      },
    );

    return completer.future;
  }

  void sendMessage(String peerId, String content) {
    if (!connected || (_myId == null)) return;
    final text = content.trim();
    if (text.isEmpty) return;
    _socket.emitAck('sendDirectMessage', {
      'recipientId': peerId,
      'content': text,
    }, (_) {});
  }

  DateTime _parseTimestamp(String raw) {
    var value = raw.trim();
    if (!value.contains('T')) {
      value = value.replaceFirst(' ', 'T');
    }
    value = value.replaceAllMapped(
      RegExp(r'([+-]\d{2})(\d{2})$'),
      (m) => '${m[1]}:${m[2]}',
    );
    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  String _formatForServer(DateTime value) => value.toUtc().toIso8601String();

  Future<List<ChatUser>> searchUsers(String text) async {
    if (!connected) return [];
    final query = text.trim();
    if (query.isEmpty) return [];

    final completer = Completer<List<ChatUser>>();
    _socket.emitAck('searchUsers', query, (resp) {
      try {
        final list = (resp as List)
            .map(
              (u) => ChatUser(
                userId: u['userId'] as String,
                displayName: (u['displayName'] as String?) ?? 'Unknown',
                lastMessage: null,
                lastTime: null,
                unreadCount: 0,
                profileImageUrl: u['profileImageUrl'] as String?,
              ),
            )
            .toList();
        completer.complete(list);
      } catch (_) {
        completer.complete([]);
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
