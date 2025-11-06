import 'package:flutter/material.dart';
import 'package:jic_mob/core/widgets/segmented_tabs.dart';
import 'package:jic_mob/core/widgets/app_tag.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;

class CaseDetailPage extends StatefulWidget {
  final String id;
  const CaseDetailPage({super.key, required this.id});

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  int _tabIndex = 0; // 0: 사건 정보, 1: 수사기록 내역

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('사건 상세'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3C3C43),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '해외 공유 플랫폼 사이트에 업로드 사건',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              AppTag(text: '유튜브동영상'),
              AppTag(text: '디지털 증거물 수집중'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoSummary(id: widget.id),
          const SizedBox(height: 12),
          SegmentedTabs(
            index: _tabIndex,
            labels: const ['사건 정보', '수사기록 내역'],
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 12),
          if (_tabIndex == 0) ...[
            _SectionCard(
              title: '사건 개요',
              body:
                  '성범죄사건가 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 원고는 성범죄자 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 원고는 성범죄자 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 업로드를 제지 [더보기]',
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '기타사항',
              body:
                  '성범죄사건가 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 원고는 성범죄자 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 원고는 성범죄자 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한 저작침해소송으로 업로드를 제지 [더보기]',
            ),
          ] else ...[
            _RecordList(),
          ],
        ],
      ),
    );
  }
}

class _InfoSummary extends StatelessWidget {
  final String id;
  const _InfoSummary({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _row('사건 번호', id),
          _row('발생 일시', '2024-01-01 05:59:00'),
          _row('수사 대응 순위', 'C0'),
          _row('관련국가', '태국'),
          _row('콘텐츠 유형', '웹툰'),
          _row('저작권 침해 유형', '불법 유통'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String body;
  const _SectionCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Color(0xFF464A50))),
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) {
        final recId = 'REC-${i + 1}';
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              app_router.AppRoute.recordDetail,
              arguments: app_router.RecordDetailArgs(recId),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
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
              children: [
                const AppBadge(text: '기록', filled: false),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '디지털 포렌식 증거물 수집',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('2024.01.2${i}'),
              ],
            ),
          ),
        );
      }),
    );
  }
}
