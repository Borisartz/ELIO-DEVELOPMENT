import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/config_model.dart';

class ConfigService {
  static const _key = 'elio_http_config';

  Future<void> saveConfig(EspConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config.toMap()));
  }

  Future<EspConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const EspConfig();
    return EspConfig.fromMap(jsonDecode(raw));
  }

  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
