import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/models/post/post.dart';
import 'package:jic_mob/core/models/post/post_detail.dart';
import 'package:jic_mob/core/provider/posts_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailPage extends StatefulWidget {
  final String id;
  final String? boardType;
  const PostDetailPage({super.key, required this.id, this.boardType});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _loading = true;
  String? _error;
  PostDetailResponse? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  BoardType _parseBoardType(String? s) {
    if (s == null) return BoardType.notice;
    try {
      return BoardType.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
      );
    } catch (_) {
      return BoardType.notice;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<PostsProvider>();
    final boardType = _parseBoardType(widget.boardType);

    try {
      final res = await provider.fetchPostDetail(
        boardType: boardType,
        id: widget.id,
      );
      setState(() {
        _detail = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F7F5);
    final boardType = _parseBoardType(widget.boardType);
    final title = boardType == BoardType.notice ? '공지사항' : '조사정보';

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
            title: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final post = detail.current;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        InkWell(
          onTap: () {},
          child: Text(
            post.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _meta('작성일', post.createdAt.toString()),
            _meta('작성자', post.createdBy ?? ''),
            _meta('조회수', post.viewCount.toString()),
          ],
        ),
        const SizedBox(height: 22),
        // HTML content
        if ((post.content ?? '').isNotEmpty)
          PostDetailHtml(htmlContent: post.content ?? ''),

        const SizedBox(height: 12),
        if (post.attachments.isNotEmpty) ...[
          for (final attachment in post.attachments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Color(0xFF111827),
                    ),
                    Text('첨부파일', style: TextStyle(color: Color(0xFF111827))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachment.fileName,
                        style: const TextStyle(color: Color(0xFF5D5996)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 16,
                  color: Color(0xFF000000),
                ),
                Text('첨부파일', style: TextStyle(color: Color(0xFF000000))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '없음',
                    style: TextStyle(color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Icon(Icons.file_download_outlined, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(height: 1),
        if (detail.prev != null)
          _PrevNextItem(
            label: '이전글',
            title: detail.prev!.title,
            //dateTime: detail.prev!.createdAt,
            dateTime: DateFormat(
              'yyyy.MM.dd HH:mm:ss',
            ).format(detail.prev!.createdAt),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                app_router.AppRoute.postDetail,
                arguments: app_router.PostDetailArgs(
                  detail.prev!.postId,
                  boardType: widget.boardType,
                ),
              );
            },
          ),
        const Divider(height: 1),
        if (detail.next != null)
          _PrevNextItem(
            label: '다음글',
            title: detail.next!.title,
            dateTime: DateFormat(
              'yyyy.MM.dd HH:mm:ss',
            ).format(detail.next!.createdAt),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                app_router.AppRoute.postDetail,
                arguments: app_router.PostDetailArgs(
                  detail.next!.postId,
                  boardType: widget.boardType,
                ),
              );
            },
          ),
        if (detail.next != null) const Divider(height: 1),
      ],
    );
  }

  Widget _meta(String label, String value) {
    final formattedValue = label == '작성일'
        ? DateFormat('yyyy.MM.dd').format(DateTime.parse(value))
        : value;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: formattedValue,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
          ),
        ],
      ),
    );
  }
}

class _PrevNextItem extends StatelessWidget {
  final String label;
  final String title;
  final String dateTime;
  final VoidCallback onTap;
  const _PrevNextItem({
    required this.label,
    required this.title,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  label == '이전글'
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF111827),
                ),
                const SizedBox(width: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xB3363249),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateTime,
              style: const TextStyle(fontSize: 12, color: Color(0xFF656161)),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailHtml extends StatelessWidget {
  final String htmlContent;
  const PostDetailHtml({required this.htmlContent, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Html(
        data: htmlContent,
        extensions: [TableHtmlExtension()],
        onLinkTap: (url, attributes, element) async {
          if (url == null) return;
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          }
        },
        style: {
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            lineHeight: LineHeight(1.6),
            color: const Color(0xFF333333),
          ),
          'p': Style(
            margin: Margins.only(bottom: 12),
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            lineHeight: LineHeight(1.6),
            color: const Color(0xFF333333),
          ),
          'table': Style(
            margin: Margins.only(bottom: 16),
            display: Display.block,
          ),
          'tr': Style(),
          'th': Style(
            padding: HtmlPaddings.all(8),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
            fontSize: FontSize(14),
          ),
          'td': Style(
            padding: HtmlPaddings.all(8),
            textAlign: TextAlign.center,
            color: const Color(0xFF333333),
            fontSize: FontSize(14),
          ),
          'a': Style(
            color: const Color(0xFF2563EB),
            textDecoration: TextDecoration.underline,
          ),
        },
        shrinkWrap: true,
      ),
    );
  }
}
