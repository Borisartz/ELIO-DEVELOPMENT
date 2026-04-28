import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  static final WebSocketService _instance = WebSocketService._internal();

  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<Uint8List> _framesController =
      StreamController<Uint8List>.broadcast();
  final ValueNotifier<String> connectionStatus = ValueNotifier('Disconnected');

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _ip = '192.168.4.1';
  int _port = 81;
  bool _isIntentionallyClosed = false;
  int _retryCount = 0;
  final int _maxRetries = 5;

  Stream<String> get status => _statusController.stream;
  Stream<Uint8List> get frames => _framesController.stream;
  bool get isConnected => _isConnected;

  void configure(String ip, int port) {
    _ip = ip;
    _port = port;
    _retryCount = 0;
    _isIntentionallyClosed = false;
  }

  Future<bool> connect() async {
    if (_isConnected) return true;
    try {
      _statusController.add('Connecting...');
      connectionStatus.value = 'Connecting...';
      _channel = WebSocketChannel.connect(Uri.parse('ws://$_ip:$_port'));

      // Timeout after 5 seconds if ESP32 doesn't respond
      await _channel!.ready.timeout(const Duration(seconds: 5));

      _isConnected = true;
      _retryCount = 0; // Reset retry count on success
      _statusController.add('Connected');
      connectionStatus.value = 'Connected';

      _channel!.stream.listen(
        _handleIncoming,
        onError: (error) {
          _isConnected = false;
          if (!_isIntentionallyClosed) _startReconnectLoop();
        },
        onDone: () {
          _isConnected = false;
          if (!_isIntentionallyClosed) _startReconnectLoop();
        },
      );
      return true;
    } catch (e) {
      _isConnected = false;
      if (!_isIntentionallyClosed) {
        _startReconnectLoop();
      } else {
        _statusController.add('Disconnected');
        connectionStatus.value = 'Disconnected';
      }
      return false;
    }
  }

  void _startReconnectLoop() {
    if (_retryCount >= _maxRetries || _isIntentionallyClosed) {
      _statusController.add('Disconnected');
      connectionStatus.value = 'Disconnected';
      return;
    }

    _statusController.add('Reconnecting...');
    connectionStatus.value = 'Reconnecting...';

    // Exponential backoff: 2s, 4s, 8s, 16s... max 30s
    final delayMs = (2000 * (1 << _retryCount)).clamp(2000, 30000);
    _retryCount++;

    Future.delayed(Duration(milliseconds: delayMs), () async {
      if (_isIntentionallyClosed) return;
      bool success = await connect();
      if (!success && !_isIntentionallyClosed) {
        _startReconnectLoop(); // Recursively retry
      }
    });
  }

  void _handleIncoming(dynamic message) {
    if (message is Uint8List) {
      _framesController.add(message);
      return;
    }

    if (message is List<int>) {
      _framesController.add(Uint8List.fromList(message));
      return;
    }

    if (message is! String) return;

    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded['frame'] is String) {
        _framesController.add(base64Decode(decoded['frame'] as String));
      }

      if (decoded['status'] is String) {
        _statusController.add(decoded['status'] as String);
      }
    } catch (_) {
      // Ignore plain text and malformed payloads.
    }
  }

  void sendMotorCommand(int left, int right) {
    if (!_isConnected || _channel == null) return;

    _channel!.sink.add(
      jsonEncode({'cmd': 'motor', 'left': left, 'right': right}),
    );
  }

  void sendServoCommand(String part, int value) {
    if (!_isConnected || _channel == null) return;

    _channel!.sink.add(
      jsonEncode({'cmd': 'servo', 'part': part, 'val': value}),
    );
  }

  void disconnect() {
    _isIntentionallyClosed = true;
    _channel?.sink.close();
    _isConnected = false;
    _statusController.add('Disconnected');
    connectionStatus.value = 'Disconnected';
  }
}
