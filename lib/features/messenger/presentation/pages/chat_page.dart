import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late List<_ChatEntry> _items;

  @override
  void initState() {
    super.initState();
    _items = _seedItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(
        _ChatEntry.message(isMe: true, text: text, timeLabel: '오후 1:22'),
      );
    });
    _controller.clear();
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('김철수'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Top banner placeholder like the screenshot's blue border box
          Container(
            height: 100,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFE1FF), width: 2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final it = _items[index];
                if (it.type == _ChatEntryType.dateSeparator) {
                  return _DateSeparator(text: it.text);
                }
                return _MessageBubble(
                  isMe: it.isMe,
                  text: it.text,
                  timeLabel: it.timeLabel,
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

  List<_ChatEntry> _seedItems() => [
    _ChatEntry.message(
      isMe: false,
      text:
          "We've got clearer evidence that this copyright infringement case involves an overseas server.",
      timeLabel: '오후 1:21',
    ),
    _ChatEntry.message(
      isMe: true,
      text: 'Which country? Were you still tracing the IPs?',
      timeLabel: '오후 1:21',
    ),
    _ChatEntry.date('2025년 5월 3일 토요일'),
    _ChatEntry.message(
      isMe: false,
      text:
          'Yes, our analysis shows that the content was distributed via a U.S.-based hosting provider.\nWe suspect the domain owner is the same individual.',
      timeLabel: '오후 1:21',
    ),
    _ChatEntry.message(
      isMe: true,
      text:
          "Then we should prepare an MLAT request. Let's also consider going through INTERPOL.",
      timeLabel: '오후 1:21',
    ),
    _ChatEntry.message(
      isMe: false,
      text:
          "I've already drafted a preliminary request. All the details are summarized in the report.\n\nPlease review the report.",
      timeLabel: '오후 1:21',
    ),
  ];
}

enum _ChatEntryType { message, dateSeparator }

class _ChatEntry {
  final _ChatEntryType type;
  final bool isMe;
  final String text;
  final String timeLabel;

  _ChatEntry._({
    required this.type,
    this.isMe = false,
    this.text = '',
    this.timeLabel = '',
  });

  factory _ChatEntry.message({
    required bool isMe,
    required String text,
    required String timeLabel,
  }) {
    return _ChatEntry._(
      type: _ChatEntryType.message,
      isMe: isMe,
      text: text,
      timeLabel: timeLabel,
    );
  }

  factory _ChatEntry.date(String text) {
    return _ChatEntry._(type: _ChatEntryType.dateSeparator, text: text);
  }
}

class _DateSeparator extends StatelessWidget {
  final String text;
  const _DateSeparator({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String timeLabel;
  const _MessageBubble({
    required this.isMe,
    required this.text,
    required this.timeLabel,
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
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE5E7EB)),
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
                      '김철수  $timeLabel',
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
