import 'package:jic_mob/core/network/api_client.dart';
import 'package:jic_mob/core/models/pagination.dart';
import 'package:jic_mob/core/models/investigation_record/investigation_record.dart';

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

class InvestigationRecordRepository {
  final ApiClient _apiClient;

  InvestigationRecordRepository(this._apiClient);

  Future<PagedResponse<InvestigationRecord>> getInvestigationRecords({
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
    int page = 0,
    int size = 10,
    String? caseId,
  }) async {
    final queryParams = <String, dynamic>{
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      'page': page,
      'size': size,
    };
    if (caseId != null) queryParams['caseId'] = caseId;

    final response = await _apiClient.get(
      '/investigation-records/list',
      queryParameters: queryParams,
      receiveTimeout: const Duration(seconds: 60),
    );

    final data = response.data;
    if (data == null) throw ApiException('Empty response from server');

    if (data is Map || data is Map<String, dynamic>) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      if (map.containsKey('rows')) {
        final rows = map['rows'] as List? ?? [];

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

        return PagedResponse<InvestigationRecord>.fromJson(
          normalized,
          (item) => InvestigationRecord.fromJson(item),
        );
      }
    }

    throw ApiException('Unexpected response format for investigation records');
  }

  Future<InvestigationRecord> getInvestigationRecordById(String recordId) async {
    final response = await _apiClient.get(
      '/investigation-records/$recordId',
      receiveTimeout: const Duration(seconds: 60),
    );

    final data = response.data;
    if (data == null) throw ApiException('Empty response from server');

    if (data is Map || data is Map<String, dynamic>) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      return InvestigationRecord.fromJson(map);
    }

    throw ApiException('Unexpected response format for investigation record');
  }

  Future<bool> checkAccess(String recordId) async {
    final response = await _apiClient.get(
      '/investigation-records/check-access/$recordId',
      receiveTimeout: const Duration(seconds: 30),
    );

    final data = response.data;
    if (data == null) throw ApiException('Empty response from server');

    if (data is bool) return data;

    if (data is Map || data is Map<String, dynamic>) {
      final map = data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map);

      if (map.containsKey('allowed')) return map['allowed'] == true;
      if (map.containsKey('access')) return map['access'] == true;
      if (map.containsKey('hasAccess')) return map['hasAccess'] == true;

      if (map.containsKey('status')) {
        final s = map['status']?.toString().toLowerCase();
        if (s == 'ok' || s == 'allowed') return true;
      }
    }

    throw ApiException('Unexpected response format for check-access');
  }
}
