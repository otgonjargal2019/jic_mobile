import 'package:flutter/foundation.dart';
import 'package:jic_mob/core/models/post/post.dart';
import 'package:jic_mob/core/repository/posts_repository.dart';
import 'package:jic_mob/core/models/post/post_detail.dart';

class PostsProvider extends ChangeNotifier {
  final PostsRepository _repository;

  PostsProvider(this._repository);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<Post> _notices = [];
  List<Post> get notices => _notices;
  bool _hasMoreNotices = true;
  int _noticesPage = 0;

  List<Post> _investigations = [];
  List<Post> get investigations => _investigations;
  bool _hasMoreInvestigations = true;
  int _investigationsPage = 0;

  Future<void> loadPosts() async {
    await Future.wait([
      loadMoreNotices(refresh: true),
      loadMoreInvestigations(refresh: true),
    ]);
  }

  Future<void> loadMoreNotices({bool refresh = false, int size = 10}) async {
    if (!refresh && !_hasMoreNotices) return;
    if (_loading && !refresh) return;

    if (refresh) {
      _noticesPage = 0;
      _hasMoreNotices = true;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final page = _noticesPage;
      final res = await _repository.getPosts(
        type: BoardType.notice,
        page: page,
        size: size,
      );

      if (refresh) {
        _notices = res.content;
      } else {
        _notices = [..._notices, ...res.content];
      }

      _hasMoreNotices = !res.last;
      _noticesPage = page + 1;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreInvestigations({
    bool refresh = false,
    int size = 10,
  }) async {
    if (!refresh && !_hasMoreInvestigations) return;
    if (_loading && !refresh) return;

    if (refresh) {
      _investigationsPage = 0;
      _hasMoreInvestigations = true;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final page = _investigationsPage;
      final res = await _repository.getPosts(
        type: BoardType.research,
        page: page,
        size: size,
      );

      if (refresh) {
        _investigations = res.content;
      } else {
        _investigations = [..._investigations, ...res.content];
      }

      _hasMoreInvestigations = !res.last;
      _investigationsPage = page + 1;
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

  Future<PostDetailResponse> fetchPostDetail({
    required BoardType boardType,
    required String id,
  }) async {
    try {
      final res = await _repository.getPost(type: boardType, id: id);
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
