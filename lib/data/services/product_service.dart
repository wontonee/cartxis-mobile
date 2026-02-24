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
        // API expects sort_by/sort_order
        'sort_by': sort,
        'sort_order': order,
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
    int? categoryId,
  }) async {
    // Use the unified products listing endpoint so we can filter via query params.
    // Matches API docs: /api/v1/products?featured=true&category_ids=...
    final queryParams = <String, String>{
      'page': '1',
      'per_page': limit.toString(),
      'featured': 'true',
      'sort_by': 'created_at',
      'sort_order': 'desc',
    };

    if (categoryId != null) {
      // API supports category_ids (comma-separated). Use single id for Home filter.
      queryParams['category_ids'] = categoryId.toString();
    }

    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: queryParams,
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve featured products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    final parsed = ProductsResponse.fromJson(response);
    return parsed.data;
  }

  /// Get new arrivals
  Future<List<ProductModel>> getNewArrivals({
    int limit = 10,
    int? categoryId,
  }) async {
    // Prefer unified products listing endpoint so category filter works.
    // The backend uses `is_new=1` (see getNewProducts()).
    final queryParams = <String, String>{
      'page': '1',
      'per_page': limit.toString(),
      'is_new': '1',
      'sort_by': 'created_at',
      'sort_order': 'desc',
    };

    if (categoryId != null) {
      queryParams['category_ids'] = categoryId.toString();
    }

    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: queryParams,
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve new arrivals',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    final parsed = ProductsResponse.fromJson(response);
    // Fallback for older backends that only support /products/new-arrivals
    if (parsed.data.isEmpty) {
      final fallbackParams = <String, String>{
        'page': '1',
        'per_page': limit.toString(),
        'sort_by': 'created_at',
        'sort_order': 'desc',
      };

      if (categoryId != null) {
        // Some endpoints use category_id, some use category_ids; try category_ids first.
        fallbackParams['category_ids'] = categoryId.toString();
      }

      final fallbackResponse = await _apiClient.get(
        ApiConfig.productsNewArrivals,
        queryParameters: fallbackParams,
      );

      if (fallbackResponse['success'] == false) {
        throw ApiException(
          message: fallbackResponse['message'] ?? 'Failed to retrieve new arrivals',
          code: fallbackResponse['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
          errors: fallbackResponse['errors'] as Map<String, dynamic>?,
        );
      }

      return ProductsResponse.fromJson(fallbackResponse).data;
    }

    return parsed.data;
  }

  /// Get on-sale products (flash sale)
  Future<List<ProductModel>> getOnSaleProducts({
    int limit = 10,
    int? categoryId,
  }) async {
    // Prefer unified products listing endpoint so category filter works.
    final queryParams = <String, String>{
      'page': '1',
      'per_page': limit.toString(),
      // Most backends use on_sale=1/0.
      'on_sale': '1',
      'sort_by': 'created_at',
      'sort_order': 'desc',
    };

    if (categoryId != null) {
      queryParams['category_ids'] = categoryId.toString();
    }

    final response = await _apiClient.get(
      ApiConfig.products,
      queryParameters: queryParams,
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve sale products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    final parsed = ProductsResponse.fromJson(response);
    // Fallback for older backends that only support /products/on-sale
    if (parsed.data.isEmpty) {
      final fallbackParams = <String, String>{
        'page': '1',
        'per_page': limit.toString(),
        'sort_by': 'created_at',
        'sort_order': 'desc',
      };

      if (categoryId != null) {
        fallbackParams['category_ids'] = categoryId.toString();
      }

      final fallbackResponse = await _apiClient.get(
        ApiConfig.productsOnSale,
        queryParameters: fallbackParams,
      );

      if (fallbackResponse['success'] == false) {
        throw ApiException(
          message: fallbackResponse['message'] ?? 'Failed to retrieve sale products',
          code: fallbackResponse['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
          errors: fallbackResponse['errors'] as Map<String, dynamic>?,
        );
      }

      return ProductsResponse.fromJson(fallbackResponse).data;
    }

    return parsed.data;
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
        // API expects sort_by/sort_order
        'sort_by': 'created_at',
        'sort_order': 'desc',
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

  /// Get products by category
  Future<ProductsResponse> getCategoryProducts({
    required int categoryId,
    int page = 1,
    int perPage = 20,
    String sort = 'created_at',
    String order = 'desc',
  }) async {
    final response = await _apiClient.get(
      '/api/${ApiConfig.apiVersion}/categories/$categoryId/products',
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        // API expects sort_by/sort_order
        'sort_by': sort,
        'sort_order': order,
      },
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve category products',
        code: response['error_code'] ?? 'PRODUCTS_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    return ProductsResponse.fromJson(response);
  }
}
