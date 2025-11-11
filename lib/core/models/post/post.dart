class Attachment {
  final String fileName;

  Attachment({required this.fileName});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(fileName: json['fileName']?.toString() ?? '');
  }
}

class Post {
  final String postId;
  final BoardType boardType;
  final String title;
  final String? content;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final List<Attachment> attachments;

  const Post({
    required this.postId,
    required this.boardType,
    required this.title,
    this.content,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.attachments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
    final attachments = attachmentsJson
        .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
        .toList();

    return Post(
      postId: json['postId'] as String,
      boardType: BoardType.values.firstWhere(
        (e) =>
            e.name.toUpperCase() == (json['boardType'] as String).toUpperCase(),
        orElse: () => BoardType.notice,
      ),
      title: json['title'] as String,
      content: json['content'] as String?,
      createdBy: json['creator']?['nameKr'] ?? json['creator']?['nameEn'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'boardType': boardType.name.toUpperCase(),
      'title': title,
      'content': content,
      'creator': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewCount': viewCount,
    };
  }
}

enum BoardType {
  notice, // 공지사항
  research, // 조사정보
}
