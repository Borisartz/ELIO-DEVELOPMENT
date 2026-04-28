import 'dart:async';
import 'dart:typed_data';

import 'package:elio/services/websocket_service.dart';
import 'package:flutter/material.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final WebSocketService _ws = WebSocketService();

  StreamSubscription<Uint8List>? _frameSub;

  Uint8List? _currentFrame;
  String _currentStatus = 'Connecting...';

  double _pwmSpeed = 75;
  double _baseAngle = 90;
  double _elbowAngle = 45;
  double _gripperVal = 10;

  final Color backgroundMain = const Color(0xFFF5F7F6);
  final Color textPrimary = const Color(0xFF1C2833);
  final Color textSecondary = const Color(0xFF7F8C8D);
  final Color primaryColor = const Color(0xFF1D9E75);
  final Color blueAccent = const Color(0xFF3498DB);
  final Color purpleAccent = const Color(0xFF9B59B6);
  final Color orangeAccent = const Color(0xFFE67E22);
  final Color redAccent = const Color(0xFFE74C3C);
  final Color cardBorder = const Color(0xFFE8ECEB);
  final Color surface = Colors.white;

  bool get _isOperational => _currentStatus == 'Connected';

  @override
  void initState() {
    super.initState();

    _currentStatus = _ws.connectionStatus.value;
    _ws.connectionStatus.addListener(_onStatusChanged);

    _frameSub = _ws.frames.listen((frame) {
      if (!mounted) return;
      setState(() => _currentFrame = frame);
    });

    _ws.connect();
  }

  void _onStatusChanged() {
    if (mounted) {
      setState(() {
        _currentStatus = _ws.connectionStatus.value;
      });
    }
  }

  @override
  void dispose() {
    _ws.connectionStatus.removeListener(_onStatusChanged);
    _frameSub?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  void _sendMotor(int left, int right) {
    _ws.sendMotorCommand(left, right);
  }

  void _sendServo(String part, double value) {
    _ws.sendServoCommand(part, value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _currentStatus == 'Connected';
    final isReconnecting = _currentStatus == 'Reconnecting...';

    return Scaffold(
      backgroundColor: backgroundMain,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isConnected, isReconnecting),
                const SizedBox(height: 16),
                _buildStatusSummary(isConnected, isReconnecting),
                const SizedBox(height: 16),
                _buildCameraCard(),
                const SizedBox(height: 16),
                _buildDriveControls(),
                const SizedBox(height: 16),
                _buildArmControls(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isConnected, bool isReconnecting) {
    Color statusColor = isConnected
        ? primaryColor
        : isReconnecting
        ? orangeAccent
        : redAccent;
    String displayText = isConnected
        ? 'LIVE'
        : isReconnecting
        ? 'RECONNECTING...'
        : 'OFFLINE';

    return Row(
      children: [
        _buildHeaderIconButton(Icons.menu, () {}),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ELIO',
                style: TextStyle(
                  color: Color(0xFF1C2833),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Robot control dashboard',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(icon, color: textPrimary, size: 22),
        ),
      ),
    );
  }

  Widget _buildStatusSummary(bool isConnected, bool isReconnecting) {
    Color statusColor = isConnected
        ? primaryColor
        : isReconnecting
        ? orangeAccent
        : redAccent;
    IconData statusIcon = isConnected
        ? Icons.smart_toy_outlined
        : isReconnecting
        ? Icons.autorenew
        : Icons.warning_amber_rounded;
    String statusMessage = isConnected
        ? 'Connected and ready'
        : isReconnecting
        ? 'Reconnecting...'
        : 'Not connected yet';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ELIO Robot',
                  style: TextStyle(
                    color: Color(0xFF1C2833),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusMessage,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_currentFrame != null)
                Image.memory(
                  _currentFrame!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
              else
                Container(
                  color: const Color(0xFFF0F3F2),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1D9E75)),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '98%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DETECTION',
                            style: TextStyle(
                              color: Color(0xFF1D9E75),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Plastic Bottle',
                            style: TextStyle(
                              color: Color(0xFF1C2833),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBorder),
                        ),
                        child: const Icon(
                          Icons.lock_open,
                          color: Color(0xFF7F8C8D),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriveControls() {
    return _buildSection(
      title: 'DRIVE CONTROLS',
      child: AbsorbPointer(
        absorbing: !_isOperational,
        child: Opacity(
          opacity: _isOperational ? 1.0 : 0.3,
          child: Column(
            children: [
              _buildSliderCard(
                label: 'Speed (PWM)',
                valueText: '${_pwmSpeed.toInt()}%',
                value: _pwmSpeed,
                min: 0,
                max: 100,
                onChanged: (val) => setState(() => _pwmSpeed = val),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 240,
                height: 240,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  children: [
                    const SizedBox(),
                    _buildDpadButton(
                      Icons.arrow_upward,
                      () => _sendMotor(_pwmSpeed.toInt(), _pwmSpeed.toInt()),
                    ),
                    const SizedBox(),
                    _buildDpadButton(
                      Icons.arrow_back,
                      () => _sendMotor(-_pwmSpeed.toInt(), _pwmSpeed.toInt()),
                    ),
                    GestureDetector(
                      onTapDown: (_) => _sendMotor(0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: redAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: redAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(Icons.hexagon, color: redAccent, size: 36),
                      ),
                    ),
                    _buildDpadButton(
                      Icons.arrow_forward,
                      () => _sendMotor(_pwmSpeed.toInt(), -_pwmSpeed.toInt()),
                    ),
                    const SizedBox(),
                    _buildDpadButton(
                      Icons.arrow_downward,
                      () => _sendMotor(-_pwmSpeed.toInt(), -_pwmSpeed.toInt()),
                    ),
                    const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArmControls() {
    return _buildSection(
      title: 'ARM MANIPULATION',
      child: AbsorbPointer(
        absorbing: !_isOperational,
        child: Opacity(
          opacity: _isOperational ? 1.0 : 0.3,
          child: Column(
            children: [
              _buildSliderCard(
                label: 'Base',
                valueText: '${_baseAngle.toInt()}°',
                value: _baseAngle,
                min: 0,
                max: 180,
                onChanged: (val) {
                  setState(() => _baseAngle = val);
                  _sendServo('base', val);
                },
              ),
              const SizedBox(height: 18),
              _buildSliderCard(
                label: 'Elbow',
                valueText: '${_elbowAngle.toInt()}°',
                value: _elbowAngle,
                min: 0,
                max: 180,
                onChanged: (val) {
                  setState(() => _elbowAngle = val);
                  _sendServo('elbow', val);
                },
              ),
              const SizedBox(height: 18),
              _buildSliderCard(
                label: 'Gripper',
                valueText: _gripperVal < 30 ? 'Open' : 'Closed',
                value: _gripperVal,
                min: 0,
                max: 100,
                onChanged: (val) {
                  setState(() => _gripperVal = val);
                  _sendServo('gripper', val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _sendServo('gripper', 100),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pinch, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'PICK UP',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _sendServo('gripper', 0),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.back_hand, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'RELEASE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1C2833),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            thumbColor: primaryColor,
            activeTrackColor: primaryColor,
            inactiveTrackColor: const Color(0xFFE1E7E5),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: primaryColor.withValues(alpha: 0.14),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildDpadButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      onTapUp: (_) => _sendMotor(0, 0),
      onTapCancel: () => _sendMotor(0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: textPrimary, size: 32),
      ),
    );
  }
}
