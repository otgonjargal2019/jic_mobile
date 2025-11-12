import 'package:flutter/material.dart';
import 'package:jic_mob/core/provider/case_provider.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/features/cases/presentation/widgets/case_card.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/widgets/segmented_tabs.dart';
import 'package:provider/provider.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  int _tabIndex = 0; // 0: 전체, 1: 진행중, 2: 종료

  @override
  void initState() {
    super.initState();
    // Load cases when the page is first created via the global provider
    Future.microtask(() => context.read<CaseProvider>().loadCases());
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final caseProvider = context.watch<CaseProvider>();
    final isLoading = caseProvider.loading;
    final error = caseProvider.error;
    final cases = caseProvider.cases;
    // final filtered = (() {
    //   switch (_tabIndex) {
    //     case 1:
    //       return cases.where((e) => e.status == '진행중').toList();
    //     case 2:
    //       return cases.where((e) => e.status == '종료').toList();
    //     default:
    //       return cases;
    //   }
    // })();
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFDCDCDC),
            width: 1, // 1px solid line
          ),
        ),
        toolbarHeight: 99,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: const Text(
                  '전체사건 현황',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SegmentedTabs(
                  index: _tabIndex,
                  labels: const ['전체', '진행중인 사건', '종료 사건'],
                  onChanged: (i) => setState(() => _tabIndex = i),
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 12),
              if (error != null)
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<CaseProvider>().loadCases(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              else if (isLoading && cases.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<CaseProvider>().loadCases(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                          final provider = context.read<CaseProvider>();
                          provider.loadMoreCases();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: cases.length + (isLoading ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index == cases.length) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = cases[index];
                          return CaseCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                app_router.AppRoute.caseDetail,
                                arguments: app_router.CaseDetailArgs(item.id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

// removed local segmented tabs in favor of shared SegmentedTabs widget
