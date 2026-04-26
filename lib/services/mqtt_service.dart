import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient? _client;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<bool> connect({
    required String broker,
    required int port,
    required String clientId,
    String? username,
    String? password,
  }) async {
    try {
      _client = MqttServerClient.withPort(broker, clientId, port);
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillQos(MqttQos.atLeastOnce)
          .startClean();

      if (username != null && username.isNotEmpty) {
        _client!.connectionMessage = _client!.connectionMessage!.authenticateAs(
          username,
          password,
        );
      }

      _client!.onConnected = () => _isConnected = true;
      _client!.onDisconnected = () => _isConnected = false;

      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _isConnected = true;
        return true;
      }
      return false;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  void publish(String topic, String message) {
    if (!_isConnected || _client == null) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
  }
}
