import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

/// API Client for handling HTTP requests
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? _createClient();

  /// Create HTTP client with certificate handling for development
  static http.Client _createClient() {
    // In test mode, allow self-signed certificates
    if (!ApiConfig.isProduction) {
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return IOClient(ioClient);
    }
    return http.Client();
  }

  /// GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(endpoint))
          .replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: await _buildHeaders(headers),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed',
        code: 'CONNECTION_FAILED',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(endpoint));

      final response = await _client
          .post(
            uri,
            headers: await _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed',
        code: 'CONNECTION_FAILED',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(endpoint));

      final response = await _client
          .put(
            uri,
            headers: await _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed',
        code: 'CONNECTION_FAILED',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// POST Multipart Request (for file uploads)
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);

      // Add headers (without Content-Type as it's set automatically for multipart)
      final builtHeaders = await _buildHeaders(headers);
      builtHeaders.remove('Content-Type'); // Remove JSON content type
      request.headers.addAll(builtHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      // Send request
      final streamedResponse = await _client
          .send(request)
          .timeout(ApiConfig.receiveTimeout);

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed',
        code: 'CONNECTION_FAILED',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getFullUrl(endpoint));

      final response = await _client
          .delete(
            uri,
            headers: await _buildHeaders(headers),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on http.ClientException {
      throw ApiException(
        message: 'Connection failed',
        code: 'CONNECTION_FAILED',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Build headers with default values
  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication token if available
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        defaultHeaders['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
    }

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;


    // Try to parse response body
    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse response',
        code: 'PARSE_ERROR',
      );
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      return responseData;
    } else if (statusCode == 401) {
      throw ApiException(
        message: responseData['message'] ?? 'Unauthorized',
        code: responseData['error_code'] ?? 'UNAUTHORIZED',
        statusCode: statusCode,
      );
    } else if (statusCode == 422) {
      throw ApiException(
        message: responseData['message'] ?? 'Validation error',
        code: responseData['error_code'] ?? 'VALIDATION_ERROR',
        statusCode: statusCode,
        errors: responseData['errors'] as Map<String, dynamic>?,
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ApiException(
        message: responseData['message'] ?? 'Client error',
        code: responseData['error_code'] ?? 'CLIENT_ERROR',
        statusCode: statusCode,
      );
    } else if (statusCode >= 500) {
      throw ApiException(
        message: responseData['message'] ?? 'Server error',
        code: responseData['error_code'] ?? 'SERVER_ERROR',
        statusCode: statusCode,
      );
    }

    return responseData;
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
