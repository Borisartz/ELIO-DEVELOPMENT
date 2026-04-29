import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/websocket_service.dart';

// ---------------------------------------------------------------------------
// Existing providers (kept for backward compatibility)
// ---------------------------------------------------------------------------

/// Exposes the WebSocket singleton's [ValueNotifier<String>] for connection
/// status.  Prefer [robotStatusProvider] for reactive Riverpod consumption.
final robotConnectionProvider = Provider<ValueNotifier<String>>((ref) {
  return WebSocketService().connectionStatus;
});

/// Live MJPEG frame stream from the ESP32 camera.
final robotFrameProvider = StreamProvider<Uint8List>((ref) {
  return WebSocketService().frames;
});

/// Connection status as a stream that immediately emits the current value,
/// then follows updates from the WebSocket service.
final robotStatusProvider = StreamProvider<String>((ref) async* {
  final ws = WebSocketService();
  yield ws.connectionStatus.value;
  yield* ws.status;
});

// ---------------------------------------------------------------------------
// Robot control state
// ---------------------------------------------------------------------------

/// Local UI state for robot control sliders.
class RobotState {
  final double pwmSpeed;
  final double baseAngle;
  final double elbowAngle;
  final double gripperVal;

  const RobotState({
    this.pwmSpeed = 75,
    this.baseAngle = 90,
    this.elbowAngle = 45,
    this.gripperVal = 10,
  });

  RobotState copyWith({
    double? pwmSpeed,
    double? baseAngle,
    double? elbowAngle,
    double? gripperVal,
  }) {
    return RobotState(
      pwmSpeed: pwmSpeed ?? this.pwmSpeed,
      baseAngle: baseAngle ?? this.baseAngle,
      elbowAngle: elbowAngle ?? this.elbowAngle,
      gripperVal: gripperVal ?? this.gripperVal,
    );
  }
}

// ---------------------------------------------------------------------------
// Robot control notifier
// ---------------------------------------------------------------------------

class RobotControlNotifier extends Notifier<RobotState> {
  WebSocketService get _ws => WebSocketService();

  @override
  RobotState build() => const RobotState();

  // Connection lifecycle ──────────────────────────────────────────────────────

  void connect() => _ws.connect();
  void disconnect() => _ws.disconnect();

  // Drive commands ────────────────────────────────────────────────────────────

  void sendMotor(int left, int right) => _ws.sendMotorCommand(left, right);

  // Arm commands + local state update ────────────────────────────────────────

  void setPwmSpeed(double v) => state = state.copyWith(pwmSpeed: v);

  void setBaseAngle(double v) {
    state = state.copyWith(baseAngle: v);
    _ws.sendServoCommand('base', v.toInt());
  }

  void setElbowAngle(double v) {
    state = state.copyWith(elbowAngle: v);
    _ws.sendServoCommand('elbow', v.toInt());
  }

  void setGripperVal(double v) {
    state = state.copyWith(gripperVal: v);
    _ws.sendServoCommand('gripper', v.toInt());
  }

  void pickUp() => _ws.sendServoCommand('gripper', 100);
  void release() => _ws.sendServoCommand('gripper', 0);
}

final robotControlProvider =
    NotifierProvider<RobotControlNotifier, RobotState>(
      RobotControlNotifier.new,
    );
