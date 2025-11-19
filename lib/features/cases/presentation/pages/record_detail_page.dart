import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
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
    Future.microtask(
      () =>
          context.read<InvestigationRecordProvider>().loadRecordById(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final provider = context.watch<InvestigationRecordProvider>();
    final isLoading = provider.recordLoading;
    final error = provider.recordError;
    final record = provider.currentRecord;

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
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          height: 99,
          child: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.arrow_back_ios, size: 22),
                ),
              ),
            ),
            elevation: 0,
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 99,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Builder(
          builder: (_) {
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
              padding: const EdgeInsets.all(0.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "수사 기록 조회",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Container(color: Color(0xFFEAEAEA)),
                ),
                _AuthorsSection(record: record),
                SizedBox(
                  height: 10,
                  child: Container(color: Color(0xFFEAEAEA)),
                ),
                _AttachmentsSection(record: record),
                SizedBox(
                  height: 10,
                  child: Container(color: Color(0xFFEAEAEA)),
                ),
                _InvestigationSection(record: record),
              ],
            );
          },
        ),
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
    String creatorAvatar = '';
    String creatorHq = '';
    String creatorDept = '';
    String creatorDate = record.createdAt != null
        ? DateFormat(
            'yyyy/MM/dd',
          ).format(DateTime.parse(record.createdAt.toString()))
        : '';
    if (creator is Map) {
      final c = creator as Map;
      creatorName = (c['nameEn'] ?? c['nameKr'] ?? c['loginId'] ?? '')
          .toString();
      creatorAvatar = c['profileImageUrl']?.toString() ?? '';
      creatorHq = c['headquarterName']?.toString() ?? '';
      creatorDept = c['departmentName']?.toString() ?? '';
    }

    String reviewerName = '';
    String reviewerAvatar = '';
    String reviewerHq = '';
    String reviewerDept = '';
    String reviewerDate = record.reviewedAt != null
        ? DateFormat(
            'yyyy/MM/dd',
          ).format(DateTime.parse(record.reviewedAt.toString()))
        : '';
    if (reviewer is Map) {
      final r = reviewer as Map;
      reviewerName = (r['nameEn'] ?? r['nameKr'] ?? r['loginId'] ?? '')
          .toString();
      reviewerAvatar = r['profileImageUrl']?.toString() ?? '';
      reviewerHq = r['headquarterName']?.toString() ?? '';
      reviewerDept = r['departmentName']?.toString() ?? '';
    }

    return _CardSection(
      title: '작성자',
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      expandable: true,
      child: Column(
        children: [
          _AuthorRow(
            name: creatorName.isNotEmpty ? creatorName : '(미등록)',
            avatarUrl: creatorAvatar.isNotEmpty ? creatorAvatar : '',
            hq: creatorHq,
            dept: creatorDept,
            date: creatorDate,
            tag: '작성자',
          ),
          reviewerName.isNotEmpty
              ? _AuthorRow(
                  name: reviewerName.isNotEmpty ? reviewerName : '(미등록)',
                  avatarUrl: reviewerAvatar.isNotEmpty ? reviewerAvatar : '',
                  hq: reviewerHq,
                  dept: reviewerDept,
                  date: reviewerDate,
                  tag: '검토자',
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

class UserBadge extends StatelessWidget {
  final String text;
  final bool filled;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final TextStyle? textStyle;

  const UserBadge({
    super.key,
    required this.text,
    this.filled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.background,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        background ?? (filled ? const Color(0xFFEFF1F5) : Colors.transparent);
    final border = Border.all(color: borderColor ?? const Color(0xB2363249));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: filled ? null : border,
      ),
      child: Text(
        text,
        style:
            textStyle ??
            const TextStyle(fontSize: 14, color: Color(0xB2363249)),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String hq;
  final String dept;
  final String date;
  final String tag;

  const _AuthorRow({
    this.avatarUrl = '',
    required this.name,
    required this.hq,
    required this.dept,
    required this.date,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // enough for a top + bottom line
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0, // half of height, stopping before avatar
                  left: 20, // center
                  child: Container(width: 1, color: const Color(0xFFC8C8C8)),
                ),

                Positioned(
                  top: 20,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFBDBDBD),
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$hq ${hq.isNotEmpty && dept.isNotEmpty ? " | " : ""} $dept',
                  style: const TextStyle(
                    color: Color(0xFF5F5F5F),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF7BA591),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Tag badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: UserBadge(text: tag, filled: false),
          ),
        ],
      ),
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

    bool _isTrue(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      return v.toString().toLowerCase() == 'true';
    }

    List digitalEvidence = [];
    List investigationReport = [];

    for (var item in items) {
      if (item is Map) {
        if (_isTrue(item['digitalEvidence'])) digitalEvidence.add(item);
        if (_isTrue(item['investigationReport'])) investigationReport.add(item);
      }
    }

    return _CardSection(
      title: '첨부파일',
      expandable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: investigationReport.isEmpty && digitalEvidence.isEmpty
            ? [const Text('첨부파일이 없습니다')]
            : [
                const Text(
                  '수사 보고서',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                ...investigationReport.map((f) {
                  final name = (f is Map)
                      ? (f['fileName']?.toString() ?? '')
                      : f.toString();
                  final size = f['fileSize'] != null
                      ? (f['fileSize'] / 1024).toStringAsFixed(1)
                      : "";
                  return Column(children: [_FileRow(name, size)]);
                }),
                const Divider(height: 16, color: Color(0xFFC8C8C8)),
                const Text(
                  '디지털 증거물',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                ...digitalEvidence.map((f) {
                  final name = (f is Map)
                      ? (f['fileName']?.toString() ?? '')
                      : f.toString();
                  final size = f['fileSize'] != null
                      ? (f['fileSize'] / 1024).toStringAsFixed(1)
                      : "";
                  return Column(children: [_FileRow(name, size)]);
                }),
              ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final String name;
  final String size;
  const _FileRow(this.name, this.size);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(color: Color(0xFF737080))),
            size.trim().isNotEmpty
                ? Text(
                    ' (${size}KB)',
                    style: TextStyle(color: Color(0xFFAAAAAA)),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}

class _InvestigationSection extends StatelessWidget {
  final InvestigationRecord record;
  const _InvestigationSection({required this.record});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return _CardSection(
      title: '사건 수사 기록',
      child: Column(
        children: [
          _KVRow('사건 번호', record.number.toString()),
          _KVRow(
            '작성일',
            record.createdAt != null
                ? DateFormat(
                    'yyyy-MM-dd hh:mm:ss',
                  ).format(DateTime.parse(record.createdAt.toString()))
                : '',
          ),
          _KVRow(
            '사건명',
            record.caseInstance?['caseName'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const Divider(height: 16),
          _KVRow('수사기록명', record.recordName ?? ''),
          _KVRow('본인등급', record.securityLevel.toString(), isBadge: true),
          _KVRow(
            '상세진행상황',
            record.progressStatus != null &&
                    record.progressStatus!.trim().isNotEmpty
                ? loc.translate(
                    'case_details.progressStatus.${record.progressStatus}',
                  )
                : '',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: const Color(0xFF737080),
            ),
          ),
          _KVRow('수사 내용', record.content ?? ''),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String k;
  final String v;
  final TextStyle style;
  final bool isBadge;
  const _KVRow(
    this.k,
    this.v, {
    this.style = const TextStyle(
      fontWeight: FontWeight.normal,
      color: const Color(0xFF111827),
    ),
    this.isBadge = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F5F5F),
              ),
            ),
          ),
          const SizedBox(width: 8),
          this.isBadge
              ? Container(
                  padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
                  decoration: BoxDecoration(
                    color: Color(0xFFDB8383),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$v등급',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                )
              : Expanded(
                  child: Text(v, textAlign: TextAlign.left, style: style),
                ),
        ],
      ),
    );
  }
}

class _CardSection extends StatefulWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool expandable;

  const _CardSection({
    required this.title,
    required this.child,
    this.expandable = false,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  State<_CardSection> createState() => _CardSectionState();
}

class _CardSectionState extends State<_CardSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.expandable
            ? [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _expanded ? 0 : 0.5,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: widget.child,
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ]
            : [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    widget.child,
                  ],
                ),
              ],
      ),
    );
  }
}
