import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/models/post/post.dart';
import 'package:jic_mob/core/models/post/post_detail.dart';
import 'package:jic_mob/core/provider/posts_provider.dart';
import 'package:flutter_html/flutter_html.dart';

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
    final boardType = _parseBoardType(widget.boardType);
    final title = boardType == BoardType.notice ? '공지사항' : '조사정보';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
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
              color: Color(0xFF2563EB),
              decoration: TextDecoration.underline,
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
        const SizedBox(height: 16),
        // Render HTML content like a browser. Use flutter_html to convert
        // HTML strings into Flutter widgets (links, images, lists, etc.).
        if ((post.content ?? '').isNotEmpty)
          Html(data: post.content ?? '')
        else
          const SizedBox.shrink(),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.attach_file, size: 18, color: Color(0xFF6B7280)),
            SizedBox(width: 6),
            Text('첨부파일', style: TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
        const SizedBox(height: 8),
        if (post.attachments.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final attachment in post.attachments)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCE7F9)),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          attachment.fileName,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.file_download_outlined,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDCE7F9)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '첨부파일 없음',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
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
        const Divider(height: 1),
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
              color: Color(0xFF9AA0A6),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: formattedValue,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
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
                  color: const Color(0xFF9AA0A6),
                ),
                const SizedBox(width: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9AA0A6),
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
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateTime,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
      ),
    );
  }
}
