import 'package:flutter/foundation.dart';

import '../../features/auth/domain/models/user_profile.dart';
import '../network/api_client.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _loading = false;
  String? _error;
  String? _accessToken;

  UserProfile? get profile => _profile;
  bool get isLoggedIn => _profile != null;
  bool get isLoading => _loading;
  String? get error => _error;
  String? get accessToken => _accessToken;

  void setProfile(UserProfile? profile) {
    _profile = profile;
    notifyListeners();
  }

  void setAccessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  void updateProfile({String? name, String? email, String? avatarUrl}) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
    notifyListeners();
  }

  void clear() {
    _profile = null;
    _error = null;
    _accessToken = null;
    notifyListeners();
  }

  /// Fetches the current user's profile from the backend `/api/user/me` endpoint
  /// and stores a simplified view into this provider.
  Future<void> fetchMe() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final api = await ApiClient.create();
      final res = await api.getMe();
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final userData = (data['userData'] as Map?)?.cast<String, dynamic>();
        if (userData != null) {
          final nameKr = userData['nameKr']?.toString();
          final nameEn = userData['nameEn']?.toString();
          final displayName = (nameEn != null && nameEn.isNotEmpty)
              ? nameEn
              : (nameKr ?? '');

          final id = (userData['userId'] ?? data['userId'])?.toString() ?? '';
          final role = userData['role']?.toString();
          final email = userData['email']?.toString();
          final avatarUrl = userData['profileImageUrl']?.toString();

          setProfile(
            UserProfile(
              id: id,
              name: displayName,
              role: role ?? '',
              email: email,
              avatarUrl: avatarUrl,
              extra: userData,
            ),
          );
        } else {
          // Unexpected shape; clear profile but no hard error.
          clear();
        }
      } else {
        clear();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
