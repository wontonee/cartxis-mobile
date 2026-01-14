import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/config/api_config.dart';
import '../models/banner_model.dart';

class BannerService {
  final ApiClient _apiClient;

  BannerService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch banners for mobile home hero placement.
  ///
  /// Backend examples (per CMS docs):
  /// - GET /api/v1/banners?mobile=true&placement=home-hero&limit=2
  /// - GET /api/v1/banners?identifiers=a,b
  Future<List<BannerModel>> getHomeHeroBanners({int limit = 2}) async {
    // The backend API supports filtering via `identifier` / `identifiers` (as per Postman docs).
    // We fetch the two known identifiers used in the Home hero slot.
    return getBanners(
      identifiers: const [
        'mobile-home-hero-summer-sale',
        'mobile-home-hero-fashion-week',
      ],
      limit: limit,
    );
  }

  Future<List<BannerModel>> getBanners({
    int? limit,
    List<String>? identifiers,
    int? channelId,
  }) async {
    final queryParams = <String, String>{};

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (identifiers != null && identifiers.isNotEmpty) {
      queryParams['identifiers'] = identifiers.join(',');
    }
    if (channelId != null) {
      queryParams['channel_id'] = channelId.toString();
    }

    final response = await _apiClient.get(
      ApiConfig.banners,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve banners',
        code: response['error_code'] ?? 'BANNERS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    final dynamic data = response['data'];

    final List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final dynamic inner = data['data'] ?? data['items'] ?? data['banners'] ?? data['results'];
      if (inner is List) {
        items = inner;
      } else {
        items = const [];
      }
    } else {
      items = const [];
    }

    final banners = <BannerModel>[];
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final banner = BannerModel.fromJson(item);
        // Keep items even if fields are missing, but prefer those with images.
        banners.add(banner);
      }
    }

    // Prefer banners with image URLs first.
    banners.sort((a, b) {
      final aHas = a.imageUrl.trim().isNotEmpty;
      final bHas = b.imageUrl.trim().isNotEmpty;
      if (aHas == bHas) return 0;
      return bHas ? 1 : -1;
    });

    return banners;
  }
}
