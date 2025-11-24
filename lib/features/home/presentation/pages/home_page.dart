import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jic_mob/core/provider/dashboard_provider.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/features/home/presentation/widgets/profile_card.dart';
import 'package:jic_mob/features/home/presentation/widgets/case_status_section.dart';
import 'package:jic_mob/features/home/presentation/widgets/recent_cases_section.dart';

class HomePage extends StatefulWidget {
  static const route = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final dashboard = context.watch<DashboardProvider>();
    final dashboardData = dashboard.data;
    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(99),
        child: Container(
          decoration: const BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDCDCDC), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          height: 99,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 28, height: 28),
              const SizedBox(width: 12),
              const Text(
                '국제공조수사플랫폼',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF363249),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardProvider>().refresh(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const ProfileCard(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  '내사건 현황',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF363453),
                  ),
                ),
              ),
              CaseStatusSection(
                provider: dashboard,
                onRetry: () => context.read<DashboardProvider>().refresh(),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  '최근 수사한 사건',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF363453),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              RecentCasesSection(
                items: dashboardData?.recentCases ?? const [],
                isLoading:
                    dashboard.loading &&
                    (dashboardData?.recentCases.isEmpty ?? true),
                error: dashboard.error,
                onRetry: () => context.read<DashboardProvider>().refresh(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0),
    );
  }
}
