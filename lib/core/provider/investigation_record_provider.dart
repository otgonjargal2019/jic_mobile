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

  bool _hasMore = true;
  bool get hasMore => _hasMore;
  int _page = 0;
  String? _caseId;

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
}
