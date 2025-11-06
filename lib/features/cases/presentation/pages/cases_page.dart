import 'package:flutter/material.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/features/cases/domain/models/case_item.dart';
import 'package:jic_mob/features/cases/presentation/widgets/case_card.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/widgets/segmented_tabs.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  int _tabIndex = 0; // 0: 전체, 1: 진행중, 2: 종료

  List<CaseItem> get _all => _sampleItems();
  List<CaseItem> get _filtered {
    switch (_tabIndex) {
      case 1:
        return _all.where((e) => e.status == '진행중').toList();
      case 2:
        return _all.where((e) => e.status == '종료').toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '전체사건 현황',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 12),
              SegmentedTabs(
                index: _tabIndex,
                labels: const ['전체', '진행중인 사건', '종료 사건'],
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: 12),
              Expanded(child: _CasesList(_filtered)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _CasesList extends StatelessWidget {
  final List<CaseItem> items;
  const _CasesList(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) => CaseCard(
        item: items[index],
        onTap: () {
          Navigator.of(context).pushNamed(
            app_router.AppRoute.caseDetail,
            arguments: app_router.CaseDetailArgs(items[index].id),
          );
        },
      ),
    );
  }
}

List<CaseItem> _sampleItems() {
  return const [
    CaseItem(
      title: '해외 공유 플랫폼 사이트에 업로드 사건',
      chips: ['유튜브동영상', '디지털 포렌식 수집됨'],
      status: '진행중',
      date: '2024.01.21',
      id: '156-8156',
    ),
    CaseItem(
      title: '해외 공유 플랫폼 사이트에 업로드 사건',
      chips: ['트위터게시물', '디지털 증거물 수집중'],
      status: '진행중',
      date: '2024.01.21',
      id: '156-8157',
    ),
    CaseItem(
      title: '해외 공유 플랫폼 사이트에 업로드 사건',
      chips: ['트위터게시물', '디지털 증거물 수집중'],
      status: '종료',
      date: '2024.01.21',
      id: '156-8158',
    ),
  ];
}

// removed local segmented tabs in favor of shared SegmentedTabs widget
