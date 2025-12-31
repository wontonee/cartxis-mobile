import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/address_service.dart';
import 'package:vortex_app/data/services/checkout_service.dart';
import 'package:vortex_app/presentation/screens/checkout/add_address_screen.dart';
import 'package:vortex_app/presentation/screens/checkout/shipping_screen.dart';

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
  bool _isLoadingAddresses = true;
  bool _isSavingAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      print('🔄 Fetching addresses...');
      setState(() => _isLoadingAddresses = true);
      final addresses = await _addressService.getAddresses();
      print('✅ Addresses fetched: ${addresses.length} addresses');
      print('📦 Addresses data: $addresses');
      setState(() {
        _addresses = addresses;
        // Auto-select default shipping address
        final defaultAddress = addresses.firstWhere(
          (addr) => addr['is_default_shipping'] == true,
          orElse: () => null,
        );
        if (defaultAddress != null) {
          _selectedShippingAddressId = defaultAddress['id'];
          print('✅ Default address selected: ${defaultAddress['id']}');
        }
        _isLoadingAddresses = false;
      });
      print('✅ State updated, loading = false');
    } catch (e, stackTrace) {
      print('❌ Fetch addresses error: $e');
      print('❌ Stack trace: $stackTrace');
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
      await _checkoutService.setShippingAddress(addressId);
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ShippingScreen(),
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
    final subtotal = summary['subtotal'] ?? 0.0;
    final discount = summary['discount'] ?? 0.0;
    final total = summary['total'] ?? 0.0;
    final currency = summary['currency'] ?? 'USD';
    final addresses = widget.checkoutData['addresses'] as List? ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2633) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  _buildSummaryRow('Items', '$itemsCount', isDark),
                  _buildSummaryRow('Subtotal', '\$$subtotal', isDark),
                  if (discount > 0)
                    _buildSummaryRow('Discount', '-\$$discount', isDark, isDiscount: true),
                  const Divider(height: 24),
                  _buildSummaryRow('Total', '\$$total', isDark, isBold: true),
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
                  final price = item['price'] ?? 0.0;
                  final itemSubtotal = item['subtotal'] ?? 0.0;
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
                              Text(
                                'Qty: $quantity × \$$price',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$$itemSubtotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No billing address added',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to add billing address screen
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Billing Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
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
            onPressed: _selectedShippingAddressId == null 
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

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isBold = false, bool isDiscount = false}) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.green : (isBold ? AppColors.primary : (isDark ? Colors.white : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}
