import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';
import 'package:vortex_app/data/services/wishlist_service.dart';
import 'package:vortex_app/data/services/cart_service.dart';
import 'package:vortex_app/data/models/wishlist_model.dart';
import 'package:vortex_app/presentation/widgets/skeleton_loader.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();

  bool _isGridView = true;
  bool _isLoading = true;
  List<WishlistItemModel> _wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  String? _errorMessage;

  Future<void> _loadWishlist() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final wishlist = await _wishlistService.getWishlist();

      if (mounted) {
        setState(() {
          _wishlistItems = wishlist.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _removeFromWishlist(
      int wishlistItemId, String productName) async {
    try {
      await _wishlistService.removeFromWishlist(wishlistItemId);

      if (mounted) {
        setState(() {
          _wishlistItems.removeWhere((item) => item.id == wishlistItemId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName removed from wishlist'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(WishlistItemModel item) async {
    try {
      // Use the move-to-cart API endpoint
      await _wishlistService.moveToCart(item.id);

      if (mounted) {
        setState(() {
          _wishlistItems.removeWhere((i) => i.id == item.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} moved to cart'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _moveAllToCart() async {
    final availableItems =
        _wishlistItems.where((item) => item.product.inStock).toList();

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
            onPressed: () async {
              Navigator.pop(context);

              // Add all items to cart
              for (final item in availableItems) {
                try {
                  await _cartService.addToCart(
                    productId: item.product.id,
                    quantity: 1,
                  );
                } catch (e) {
                  // Continue with other items if one fails
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${availableItems.length} items added to cart'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
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

  Color _getStockColor(String status, bool isDark) {
    switch (status) {
      case 'in_stock':
        return isDark ? Colors.green.shade400 : Colors.green.shade600;
      case 'low_stock':
        return isDark ? Colors.amber.shade500 : Colors.amber.shade600;
      case 'out_of_stock':
        return Colors.red.shade500;
      default:
        return Colors.grey;
    }
  }

  String _getStockText(String status) {
    switch (status) {
      case 'in_stock':
        return 'In Stock';
      case 'low_stock':
        return 'Low Stock';
      case 'out_of_stock':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF182430) : Colors.white,
        elevation: 0,
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Product Grid
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _isGridView ? 2 : 1,
                      childAspectRatio: _isGridView ? 0.58 : 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) =>
                        const ProductCardSkeleton(),
                  )
                else if (_errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadWishlist,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_wishlistItems.isEmpty)
                  _buildEmptyState(isDark)
                else
                  RefreshIndicator(
                    onRefresh: _loadWishlist,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _isGridView ? 2 : 1,
                        // Give list view items more height so text/CTA fit comfortably
                        mainAxisExtent: _isGridView ? 300 : 220,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _wishlistItems.length,
                      itemBuilder: (context, index) {
                        final item = _wishlistItems[index];
                        return _buildProductCard(item, isDark);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(WishlistItemModel item, bool isDark) {
    final product = item.product;
    final isAvailable = product.inStock;
    final hasDiscount = product.discountPercentage > 0;

    // Get first image
    String imageUrl = '';
    if (product.images.isNotEmpty) {
      final firstImage = product.images[0];
      if (firstImage is String) {
        imageUrl = firstImage;
      } else if (firstImage is Map<String, dynamic>) {
        imageUrl = firstImage['path']?.toString() ?? '';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {
            'product': {
              'id': product.id,
              'sku': product.sku,
              'name': product.name,
              'description': product.description ?? product.shortDescription,
              'price': product.finalPrice,
              'discountPrice': product.specialPrice,
              'stock': product.quantity,
              'stockStatus': product.stockStatus,
              'inStock': product.inStock,
              'images': product.images,
              'categories': product.categories,
              'rating': product.reviewsSummary.averageRating,
              'reviewsCount': product.reviewsSummary.totalReviews,
              'reviews_count': product.reviewsSummary.totalReviews,
            }
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF182430) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: _isGridView ? 140 : 140,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image, size: 50),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image, size: 50),
                        ),
                ),
                // Remove Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromWishlist(item.id, product.name),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0F172A) : Colors.white)
                            .withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                    children: [
                      if (product.specialPrice != null &&
                          product.specialPrice != product.price) ...[
                        Flexible(
                          child: PriceText(
                            amount: product.specialPrice!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: PriceText(
                            amount: product.price,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ] else
                        Flexible(
                          child: PriceText(
                            amount: product.price,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: isAvailable ? () => _addToCart(item) : null,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
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
