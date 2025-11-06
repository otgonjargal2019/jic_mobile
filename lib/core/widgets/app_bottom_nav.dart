import 'package:flutter/material.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;

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
    return NavigationBar(
      selectedIndex: currentIndex,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => _onTap(context, i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(Icons.folder_open),
          label: 'Cases',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Messenger',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: 'Posts',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none),
          selectedIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
    );
  }
}
