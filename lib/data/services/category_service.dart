import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/category_model.dart';

/// Category Service
class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all categories
  Future<List<CategoryModel>> getCategories({String? search}) async {
    final trimmedSearch = search?.trim();
    final response = await _apiClient.get(
      ApiConfig.categories,
      queryParameters: (trimmedSearch == null || trimmedSearch.isEmpty)
          ? null
          : {
              'search': trimmedSearch,
            },
    );

    // Check success first before parsing data
    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve categories',
        code: response['error_code'] ?? 'CATEGORIES_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    // Parse the data array directly
    final List<dynamic> dataList = response['data'] as List<dynamic>;
    return dataList.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get parent categories (categories without parent_id)
  Future<List<CategoryModel>> getParentCategories() async {
    final categories = await getCategories();
    return categories.where((category) => category.parentId == null).toList();
  }

  /// Get category by slug
  Future<CategoryModel?> getCategoryBySlug(String slug) async {
    final categories = await getCategories();
    
    // Search in parent categories
    for (final category in categories) {
      if (category.slug == slug) {
        return category;
      }
      // Search in children
      for (final child in category.children) {
        if (child.slug == slug) {
          return child;
        }
      }
    }
    
    return null;
  }
}
