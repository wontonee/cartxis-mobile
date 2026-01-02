import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isGridView = true;

  // Mock wishlist data
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'name': 'Nike Air Max 270',
      'price': 150.00,
      'originalPrice': 187.50,
      'discount': '-20%',
      'image': 'https://via.placeholder.com/300x300/FF5733/FFFFFF?text=Nike+Air+Max',
      'stockStatus': 'In Stock',
      'isAvailable': true,
    },
    {
      'id': '2',
      'name': 'Nike Air Jordan 1 Green',
      'price': 180.00,
      'originalPrice': null,
      'discount': null,
      'image': 'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Air+Jordan+1',
      'stockStatus': 'Low Stock',
      'isAvailable': true,
    },
    {
      'id': '3',
      'name': 'Puma RS-X Reinvention',
      'price': 110.00,
      'originalPrice': null,
      'discount': null,
      'image': 'https://via.placeholder.com/300x300/9C27B0/FFFFFF?text=Puma+RS-X',
      'stockStatus': 'In Stock',
      'isAvailable': true,
    },
    {
      'id': '4',
      'name': 'Adidas Ultraboost DNA',
      'price': 190.00,
      'originalPrice': null,
      'discount': null,
      'image': 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Ultraboost',
      'stockStatus': 'Out of Stock',
      'isAvailable': false,
    },
    {
      'id': '5',
      'name': 'New Balance 574 Core',
      'price': 85.00,
      'originalPrice': null,
      'discount': null,
      'image': 'https://via.placeholder.com/300x300/FF9800/FFFFFF?text=New+Balance',
      'stockStatus': 'In Stock',
      'isAvailable': true,
    },
    {
      'id': '6',
      'name': 'Nike Kyrie 7',
      'price': 130.00,
      'originalPrice': null,
      'discount': null,
      'image': 'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Nike+Kyrie+7',
      'stockStatus': 'In Stock',
      'isAvailable': true,
    },
  ];

  void _removeFromWishlist(String id) {
    setState(() {
      _wishlistItems.removeWhere((item) => item['id'] == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from wishlist'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart - using the indexed stack, switch to cart tab (index 2)
            // This would need to be handled by a state management solution in production
          },
        ),
      ),
    );
  }

  void _moveAllToCart() {
    final availableItems = _wishlistItems.where((item) => item['isAvailable'] as bool).toList();
    
    if (availableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available items to add'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Cart'),
        content: Text('Move ${availableItems.length} items to cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${availableItems.length} items added to cart'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('MOVE'),
          ),
        ],
      ),
    );
  }

  void _notifyWhenAvailable(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You\'ll be notified when ${item['name']} is back in stock'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.amber.shade700,
      ),
    );
  }

  Color _getStockColor(String status, bool isDark) {
    switch (status) {
      case 'In Stock':
        return isDark ? Colors.green.shade400 : Colors.green.shade600;
      case 'Low Stock':
        return isDark ? Colors.amber.shade500 : Colors.amber.shade600;
      case 'Out of Stock':
        return Colors.red.shade500;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.8) : Colors.white.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My Wishlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Show filter options
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filter options coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark 
                            ? const Color(0xFF1E293B) 
                            : const Color(0xFFF1F5F9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // View Toggle & Count
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_wishlistItems.length} Items',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                // Segmented Control
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildViewButton(
                        icon: Icons.grid_view,
                        isSelected: _isGridView,
                        onTap: () => setState(() => _isGridView = true),
                        isDark: isDark,
                      ),
                      _buildViewButton(
                        icon: Icons.view_list,
                        isSelected: !_isGridView,
                        onTap: () => setState(() => _isGridView = false),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: Stack(
              children: [
                _wishlistItems.isEmpty
                    ? _buildEmptyState(isDark)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isGridView ? 2 : 1,
                          childAspectRatio: _isGridView ? 0.58 : 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _wishlistItems.length,
                        itemBuilder: (context, index) {
                          final item = _wishlistItems[index];
                          return _buildProductCard(item, isDark);
                        },
                      ),

                // Floating Action Button - Move All to Cart
                if (_wishlistItems.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8)).withOpacity(0),
                            isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
                            isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: _moveAllToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Move All to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, bool isDark) {
    final isAvailable = item['isAvailable'] as bool;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      item['image'] as String,
                      fit: BoxFit.cover,
                      opacity: isAvailable ? null : const AlwaysStoppedAnimation(0.6),
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Remove Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => _removeFromWishlist(item['id'] as String),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),

                // Discount Badge
                if (item['discount'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['discount'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Sold Out Overlay
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Sold Out',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
                  item['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 3),

                // Price
                Row(
                  children: [
                    if (item['originalPrice'] != null) ...[
                      DiscountedPriceText(
                        originalPrice: (item['originalPrice'] as num?)?.toDouble() ?? 0.0,
                        discountedPrice: (item['price'] as num?)?.toDouble() ?? 0.0,
                        fontSize: 15,
                        discountedPriceColor: isAvailable
                            ? AppColors.primary
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                    ] else ...[
                      StyledPriceText(
                        amount: (item['price'] as num?)?.toDouble() ?? 0.0,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? AppColors.primary
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),

                // Stock Status
                Text(
                  item['stockStatus'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getStockColor(item['stockStatus'] as String, isDark),
                  ),
                ),
                const SizedBox(height: 6),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: isAvailable
                        ? ElevatedButton(
                            onPressed: () => _addToCart(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () => _notifyWhenAvailable(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark 
                                  ? const Color(0xFF334155) 
                                  : const Color(0xFFF1F5F9),
                              foregroundColor: isDark 
                                  ? Colors.grey.shade500 
                                  : Colors.grey.shade400,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_outlined, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Notify',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding items you love!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Stay on this tab, user can use bottom nav to go elsewhere
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }
}
