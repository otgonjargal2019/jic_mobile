import 'package:jic_mob/core/models/dashboard/dashboard_data.dart';
import 'package:jic_mob/core/network/api_client.dart'
    show ApiClient, ApiException;

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardData> fetchDashboard() async {
    final response = await _apiClient.get(
      '/api/dashboard/main',
      receiveTimeout: const Duration(seconds: 20),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return DashboardData.fromJson(data);
    }
    if (data is Map) {
      return DashboardData.fromJson(Map<String, dynamic>.from(data));
    }
    throw ApiException('Unexpected response from /api/dashboard/main');
  }
}
