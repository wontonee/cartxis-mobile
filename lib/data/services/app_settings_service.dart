import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';

/// App Settings Service
/// Fetches public app configuration from the backend.
class AppSettingsService {
  final ApiClient _apiClient;

  AppSettingsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Returns app settings data map, or null on failure.
  Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final response = await _apiClient.get(ApiConfig.appSettings);
      if (response['data'] is Map<String, dynamic>) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the mobile auth logo URL, or null if not set.
  Future<String?> getMobileAuthLogo() async {
    final settings = await fetchSettings();
    final logo = settings?['mobile_auth_logo'];
    if (logo is String && logo.isNotEmpty) return logo;
    return null;
  }
}
