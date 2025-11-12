import 'package:flutter/foundation.dart';
import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/repository/case_repository.dart';

class CaseProvider extends ChangeNotifier {
  final CaseRepository _repository;

  CaseProvider(this._repository);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<Case> _cases = [];
  List<Case> get cases => _cases;
  bool _hasMoreCases = true;
  int _casesPage = 0;

  /// Load both lists (refresh)
  Future<void> loadCases() async {
    await Future.wait([
      loadMoreCases(refresh: true),
    ]);
  }

  Future<void> loadMoreCases({bool refresh = false, int size = 10}) async {
    if (!refresh && !_hasMoreCases) return;
    if (_loading && !refresh) return;

    if (refresh) {
      _casesPage = 0;
      _hasMoreCases = true;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final page = _casesPage;
      final res = await _repository.getCases(
        page: page,
        size: size,
      );

      if (refresh) {
        _cases = res.content;
      } else {
        _cases = [..._cases, ...res.content];
      }

      _hasMoreCases = !res.last;
      _casesPage = page + 1;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
