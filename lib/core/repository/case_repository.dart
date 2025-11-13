import 'package:jic_mob/core/network/api_client.dart';
import 'package:jic_mob/core/models/pagination.dart';
import 'package:jic_mob/core/models/case/case.dart';

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  try {
    return int.parse(v.toString());
  } catch (_) {
    return 0;
  }
}

class CaseRepository {
  final ApiClient _apiClient;

  CaseRepository(this._apiClient);

  Future<PagedResponse<Case>> getCases({
    String sortBy = 'number',
    String sortDirection = 'desc',
    int page = 0,
    int size = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      'page': page,
      'size': size,
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/api/cases',
      queryParameters: queryParams,
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

      if (map.containsKey('rows')) {
        final rows = map['rows'] as List? ?? [];

        // Determine total elements from possible fields
        int totalElements = 0;
        if (map.containsKey('total')) {
          totalElements = _toInt(map['total']);
        } else if (map.containsKey('totalElements')) {
          totalElements = _toInt(map['totalElements']);
        } else if (map['meta'] is Map) {
          final meta = Map<String, dynamic>.from(map['meta']);
          if (meta.containsKey('totalItems')) {
            totalElements = _toInt(meta['totalItems']);
          } else if (meta.containsKey('totalElements')) {
            totalElements = _toInt(meta['totalElements']);
          }
        }

        final int totalPages = (size > 0) ? ((totalElements + size - 1) ~/ size) : 0;
        final bool first = page <= 0;
        final bool last = totalPages == 0 ? true : page >= (totalPages - 1);

        final normalized = <String, dynamic>{
          'content': rows,
          'number': page,
          'totalElements': totalElements,
          'totalPages': totalPages,
          'first': first,
          'last': last,
        };

        return PagedResponse<Case>.fromJson(
          normalized,
          (item) => Case.fromJson(item),
        );
      }

    }

    throw ApiException('Unexpected response format for posts');
  }

}
