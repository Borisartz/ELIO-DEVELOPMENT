class HttpResponseModel {
  final bool success;
  final String message;
  final DateTime timestamp;

  const HttpResponseModel({
    required this.success,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'success': success,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HttpResponseModel.fromMap(Map<String, dynamic> map) {
    return HttpResponseModel(
      success: map['success'] == true,
      message: (map['message'] ?? '').toString(),
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
