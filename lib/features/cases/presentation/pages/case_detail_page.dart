import 'package:flutter/material.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/widgets/segmented_tabs.dart';
import 'package:jic_mob/core/widgets/app_tag.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/provider/case_provider.dart';
import 'package:jic_mob/core/models/case/case.dart';
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
    Future.microtask(() =>
        context.read<CaseProvider>().loadCaseByUUID(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    final provider = context.watch<CaseProvider>();
    final isLoading = provider.loading;
    final error = provider.error;
    final caseDetail = provider.currentCase;

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
            Text(
              caseDetail.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: caseDetail.chips.map((c) => AppTag(text: c)).toList(),
            ),
            const SizedBox(height: 12),
            _InfoSummary(caseData: caseDetail),
            const SizedBox(height: 12),
            SegmentedTabs(
              index: _tabIndex,
              labels: const ['사건 정보', '수사기록 내역'],
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            const SizedBox(height: 12),
            if (_tabIndex == 0) ...[
              _SectionCard(title: '사건 개요', body: caseDetail.infringementType),
              const SizedBox(height: 16),
              _SectionCard(title: '기타사항', body: caseDetail.progressStatus),
            ] else ...[
              _RecordList(),
            ],
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
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
          _row(loc.translate('case_details.case_number'), caseData.number),
          _row(loc.translate('case_details.investigationDate'), caseData.investigationDate),
          _row(loc.translate('case_details.priority'), caseData.priority),
          _row(loc.translate('case_details.relatedCountries'), caseData.relatedCountries),
          _row(loc.translate('case_details.contentType'), caseData.contentType),
          _row(loc.translate('case_details.infringementType'), caseData.infringementType),
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
