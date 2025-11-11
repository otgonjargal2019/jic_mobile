import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

/// Lightweight wrapper around a Socket.IO client connection.
/// The server currently accepts an `auth.userId` payload for development.
class SocketService {
  io.Socket? _socket;
  Completer<void>? _connectionCompleter;

  bool get isConnected => _socket?.connected == true;
  io.Socket? get raw => _socket;

  Future<void> connect({
    required String baseUrl,
    required String userId,
  }) async {
    if (isConnected) return;

    _connectionCompleter = Completer<void>();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'userId': userId})
          .build(),
    );

    _socket?.onConnect((_) {
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete();
      }
    });

    _socket?.onConnectError((error) {
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.completeError('Connection error: $error');
      }
    });

    try {
      await _connectionCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Socket connection timeout'),
      );
    } finally {
      _connectionCompleter = null;
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void emitAck(String event, dynamic data, Function(dynamic) ack) {
    _socket?.emitWithAck(event, data, ack: ack);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
