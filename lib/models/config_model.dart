class EspConfig {
  final String esp32IpAddress;
  final int port;

  const EspConfig({this.esp32IpAddress = '192.168.4.1', this.port = 80});

  EspConfig copyWith({String? esp32IpAddress, int? port}) {
    return EspConfig(
      esp32IpAddress: esp32IpAddress ?? this.esp32IpAddress,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toMap() => {
    'esp32IpAddress': esp32IpAddress,
    'port': port,
  };

  factory EspConfig.fromMap(Map<String, dynamic> map) => EspConfig(
    esp32IpAddress: map['esp32IpAddress'] ?? '192.168.4.1',
    port: map['port'] ?? 80,
  );
}
