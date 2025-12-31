import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'label': 'Home',
      'isDefault': true,
      'icon': Icons.home,
      'name': 'Jane Doe',
      'address': '1234 Market Street, Apt 4B\nSan Francisco, CA 94103\nUnited States',
      'phone': '+1 (555) 012-3456',
    },
    {
      'id': '2',
      'label': 'Office',
      'isDefault': false,
      'icon': Icons.work,
      'name': 'Jane Doe',
      'address': '800 Tech Plaza, Suite 200\nSan Jose, CA 95110\nUnited States',
      'phone': '+1 (555) 987-6543',
    },
    {
      'id': '3',
      'label': 'Parents\' House',
      'isDefault': false,
      'icon': Icons.location_on,
      'name': 'John Doe Sr.',
      'address': '45 Maple Avenue\nPortland, OR 97205\nUnited States',
      'phone': '+1 (503) 555-0199',
    },
  ];

  void _deleteAddress(String id) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _addresses.removeWhere((address) => address['id'] == id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address deleted')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editAddress(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit address coming soon')),
    );
  }

  void _addNewAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new address coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF101922).withOpacity(0.95)
                    : const Color(0xFFF6F7F8).withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Address Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'SAVED ADDRESSES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Address Cards
                    ..._addresses.map((address) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildAddressCard(address, isDark),
                      );
                    }),

                    const SizedBox(height: 80), // Space for sticky button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Footer Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: _addNewAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, bool isDark) {
    final isDefault = address['isDefault'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault
              ? AppColors.primary.withOpacity(0.2)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? AppColors.primary.withOpacity(0.1)
                        : (isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFF3F4F6)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    address['icon'] as IconData,
                    color: isDefault
                        ? AppColors.primary
                        : (isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280)),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Address Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label and Default Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address['label'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0D141B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Address Details
                      Text(
                        '${address['name']}\n${address['address']}',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Phone Number
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            address['phone'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              color: isDark
                  ? const Color(0xFF1F2937).withOpacity(0.5)
                  : const Color(0xFFF9FAFB),
            ),
            child: Row(
              children: [
                // Edit Button
                Expanded(
                  child: InkWell(
                    onTap: () => _editAddress(address['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: isDefault
                                ? AppColors.primary
                                : (isDark
                                    ? const Color(0xFFD1D5DB)
                                    : const Color(0xFF4B5563)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDefault
                                  ? AppColors.primary
                                  : (isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF4B5563)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Delete Button
                Expanded(
                  child: InkWell(
                    onTap: isDefault
                        ? null
                        : () => _deleteAddress(address['id'] as String),
                    child: Opacity(
                      opacity: isDefault ? 0.5 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: isDefault
                                  ? Colors.red.withOpacity(0.5)
                                  : (isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF4B5563)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDefault
                                    ? Colors.red.withOpacity(0.5)
                                    : (isDark
                                        ? const Color(0xFFD1D5DB)
                                        : const Color(0xFF4B5563)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
