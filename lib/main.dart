import 'package:flutter/material.dart';
import 'package:jic_mob/core/provider/case_provider.dart';
import 'package:jic_mob/core/provider/dashboard_provider.dart';
import 'package:jic_mob/core/repository/case_repository.dart';
import 'package:jic_mob/core/repository/dashboard_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/app_router.dart' as app_router;
import 'package:provider/provider.dart';
import 'core/state/user_provider.dart';
import 'core/state/chat_provider.dart';
import 'core/repository/posts_repository.dart';
import 'core/provider/posts_provider.dart';
import 'core/repository/investigation_record_repository.dart';
import 'core/provider/investigation_record_provider.dart';
import 'core/state/notification_provider.dart';
import 'core/widgets/session_bootstrapper.dart';
import 'core/network/realtime_gateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeGateway()),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PostsProvider(PostsRepository()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ChatProvider(ctx.read<RealtimeGateway>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotificationProvider(ctx.read<RealtimeGateway>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CaseProvider(
            CaseRepository(context.read<UserProvider>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InvestigationRecordProvider(
            InvestigationRecordRepository(),
          ),
        ),
      ],
      child: const SessionBootstrapper(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      fontFamily: 'NotoSansKR',
      fontFamilyFallback: const ['Inter'],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.appTitle ?? 'JIC',
      theme: baseTheme.copyWith(colorScheme: baseTheme.colorScheme),
      locale: const Locale('ko'),
      onGenerateRoute: app_router.onGenerateRoute,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ko')],
      home: const LoginPage(),
      routes: {
        LoginPage.route: (_) => const LoginPage(),
        ProfilePage.route: (_) => const ProfilePage(),
      },
    );
  }
}
