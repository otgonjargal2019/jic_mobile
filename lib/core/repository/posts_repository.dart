import 'package:jic_mob/core/models/post/post.dart';
import 'package:jic_mob/core/network/api_client.dart';
import 'package:jic_mob/core/models/pagination.dart';
import 'package:jic_mob/core/models/post/post_detail.dart';

class PostsRepository {
  final ApiClient _apiClient;

  PostsRepository(this._apiClient);

  Future<PagedResponse<Post>> getPosts({
    BoardType? type,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      '/api/posts',
      queryParameters: {
        if (type != null) 'boardType': type.name.toUpperCase(),
        'page': page.toString(),
        'size': size.toString(),
      },
      receiveTimeout: const Duration(seconds: 60),
    );
    final data = response.data;
    if (data == null) {
      throw ApiException('Empty response from server');
    }

    if (data is Map || data is Map<String, dynamic>) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      if (map.containsKey('data') && map.containsKey('meta')) {
        final innerData = map['data'];
        final meta = map['meta'];

        final normalized = <String, dynamic>{
          'content': innerData ?? [],
          'number': (meta?['currentPage'] ?? meta?['page']) ?? page,
          'totalElements': meta?['totalItems'] ?? meta?['total'] ?? 0,
          'totalPages': meta?['totalPages'] ?? 0,
          'first': meta?['hasPrevious'] != null
              ? !(meta['hasPrevious'] as bool)
              : false,
          'last': meta?['hasNext'] != null ? !(meta['hasNext'] as bool) : false,
        };

        return PagedResponse<Post>.fromJson(
          normalized,
          (item) => Post.fromJson(item),
        );
      }

      if (map.containsKey('content')) {
        return PagedResponse<Post>.fromJson(
          Map<String, dynamic>.from(map),
          (item) => Post.fromJson(item),
        );
      }
    }

    throw ApiException('Unexpected response format for posts');
  }

  Future<PostDetailResponse> getPost({
    required BoardType type,
    required String id,
  }) async {
    final response = await _apiClient.get(
      '/api/posts/${type.name.toUpperCase()}/$id',
      receiveTimeout: const Duration(seconds: 30),
    );

    final data = response.data;
    if (data == null) throw ApiException('Empty response from server');

    if (data is Map || data is Map<String, dynamic>) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);
      if (map.containsKey('data')) {
        final inner = map['data'];
        if (inner is Map<String, dynamic>) {
          return PostDetailResponse.fromJson(inner);
        }
      }

      if (map.containsKey('current')) {
        return PostDetailResponse.fromJson(Map<String, dynamic>.from(map));
      }
    }

    throw ApiException('Unexpected response format for post detail');
  }
}
