import 'package:flutter/foundation.dart';
import 'package:jic_mob/core/models/dashboard/dashboard_data.dart';
import 'package:jic_mob/core/repository/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider(this._repository);

  DashboardData? _data;
  DashboardData? get data => _data;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_loading) return;
    if (!forceRefresh && _data != null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.fetchDashboard();
      _data = response;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDashboard(forceRefresh: true);

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
