import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/state/chat_provider.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    switch (index) {
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

    final theme = Theme.of(context);
    const activeColor = Color(0xFF1F2933);
    const inactiveColor = Color(0xFF9CA3AF);
    final labelStyle =
        theme.textTheme.labelSmall ?? const TextStyle(fontSize: 12);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 90,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        backgroundColor: Colors.white,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? activeColor
              : inactiveColor;
          return IconThemeData(color: color, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? activeColor
              : inactiveColor;
          return labelStyle.copyWith(height: 0.85, color: color);
        }),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDCDCDC), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '홈',
            ),
            const NavigationDestination(
              icon: Icon(Icons.apps),
              selectedIcon: Icon(Icons.apps_outlined),
              label: '전체사건',
            ),
            NavigationDestination(
              icon: Semantics(
                label: '메신저',
                child: SizedBox(
                  height: 60,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, 3),
                      child: _NavIconWithBadge(
                        icon: Transform.rotate(
                          angle: -0.6,
                          child: const Icon(Icons.send_outlined),
                        ),
                        badgeCount: unreadUsers,
                      ),
                    ),
                  ),
                ),
              ),
              selectedIcon: Semantics(
                label: '메신저',
                child: SizedBox(
                  height: 60,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, 3),
                      child: _NavIconWithBadge(
                        icon: Transform.rotate(
                          angle: -0.6,
                          child: const Icon(Icons.send),
                        ),
                        badgeCount: unreadUsers,
                      ),
                    ),
                  ),
                ),
              ),
              label: '',
            ),
            const NavigationDestination(
              icon: Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article),
              label: '게시판',
            ),
            NavigationDestination(
              icon: _NavIconWithBadge(
                icon: const Icon(Icons.notifications_none),
                badgeCount: unreadNotifCount,
              ),
              selectedIcon: _NavIconWithBadge(
                icon: const Icon(Icons.notifications),
                badgeCount: unreadNotifCount,
              ),
              label: '알람',
            ),
          ],
        ),
      ),
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
