import 'package:flutter/material.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/core/provider/investigation_record_provider.dart';
import 'package:jic_mob/core/models/investigation_record/investigation_record.dart';

class RecordDetailPage extends StatefulWidget {
  final String id;
  const RecordDetailPage({super.key, required this.id});

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load the record when page opens
    Future.microtask(() =>
        context.read<InvestigationRecordProvider>().loadRecordById(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    final provider = context.watch<InvestigationRecordProvider>();
    final isLoading = provider.recordLoading;
    final error = provider.recordError;
    final record = provider.currentRecord;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('수사 기록 조회'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3C3C43),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(builder: (_) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.error_outline, size: 36, color: Colors.red[700]),
                const SizedBox(height: 8),
                Text(error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.loadRecordById(widget.id),
                  child: const Text('다시 시도'),
                ),
              ],
            );
          }

          if (record == null) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          return ListView(
            children: [
              _AuthorsSection(record: record),
              const SizedBox(height: 12),
              _AttachmentsSection(record: record),
              const SizedBox(height: 12),
              _InvestigationSection(record: record),
            ],
          );
        }),
      ),
    );
  }
}

class _AuthorsSection extends StatelessWidget {
  final InvestigationRecord record;
  const _AuthorsSection({required this.record});

  @override
  Widget build(BuildContext context) {
    final creator = record.creator;
    final reviewer = record.reviewer;
    String creatorName = '';
    String creatorDept = '';
    String creatorDate = record.createdAt?.split('T').first ?? '';
    if (creator is Map) {
      final c = creator as Map;
      creatorName = (c['nameEn'] ?? c['nameKr'] ?? c['loginId'] ?? '').toString();
      // try to build a dept string from available keys
      final country = (c['countryName'] ?? c['headquarterName'] ?? c['departmentName'])?.toString();
      creatorDept = country ?? '';
    }

    String reviewerName = '';
    String reviewerDept = '';
    String reviewerDate = record.reviewedAt?.split('T').first ?? '';
    if (reviewer is Map) {
      final r = reviewer as Map;
      reviewerName = (r['nameEn'] ?? r['nameKr'] ?? r['loginId'] ?? '').toString();
      reviewerDept = (r['countryName'] ?? r['headquarterName'] ?? r['departmentName'])?.toString() ?? '';
    }

    return _CardSection(
      title: '작성자',
      child: Column(
        children: [
          _AuthorRow(
            name: creatorName.isNotEmpty ? creatorName : '(미등록)',
            dept: creatorDept,
            date: creatorDate,
            tag: '작성자',
          ),
          const SizedBox(height: 12),
          _AuthorRow(
            name: reviewerName.isNotEmpty ? reviewerName : '(미등록)',
            dept: reviewerDept,
            date: reviewerDate,
            tag: '검토자',
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final String name;
  final String dept;
  final String date;
  final String tag;
  const _AuthorRow({
    required this.name,
    required this.dept,
    required this.date,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFBDBDBD)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                dept,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(color: Color(0xFF8D93A1), fontSize: 12),
              ),
            ],
          ),
        ),
        AppBadge(text: tag, filled: false),
      ],
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  final InvestigationRecord record;
  const _AttachmentsSection({required this.record});

  @override
  Widget build(BuildContext context) {
    final files = record.attachedFiles;
    List items = [];
    if (files is List) items = files;

    return _CardSection(
      title: '첨부파일',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.isEmpty
            ? [const Text('첨부파일이 없습니다')]
            : items.map((f) {
                final name = (f is Map) ? (f['fileName']?.toString() ?? '') : f.toString();
                return Column(
                  children: [
                    _FileRow(name),
                  ],
                );
              }).toList(),
      ),
    );
  }
}



class _FileRow extends StatelessWidget {
  final String name;
  const _FileRow(this.name);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.insert_drive_file,
              size: 18,
              color: Color(0xFF9AA0A6),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(name)),
          ],
        ),
        const Divider(height: 16),
      ],
    );
  }
}

class _InvestigationSection extends StatelessWidget {
  final InvestigationRecord record;
  const _InvestigationSection({required this.record});

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: '사건 수사 기록',
      child: Column(
        children: [
          _KVRow('사건 번호', record.number.toString()),
          _KVRow('작성일', record.createdAt ?? ''),
          _KVRow('수사기록명', record.recordName ?? ''),
          _KVRow('본인등급', record.securityLevel.toString(), highlight: true),
          _KVRow('상세진행상황', record.progressStatus ?? ''),
          _KVRow('수사 내용', record.content ?? ''),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String k;
  final String v;
  final bool highlight;
  const _KVRow(this.k, this.v, {this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: highlight
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardSection({required this.title, required this.child});

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
          child,
        ],
      ),
    );
  }
}
