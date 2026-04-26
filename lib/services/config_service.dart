import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/config_model.dart';

class ConfigService {
  static const _key = 'elio_esp_config';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveConfig(EspConfig config) async {
    await _secureStorage.write(
      key: _key,
      value: jsonEncode(config.toMap()),
    );
  }

  Future<EspConfig> loadConfig() async {
    final raw = await _secureStorage.read(key: _key);
    if (raw == null) return const EspConfig();
    return EspConfig.fromMap(jsonDecode(raw));
  }

  Future<void> clearConfig() async {
    await _secureStorage.delete(key: _key);
  }
}
