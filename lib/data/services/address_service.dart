import 'package:vortex_app/core/network/api_client.dart';

class AddressService {
  final ApiClient _apiClient = ApiClient();

  /// Add a new address
  Future<Map<String, dynamic>> addAddress({
    required String firstName,
    required String lastName,
    required String addressLine1,
    required String zipCode,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? phone,
    bool isDefault = false,
  }) async {
    try {
      print('📍 Adding new address...');
      print('📍 Address1: $addressLine1');
      print('📍 Zip: $zipCode, City: $city, State: $state, Country: $country');
      
      final response = await _apiClient.post(
        '/api/v1/customer/addresses',
        body: {
          'address_line_1': addressLine1,
          if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          'postal_code': zipCode,
          if (country != null && country.isNotEmpty) 'country': country,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'is_default': isDefault,
        },
      );
      
      print('📍 Response received: ${response['success']}');

      if (response['success'] == true) {
        print('✅ Address added successfully');
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      print('❌ Add address error: $e');
      rethrow;
    }
  }

  /// Get all addresses
  Future<List<dynamic>> getAddresses() async {
    try {
      print('📍 Fetching addresses...');
      final response = await _apiClient.get('/api/v1/customer/addresses');

      if (response['success'] == true) {
        print('✅ Addresses fetched successfully');
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch addresses');
      }
    } catch (e) {
      print('❌ Fetch addresses error: $e');
      rethrow;
    }
  }
}
