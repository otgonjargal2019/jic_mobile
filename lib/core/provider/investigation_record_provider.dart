import 'package:flutter/foundation.dart';
import 'package:jic_mob/core/models/investigation_record/investigation_record.dart';
import 'package:jic_mob/core/repository/investigation_record_repository.dart';

class InvestigationRecordProvider extends ChangeNotifier {
  final InvestigationRecordRepository _repository;

  InvestigationRecordProvider(this._repository);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<InvestigationRecord> _records = [];
  List<InvestigationRecord> get records => _records;

  InvestigationRecord? _currentRecord;
  InvestigationRecord? get currentRecord => _currentRecord;

  bool _recordLoading = false;
  bool get recordLoading => _recordLoading;

  String? _recordError;
  String? get recordError => _recordError;

  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int _page = 0;
  String? _caseId;

  String? _sortDirection;

  String get sortDirection => _sortDirection ?? 'desc';

  void toggleSortDirection() async {
    if (_sortDirection == 'asc') {
      _sortDirection = 'desc';
    } else {
      _sortDirection = 'asc';
    }
    await Future.wait([loadMoreRecords(refresh: true)]);
  }

  void clearRecords() {
    _records = [];
    _page = 0;
    _hasMore = true;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> loadRecords({String? caseId}) async {
    _caseId = caseId;
    await Future.wait([loadMoreRecords(refresh: true)]);
  }

  Future<void> loadMoreRecords({bool refresh = false, int size = 10}) async {
    if (!refresh && !_hasMore) return;
    if (_loading && !refresh) return;

    if (refresh) {
      _page = 0;
      _hasMore = true;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final page = _page;
      final res = await _repository.getInvestigationRecords(
        sortDirection: _sortDirection ?? 'desc',
        page: page,
        size: size,
        caseId: _caseId,
      );

      if (refresh) {
        _records = res.content;
      } else {
        _records = [..._records, ...res.content];
      }
      if (res.content.isEmpty) {
        _hasMore = false;
      } else {
        _hasMore = !res.last;
        _page = page + 1;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _records = [];
    _page = 0;
    _hasMore = true;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> loadRecordById(String recordId) async {
    _recordLoading = true;
    _recordError = null;
    _currentRecord = null;
    notifyListeners();

    try {
      final rec = await _repository.getInvestigationRecordById(recordId);
      _currentRecord = rec;
      _recordError = null;
    } catch (e) {
      _recordError = e.toString();
    } finally {
      _recordLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentRecord() {
    _currentRecord = null;
    _recordError = null;
    _recordLoading = false;
    notifyListeners();
  }
}
