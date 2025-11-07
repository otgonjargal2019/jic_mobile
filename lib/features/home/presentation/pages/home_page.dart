import 'package:flutter/material.dart';
import 'package:jic_mob/features/cases/domain/models/case_item.dart';
import 'package:jic_mob/features/cases/presentation/widgets/case_card.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';

class HomePage extends StatefulWidget {
  static const route = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _HeaderCard(),
            SizedBox(height: 12),
            _ProfileCard(),
            SizedBox(height: 12),
            _CaseStatusCard(),
            SizedBox(height: 12),
            _RecentCasesSection(),
            SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: const [
          _MiniLogo(size: 20),
          SizedBox(width: 8),
          Text(
            '국제공조수사플랫폼',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C3C43),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final name = user?.name ?? 'Guest';
    final email = user?.email ?? '—';
    final shortId = (user?.id ?? '').isNotEmpty
        ? '#${(user!.id.length >= 8 ? user.id.substring(0, 8) : user.id)}'
        : 'Not signed in';
    final avatarUrl = user?.avatarUrl;
    const cardColor = Color(0xFF2C2D3A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: email),
                        _Chip(text: shortId),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              tooltip: 'Logout',
              onPressed: () async {
                try {
                  final api = await ApiClient.create();
                  await api.logout();
                } catch (_) {}

                if (context.mounted) {
                  // Clear user provider state on logout
                  context.read<UserProvider>().clear();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3B49),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CaseStatusCard extends StatelessWidget {
  const _CaseStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내사건 현황',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: _Donut(total: 27, percent: 0.72),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: const [
                      _StatusRow(
                        label: '진행 중인 사건',
                        value: 3,
                        color: Color(0xFF39BE8C),
                      ),
                      SizedBox(height: 8),
                      _StatusRow(
                        label: '미해결 사건',
                        value: 10,
                        color: Color(0xFF9AA0A6),
                      ),
                      SizedBox(height: 8),
                      _StatusRow(
                        label: '종료된 사건',
                        value: 13,
                        color: Color(0xFF60646B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

class _Donut extends StatelessWidget {
  final int total;
  final double percent; // 0..1
  const _Donut({required this.total, required this.percent});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF39BE8C);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 10,
            backgroundColor: const Color(0xFFEAECEE),
            color: green,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$total',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const Text(
              '건',
              style: TextStyle(color: Color(0xFF9AA0A6), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentCasesSection extends StatelessWidget {
  const _RecentCasesSection();

  @override
  Widget build(BuildContext context) {
    final items = [
      const CaseItem(
        title: '해외 공유 플랫폼 사이트에 업로드 사건',
        chips: const ['유튜브동영상', '디지털 포렌식 수집됨'],
        status: '진행중',
        date: '2024.01.21',
        id: '156-8156',
      ),
      const CaseItem(
        title: '해외 공유 플랫폼 사이트에 업로드 사건',
        chips: const ['트위터게시물', '디지털 증거물 수집중'],
        status: '진행중',
        date: '2024.01.21',
        id: '156-8157',
      ),
      const CaseItem(
        title: '해외 공유 플랫폼 사이트에 업로드 사건',
        chips: const ['트위터게시물', '디지털 증거물 수집중'],
        status: '진행중',
        date: '2024.01.21',
        id: '156-8158',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 수사한 사건',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...items.map((e) => CaseCard(item: e)).toList(),
      ],
    );
  }
}

class _MiniLogo extends StatelessWidget {
  final double size;
  const _MiniLogo({this.size = 18});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2E7BF6);
    const green = Color(0xFF39BE8C);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.6,
            child: _roundedTile(color: blue, size: size * 0.95),
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: Transform.rotate(
              angle: -0.6,
              child: _roundedTile(color: green, size: size * 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedTile({required Color color, required double size}) {
    return Container(
      width: size,
      height: size * 0.55,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
    );
  }
}
