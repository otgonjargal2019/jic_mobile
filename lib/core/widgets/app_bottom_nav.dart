import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/state/chat_provider.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';

class AppBottomNav extends StatelessWidget {
  final int
  currentIndex; // 0: Home, 1: Cases, 2: Messenger, 3: Posts, 4: Notifications
  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int i) {
    if (i == currentIndex) return; // no-op if selecting current tab
    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(app_router.AppRoute.cases);
        break;
      case 2:
        Navigator.of(
          context,
        ).pushReplacementNamed(app_router.AppRoute.messenger);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(app_router.AppRoute.posts);
        break;
      case 4:
        Navigator.of(
          context,
        ).pushReplacementNamed(app_router.AppRoute.notifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final unreadUsers = chat.unreadUsersCount;

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
        const NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
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
