import 'package:flutter/material.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _sampleNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 0, // hide default toolbar; custom header below
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top white banner placeholder like in the screenshot
          Container(height: 60, color: Colors.white),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: const Text(
              '알림',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final it = items[index];
                return _NotificationCard(item: it);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_NotificationItem> get _sampleNotifications => [
    _NotificationItem(title: '회원 정보 변경 승인', dateTime: '2024-02-09 18:32:44'),
    _NotificationItem(
      title: '회원 정보 변경 거절',
      lines: const ['사유 : 시스템 정보상 정보와 불일치'],
      dateTime: '2024-02-09 18:32:44',
    ),
    _NotificationItem(
      title: '신규 사건 배정',
      lines: const ['사건 번호 : 3254', '사건 명 : 웹툴 A 수단 복제사건'],
      dateTime: '2024-02-09 18:32:44',
    ),
    _NotificationItem(
      title: '상세 진행 현황 변동',
      lines: const ['사건 번호 : 3254', '사건 명 : 웹툴 A 수단 복제사건'],
      dateTime: '2024-02-09 18:32:44',
    ),
    _NotificationItem(
      title: '계정 권한 변동',
      lines: const ['계정 권한이 “수사관리자”로 변경되었습니다.'],
      dateTime: '2024-02-09 18:32:44',
    ),
    _NotificationItem(
      title: '신규 계정 등록',
      lines: const ['ID : Bump18267', '성명 : 김철수'],
      dateTime: '2024-02-09 18:32:44',
    ),
  ];
}

class _NotificationItem {
  final String title;
  final List<String> lines;
  final String dateTime;
  const _NotificationItem({
    required this.title,
    this.lines = const [],
    required this.dateTime,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (item.lines.isNotEmpty) const SizedBox(height: 6),
          for (final line in item.lines) ...[
            Text(
              line,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.dateTime,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
          ),
        ],
      ),
    );
  }
}
