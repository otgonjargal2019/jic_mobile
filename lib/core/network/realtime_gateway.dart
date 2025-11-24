import 'dart:async';
import 'package:flutter/foundation.dart';
import 'socket_service.dart';

class RealtimeGateway extends ChangeNotifier {
  final SocketService _socket = SocketService();
  final Set<String> _modules = <String>{};

  String? _userId;
  String? _token;
  Future<void>? _activeConnect;

  bool get isConnected => _socket.isConnected;
  SocketService get client => _socket;

  Future<void> connectModule({
    required String module,
    required String baseUrl,
    required String userId,
    required String token,
  }) async {
    if (module.isEmpty) {
      throw ArgumentError('module name must not be empty');
    }

    while (_activeConnect != null) {
      try {
        await _activeConnect;
      } catch (_) {
        break;
      }
    }

    final completer = Completer<void>();
    _activeConnect = completer.future;

    try {
      final sameCredentials =
          _userId == userId && _token == token && _socket.isConnected;

      if (!sameCredentials) {
        if (_socket.isConnected) {
          _socket.disconnect();
        }
        _modules.clear();
        _userId = userId;
        _token = token;
        await _socket.connect(baseUrl: baseUrl, token: token);
      } else if (!_socket.isConnected) {
        await _socket.connect(baseUrl: baseUrl, token: token);
      }

      _modules.add(module);
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _activeConnect = null;
    }
  }

  void disconnectModule(String module) {
    _modules.remove(module);
    if (_modules.isEmpty) {
      _socket.disconnect();
      _userId = null;
      _token = null;
    }
  }

  void forceDisconnect() {
    _modules.clear();
    _socket.disconnect();
    _userId = null;
    _token = null;
  }
}
