import 'package:flutter/material.dart';
import 'package:elio/models/config_model.dart';
import 'package:elio/services/config_service.dart';
import 'package:elio/services/mqtt_service.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  // Controllers — WiFi
  final _ssidController = TextEditingController();
  final _wifiPassController = TextEditingController();

  // Controllers — MQTT
  final _brokerController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '1883');
  final _clientIdController = TextEditingController(text: 'elio_app');
  final _mqttUserController = TextEditingController();
  final _mqttPassController = TextEditingController();

  // Controllers — Camera
  final _cameraUrlController = TextEditingController();

  final _configService = ConfigService();
  final _mqttService = MqttService();

  bool _obscureWifiPass = true;
  bool _obscureMqttPass = true;
  bool _isTesting = false;
  bool _isSaving = false;
  _ConnectionStatus _status = _ConnectionStatus.idle;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final config = await _configService.loadConfig();
    setState(() {
      _ssidController.text = config.wifiSsid;
      _wifiPassController.text = config.wifiPassword;
      _brokerController.text = config.mqttBroker;
      _portController.text = config.mqttPort.toString();
      _clientIdController.text = config.mqttClientId;
      _mqttUserController.text = config.mqttUsername;
      _mqttPassController.text = config.mqttPassword;
      _cameraUrlController.text = config.cameraUrl;
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    final config = EspConfig(
      wifiSsid: _ssidController.text.trim(),
      wifiPassword: _wifiPassController.text,
      mqttBroker: _brokerController.text.trim(),
      mqttPort: int.tryParse(_portController.text) ?? 1883,
      mqttClientId: _clientIdController.text.trim(),
      mqttUsername: _mqttUserController.text.trim(),
      mqttPassword: _mqttPassController.text,
      cameraUrl: _cameraUrlController.text.trim(),
    );
    await _configService.saveConfig(config);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuration saved successfully'),
          backgroundColor: const Color(0xFF0F6E56),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_brokerController.text.isEmpty) {
      _showError('Please enter MQTT broker IP address');
      return;
    }

    setState(() {
      _isTesting = true;
      _status = _ConnectionStatus.testing;
    });

    final success = await _mqttService.connect(
      broker: _brokerController.text.trim(),
      port: int.tryParse(_portController.text) ?? 1883,
      clientId: _clientIdController.text.trim(),
      username: _mqttUserController.text.trim(),
      password: _mqttPassController.text,
    );

    setState(() {
      _isTesting = false;
      _status = success
          ? _ConnectionStatus.connected
          : _ConnectionStatus.failed;
    });

    if (success) {
      _mqttService.disconnect();
    }
  }

  Future<void> _clearConfig() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear configuration'),
        content: const Text(
          'This will delete all saved WiFi and MQTT settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _configService.clearConfig();
      _ssidController.clear();
      _wifiPassController.clear();
      _brokerController.text = '192.168.1.100';
      _portController.text = '1883';
      _clientIdController.text = 'elio_app';
      _mqttUserController.clear();
      _mqttPassController.clear();
      _cameraUrlController.clear();
      setState(() => _status = _ConnectionStatus.idle);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _wifiPassController.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _clientIdController.dispose();
    _mqttUserController.dispose();
    _mqttPassController.dispose();
    _cameraUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESP32 Config',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Connect ELIO robot via WiFi + MQTT',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  // Clear button
                  IconButton(
                    onPressed: _clearConfig,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFC62828),
                    ),
                    tooltip: 'Clear config',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Connection status banner
              _buildStatusBanner(),

              const SizedBox(height: 20),

              // WiFi section
              _buildSection(
                title: 'WiFi Settings',
                icon: Icons.wifi,
                color: const Color(0xFF2196F3),
                children: [
                  _buildField(
                    controller: _ssidController,
                    label: 'WiFi SSID',
                    hint: 'Enter your WiFi network name',
                    icon: Icons.wifi,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _wifiPassController,
                    label: 'WiFi Password',
                    hint: 'Enter WiFi password',
                    icon: Icons.lock_outline,
                    obscure: _obscureWifiPass,
                    onToggleObscure: () =>
                        setState(() => _obscureWifiPass = !_obscureWifiPass),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // MQTT section
              _buildSection(
                title: 'MQTT Broker',
                icon: Icons.router_outlined,
                color: const Color(0xFF0F6E56),
                children: [
                  _buildField(
                    controller: _brokerController,
                    label: 'Broker IP Address',
                    hint: '192.168.1.100',
                    icon: Icons.dns_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _portController,
                    label: 'Port',
                    hint: '1883',
                    icon: Icons.settings_ethernet,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _clientIdController,
                    label: 'Client ID',
                    hint: 'elio_app',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _mqttUserController,
                    label: 'Username (optional)',
                    hint: 'Leave empty if not required',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _mqttPassController,
                    label: 'Password (optional)',
                    hint: 'Leave empty if not required',
                    icon: Icons.lock_outline,
                    obscure: _obscureMqttPass,
                    onToggleObscure: () =>
                        setState(() => _obscureMqttPass = !_obscureMqttPass),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Camera section
              _buildSection(
                title: 'Camera Stream',
                icon: Icons.camera_alt_outlined,
                color: const Color(0xFF9C27B0),
                children: [
                  _buildField(
                    controller: _cameraUrlController,
                    label: 'ESP32-CAM Stream URL',
                    hint: 'http://192.168.1.101:81/stream',
                    icon: Icons.videocam_outlined,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usually http://<ESP32-IP>:81/stream',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // MQTT Topics info card
              _buildTopicsCard(),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F6E56),
                              ),
                            )
                          : const Icon(
                              Icons.wifi_tethering,
                              color: Color(0xFF0F6E56),
                              size: 18,
                            ),
                      label: Text(
                        _isTesting ? 'Testing...' : 'Test connection',
                        style: const TextStyle(
                          color: Color(0xFF0F6E56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF0F6E56)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveConfig,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(_isSaving ? 'Saving...' : 'Save config'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6E56),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    switch (_status) {
      case _ConnectionStatus.connected:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        title = 'Connected successfully';
        subtitle = 'MQTT broker is reachable';
        break;
      case _ConnectionStatus.failed:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = Icons.error_outline;
        title = 'Connection failed';
        subtitle = 'Check broker IP and port';
        break;
      case _ConnectionStatus.testing:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        icon = Icons.sync;
        title = 'Testing connection...';
        subtitle = 'Connecting to MQTT broker';
        break;
      case _ConnectionStatus.idle:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF666666);
        icon = Icons.info_outline;
        title = 'Not tested';
        subtitle = 'Fill in settings and tap Test';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F6E56), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildTopicsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.topic_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'MQTT Topics',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _topicRow('elio/ctrl', 'App → Robot movement commands'),
          _topicRow('elio/status', 'Robot → App status updates'),
          _topicRow('elio/sort', 'Robot → Waste sorting results'),
          _topicRow('elio/cam', 'Camera stream control'),
        ],
      ),
    );
  }

  Widget _topicRow(String topic, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F6E56).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              topic,
              style: const TextStyle(
                color: Color(0xFF4ECCA3),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ConnectionStatus { idle, testing, connected, failed }
