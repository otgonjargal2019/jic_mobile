import 'dart:io' show Directory;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => status != null ? '$status: $message' : message;
}

class ApiClient {
  final Dio _dio;
  // ignore: unused_field
  final PersistCookieJar? _jar; // null on web

  ApiClient._(this._dio, this._jar);

  static Future<ApiClient> create({String? baseUrl}) async {
    final dio = Dio(
      BaseOptions(
        baseUrl:
            baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:8080',
            ),
        headers: const {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    PersistCookieJar? jar;

    if (kIsWeb) {
      // Ensure cookies are sent/received on web via fetch with credentials.
      // Use dynamic to avoid hard dependency on BrowserHttpClientAdapter symbol on non-web builds.
      try {
        (dio.httpClientAdapter as dynamic).withCredentials = true;
      } catch (_) {}
    } else {
      final Directory supportDir = await getApplicationSupportDirectory();
      jar = PersistCookieJar(
        storage: FileStorage('${supportDir.path}/.cookies'),
        ignoreExpires: false,
      );
      dio.interceptors.add(CookieManager(jar));
    }

    return ApiClient._(dio, jar);
  }

  Future<void> login({
    required String loginId,
    required String password,
    required bool stayLoggedIn,
  }) async {
    try {
      final res = await _dio.post(
        '/api/auth/login',
        data: {
          'loginId': loginId,
          'password': password,
          'stayLoggedIn': stayLoggedIn,
        },
      );

      final data = res.data;
      if (data is Map && data['success'] == true) {
        return;
      }

      final msg =
          (data is Map ? data['message'] : null)?.toString() ?? 'Login failed';
      throw ApiException(msg, res.statusCode);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['message'] : null)?.toString() ??
          e.message ??
          'Login failed';
      throw ApiException(msg, e.response?.statusCode);
    }
  }

  // Authenticated request: returns current user's profile and related lists.
  // Backend endpoint per server: /api/user/me
  Future<Response<dynamic>> getMe() => _dio.get('/api/user/me');

  /// Logs out the current session.
  ///
  /// - On non-web: clears the persisted cookie jar so future requests are unauthenticated.
  /// - On web: cannot clear HttpOnly cookies client-side; without a backend logout endpoint,
  ///   the browser will retain the cookie until it expires or the site is cleared.
  Future<void> logout() async {
    // Clear cookies on non-web platforms
    if (_jar != null) {
      try {
        await _jar.deleteAll();
      } catch (_) {}
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? receiveTimeout,
  }) async {
    final options = receiveTimeout != null
        ? Options(receiveTimeout: receiveTimeout)
        : null;

    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
