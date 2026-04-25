class EspConfig {
  final String wifiSsid;
  final String wifiPassword;
  final String mqttBroker;
  final int mqttPort;
  final String mqttClientId;
  final String mqttUsername;
  final String mqttPassword;
  final String cameraUrl;

  const EspConfig({
    this.wifiSsid = '',
    this.wifiPassword = '',
    this.mqttBroker = '192.168.1.100',
    this.mqttPort = 1883,
    this.mqttClientId = 'elio_app',
    this.mqttUsername = '',
    this.mqttPassword = '',
    this.cameraUrl = '',
  });

  EspConfig copyWith({
    String? wifiSsid,
    String? wifiPassword,
    String? mqttBroker,
    int? mqttPort,
    String? mqttClientId,
    String? mqttUsername,
    String? mqttPassword,
    String? cameraUrl,
  }) {
    return EspConfig(
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      mqttBroker: mqttBroker ?? this.mqttBroker,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttClientId: mqttClientId ?? this.mqttClientId,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      cameraUrl: cameraUrl ?? this.cameraUrl,
    );
  }

  Map<String, dynamic> toMap() => {
    'wifiSsid': wifiSsid,
    'wifiPassword': wifiPassword,
    'mqttBroker': mqttBroker,
    'mqttPort': mqttPort,
    'mqttClientId': mqttClientId,
    'mqttUsername': mqttUsername,
    'mqttPassword': mqttPassword,
    'cameraUrl': cameraUrl,
  };

  factory EspConfig.fromMap(Map<String, dynamic> map) => EspConfig(
    wifiSsid: map['wifiSsid'] ?? '',
    wifiPassword: map['wifiPassword'] ?? '',
    mqttBroker: map['mqttBroker'] ?? '192.168.1.100',
    mqttPort: map['mqttPort'] ?? 1883,
    mqttClientId: map['mqttClientId'] ?? 'elio_app',
    mqttUsername: map['mqttUsername'] ?? '',
    mqttPassword: map['mqttPassword'] ?? '',
    cameraUrl: map['cameraUrl'] ?? '',
  );
}
