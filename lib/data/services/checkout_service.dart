import 'package:vortex_app/core/network/api_client.dart';

class CheckoutService {
  final ApiClient _apiClient = ApiClient();

  /// Initialize checkout process
  Future<Map<String, dynamic>> initCheckout() async {
    try {
      final response = await _apiClient.get('/api/v1/checkout/init');
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to initialize checkout');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set shipping address
  Future<Map<String, dynamic>> setShippingAddress({
    required String firstName,
    required String lastName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/checkout/shipping-address',
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'address_line_1': addressLine1,
          if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
        },
      );
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set shipping address');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set billing address
  Future<Map<String, dynamic>> setBillingAddress({
    int? addressId,
    bool useShippingAddress = false,
  }) async {
    try {
      
      final response = await _apiClient.post(
        '/api/v1/checkout/billing-address',
        body: {
          if (addressId != null) 'address_id': addressId,
          'use_shipping_address': useShippingAddress,
        },
      );
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set billing address');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get available shipping methods
  Future<List<dynamic>> getShippingMethods() async {
    try {
      final response = await _apiClient.get('/api/v1/checkout/shipping-methods');
      
      
      if (response['success'] == true) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch shipping methods');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set shipping method
  Future<Map<String, dynamic>> setShippingMethod(String shippingMethod) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/checkout/shipping-method',
        body: {'shipping_method_code': shippingMethod},
      );
      
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        final errorMsg = response['message'] ?? 'Failed to set shipping method';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get available payment methods
  Future<List<dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('/api/v1/checkout/payment-methods');
      
      if (response['success'] == true) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch payment methods');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set payment method
  Future<Map<String, dynamic>> setPaymentMethod(String paymentMethod) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/checkout/payment-method',
        body: {'payment_method_code': paymentMethod},
      );
      
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to set payment method');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get checkout summary
  Future<Map<String, dynamic>> getCheckoutSummary() async {
    try {
      final response = await _apiClient.get('/api/v1/checkout/summary');
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch checkout summary');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Place order
  Future<Map<String, dynamic>> placeOrder({
    required int shippingAddressId,
    required String paymentMethod,
    String? notes,
    String? paymentId,
    String? orderId,
    String? signature,
  }) async {
    try {
      
      final response = await _apiClient.post(
        '/api/v1/checkout/place-order',
        body: {
          'shipping_address_id': shippingAddressId,
          'payment_method': paymentMethod,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (paymentId != null) 'payment_id': paymentId,
          if (orderId != null) 'order_id': orderId,
          if (signature != null) 'signature': signature,
        },
      );
      
      
      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        // Log validation errors if present
        if (response['errors'] != null) {
        }
        final errorMsg = response['message'] ?? 'Failed to place order';
        final errorCode = response['error_code'] ?? 'UNKNOWN_ERROR';
        throw Exception('$errorMsg (Code: $errorCode)');
      }
    } catch (e) {
      rethrow;
    }
  }
}
