import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/state/chat_provider.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _previousMessageCount = 0;
  late final ChatProvider _chat;
  bool _loadMoreScheduled = false;

  @override
  void initState() {
    super.initState();
    _chat = context.read<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chat.openPeer(widget.chatId);
      _scrollToBottom();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _chat.closePeer();
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 100 &&
        !_isLoadingMore &&
        _hasMoreMessages &&
        !_loadMoreScheduled) {
      _loadMoreScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _loadMoreScheduled = false;
          return;
        }
        _loadMoreMessages();
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    _loadMoreScheduled = false;
    if (_isLoadingMore) return;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final msgs = _chat.messagesFor(widget.chatId);

    if (msgs.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreMessages = false;
        });
      } else {
        _isLoadingMore = false;
        _hasMoreMessages = false;
      }
      return;
    }

    final oldestMessage = msgs.first;
    final before = oldestMessage.createdAt;
    final currentScrollOffset = _scrollController.offset;
    final currentScrollHeight = _scrollController.position.maxScrollExtent;

    final loadedCount = await _chat.loadMoreHistory(
      peerId: widget.chatId,
      before: before,
      limit: 10,
    );

    final hasMore = loadedCount >= 10;

    if (mounted && loadedCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final newScrollHeight = _scrollController.position.maxScrollExtent;
          final scrollDiff = newScrollHeight - currentScrollHeight;
          _scrollController.jumpTo(currentScrollOffset + scrollDiff);
        }
      });
    }

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _hasMoreMessages = hasMore;
      });
    } else {
      _isLoadingMore = false;
      _hasMoreMessages = hasMore;
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _chat.sendMessage(widget.chatId, text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, chat, _) {
            final peer = _resolvePeer(chat);
            return Text(peer.displayName);
          },
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                final msgs = chat.messagesFor(widget.chatId);
                final myId = chat.myId;
                final peer = _resolvePeer(chat);
                final peerAvatarUrl = peer.profileImageUrl;
                final peerInitials = _initials(peer.displayName);

                if (msgs.length > _previousMessageCount) {
                  _previousMessageCount = msgs.length;
                  if (_scrollController.hasClients) {
                    final position = _scrollController.position;
                    final isNearBottom =
                        position.maxScrollExtent - position.pixels < 100;
                    if (isNearBottom) {
                      _scrollToBottom();
                    }
                  } else {
                    _scrollToBottom();
                  }
                }

                final groupedMessages =
                    <String, List<MapEntry<int, ChatMessage>>>{};
                for (var i = 0; i < msgs.length; i++) {
                  final msg = msgs[i];
                  final dateKey = _formatDateKey(msg.createdAt);
                  groupedMessages
                      .putIfAbsent(dateKey, () => [])
                      .add(MapEntry(i, msg));
                }

                final items = <Widget>[];
                final sortedDates = groupedMessages.keys.toList();

                if (_isLoadingMore) {
                  items.add(
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  );
                }

                for (final dateKey in sortedDates) {
                  items.add(_DateSeparator(date: dateKey));
                  for (final entry in groupedMessages[dateKey]!) {
                    final m = entry.value;
                    final isMe = (m.senderId == myId);
                    final time = TimeOfDay.fromDateTime(m.createdAt);
                    final timeLabel =
                        '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}';
                    items.add(
                      _MessageBubble(
                        isMe: isMe,
                        text: m.content,
                        timeLabel: timeLabel,
                        avatarUrl: isMe ? null : peerAvatarUrl,
                        initials: isMe ? null : peerInitials,
                      ),
                    );
                  }
                }

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      '대화 내역이 없습니다.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) => items[index],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: const Color(0xFFF6F7F9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  ChatUser _resolvePeer(ChatProvider chat) {
    return chat.peers.firstWhere(
      (p) => p.userId == widget.chatId,
      orElse: () =>
          ChatUser(userId: widget.chatId, displayName: '채팅', unreadCount: 0),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r"\s+"));
    final first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first;
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String timeLabel;
  final String? avatarUrl;
  final String? initials;
  const _MessageBubble({
    required this.isMe,
    required this.text,
    required this.timeLabel,
    this.avatarUrl,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? const Color(0xFF3B3757)
        : const Color(0xFFF0F2F5);
    final textColor = isMe ? Colors.white : const Color(0xFF111827);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Text(
                      initials ?? '?',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA0A6),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: textColor, height: 1.25),
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA0A6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
