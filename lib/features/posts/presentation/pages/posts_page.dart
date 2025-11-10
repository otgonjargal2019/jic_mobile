import 'package:flutter/material.dart';
import 'package:jic_mob/core/navigation/app_router.dart' as app_router;
import 'package:jic_mob/core/provider/posts_provider.dart';
import 'package:jic_mob/core/widgets/app_bottom_nav.dart';
import 'package:jic_mob/core/widgets/segmented_tabs.dart';
import 'package:provider/provider.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  int _tab = 0; // 0: 공지사항, 1: 조사정보

  @override
  void initState() {
    super.initState();
    // Load posts when the page is first created
    Future.microtask(() => context.read<PostsProvider>().loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final notices = postsProvider.notices;
    final investigations = postsProvider.investigations;
    final list = _tab == 0 ? notices : investigations;
    final error = postsProvider.error;
    final loading = postsProvider.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text('게시판'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: SegmentedTabs(
              index: _tab,
              labels: const ['공지사항', '조사정보'],
              onChanged: (i) => setState(() => _tab = i),
              backgroundColor: Colors.transparent,
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(16),
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
                    onPressed: () => context.read<PostsProvider>().loadPosts(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else if (loading && list.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<PostsProvider>().loadPosts(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                      final provider = context.read<PostsProvider>();
                      if (_tab == 0) {
                        provider.loadMoreNotices();
                      } else {
                        provider.loadMoreInvestigations();
                      }
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: list.length + (loading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == list.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = list[index];
                      return _PostTile(
                        title: post.title,
                        dateTimeLabel: post.createdAt.toString(),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            app_router.AppRoute.postDetail,
                            arguments: app_router.PostDetailArgs(
                              post.postId,
                              boardType: post.boardType.name,
                            ),
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
    );
  }
}

class _PostTile extends StatelessWidget {
  final String title;
  final String dateTimeLabel;
  final VoidCallback onTap;
  const _PostTile({
    required this.title,
    required this.dateTimeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateTimeLabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
      ),
    );
  }
}
