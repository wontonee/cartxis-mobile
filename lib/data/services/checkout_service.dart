import 'package:vortex_app/core/network/api_client.dart';

class CheckoutService {
  final ApiClient _apiClient = ApiClient();

  /// Initialize checkout process
  Future<Map<String, dynamic>> initCheckout() async {
    try {
      print('🛒 Initializing checkout...');
      final response = await _apiClient.get('/api/v1/checkout/init');
      
      if (response['success'] == true) {
        print('✅ Checkout initialized successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to initialize checkout');
      }
    } catch (e) {
      print('❌ Checkout initialization error: $e');
      rethrow;
    }
  }

  /// Set shipping address
  Future<Map<String, dynamic>> setShippingAddress(int addressId) async {
    try {
      print('📍 Setting shipping address: $addressId');
      final response = await _apiClient.post(
        '/api/v1/checkout/shipping-address',
        body: {'address_id': addressId},
      );
      
      if (response['success'] == true) {
        print('✅ Shipping address set successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set shipping address');
      }
    } catch (e) {
      print('❌ Set shipping address error: $e');
      rethrow;
    }
  }

  /// Get available shipping methods
  Future<List<dynamic>> getShippingMethods() async {
    try {
      print('🚚 Fetching shipping methods...');
      final response = await _apiClient.get('/api/v1/checkout/shipping-methods');
      
      if (response['success'] == true) {
        print('✅ Shipping methods fetched successfully');
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch shipping methods');
      }
    } catch (e) {
      print('❌ Fetch shipping methods error: $e');
      rethrow;
    }
  }

  /// Set shipping method
  Future<Map<String, dynamic>> setShippingMethod(String shippingMethod) async {
    try {
      print('🚚 Setting shipping method: $shippingMethod');
      final response = await _apiClient.post(
        '/api/v1/checkout/shipping-method',
        body: {'shipping_method': shippingMethod},
      );
      
      if (response['success'] == true) {
        print('✅ Shipping method set successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set shipping method');
      }
    } catch (e) {
      print('❌ Set shipping method error: $e');
      rethrow;
    }
  }

  /// Get available payment methods
  Future<List<dynamic>> getPaymentMethods() async {
    try {
      print('💳 Fetching payment methods...');
      final response = await _apiClient.get('/api/v1/checkout/payment-methods');
      
      if (response['success'] == true) {
        print('✅ Payment methods fetched successfully');
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payment methods');
      }
    } catch (e) {
      print('❌ Fetch payment methods error: $e');
      rethrow;
    }
  }

  /// Set payment method
  Future<Map<String, dynamic>> setPaymentMethod(String paymentMethod) async {
    try {
      print('💳 Setting payment method: $paymentMethod');
      final response = await _apiClient.post(
        '/api/v1/checkout/payment-method',
        body: {'payment_method': paymentMethod},
      );
      
      if (response['success'] == true) {
        print('✅ Payment method set successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set payment method');
      }
    } catch (e) {
      print('❌ Set payment method error: $e');
      rethrow;
    }
  }

  /// Get checkout summary
  Future<Map<String, dynamic>> getCheckoutSummary() async {
    try {
      print('📋 Fetching checkout summary...');
      final response = await _apiClient.get('/api/v1/checkout/summary');
      
      if (response['success'] == true) {
        print('✅ Checkout summary fetched successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch checkout summary');
      }
    } catch (e) {
      print('❌ Fetch checkout summary error: $e');
      rethrow;
    }
  }

  /// Place order
  Future<Map<String, dynamic>> placeOrder() async {
    try {
      print('🛍️ Placing order...');
      final response = await _apiClient.post('/api/v1/checkout/place-order');
      
      if (response['success'] == true) {
        print('✅ Order placed successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      print('❌ Place order error: $e');
      rethrow;
    }
  }
}
