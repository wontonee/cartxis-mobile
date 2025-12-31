import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/product_model.dart';

/// Search Service for product search functionality
class SearchService {
  final ApiClient _apiClient;

  SearchService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Search products with filters
  /// 
  /// Parameters:
  /// - [query]: Search query string (required)
  /// - [categoryId]: Filter by category ID (optional)
  /// - [minPrice]: Minimum price filter (optional)
  /// - [maxPrice]: Maximum price filter (optional)
  Future<List<ProductModel>> searchProducts({
    required String query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'q': query,
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      print('🔍 Search params: $queryParams');

      final response = await _apiClient.get(
        '/api/v1/search',
        queryParameters: queryParams,
      );

      print('📦 Raw response type: ${response.runtimeType}');
      print('📦 Search response success: ${response['success']}');
      print('📦 Search response message: ${response['message']}');
      print('📦 Search response data type: ${response['data']?.runtimeType}');

      // Check success first before parsing data
      if (response['success'] == false) {
        throw ApiException(
          message: response['message'] ?? 'Search failed',
          code: response['error_code'] ?? 'SEARCH_FAILED',
          errors: response['errors'] as Map<String, dynamic>?,
        );
      }

      // Parse the data array
      if (response['data'] == null) {
        print('⚠️ No data in response');
        return [];
      }

      final List<dynamic> dataList = response['data'] as List<dynamic>;
      print('✅ Parsing ${dataList.length} products');
      
      return dataList.map((json) {
        try {
          return ProductModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Error parsing product: $e');
          print('Product JSON: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('❌ Search service error: $e');
      rethrow;
    }
  }

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    // This could be a separate endpoint or derived from search results
    // For now, we'll return an empty list
    // TODO: Implement when suggestions endpoint is available
    return [];
  }
}
