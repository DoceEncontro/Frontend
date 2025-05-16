class ApiError {
  final DateTime timestamp;
  final int status;
  final String error;
  final String message;
  final String path;

  ApiError({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      error: json['error'],
      message: json['message'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(),
      'status': status,
      'error': error,
      'message': message,
      'path': path,
    };
  }

  @override
  String toString() {
    return 'ApiError(status: $status, error: $error, message: $message, path: $path)';
  }
}
