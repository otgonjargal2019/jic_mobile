import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/core/config/app_config.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreNotifications = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProv = context.read<UserProvider>();
      final notifProv = context.read<NotificationProvider>();
      final token = userProv.accessToken;
      final myId = userProv.profile?.id;

      if (myId == null || myId.isEmpty || token == null || token.isEmpty) {
        return;
      }
      try {
        await notifProv.connect(
          baseUrl: AppConfig.socketBaseUrl,
          userId: myId,
          token: token,
        );
      } catch (_) {
        return;
      }

      if (notifProv.notifications.isEmpty) {
        await notifProv.loadInitialPage();
      }
      await notifProv.refreshUnreadCount();
      if (!mounted) return;
      setState(() {
        _hasMoreNotifications = notifProv.hasMore;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreNotifications) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final notifProv = context.read<NotificationProvider>();
    final notifications = notifProv.notifications;

    if (notifications.isEmpty) {
      setState(() {
        _isLoadingMore = false;
        _hasMoreNotifications = false;
      });
      return;
    }

    final oldestNotif = notifications.last;
    await notifProv.loadMoreNotifications(
      before: oldestNotif.createdAt,
      limit: 20,
    );

    setState(() {
      _isLoadingMore = false;
      _hasMoreNotifications = notifProv.hasMore;
    });
  }

  Future<void> _onRefresh() async {
    final notifProv = context.read<NotificationProvider>();
    await notifProv.loadInitialPage();
    await notifProv.refreshUnreadCount(fallbackDelay: Duration.zero);
    setState(() {
      _hasMoreNotifications = notifProv.hasMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 0,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProv, _) {
          final items = notifProv.notifications;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 60, color: Colors.white),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (notifProv.unreadCount > 0)
                      TextButton(
                        onPressed: () => notifProv.markAllAsRead(),
                        child: const Text('모두 읽음'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: notifProv.loadingPage && items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? const Center(
                        child: Text(
                          '알림이 없습니다',
                          style: TextStyle(color: Color(0xFF9AA0A6)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          itemCount: items.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == items.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final notification = items[index];
                            return _NotificationCard(
                              notification: notification,
                              onTap: () {
                                if (!notification.isRead) {
                                  notifProv.markAsRead(
                                    notification.notificationId,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const _NotificationCard({required this.notification, this.onTap});

  String _formatDateTime(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final contentLines = notification.content?.split('\n') ?? [];

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF3B82F6).withOpacity(0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            if (contentLines.isNotEmpty) const SizedBox(height: 6),
            for (final line in contentLines) ...[
              if (line.trim().isNotEmpty)
                Text(
                  line,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Text(
              _formatDateTime(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
      ),
    );
  }
}
