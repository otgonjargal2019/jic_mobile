import 'package:flutter/material.dart';
import 'package:jic_mob/core/provider/case_provider.dart';
import 'package:jic_mob/core/provider/dashboard_provider.dart';
import 'package:jic_mob/core/repository/case_repository.dart';
import 'package:jic_mob/core/repository/dashboard_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/app_router.dart' as app_router;
import 'package:provider/provider.dart';
import 'core/state/user_provider.dart';
import 'core/state/chat_provider.dart';
import 'core/network/api_client.dart';
import 'core/repository/posts_repository.dart';
import 'core/provider/posts_provider.dart';
import 'core/repository/investigation_record_repository.dart';
import 'core/provider/investigation_record_provider.dart';
import 'core/state/notification_provider.dart';
import 'core/widgets/session_bootstrapper.dart';
import 'core/network/realtime_gateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create API client (handles cookies etc.)
  final apiClient = await ApiClient.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeGateway()),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => PostsProvider(PostsRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ChatProvider(ctx.read<RealtimeGateway>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotificationProvider(ctx.read<RealtimeGateway>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CaseProvider(
            CaseRepository(apiClient, context.read<UserProvider>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => InvestigationRecordProvider(
            InvestigationRecordRepository(apiClient),
          ),
        ),
      ],
      child: const SessionBootstrapper(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.appTitle ?? 'JIC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
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
        '/home': (_) => const HomePage(),
        ProfilePage.route: (_) => const ProfilePage(),
      },
    );
  }
}
