import 'package:flutter/material.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';

class MessengerPage extends StatelessWidget {
  const MessengerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _sampleChats();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('채팅'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Column(
        children: [
          // Optional banner/header placeholder (per screenshot's top box)
          Container(
            height: 120,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '대화방, 참여자 검색',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9AA0A6)),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ChatListTile(
                  item: item,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      app_router.AppRoute.chat,
                      arguments: app_router.ChatArgs(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatItemData {
  final String id;
  final String name;
  final String message;
  final String timeLabel; // e.g. '10분전', '9월 21일'
  final int unread;
  const _ChatItemData({
    required this.id,
    required this.name,
    required this.message,
    required this.timeLabel,
    required this.unread,
  });
}

List<_ChatItemData> _sampleChats() => const [
  _ChatItemData(
    id: 'kim-1',
    name: '김철수',
    message: '보고서 검토 부탁드립니다.',
    timeLabel: '10분전',
    unread: 3,
  ),
  _ChatItemData(
    id: 'kim-2',
    name: '김하윤',
    message: '나: 증거를 업로드 했습니다.',
    timeLabel: '1시간 전',
    unread: 10,
  ),
  _ChatItemData(
    id: 'lee-1',
    name: '이준서',
    message: '현재 수사기관과 협조 중입니다. 관련…',
    timeLabel: '11시간 전',
    unread: 0,
  ),
  _ChatItemData(
    id: 'park-1',
    name: '박서연',
    message: '해당 서버는 해외에 위치해 있습니다.',
    timeLabel: '13시간 전',
    unread: 0,
  ),
  _ChatItemData(
    id: 'olivia-1',
    name: 'Olivia Bennett',
    message: 'This case has been identi…',
    timeLabel: '9월 21일',
    unread: 0,
  ),
  _ChatItemData(
    id: 'jung-1',
    name: '정지우',
    message: '피의자의 해외 접속 기록과 관련 내용…',
    timeLabel: '9월 21일',
    unread: 0,
  ),
  _ChatItemData(
    id: 'sophia-1',
    name: 'Sophia Reed',
    message: 'he server in question is loc…',
    timeLabel: '9월 21일',
    unread: 0,
  ),
];

class _ChatListTile extends StatelessWidget {
  final _ChatItemData item;
  final VoidCallback onTap;
  const _ChatListTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                _initials(item.name),
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.message,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.unread > 0) ...[
                        const SizedBox(width: 8),
                        AppBadge(
                          text: item.unread.toString(),
                          background: const Color(0xFF22C55E),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r"\s+"));
    String first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first;
    String last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}
