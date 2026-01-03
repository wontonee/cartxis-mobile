import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/core/network/api_exception.dart';
import 'package:vortex_app/data/services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;
  
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCountry;
  String? _selectedLabel;
  bool _isDefault = false;
  bool _isDefaultShipping = false;
  bool _isDefaultBilling = false;
  bool _isLoading = false;
  final AddressService _addressService = AddressService();

  // Address label options
  final List<String> _addressLabels = [
    'Home',
    'Office',
    'Work',
    'Other',
  ];

  // Common countries with their codes
  final Map<String, String> _countries = {
    'United States': 'US',
    'United Kingdom': 'GB',
    'Canada': 'CA',
    'Australia': 'AU',
    'India': 'IN',
    'Germany': 'DE',
    'France': 'FR',
    'Italy': 'IT',
    'Spain': 'ES',
    'Japan': 'JP',
    'China': 'CN',
    'Brazil': 'BR',
    'Mexico': 'MX',
    'Netherlands': 'NL',
    'Sweden': 'SE',
    'Norway': 'NO',
    'Denmark': 'DK',
    'Singapore': 'SG',
    'United Arab Emirates': 'AE',
    'Saudi Arabia': 'SA',
  };

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    if (widget.address != null) {
      final addr = widget.address!;
      _firstNameController.text = addr['first_name'] ?? '';
      _lastNameController.text = addr['last_name'] ?? '';
      _address1Controller.text = addr['address1'] ?? addr['address_line_1'] ?? '';
      _address2Controller.text = addr['address2'] ?? addr['address_line_2'] ?? '';
      _cityController.text = addr['city'] ?? '';
      _stateController.text = addr['state'] ?? '';
      _zipCodeController.text = addr['zip_code'] ?? addr['postal_code'] ?? '';
      _phoneController.text = addr['phone'] ?? '';
      _selectedCountry = addr['country'];
      _selectedLabel = addr['label'];
      _isDefault = addr['is_default'] == true;
      _isDefaultShipping = addr['is_default_shipping'] == true;
      _isDefaultBilling = addr['is_default_billing'] == true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> address;
      
      if (widget.address != null) {
        // Update existing address
        address = await _addressService.updateAddress(
          addressId: widget.address!['id'] as int,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          addressLine1: _address1Controller.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
          country: _selectedCountry,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          label: _selectedLabel,
          isDefault: _isDefault,
          isDefaultShipping: _isDefaultShipping,
          isDefaultBilling: _isDefaultBilling,
        );
      } else {
        // Add new address
        address = await _addressService.addAddress(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          addressLine1: _address1Controller.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
          country: _selectedCountry,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          label: _selectedLabel,
          isDefault: _isDefault,
          isDefaultShipping: _isDefaultShipping,
          isDefaultBilling: _isDefaultBilling,
        );
      }

      if (mounted) {
        Navigator.pop(context, address);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.address != null ? 'Address updated successfully' : 'Address added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        
        // Handle validation errors
        if (e.errors != null && e.errors!.isNotEmpty) {
          final errorsList = <String>[];
          e.errors!.forEach((key, value) {
            if (value is List) {
              errorsList.addAll(value.map((e) => e.toString()));
            } else {
              errorsList.add(value.toString());
            }
          });
          errorMessage = errorsList.join('\n');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2633) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address != null ? 'Edit Address' : 'Add Address',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // First Name
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter first name',
              icon: Icons.person_outline,
              isDark: isDark,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Last Name
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter last name',
              icon: Icons.person_outline,
              isDark: isDark,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Address Line 1
            _buildTextField(
              controller: _address1Controller,
              label: 'Address Line 1',
              hint: 'Street address, P.O. box',
              icon: Icons.home_outlined,
              isDark: isDark,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Address Line 2
            _buildTextField(
              controller: _address2Controller,
              label: 'Address Line 2',
              hint: 'Apartment, suite, unit, building (optional)',
              icon: Icons.home_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // City
            _buildTextField(
              controller: _cityController,
              label: 'City',
              hint: 'Enter city',
              icon: Icons.location_city_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // State and Zip Code
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'State/Province',
                    icon: Icons.map_outlined,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _zipCodeController,
                    label: 'Zip Code',
                    hint: 'Postal code',
                    icon: Icons.markunread_mailbox_outlined,
                    isDark: isDark,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Country Dropdown
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2633) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  hintText: 'Select country',
                  prefixIcon: Icon(
                    Icons.public_outlined,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                dropdownColor: isDark ? const Color(0xFF1A2633) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                items: _countries.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text('${entry.key} (${entry.value})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Address Label Dropdown
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2633) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedLabel,
                decoration: InputDecoration(
                  labelText: 'Address Label',
                  hintText: 'Select label (Home, Office, etc.)',
                  prefixIcon: Icon(
                    Icons.label_outline,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                dropdownColor: isDark ? const Color(0xFF1A2633) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                items: _addressLabels.map((label) {
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLabel = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Default Address Options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2633) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  // Set as default
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set as default address',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() => _isDefault = value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Set as default shipping
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set as default shipping address',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isDefaultShipping,
                        onChanged: (value) {
                          setState(() => _isDefaultShipping = value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Set as default billing
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set as default billing address',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isDefaultBilling,
                        onChanged: (value) {
                          setState(() => _isDefaultBilling = value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.address != null ? 'Update Address' : 'Save Address',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hint,
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2633) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
