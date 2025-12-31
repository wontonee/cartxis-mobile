class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Code: $code${statusCode != null ? ', Status: $statusCode' : ''})';
  }
}
