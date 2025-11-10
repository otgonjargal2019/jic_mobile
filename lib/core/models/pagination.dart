class PagedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final bool last;
  final bool first;

  const PagedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.first,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawContent = json['content'];
    final items = <T>[];
    if (rawContent is List) {
      for (final e in rawContent) {
        if (e is Map<String, dynamic>) {
          items.add(fromJsonT(e));
        } else if (e is Map) {
          items.add(fromJsonT(Map<String, dynamic>.from(e)));
        }
      }
    }

    final totalElements = (json['totalElements'] ?? json['total'] ?? 0) as int;
    final totalPages = (json['totalPages'] ?? json['totalPages'] ?? 0) as int;
    final pageNumber = (json['number'] ?? json['page'] ?? 0) as int;
    final first = json['first'] ?? false;
    final last =
        json['last'] ??
        (totalPages > 0 ? pageNumber >= totalPages - 1 : items.isEmpty);

    return PagedResponse<T>(
      content: items,
      totalElements: totalElements,
      totalPages: totalPages,
      pageNumber: pageNumber,
      first: first,
      last: last,
    );
  }
}
