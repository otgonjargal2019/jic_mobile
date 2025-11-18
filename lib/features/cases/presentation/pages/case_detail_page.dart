import 'package:flutter/material.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/widgets/segmented_tabs.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/provider/case_provider.dart';
import 'package:jic_mob/core/provider/investigation_record_provider.dart';
import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/models/investigation_record/investigation_record.dart';
import 'package:provider/provider.dart';

class CaseDetailPage extends StatefulWidget {
  final String id;
  const CaseDetailPage({super.key, required this.id});

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  int _tabIndex = 0; // 0: 사건 정보, 1: 수사기록 내역

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CaseProvider>().loadCaseByUUID(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final provider = context.watch<CaseProvider>();
    final isLoading = provider.loading;
    final error = provider.error;
    final caseDetail = provider.currentCase;

    final AppLocalizations loc = AppLocalizations.of(context)!;

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
      body: ListView(
        padding: const EdgeInsets.all(0.0),
        children: [
          if (error != null) ...[
            const SizedBox(height: 40),
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 12),
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<CaseProvider>().loadCaseByUUID(widget.id),
              child: const Text('다시 시도'),
            ),
          ] else if (isLoading) ...[
            const SizedBox(height: 40),
            const Center(child: CircularProgressIndicator()),
          ] else if (caseDetail != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        caseDetail.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: Color(0xFF39BE8C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        caseDetail.status.trim().isNotEmpty
                            ? loc.translate(
                                'case_details.status.${caseDetail.status}',
                              )
                            : '',
                        style: const TextStyle(
                          color: Color(0xFF39BE8C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      caseDetail.progressStatus.trim().isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              child: Text(
                                '|',
                                style: const TextStyle(
                                  color: Color(0xFFD4D4D4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Text(
                        caseDetail.progressStatus.trim().isNotEmpty
                            ? loc.translate(
                                'case_details.progressStatus.${caseDetail.progressStatus}',
                              )
                            : '',
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10, child: Container(color: Color(0xFFEAEAEA))),
            _InfoSummary(caseData: caseDetail),
            SizedBox(height: 10, child: Container(color: Color(0xFFEAEAEA))),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedTabs(
                    backgroundColor: Colors.transparent,
                    index: _tabIndex,
                    labels: [
                      loc.translate('case_details.caseInformation'),
                      loc.translate('case_details.invRecordsList'),
                    ],
                    onChanged: (i) => setState(() {
                      _tabIndex = i;
                      if (i == 1) {
                        context.read<InvestigationRecordProvider>().loadRecords(
                          caseId: widget.id,
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  if (_tabIndex == 0) ...[
                    _SectionCard(
                      title: loc.translate('case_details.caseOutline'),
                      body: caseDetail.outline,
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: loc.translate('case_details.etc'),
                      body: caseDetail.etc,
                    ),
                  ] else ...[
                    _RecordList(caseId: widget.id),
                  ],
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 40),
            const Center(child: Text('데이터가 없습니다')),
          ],
        ],
      ),
    );
  }
}

class _InfoSummary extends StatelessWidget {
  final Case caseData;
  const _InfoSummary({required this.caseData});

  String priorityLabel(dynamic priority) {
    if (priority == null) return '-';
    final s = priority.toString();
    const mapping = {'1': 'C1', '2': 'C2', '3': 'C3', '4': 'C4', '5': 'C5'};
    return mapping[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row(loc.translate('case_details.case_number'), caseData.number),
          _row(
            loc.translate('case_details.investigationDate'),
            caseData.investigationDate,
          ),
          _row(
            loc.translate('case_details.priority'),
            priorityLabel(caseData.priority),
          ),
          _row(
            loc.translate('case_details.relatedCountries'),
            caseData.relatedCountries,
          ),
          _row(loc.translate('case_details.contentType'), caseData.contentType),
          _row(
            loc.translate('case_details.infringementType'),
            loc.translate(
              'case_details.case_infringement_type.${caseData.infringementType}',
            ),
          ),
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
              style: const TextStyle(color: Color(0xFFA1A1A1)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
              textAlign: TextAlign.left,
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
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: Color(0xFF464A50))),
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  final String caseId;
  const _RecordList({required this.caseId});

  Color _reviewStatusColor(dynamic status) {
    if (status == null) return const Color(0xFF7C7C7C);
    final s = status is String ? status.toString().toUpperCase() : status.toString().split('.').last.toUpperCase();
    switch (s) {
      case 'WRITING':
        return const Color(0xFF3EB491);
      case 'PENDING':
        return const Color(0xFF7C7C7C);
      case 'APPROVED':
        return const Color(0xFF4F4F4F);
      case 'REJECTED':
        return const Color(0xFFDB8383);
      default:
        return const Color(0xFF7C7C7C);
    }
  }

  String _reviewStatusLabel(dynamic status) {
    if (status == null) return '';
    if (status is String) return status;
    return status.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestigationRecordProvider>();

    if (provider.records.isEmpty &&
        !provider.loading &&
        provider.error == null &&
        provider.hasMore) {
      Future.microtask(() => provider.loadRecords(caseId: caseId));
    }

    final records = provider.records;
    final isLoading = provider.loading;
    final error = provider.error;

    if (!isLoading && records.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Center(child: Text('수사 기록이 없습니다')),
        ],
      );
    }

    if (error != null && records.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.error_outline, size: 36, color: Colors.red[700]),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.loadRecords(caseId: caseId),
            child: const Text('다시 시도'),
          ),
        ],
      );
    }

    return SizedBox(
      height: 400, // allow scroll inside parent ListView
      child: RefreshIndicator(
        onRefresh: () => provider.loadRecords(caseId: caseId),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (metrics.maxScrollExtent > 0 &&
                metrics.pixels >= metrics.maxScrollExtent - 200 &&
                provider.hasMore &&
                !provider.loading) {
              provider.loadMoreRecords();
            }
            return false;
          },
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: records.length + (isLoading ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == records.length) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final rec = records[index];

              String nameEn = rec.creator?['nameEn']?.toString() ?? '';
              String nameKr = rec.creator?['nameKr']?.toString() ?? '';
              String name = '';
              if (nameEn.trim().isNotEmpty) {
                name = nameEn;
              } else if (nameKr.trim().isNotEmpty) {
                name = nameKr;
              } else {
                name = '-';
              }
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    app_router.AppRoute.recordDetail,
                    arguments: app_router.RecordDetailArgs(rec.recordId),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 0),
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF7D7D7D),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(14, 10, 14, 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.recordName ?? '(무제)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        // _reviewStatusLabel(rec.reviewStatus),
                                        rec.reviewStatus?.toString() ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          // color: _reviewStatusColor(rec.reviewStatus),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        style: const TextStyle(
                                          color: Color(0xFFA1A1A1),
                                        ),
                                        rec.createdAt?.split('T').first ?? '',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          style: const TextStyle(
                                            color: Color(0xFF737080),
                                          ),
                                          rec.createdAt?.split('T').first ?? '',
                                        ),
                                      ],
                                    ),
                                    Text(
                                          style: const TextStyle(
                                            color: Color(0xFFD6D6D6),
                                          ),
                                          '|',
                                        ),
                                    Row(
                                      children: [
                                        Text(
                                          rec.createdAt?.split('T').first ?? '',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
