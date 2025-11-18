import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/models/dashboard/dashboard_data.dart';
import 'package:jic_mob/core/provider/dashboard_provider.dart';
import 'package:jic_mob/features/cases/presentation/widgets/case_card.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/features/profile/presentation/pages/profile_page.dart';
import 'package:jic_mob/features/home/presentation/widgets/case_status_donut.dart';

const _openColor = Color(0xFF3EB491);
const _onHoldColor = Color(0xFF85D685);
const _closedColor = Color(0xFF656565);

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
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final profile = context.read<UserProvider>().profile;
    final dashboard = context.watch<DashboardProvider>();
    final dashboardData = dashboard.data;
    print('UserProvider profile: ${profile?.toJson()}');
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
                blurRadius: 4,
                offset: Offset(0, 2),
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
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const _ProfileCard(),
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
              _CaseStatusSection(
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
              const SizedBox(height: 8),
              _RecentCasesSection(
                items: dashboardData?.recentCases ?? const [],
                isLoading:
                    dashboard.loading &&
                    (dashboardData?.recentCases.isEmpty ?? true),
                error: dashboard.error,
                onRetry: () => context.read<DashboardProvider>().refresh(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final name = user?.name ?? 'Guest';
    final avatarUrl = user?.avatarUrl;
    final extra = user?.extra;
    final org = _readField(extra, ['headquarterName']);
    final dept = _readField(extra, ['departmentName']);

    final headAndDeptWidget = Row(
      children: [
        Flexible(
          child: Text(
            org,
            style: const TextStyle(
              color: Color(0xFFBFC0CA),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 1,
          height: 16,
          color: Color(0xFF707070),
        ),
        Flexible(
          child: Text(
            dept,
            style: const TextStyle(
              color: Color(0xFFBFC0CA),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF363249),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFBDBDBD),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    headAndDeptWidget,
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF6D6A7C),
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfilePage.route);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _readField(Map<String, dynamic>? extra, List<String> keys) {
  if (extra == null) return '---';
  for (final key in keys) {
    final value = extra[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '---';
}

class _CaseStatusSection extends StatelessWidget {
  final DashboardProvider provider;
  final Future<void> Function()? onRetry;

  const _CaseStatusSection({required this.provider, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final data = provider.data;

    if (provider.loading && data == null) {
      return const _DashboardLoadingCard();
    }

    if (provider.error != null && data == null) {
      return _DashboardErrorCard(
        message: '대시보드 정보를 불러오지 못했습니다.',
        detail: provider.error,
        onRetry: onRetry,
      );
    }

    final summary =
        data?.summary ??
        const DashboardCaseSummary(open: 0, onHold: 0, closed: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CaseStatusCard(summary: summary, isRefreshing: provider.loading),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _InlineMessage(
              message: '최신 데이터를 불러오지 못했습니다. 다시 시도해 주세요.',
              onRetry: onRetry,
            ),
          ),
      ],
    );
  }
}

class _CaseStatusCard extends StatelessWidget {
  final DashboardCaseSummary summary;
  final bool isRefreshing;

  const _CaseStatusCard({required this.summary, this.isRefreshing = false});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: _buildCardDecoration(),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            height: 104,
            child: CaseStatusDonut(
              summary: summary,
              openColor: _openColor,
              onHoldColor: _onHoldColor,
              closedColor: _closedColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusRow(
                  label: '진행 중인 사건',
                  value: summary.open,
                  color: _openColor,
                ),
                const SizedBox(height: 8),
                _StatusRow(
                  label: '미해결 사건',
                  value: summary.onHold,
                  color: _onHoldColor,
                ),
                const SizedBox(height: 8),
                _StatusRow(
                  label: '종료된 사건',
                  value: summary.closed,
                  color: _closedColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        card,
        if (isRefreshing)
          const Positioned(
            right: 16,
            top: 16,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatusRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF464A50))),
        ),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RecentCasesSection extends StatelessWidget {
  final List<Case> items;
  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRetry;

  const _RecentCasesSection({
    required this.items,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const _DashboardLoadingCard(minHeight: 120);
    }

    if (error != null && items.isEmpty) {
      return _DashboardErrorCard(
        message: '최근 사건 정보를 불러오지 못했습니다.',
        detail: error,
        onRetry: onRetry,
      );
    }

    if (items.isEmpty) {
      return const _RecentCasesEmpty();
    }

    return Column(
      children: items.take(3).map((e) => CaseCard(item: e)).toList(),
    );
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  final double minHeight;
  const _DashboardLoadingCard({this.minHeight = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: _buildCardDecoration(),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  final String message;
  final String? detail;
  final Future<void> Function()? onRetry;

  const _DashboardErrorCard({required this.message, this.detail, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF363249),
            ),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 12),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onRetry?.call(),
                child: const Text('다시 시도'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _InlineMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFF9AA0A6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 12),
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () => onRetry?.call(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
            child: const Text('다시 시도', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

class _RecentCasesEmpty extends StatelessWidget {
  const _RecentCasesEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildCardDecoration(),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: const Text(
        '최근 수사한 사건이 없습니다.',
        style: TextStyle(color: Color(0xFF60646B)),
      ),
    );
  }
}

BoxDecoration _buildCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}
