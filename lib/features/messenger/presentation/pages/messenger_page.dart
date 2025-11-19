import 'dart:async';

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
  Timer? _searchDebounce;
  List<ChatUser> _searchResults = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapMessenger());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapMessenger() async {
    if (!mounted) return;
    final profile = context.read<UserProvider>().profile;
    final userId = profile?.id;
    final token = context.read<UserProvider>().accessToken;
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      return;
    }

    final chat = context.read<ChatProvider>();
    await chat.connect(
      baseUrl: AppConfig.socketBaseUrl,
      userId: userId,
      token: token,
    );
    if (chat.peers.isEmpty) {
      await chat.loadPeers();
    }
  }

  void _onQueryChanged(String value) {
    final trimmed = value.trim();
    if (_query != trimmed) {
      setState(() {
        _query = trimmed;
      });
    }

    _searchDebounce?.cancel();

    if (trimmed.isEmpty) {
      if (_searchResults.isNotEmpty || _searching) {
        setState(() {
          _searchResults = const [];
          _searching = false;
        });
      }
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(trimmed);
    });
  }

  Future<void> _performSearch(String query) async {
    final chat = context.read<ChatProvider>();
    if (!chat.connected) {
      // Ensure connection exists before searching
      final profile = context.read<UserProvider>().profile;
      final userId = profile?.id;
      final token = context.read<UserProvider>().accessToken;
      if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
        return;
      }
      await chat.connect(
        baseUrl: AppConfig.socketBaseUrl,
        userId: userId,
        token: token,
      );
    }

    setState(() {
      _searching = true;
    });

    try {
      final results = await chat.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    return Scaffold(
      backgroundColor: background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(99),
        child: _MessengerAppBar(),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: '대화방, 참여자 검색',
                hintStyle: const TextStyle(
                  color: Color(0xFF909090),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9AA0A6),
                  size: 28,
                ),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFE7E7E7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chat, _) {
                  final peers = chat.peers;
                  final lowercaseQuery = _query.toLowerCase();
                  final filtered = _query.isEmpty
                      ? peers
                      : peers
                            .where(
                              (p) => p.displayName.toLowerCase().contains(
                                lowercaseQuery,
                              ),
                            )
                            .toList();

                  final hasQuery = _query.isNotEmpty;
                  List<ChatUser> displayList;
                  if (hasQuery) {
                    final Map<String, ChatUser> merged = {
                      for (final peer in filtered) peer.userId: peer,
                    };
                    for (final result in _searchResults) {
                      merged.putIfAbsent(result.userId, () => result);
                    }
                    displayList = merged.values.toList();
                  } else {
                    displayList = filtered;
                  }

                  if (!hasQuery && chat.loadingPeers && displayList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  if (hasQuery && _searching && displayList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _query.isEmpty
                        ? chat.loadPeers()
                        : _performSearch(_query),
                    child: displayList.isEmpty
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
                        : ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final peer = displayList[index];
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
      ),
    );
  }
}

class _MessengerAppBar extends StatelessWidget {
  const _MessengerAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 99,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F5),
        border: Border(bottom: BorderSide(color: Color(0xFFDCDCDC), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        '채팅',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Color(0xFF000000),
        ),
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
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                            color: Color(0xFF000000),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF909090),
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
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 15,
                          ),
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
                          background: const Color(0xFF3EB491),
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
