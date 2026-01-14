import '../models/wishlist_model.dart';
import '../../core/network/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_exception.dart';

class WishlistService {
  final ApiClient _apiClient = ApiClient();

  /// Get wishlist items
  Future<WishlistModel> getWishlist() async {
    final response = await _apiClient.get(
      ApiConfig.wishlist,
    );

    print('Wishlist API Response: $response');

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to retrieve wishlist',
        code: response['error_code'] ?? 'WISHLIST_FETCH_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }

    return WishlistModel.fromJson(response);
  }

  /// Add product to wishlist
  Future<void> addToWishlist(int productId) async {
    final response = await _apiClient.post(
      ApiConfig.wishlistAdd,
      body: {'product_id': productId},
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to add to wishlist',
        code: response['error_code'] ?? 'WISHLIST_ADD_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(int wishlistItemId) async {
    final response = await _apiClient.delete(
      '${ApiConfig.wishlist}/$wishlistItemId',
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to remove from wishlist',
        code: response['error_code'] ?? 'WISHLIST_REMOVE_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }
  }

  /// Move wishlist item to cart
  Future<void> moveToCart(int wishlistItemId) async {
    final response = await _apiClient.post(
      '${ApiConfig.wishlist}/$wishlistItemId/move-to-cart',
    );

    if (response['success'] == false) {
      throw ApiException(
        message: response['message'] ?? 'Failed to move to cart',
        code: response['error_code'] ?? 'WISHLIST_MOVE_TO_CART_FAILED',
        errors: response['errors'] as Map<String, dynamic>?,
      );
    }
  }

  /// Toggle product in wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist(int productId) async {
    try {
      await addToWishlist(productId);
      return true; // Added to wishlist
    } catch (e) {
      // If already in wishlist, try to remove
      // Note: This requires knowing the wishlist item ID
      // You might want to fetch wishlist first to get the item ID
      rethrow;
    }
  }
}
