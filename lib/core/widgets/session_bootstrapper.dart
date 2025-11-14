import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/config/app_config.dart';
import 'package:jic_mob/core/state/chat_provider.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/core/network/realtime_gateway.dart';

/// Keeps real-time socket clients (chat, notifications) in sync with the
/// authenticated user session. Once a user logs in, the sockets connect and
/// preload unread data even before the dedicated tabs are opened.
class SessionBootstrapper extends StatefulWidget {
  final Widget child;
  const SessionBootstrapper({super.key, required this.child});

  @override
  State<SessionBootstrapper> createState() => _SessionBootstrapperState();
}

class _SessionBootstrapperState extends State<SessionBootstrapper> {
  String? _activeUserId;
  String? _activeToken;
  bool _connecting = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    _ensureSession(userProvider.profile?.id, userProvider.accessToken);
    return widget.child;
  }

  void _ensureSession(String? userId, String? token) {
    final hasCredentials =
        userId != null &&
        userId.isNotEmpty &&
        token != null &&
        token.isNotEmpty;

    if (!hasCredentials) {
      if (_activeUserId != null || _activeToken != null) {
        _teardownSockets();
      }
      return;
    }

    if (_connecting) return;
    if (_activeUserId == userId && _activeToken == token) return;

    _connecting = true;
    final targetUserId = userId;
    final targetToken = token;
    Future.microtask(() async {
      try {
        final baseUrl = AppConfig.socketBaseUrl;
        final chatProvider = context.read<ChatProvider>();
        final notificationProvider = context.read<NotificationProvider>();

        try {
          await chatProvider.connect(
            baseUrl: baseUrl,
            userId: targetUserId,
            token: targetToken,
          );
        } catch (error, stack) {
          debugPrint(
            'SessionBootstrapper: chat connect failed: $error\n$stack',
          );
        }

        try {
          await notificationProvider.connect(
            baseUrl: baseUrl,
            userId: targetUserId,
            token: targetToken,
          );
        } catch (error, stack) {
          debugPrint(
            'SessionBootstrapper: notification connect failed: $error\n$stack',
          );
        }

        if (!mounted) return;
        final connectedNow =
            chatProvider.connected || notificationProvider.connected;
        if (!connectedNow) {
          _activeUserId = null;
          _activeToken = null;
          return;
        }
        _activeUserId = targetUserId;
        _activeToken = targetToken;
      } catch (error, stack) {
        debugPrint('SessionBootstrapper: unexpected error: $error\n$stack');
      } finally {
        _connecting = false;
      }
    });
  }

  void _teardownSockets() {
    final chatProvider = context.read<ChatProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final gateway = context.read<RealtimeGateway>();
    chatProvider.disconnect();
    notificationProvider.disconnect();
    gateway.forceDisconnect();
    _activeUserId = null;
    _activeToken = null;
    _connecting = false;
  }
}
