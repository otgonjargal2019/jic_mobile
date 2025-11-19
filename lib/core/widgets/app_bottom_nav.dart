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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCDCDC), width: 1)),
      ),
      child: Material(
        color: Colors.white,
        child: SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BottomNavItem(
                selected: currentIndex == 0,
                label: '홈',
                semanticsLabel: '홈',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: labelStyle,
                onTap: () => _onTap(context, 0),
                iconBuilder: (selected) =>
                    Icon(selected ? Icons.home : Icons.home_outlined),
              ),
              _BottomNavItem(
                selected: currentIndex == 1,
                label: '전체사건',
                semanticsLabel: '전체사건',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: labelStyle,
                onTap: () => _onTap(context, 1),
                iconBuilder: (selected) =>
                    Icon(selected ? Icons.apps : Icons.apps_outlined),
              ),
              _BottomNavItem(
                selected: currentIndex == 2,
                label: '',
                semanticsLabel: '메신저',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: labelStyle,
                onTap: () => _onTap(context, 2),
                iconBuilder: (selected) => _MessengerNavIcon(
                  selected: selected,
                  badgeCount: unreadUsers,
                ),
              ),
              _BottomNavItem(
                selected: currentIndex == 3,
                label: '게시판',
                semanticsLabel: '게시판',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: labelStyle,
                onTap: () => _onTap(context, 3),
                iconBuilder: (selected) =>
                    Icon(selected ? Icons.article : Icons.article_outlined),
              ),
              _BottomNavItem(
                selected: currentIndex == 4,
                label: '알람',
                semanticsLabel: '알람',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                labelStyle: labelStyle,
                onTap: () => _onTap(context, 4),
                iconBuilder: (selected) => _NavIconWithBadge(
                  icon: Icon(
                    selected ? Icons.notifications : Icons.notifications_none,
                  ),
                  badgeCount: unreadNotifCount,
                ),
              ),
            ],
          ),
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

class _MessengerNavIcon extends StatelessWidget {
  final bool selected;
  final int badgeCount;

  const _MessengerNavIcon({required this.selected, required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    const messengerColor = Color(0xFF3EB491);
    const badgeColor = Color(0xFFF6C944);
    const Color background = messengerColor;
    final Color iconColor = selected ? const Color(0xFF1F2933) : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: background,
          ),
          padding: const EdgeInsets.all(10),
          child: const SizedBox(width: 24, height: 24),
        ),
        Transform.rotate(
          angle: -0.6,
          child: Icon(Icons.send_outlined, color: iconColor, size: 24),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -5,
            top: 0,
            child: AppBadge(
              text: badgeCount > 99 ? '99+' : badgeCount.toString(),
              filled: true,
              background: badgeColor,
              textStyle: TextStyle(
                color: iconColor,
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

class _BottomNavItem extends StatelessWidget {
  final bool selected;
  final String label;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget Function(bool selected) iconBuilder;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;

  const _BottomNavItem({
    required this.selected,
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
    required this.iconBuilder,
    required this.activeColor,
    required this.inactiveColor,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? activeColor : inactiveColor;
    final bool hasLabel = label.isNotEmpty;

    return Expanded(
      child: Semantics(
        label: semanticsLabel,
        selected: selected,
        button: true,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              splashColor: const Color(0x1F000000),
              highlightColor: const Color(0x14000000),
              hoverColor: const Color(0x14000000),
              focusColor: const Color(0x14000000),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: IconThemeData(color: foreground, size: 24),
                        child: iconBuilder(selected),
                      ),
                      if (hasLabel) ...[
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: labelStyle.copyWith(
                            color: foreground,
                            height: 1.0,
                          ),
                          child: Text(label),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
