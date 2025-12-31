import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/product_model.dart';

/// Product Service
class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get products list with pagination and filters
  Future<ProductsResponse> getProducts({
    int page = 1,
    int perPage = 20,
    String sort = 'created_at',
    String order = 'desc',
  }) async {
    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort': sort,
        'order': order,
      },
    );

    // Check success first before parsing data
    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse response
    return ProductsResponse.fromJson(response);
  }

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.productsFeatured,
      queryParameters: {
        'limit': limit.toString(),
      },
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve featured products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse the data array directly
    final List<dynamic> dataList = response['data'] as List<dynamic>;
    return dataList.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get new products
  Future<ProductsResponse> getNewProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'is_new': '1',
        'sort': 'created_at',
        'order': 'desc',
      },
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve new products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    return ProductsResponse.fromJson(response);
  }
}
