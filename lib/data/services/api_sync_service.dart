import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class ApiSyncService {
  final ApiClient _apiClient;

  ApiSyncService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> sendHeartbeat({
    bool connected = true,
    bool syncEnabled = true,
    String lastStatus = 'success',
    String lastMessage = 'Sync completed successfully.',
    DateTime? lastSyncAt,
  }) async {
    final payload = {
      'connected': connected,
      'sync_enabled': syncEnabled,
      'last_status': lastStatus,
      'last_message': lastMessage,
      'last_sync_at': _formatDateTime(lastSyncAt ?? DateTime.now()),
    };

    final response = await _apiClient.post(
      ApiConfig.apiSyncHeartbeat,
      body: payload,
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Heartbeat failed',
        code: response['error_code'] ?? 'HEARTBEAT_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _apiClient.get(ApiConfig.apiSyncStatus);

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Status check failed',
        code: response['error_code'] ?? 'STATUS_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    return response;
  }

  String _formatDateTime(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = two(dateTime.month);
    final day = two(dateTime.day);
    final hour = two(dateTime.hour);
    final minute = two(dateTime.minute);
    final second = two(dateTime.second);
    return '$year-$month-$day $hour:$minute:$second';
  }
}
