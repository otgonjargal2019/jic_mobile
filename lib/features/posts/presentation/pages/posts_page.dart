import 'package:flutter/material.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/core/widgets/segmented_tabs.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  int _tab = 0; // 0: 공지사항, 1: 조사정보

  @override
  Widget build(BuildContext context) {
    final notices = _sampleNotices;
    final investigations = _sampleInvestigations;
    final list = _tab == 0 ? notices : investigations;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text('게시판'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SegmentedTabs(
              index: _tab,
              labels: const ['공지사항', '조사정보'],
              onChanged: (i) => setState(() => _tab = i),
              backgroundColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = list[index];
                return _PostTile(
                  title: item.title,
                  dateTimeLabel: item.dateTimeLabel,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      app_router.AppRoute.postDetail,
                      arguments: app_router.PostDetailArgs(item.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_PostItem> get _sampleNotices => const [
    _PostItem(
      id: 'p1',
      title: '인터폴 협력 사례 공유 세미나 참가 신청 안내',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p2',
      title: '2025 상반기 국제공조수사 워크샵 개최 안내',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p3',
      title: '국제 수사정보 공유 시스템 사용자 교육 일정 공지',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p4',
      title: '국제사이버범죄 공동대응 훈련 참가자 모집',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p5',
      title: '국가별 수사협력 연락망 업데이트 안내',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p6',
      title: '공조수사 성공사례 리포트 발간 알림',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p7',
      title: '범죄정보 실시간 공유 기능 점검 일정 안내',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p8',
      title: '국제수배자 데이터베이스 정기 점검 공지',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'p9',
      title: '신규 가입 수사관 대상 플랫폼 오리엔테이션 안내',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
  ];

  List<_PostItem> get _sampleInvestigations => const [
    _PostItem(
      id: 'i1',
      title: '랜섬웨어 조직 X 관련 수사 동향',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'i2',
      title: '불법 도박 플랫폼 자금 흐름 분석 공유',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
    _PostItem(
      id: 'i3',
      title: '해외 호스팅 업체 협조 가이드 업데이트',
      dateTimeLabel: '2024-02-09 18:32:44',
    ),
  ];
}

class _PostItem {
  final String id;
  final String title;
  final String dateTimeLabel;
  const _PostItem({
    required this.id,
    required this.title,
    required this.dateTimeLabel,
  });
}

class _PostTile extends StatelessWidget {
  final String title;
  final String dateTimeLabel;
  final VoidCallback onTap;
  const _PostTile({
    required this.title,
    required this.dateTimeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateTimeLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
      ),
    );
  }
}
