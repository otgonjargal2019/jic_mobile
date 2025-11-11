import 'package:jic_mob/core/models/post/post.dart';

class PostNeighbor {
  final String postId;
  final String title;
  final DateTime createdAt;

  PostNeighbor({
    required this.postId,
    required this.title,
    required this.createdAt,
  });

  factory PostNeighbor.fromJson(Map<String, dynamic> json) {
    return PostNeighbor(
      postId: json['postId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PostDetailResponse {
  final Post current;
  final PostNeighbor? prev;
  final PostNeighbor? next;

  PostDetailResponse({required this.current, this.prev, this.next});

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final prevJson = json['prev'] as Map<String, dynamic>?;
    final nextJson = json['next'] as Map<String, dynamic>?;

    return PostDetailResponse(
      current: Post.fromJson(currentJson),
      prev: prevJson != null ? PostNeighbor.fromJson(prevJson) : null,
      next: nextJson != null ? PostNeighbor.fromJson(nextJson) : null,
    );
  }
}
