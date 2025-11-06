import 'package:flutter/material.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';

class RecordDetailPage extends StatelessWidget {
  final String id;
  const RecordDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('수사 기록 조회'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3C3C43),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AuthorsSection(),
          SizedBox(height: 12),
          _AttachmentsSection(),
          SizedBox(height: 12),
          _InvestigationSection(),
        ],
      ),
    );
  }
}

class _AuthorsSection extends StatelessWidget {
  const _AuthorsSection();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: '작성자',
      child: Column(
        children: const [
          _AuthorRow(
            name: '고광현',
            dept: '경찰 대응 본부 | 온라인 보호부',
            date: '2024/02/28',
            tag: '작성자',
          ),
          SizedBox(height: 12),
          _AuthorRow(
            name: '김환수',
            dept: '경찰 대응 본부 | 온라인 보호부',
            date: '2024/02/28',
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
  const _AttachmentsSection();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: '첨부파일',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SubHeader('수사 보고서'),
          _FileRow('사건 B 목적자 관련 제보 수사보고서.docx (39.7KB)'),
          SizedBox(height: 8),
          _SubHeader('디지털 증거물'),
          _FileRow('사건 B 목적자 관련 음성 녹취록.mp4 (39.7KB)'),
          _FileRow('사건 B 목적자 관련 음성 녹취록.mp4 (39.7KB)'),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;
  const _SubHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
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
  const _InvestigationSection();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: '사건 수사 기록',
      child: Column(
        children: const [
          _KVRow('사건 번호', '156-8156'),
          _KVRow('작성일', '2024-01-01 05:59:00'),
          _KVRow('사건명', '사건 B'),
          _KVRow('수사기록명', '사건 B 목적자 관련 제보'),
          _KVRow('본인등급', '1등급', highlight: true),
          _KVRow('상세진행상황', '수사 중'),
          _KVRow(
            '수사 내용',
            '성범죄사건가 저작권자의 이용허락 없이 해외의 동영상 공유 플랫폼 사이트에 업로드한 영상저작물에 대한...',
          ),
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
