/// API Response Meta
class ApiMeta {
  final String timestamp;
  final String version;

  ApiMeta({
    required this.timestamp,
    required this.version,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      timestamp: json['timestamp'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'version': version,
    };
  }
}

/// Base API Response
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final ApiMeta meta;
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.meta,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && dataParser != null
          ? dataParser(json['data'])
          : null,
      meta: ApiMeta.fromJson(json['meta'] as Map<String, dynamic>),
      errorCode: json['error_code'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? dataSerializer) {
    return {
      'success': success,
      'message': message,
      'data': data != null && dataSerializer != null
          ? dataSerializer(data as T)
          : data,
      'meta': meta.toJson(),
      if (errorCode != null) 'error_code': errorCode,
    };
  }
}
