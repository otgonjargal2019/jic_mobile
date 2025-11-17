import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/state/chat_provider.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int i) {
    if (i == currentIndex) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    switch (i) {
      case 0:
        navigator.pushReplacementNamed('/home');
        break;
      case 1:
        navigator.pushReplacementNamed(app_router.AppRoute.cases);
        break;
      case 2:
        navigator.pushReplacementNamed(app_router.AppRoute.messenger);
        break;
      case 3:
        navigator.pushReplacementNamed(app_router.AppRoute.posts);
        break;
      case 4:
        navigator.pushReplacementNamed(app_router.AppRoute.notifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final unreadUsers = chat.unreadUsersCount;

    final notif = context.watch<NotificationProvider>();
    final unreadNotifCount = notif.unreadCount;

    return NavigationBar(
      selectedIndex: currentIndex,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => _onTap(context, i),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(Icons.folder_open),
          label: 'Cases',
        ),
        NavigationDestination(
          icon: _NavIconWithBadge(
            icon: Icon(Icons.chat_bubble_outline),
            badgeCount: unreadUsers,
          ),
          selectedIcon: _NavIconWithBadge(
            icon: Icon(Icons.chat_bubble),
            badgeCount: unreadUsers,
          ),
          label: 'Messenger',
        ),
        const NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: 'Posts',
        ),
        NavigationDestination(
          icon: _NavIconWithBadge(
            icon: Icon(Icons.notifications_none),
            badgeCount: unreadNotifCount,
          ),
          selectedIcon: _NavIconWithBadge(
            icon: Icon(Icons.notifications),
            badgeCount: unreadNotifCount,
          ),
          label: 'Notifications',
        ),
      ],
    );
  }
}

class _NavIconWithBadge extends StatelessWidget {
  final Widget icon;
  final int badgeCount;

  const _NavIconWithBadge({required this.icon, required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) return icon;

    final display = badgeCount > 99 ? '99+' : badgeCount.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -10,
          top: -4,
          child: AppBadge(
            text: display,
            background: const Color(0xFF22C55E),
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          ),
        ),
      ],
    );
  }
}
