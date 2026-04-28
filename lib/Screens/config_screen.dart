import 'package:elio/models/config_model.dart';
import 'package:elio/services/config_service.dart';
import 'package:elio/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'control_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _ip1 = TextEditingController(text: '192');
  final TextEditingController _ip2 = TextEditingController(text: '168');
  final TextEditingController _ip3 = TextEditingController(text: '1');
  final TextEditingController _ip4 = TextEditingController(text: '100');
  final TextEditingController _port = TextEditingController(text: '81');

  final ConfigService _configService = ConfigService();

  bool saveDefault = true;
  bool _isConnecting = false;

  final Color backgroundMain = const Color(0xFFF5F7F6);
  final Color textPrimary = const Color(0xFF1C2833);
  final Color textSecondary = const Color(0xFF7F8C8D);
  final Color primaryColor = const Color(0xFF1D9E75);
  final Color blueAccent = const Color(0xFF3498DB);
  final Color orangeAccent = const Color(0xFFE67E22);
  final Color redAccent = const Color(0xFFE74C3C);
  final Color cardBorder = const Color(0xFFE8ECEB);
  final Color inputSurface = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final config = await _configService.loadConfig();
    final parts = config.esp32IpAddress.split('.');

    if (!mounted) return;

    if (parts.length == 4) {
      _ip1.text = parts[0];
      _ip2.text = parts[1];
      _ip3.text = parts[2];
      _ip4.text = parts[3];
    }
    _port.text = config.port.toString();
  }

  Future<void> _connect() async {
    final ipParts = [_ip1.text, _ip2.text, _ip3.text, _ip4.text];
    final parsedParts = ipParts.map(int.tryParse).toList();
    final parsedPort = int.tryParse(_port.text);

    final ipValid = parsedParts.every(
      (segment) => segment != null && segment >= 0 && segment <= 255,
    );
    final portValid =
        parsedPort != null && parsedPort > 0 && parsedPort <= 65535;

    if (!ipValid || !portValid) {
      _showSnack('Please enter a valid IP address and port', isError: true);
      return;
    }

    final ip = parsedParts.join('.');
    final port = parsedPort;

    // 1. Start loading state
    setState(() => _isConnecting = true);

    // 2. Configure and AWAIT the connection result
    WebSocketService().configure(ip, port);
    bool success = await WebSocketService().connect();

    // 3. Stop loading state
    if (!mounted) return;
    setState(() => _isConnecting = false);

    // 4. Handle Result
    if (success) {
      if (saveDefault) {
        await _configService.saveConfig(
          EspConfig(esp32IpAddress: ip, port: port),
        );
      }
      // Only navigate if actually connected
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ControlScreen()),
      );
    } else {
      // Show error and STAY on Config Screen
      _showSnack(
        'Connection failed. Is ELIO turned on and on the same WiFi?',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFC62828)
            : const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _ip1.dispose();
    _ip2.dispose();
    _ip3.dispose();
    _ip4.dispose();
    _port.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderIconButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  const Text(
                    'Connect to ELIO',
                    style: TextStyle(
                      color: Color(0xFF1C2833),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildHeaderIconButton(Icons.settings, () {}),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBUinIN2aGdLg1fU2_rgu67j0EHsNx1voLJmlkDFlqXRm0csgEaXwg5dSybXRiNfIlqTcFuhjFj2UXBlN2yofzAqQtXpgpuLGhctURn1ZN8OucOFOD1IEy4g9gP7ORY0P1ENezpePCb44TpXiV7O9Jf_kEoPrQ4MW67fSUW2aFKGR7RAE62Dtjh-tVrdY0IUXa_ncD6Oo95Cwqn2hDfCQdJZYUj_NZ4cQhLU1JMuw_HgPWjhj1qz1LUwuGaMyHA6iPNttJgfF1EQuM',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: redAccent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DISCONNECTED',
                        style: TextStyle(
                          color: Color(0xFFE74C3C),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Ensure your phone is on the robot\'s Wi-Fi.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Settings',
                      style: TextStyle(
                        color: Color(0xFF1C2833),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'IP Address',
                      style: TextStyle(
                        color: Color(0xFF1C2833),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildIpField(_ip1),
                        const _DotSeparator(),
                        _buildIpField(_ip2),
                        const _DotSeparator(),
                        _buildIpField(_ip3),
                        const _DotSeparator(),
                        _buildIpField(_ip4),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Port',
                      style: TextStyle(
                        color: Color(0xFF1C2833),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPortField(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Save as default config',
                          style: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Switch(
                          value: saveDefault,
                          onChanged: (val) => setState(() => saveDefault = val),
                          activeThumbColor: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnecting
                        ? primaryColor.withValues(alpha: 0.6)
                        : primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isConnecting)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      else
                        const Icon(Icons.wifi_tethering, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        _isConnecting
                            ? 'CONNECTING...'
                            : 'ESTABLISH CONNECTION',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(icon, color: textPrimary, size: 22),
        ),
      ),
    );
  }

  Widget _buildIpField(TextEditingController controller) {
    return Expanded(
      child: SizedBox(
        height: 54,
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortField() {
    return SizedBox(
      height: 54,
      child: TextField(
        controller: _port,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: Color(0xFF1C2833),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: inputSurface,
          suffixIcon: const Icon(Icons.lan, color: Color(0xFF7F8C8D)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}

class _DotSeparator extends StatelessWidget {
  const _DotSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '.',
        style: TextStyle(
          color: Color(0xFF7F8C8D),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
