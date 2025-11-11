import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/config/app_config.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/state/chat_provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapMessenger());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapMessenger() async {
    if (!mounted) return;
    final profile = context.read<UserProvider>().profile;
    final userId = profile?.id;
    if (userId == null || userId.isEmpty) return;

    final chat = context.read<ChatProvider>();
    await chat.connect(baseUrl: AppConfig.socketBaseUrl, userId: userId);
    if (chat.peers.isEmpty) {
      await chat.loadPeers();
    }
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('채팅'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 2),
      body: Column(
        children: [
          Container(
            height: 120,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
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
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                final peers = chat.peers;
                final filtered = _query.isEmpty
                    ? peers
                    : peers
                          .where(
                            (p) => p.displayName.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .toList();

                if (chat.loadingPeers && filtered.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                return RefreshIndicator(
                  onRefresh: chat.loadPeers,
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 160),
                            Center(
                              child: Text(
                                '대화 내역이 없습니다.',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final peer = filtered[index];
                            return _ChatListTile(
                              peer: peer,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  app_router.AppRoute.chat,
                                  arguments: app_router.ChatArgs(peer.userId),
                                );
                              },
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatUser peer;
  final VoidCallback onTap;
  const _ChatListTile({required this.peer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMessage = peer.lastMessage ?? '새 메시지를 입력해 보세요.';
    final timeLabel = _formatRelativeTime(peer.lastTime);

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
              backgroundImage:
                  (peer.profileImageUrl != null &&
                      peer.profileImageUrl!.isNotEmpty)
                  ? NetworkImage(peer.profileImageUrl!)
                  : null,
              child:
                  (peer.profileImageUrl == null ||
                      peer.profileImageUrl!.isEmpty)
                  ? Text(
                      _initials(peer.displayName),
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
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
                          peer.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeLabel,
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
                          lastMessage,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (peer.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        AppBadge(
                          text: peer.unreadCount > 99
                              ? '99+'
                              : peer.unreadCount.toString(),
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
    final first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first;
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }

  String _formatRelativeTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    return '${timestamp.year}.$month.$day';
  }
}
