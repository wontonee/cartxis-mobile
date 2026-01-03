import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/cart_model.dart';

/// Cart Service for managing shopping cart operations
class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Add product to cart
  /// 
  /// Parameters:
  /// - [productId]: ID of the product to add
  /// - [quantity]: Quantity of the product (default: 1)
  /// 
  /// Returns true if successful, throws ApiException on error
  Future<bool> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      
      final response = await _apiClient.post(
        '/api/v1/cart/add',
        body: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get cart items
  Future<CartModel> getCart() async {
    try {
      final response = await _apiClient.get('/api/v1/cart');
      
      
      if (response['success'] == true && response['data'] != null) {
        return CartModel.fromJson(response['data']);
      } else {
        throw ApiException(
          message: response['message'] ?? 'Failed to get cart',
          code: 'CART_FETCH_FAILED',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/cart/items/$cartItemId',
        body: {'quantity': quantity},
      );
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int cartItemId) async {
    try {
      final response = await _apiClient.delete('/api/v1/cart/items/$cartItemId');
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    try {
      final response = await _apiClient.delete('/api/v1/cart/clear');
      return response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get cart items count
  Future<int> getCartCount() async {
    try {
      final response = await _apiClient.get('/api/v1/cart/count');
      
      if (response['success'] == true && response['data'] != null) {
        final count = response['data']['count'] ?? 0;
        return count;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
