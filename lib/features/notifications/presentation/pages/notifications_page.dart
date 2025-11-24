import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/config/app_config.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';

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
    _scrollController.removeListener(_onScroll);
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(99),
        child: Container(
          height: 99,
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F5),
            border: Border(
              bottom: BorderSide(color: Color(0xFFDCDCDC), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const SafeArea(
            bottom: false,
            child: Text(
              '알림',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProv, _) {
          final items = notifProv.notifications;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //const SizedBox(height: 8),
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
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final translatedTitle =
        l10n?.translate(notification.title.trim()) ?? notification.title;

    final contentEntries = <String>[];
    final rawContent = notification.content;
    if (rawContent != null && rawContent.trim().isNotEmpty) {
      Map<String, dynamic>? parsed;
      try {
        final decoded = jsonDecode(rawContent);
        if (decoded is Map<String, dynamic>) {
          parsed = decoded;
        } else if (decoded is Map) {
          parsed = decoded.map((key, value) => MapEntry('$key', value));
        }
      } catch (_) {
        parsed = null;
      }

      if (parsed != null) {
        parsed.forEach((key, value) {
          final label = _translateString(l10n, key);
          String displayValue = '';
          if (value is String) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              displayValue = _translateString(l10n, trimmed);
            }
          } else if (value != null) {
            displayValue = value.toString();
          }

          final line = displayValue.isEmpty ? label : '$label: $displayValue';
          if (line.trim().isNotEmpty) {
            contentEntries.add(line);
          }
        });
      } else {
        for (final line in rawContent.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            contentEntries.add(trimmed);
          }
        }
      }
    }

    final isRead = notification.isRead;
    final backgroundColor = const Color(0xFFFCFCFC);
    final titleColor = const Color(0xFF363249);
    final contentColor = const Color(0xFF363453);

    return Opacity(
      opacity: isRead ? 0.5 : 1.0,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x44000000),
              offset: Offset(2, 4),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          translatedTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (contentEntries.isNotEmpty) const SizedBox(height: 6),
                  for (final line in contentEntries)
                    Text(
                      line,
                      style: TextStyle(
                        fontSize: 14,
                        color: contentColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _translateString(AppLocalizations? l10n, String source) {
  if (source.trim().isEmpty) {
    return source;
  }
  final translated = l10n?.translate(source.trim()) ?? source.trim();
  return translated.isEmpty ? source.trim() : translated;
}
