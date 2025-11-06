import 'package:flutter/material.dart';
import 'package:jic_mob/features/cases/presentation/pages/case_detail_page.dart';
import 'package:jic_mob/features/cases/presentation/pages/cases_page.dart';
import 'package:jic_mob/features/cases/presentation/pages/record_detail_page.dart';
import 'package:jic_mob/features/messenger/presentation/pages/chat_page.dart';
import 'package:jic_mob/features/messenger/presentation/pages/messenger_page.dart';
import 'package:jic_mob/features/posts/presentation/pages/post_detail_page.dart';
import 'package:jic_mob/features/posts/presentation/pages/posts_page.dart';
import 'package:jic_mob/features/notifications/presentation/pages/notifications_page.dart';

class AppRoute {
  static const cases = '/cases';
  static const caseDetail = '/cases/detail';
  static const recordDetail = '/records/detail';
  static const messenger = '/messenger';
  static const chat = '/chat';
  static const posts = '/posts';
  static const postDetail = '/posts/detail';
  static const notifications = '/notifications';
}

class CaseDetailArgs {
  final String id;
  const CaseDetailArgs(this.id);
}

class RecordDetailArgs {
  final String id;
  const RecordDetailArgs(this.id);
}

class ChatArgs {
  final String chatId;
  const ChatArgs(this.chatId);
}

class PostDetailArgs {
  final String id;
  const PostDetailArgs(this.id);
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoute.cases:
      return MaterialPageRoute(builder: (_) => const CasesPage());
    case AppRoute.caseDetail:
      final args = settings.arguments as CaseDetailArgs?;
      return MaterialPageRoute(
        builder: (_) => CaseDetailPage(id: args?.id ?? ''),
      );
    case AppRoute.recordDetail:
      final args = settings.arguments as RecordDetailArgs?;
      return MaterialPageRoute(
        builder: (_) => RecordDetailPage(id: args?.id ?? ''),
      );
    case AppRoute.messenger:
      return MaterialPageRoute(builder: (_) => const MessengerPage());
    case AppRoute.chat:
      final args = settings.arguments as ChatArgs?;
      return MaterialPageRoute(
        builder: (_) => ChatPage(chatId: args?.chatId ?? ''),
      );
    case AppRoute.posts:
      return MaterialPageRoute(builder: (_) => const PostsPage());
    case AppRoute.postDetail:
      final args = settings.arguments as PostDetailArgs?;
      return MaterialPageRoute(
        builder: (_) => PostDetailPage(id: args?.id ?? ''),
      );
    case AppRoute.notifications:
      return MaterialPageRoute(builder: (_) => const NotificationsPage());
  }
  return null;
}
