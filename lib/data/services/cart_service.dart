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
      print('🛒 ===== ADD TO CART REQUEST =====');
      print('🛒 Product ID: $productId');
      print('🛒 Quantity: $quantity');
      print('🛒 Payload: {"product_id": $productId, "quantity": $quantity}');
      
      final response = await _apiClient.post(
        '/api/v1/cart/add',
        body: {
          'product_id': productId,
          'quantity': quantity,
        },
      );

      print('✅ Add to cart API response: $response');
      print('✅ Response data: ${response['data']}');
      print('🛒 ================================');
      return response['success'] == true;
    } catch (e) {
      print('❌ Add to cart error: $e');
      rethrow;
    }
  }

  /// Get cart items
  Future<CartModel> getCart() async {
    try {
      print('🛒 Fetching cart...');
      final response = await _apiClient.get('/api/v1/cart');
      
      print('🛒 Cart API response: $response');
      
      if (response['success'] == true && response['data'] != null) {
        print('✅ Cart retrieved: ${response['data']['items'].length} items');
        return CartModel.fromJson(response['data']);
      } else {
        throw ApiException(
          message: response['message'] ?? 'Failed to get cart',
          code: 'CART_FETCH_FAILED',
        );
      }
    } catch (e) {
      print('❌ Get cart error: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<bool> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      print('🔄 Updating cart item $cartItemId to quantity $quantity');
      final response = await _apiClient.put(
        '/api/v1/cart/items/$cartItemId',
        body: {'quantity': quantity},
      );
      print('✅ Cart item updated successfully');
      return response['success'] == true;
    } catch (e) {
      print('❌ Update cart error: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int cartItemId) async {
    try {
      final response = await _apiClient.delete('/api/v1/cart/items/$cartItemId');
      return response['success'] == true;
    } catch (e) {
      print('❌ Remove from cart error: $e');
      rethrow;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    try {
      final response = await _apiClient.delete('/api/v1/cart/clear');
      return response['success'] == true;
    } catch (e) {
      print('❌ Clear cart error: $e');
      rethrow;
    }
  }

  /// Get cart items count
  Future<int> getCartCount() async {
    try {
      print('🛒 Fetching cart count...');
      final response = await _apiClient.get('/api/v1/cart/count');
      
      if (response['success'] == true && response['data'] != null) {
        final count = response['data']['count'] ?? 0;
        print('✅ Cart count: $count');
        return count;
      }
      return 0;
    } catch (e) {
      print('❌ Get cart count error: $e');
      return 0;
    }
  }
}
