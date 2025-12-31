import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

/// Authentication Service
class AuthService {
  final ApiClient _apiClient;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Login
  Future<LoginData> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.authLogin,
      body: {
        'email': email,
        'password': password,
        'device_name': deviceName ?? ApiConfig.deviceName,
      },
    );

    // Check success first before parsing data
    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Login failed',
        code: response['error_code'] ?? 'LOGIN_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse response
    final apiResponse = ApiResponse<LoginData>.fromJson(
      response,
      (data) => LoginData.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        message: apiResponse.message,
        code: apiResponse.errorCode ?? 'LOGIN_FAILED',
      );
    }

    // Save token and user data
    await _saveAuthData(apiResponse.data!);

    return apiResponse.data!;
  }

  /// Register
  Future<LoginData> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.authRegister,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'terms_accepted': '1',
      },
    );

    // Check success first before parsing data
    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Registration failed',
        code: response['error_code'] ?? 'REGISTER_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse response
    final apiResponse = ApiResponse<LoginData>.fromJson(
      response,
      (data) => LoginData.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        message: apiResponse.message,
        code: apiResponse.errorCode ?? 'REGISTER_FAILED',
      );
    }

    // Save token and user data
    await _saveAuthData(apiResponse.data!);

    return apiResponse.data!;
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(LoginData loginData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save token
    print('💾 Saving auth token: ${loginData.token.substring(0, 20)}...');
    await prefs.setString(_tokenKey, loginData.token);
    print('✅ Token saved successfully');
    
    // Save user data as JSON string
    await prefs.setString(_userKey, _userToJson(loginData.user));
    
    // Keep the existing isLoggedIn flag
    await prefs.setBool('isLoggedIn', true);
  }

  /// Convert user to JSON string
  String _userToJson(UserModel user) {
    final userMap = user.toJson();
    final buffer = StringBuffer();
    buffer.write('{');
    
    userMap.forEach((key, value) {
      if (buffer.length > 1) buffer.write(',');
      buffer.write('"$key":');
      if (value == null) {
        buffer.write('null');
      } else if (value is String) {
        buffer.write('"$value"');
      } else {
        buffer.write('$value');
      }
    });
    
    buffer.write('}');
    return buffer.toString();
  }

  /// Parse user from JSON string
  UserModel? _parseUserFromJson(String jsonString) {
    try {
      // Basic JSON parsing for our user model
      final data = <String, dynamic>{};
      final content = jsonString.substring(1, jsonString.length - 1); // Remove { }
      final pairs = content.split(',');
      
      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          var value = parts[1].trim();
          
          if (value == 'null') {
            data[key] = null;
          } else if (value.startsWith('"')) {
            data[key] = value.replaceAll('"', '');
          } else {
            data[key] = int.tryParse(value) ?? value;
          }
        }
      }
      
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get saved user
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      return _parseUserFromJson(userJson);
    }
    
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear authentication data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool('isLoggedIn', false);
  }

  /// Get authorization header
  Future<Map<String, String>?> getAuthHeaders() async {
    final token = await getToken();
    
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
      };
    }
    
    return null;
  }

  /// Get user profile from API
  Future<UserModel> getProfile() async {
    final headers = await getAuthHeaders();
    
    if (headers == null) {
      throw ApiException(
        message: 'Not authenticated',
        code: 'NOT_AUTHENTICATED',
      );
    }

    final response = await _apiClient.get(
      ApiConfig.authMe,
      headers: headers,
    );

    // Check success first before parsing data
    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve user details',
        code: response['error_code'] ?? 'PROFILE_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse response
    final apiResponse = ApiResponse<UserModel>.fromJson(
      response,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        message: apiResponse.message,
        code: apiResponse.errorCode ?? 'PROFILE_FETCH_FAILED',
      );
    }

    // Update stored user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, _userToJson(apiResponse.data!));

    return apiResponse.data!;
  }
}
