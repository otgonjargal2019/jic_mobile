import 'package:flutter/material.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;

class PostDetailPage extends StatelessWidget {
  final String id;
  const PostDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final post = _samplePost(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('공지사항'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ListView(
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
              _meta('작성일', post.dateLabel),
              _meta('작성자', '관리자'),
              _meta('조회수', post.views.toString()),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.attach_file, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text('첨부파일', style: TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDCE7F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    post.attachment,
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
          const SizedBox(height: 16),
          const Divider(height: 1),
          _PrevNextItem(
            label: '이전글',
            title: '인터폴 협력 사례 공유 세미나 참가 신청 안내',
            dateTime: '2024-02-09 18:32:44',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                app_router.AppRoute.postDetail,
                arguments: const app_router.PostDetailArgs('prev'),
              );
            },
          ),
          const Divider(height: 1),
          _PrevNextItem(
            label: '다음글',
            title: '인터폴 협력 사례 공유 세미나 참가 신청 안내',
            dateTime: '2024-02-09 18:32:44',
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                app_router.AppRoute.postDetail,
                arguments: const app_router.PostDetailArgs('next'),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
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
            text: value,
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

class _PostDetailData {
  final String title;
  final String dateLabel;
  final int views;
  final String body;
  final String attachment;
  const _PostDetailData({
    required this.title,
    required this.dateLabel,
    required this.views,
    required this.body,
    required this.attachment,
  });
}

_PostDetailData _samplePost(String id) {
  return const _PostDetailData(
    title: '인터폴 협력 사례 공유 세미나 참가 신청 안내',
    dateLabel: '2025.05.19',
    views: 125,
    body: '2025년 상반기 국제공조수사 워크샵 개최안내의 자세한 내용은 첨부파일로 확인하시기 바랍니다.',
    attachment: '2025 국제 공조수사 워크샵 개최안내.docx',
  );
}
