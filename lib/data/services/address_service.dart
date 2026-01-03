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
    String? company,
    String? label,
    bool isDefault = false,
    bool isDefaultShipping = false,
    bool isDefaultBilling = false,
  }) async {
    try {
      // Generate full_name from first_name and last_name
      final fullName = '$firstName ${lastName.isNotEmpty ? lastName : ''}'.trim();
      
      final response = await _apiClient.post(
        '/api/v1/customer/addresses',
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': fullName,
          if (company != null && company.isNotEmpty) 'company': company,
          if (label != null && label.isNotEmpty) 'label': label,
          'address_line_1': addressLine1,
          if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          'postal_code': zipCode,
          if (country != null && country.isNotEmpty) 'country': country,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'is_default': isDefault,
          'is_default_shipping': isDefaultShipping,
          'is_default_billing': isDefaultBilling,
        },
      );

      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all addresses
  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await _apiClient.get('/api/v1/customer/addresses');

      if (response['success'] == true) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch addresses');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing address
  Future<Map<String, dynamic>> updateAddress({
    required int addressId,
    required String firstName,
    required String lastName,
    required String addressLine1,
    required String zipCode,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? phone,
    String? company,
    String? label,
    bool isDefault = false,
    bool isDefaultShipping = false,
    bool isDefaultBilling = false,
  }) async {
    try {
      // Generate full_name from first_name and last_name
      final fullName = '$firstName ${lastName.isNotEmpty ? lastName : ''}'.trim();
      
      final response = await _apiClient.put(
        '/api/v1/customer/addresses/$addressId',
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': fullName,
          if (company != null && company.isNotEmpty) 'company': company,
          if (label != null && label.isNotEmpty) 'label': label,
          'address_line_1': addressLine1,
          if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          'postal_code': zipCode,
          if (country != null && country.isNotEmpty) 'country': country,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'is_default': isDefault,
          'is_default_shipping': isDefaultShipping,
          'is_default_billing': isDefaultBilling,
        },
      );

      if (response['success'] == true) {
        return response['data'] ?? {};
      } else {
        throw Exception(response['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(int addressId) async {
    try {
      final response = await _apiClient.delete('/api/v1/customer/addresses/$addressId');

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      rethrow;
    }
  }
}
