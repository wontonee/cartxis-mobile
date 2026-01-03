import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/address_service.dart';
import 'package:vortex_app/data/services/checkout_service.dart';
import 'package:vortex_app/presentation/screens/checkout/add_address_screen.dart';
import 'package:vortex_app/presentation/screens/checkout/shipping_screen.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;

  const CheckoutScreen({super.key, required this.checkoutData});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AddressService _addressService = AddressService();
  final CheckoutService _checkoutService = CheckoutService();
  List<dynamic> _addresses = [];
  int? _selectedShippingAddressId;
  int? _selectedBillingAddressId;
  bool _useShippingAddressForBilling = false;
  bool _isLoadingAddresses = true;
  bool _isSavingAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      setState(() => _isLoadingAddresses = true);
      final addresses = await _addressService.getAddresses();
      setState(() {
        _addresses = addresses;
        // Auto-select default shipping address
        final defaultAddress = addresses.firstWhere(
          (addr) => addr['is_default_shipping'] == true,
          orElse: () => null,
        );
        if (defaultAddress != null) {
          _selectedShippingAddressId = defaultAddress['id'];
        }
        _isLoadingAddresses = false;
      });
    } catch (e, stackTrace) {
      setState(() => _isLoadingAddresses = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch addresses: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectShippingAddress(int addressId) async {
    try {
      setState(() => _isSavingAddress = true);
      
      // Find the selected address from the list
      final selectedAddr = _addresses.firstWhere(
        (addr) => addr['id'] == addressId,
        orElse: () => throw Exception('Address not found'),
      );
      
      // Extract address details with field name mapping
      final firstName = selectedAddr['first_name']?.toString() ?? '';
      final lastName = selectedAddr['last_name']?.toString() ?? '';
      final phone = selectedAddr['phone']?.toString() ?? '';
      final addressLine1 = selectedAddr['address1']?.toString() ?? 
                          selectedAddr['address_line1']?.toString() ?? 
                          selectedAddr['address_line_1']?.toString() ?? '';
      final addressLine2 = selectedAddr['address2']?.toString() ?? 
                          selectedAddr['address_line2']?.toString() ?? 
                          selectedAddr['address_line_2']?.toString();
      final city = selectedAddr['city']?.toString() ?? '';
      final state = selectedAddr['state']?.toString() ?? '';
      final postalCode = selectedAddr['zip_code']?.toString() ?? 
                        selectedAddr['postal_code']?.toString() ?? '';
      final country = selectedAddr['country']?.toString() ?? 'IN';
      
      await _checkoutService.setShippingAddress(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );
      
      setState(() {
        _selectedShippingAddressId = addressId;
        _isSavingAddress = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shipping address saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSavingAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectBillingAddress(int addressId) async {
    await _setBillingAddress(addressId: addressId);
  }

  Future<void> _setBillingAddress({
    int? addressId,
    bool useShippingAddress = false,
  }) async {
    try {
      setState(() => _isSavingAddress = true);
      await _checkoutService.setBillingAddress(
        addressId: useShippingAddress ? _selectedShippingAddressId : addressId,
        useShippingAddress: useShippingAddress,
      );
      setState(() {
        if (!useShippingAddress) {
          _selectedBillingAddressId = addressId;
        }
        _isSavingAddress = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(useShippingAddress 
              ? 'Using shipping address for billing'
              : 'Billing address saved'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSavingAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set billing address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _proceedToShipping() async {
    if (_selectedShippingAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to shipping method selection screen
    if (mounted) {
      // Get selected address data
      final selectedAddress = _addresses.firstWhere(
        (addr) => addr['id'] == _selectedShippingAddressId,
        orElse: () => {},
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShippingScreen(
            selectedAddress: selectedAddress,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = widget.checkoutData['cart'] as Map<String, dynamic>? ?? {};
    final summary = cart['summary'] as Map<String, dynamic>? ?? {};
    final items = cart['items'] as List? ?? [];
    final itemsCount = summary['items_count'] ?? 0;
    final subtotal = (summary['subtotal'] as num?)?.toDouble() ?? 0.0;
    final discount = (summary['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (summary['total'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2633) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            _buildSection(
              isDark,
              'Order Summary',
              Column(
                children: [
                  _buildSummaryRow('Items', '$itemsCount', isDark, isItemCount: true),
                  _buildSummaryRow('Subtotal', subtotal, isDark),
                  if (discount > 0)
                    _buildSummaryRow('Discount', -discount, isDark, isDiscount: true),
                  const Divider(height: 24),
                  _buildSummaryRow('Total', total, isDark, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cart Items Section
            _buildSection(
              isDark,
              'Cart Items ($itemsCount)',
              Column(
                children: items.map<Widget>((item) {
                  final product = item['product'] as Map<String, dynamic>? ?? {};
                  final quantity = item['quantity'] ?? 0;
                  final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                  final itemSubtotal = (item['subtotal'] as num?)?.toDouble() ?? 0.0;
                  final productName = product['name'] ?? 'Unknown Product';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Qty: $quantity × ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  StyledPriceText(
                                    amount: price,
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        StyledPriceText(
                          amount: itemSubtotal,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Shipping Address Section
            _buildSection(
              isDark,
              'Shipping Address',
              _isLoadingAddresses
                  ? const Center(child: CircularProgressIndicator())
                  : _addresses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'No shipping address added',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AddAddressScreen(),
                                      ),
                                    );
                                    if (result != null && mounted) {
                                      _fetchAddresses();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Address'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            ..._addresses.map<Widget>((address) {
                              final isSelected = _selectedShippingAddressId == address['id'];
                              return GestureDetector(
                                onTap: _isSavingAddress ? null : () {
                                  _selectShippingAddress(address['id']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1A2633) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                        color: isSelected ? AppColors.primary : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  address['full_name'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.white : Colors.black87,
                                                  ),
                                                ),
                                                if (address['is_default_shipping'] == true) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text(
                                                      'Default',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address['formatted_address'] ?? 'N/A',
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (address['phone'] != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Phone: ${address['phone']}',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddAddressScreen(),
                                  ),
                                );
                                if (result != null && mounted) {
                                  _fetchAddresses();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add New Address'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 16),

            // Billing Address Section
            _buildSection(
              isDark,
              'Billing Address',
              _isLoadingAddresses
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        // Option to use shipping address
                        CheckboxListTile(
                          value: _useShippingAddressForBilling,
                          onChanged: (value) async {
                            if (value == true && _selectedShippingAddressId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select shipping address first'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            setState(() {
                              _useShippingAddressForBilling = value ?? false;
                              if (value == true) {
                                _selectedBillingAddressId = null;
                              }
                            });
                            
                            if (value == true) {
                              await _setBillingAddress(useShippingAddress: true);
                            }
                          },
                          title: const Text('Same as shipping address'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        
                        if (!_useShippingAddressForBilling) ...[
                          const SizedBox(height: 8),
                          if (_addresses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No billing address added',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._addresses.map<Widget>((address) {
                              final isSelected = _selectedBillingAddressId == address['id'];
                              return GestureDetector(
                                onTap: _isSavingAddress ? null : () {
                                  _selectBillingAddress(address['id']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1A2633) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                        color: isSelected ? AppColors.primary : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${address['first_name'] ?? ''} ${address['last_name'] ?? ''}'.trim(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address['address_line1'] ?? '',
                                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                            ),
                                            if (address['address_line2'] != null && address['address_line2'].toString().isNotEmpty)
                                              Text(
                                                address['address_line2'],
                                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                              ),
                                            Text(
                                              '${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['postal_code'] ?? ''}',
                                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                            ),
                                            if (address['phone'] != null)
                                              Text(
                                                'Phone: ${address['phone']}',
                                                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddAddressScreen(),
                                ),
                              );
                              if (result == true) {
                                _fetchAddresses();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Billing Address'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2633) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (_selectedShippingAddressId == null || 
                       (!_useShippingAddressForBilling && _selectedBillingAddressId == null))
              ? null 
              : () {
                  _proceedToShipping();
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2633) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value, bool isDark, {bool isBold = false, bool isDiscount = false, bool isItemCount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          if (isItemCount)
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
          else
            StyledPriceText(
              amount: value is double ? value : double.tryParse(value.toString()) ?? 0.0,
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.green : (isBold ? AppColors.primary : (isDark ? Colors.white : Colors.black87)),
            ),
        ],
      ),
    );
  }
}
