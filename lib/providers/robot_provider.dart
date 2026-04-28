import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/websocket_service.dart';

// Expose the existing WebSocket singleton status.
final robotConnectionProvider = Provider<ValueNotifier<String>>((ref) {
  return WebSocketService().connectionStatus;
});

// Expose frame stream.
final robotFrameProvider = StreamProvider<Uint8List>((ref) {
  return WebSocketService().frames;
});
