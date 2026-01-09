import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/product_service.dart';
import 'package:vortex_app/data/services/cart_service.dart';
import 'package:vortex_app/data/models/product_model.dart';
import 'package:vortex_app/presentation/screens/products/product_detail_screen.dart';
import '../../widgets/skeleton_loader.dart';

class NewArrivalsScreen extends StatefulWidget {
  final VoidCallback? onCartChanged;
  
  const NewArrivalsScreen({super.key, this.onCartChanged});

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  final _productService = ProductService();
  final _cartService = CartService();
  final _scrollController = ScrollController();
  
  List<ProductModel> _products = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isAddingToCart = false;
  
  int _currentPage = 1;
  final int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoadingInitial = true;
      });

      final products = await _productService.getNewArrivals(
        limit: _perPage,
      );
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoadingInitial = false;
          _hasMore = products.length >= _perPage;
          _currentPage = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      // Note: We'll pass a higher limit to get more products
      // Since the API doesn't have page parameter, we'll increase the limit
      final nextLimit = (_currentPage + 1) * _perPage;
      final products = await _productService.getNewArrivals(
        limit: nextLimit,
      );
      
      if (mounted) {
        setState(() {
          // Only add new products that we don't already have
          final newProducts = products.skip(_products.length).toList();
          _products.addAll(newProducts);
          _isLoadingMore = false;
          _hasMore = newProducts.isNotEmpty;
          _currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    if (_isAddingToCart) return;

    try {
      setState(() {
        _isAddingToCart = true;
      });

      await _cartService.addToCart(
        productId: product.id,
        quantity: 1,
      );

      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });

        widget.onCartChanged?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101922) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Arrivals',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingInitial
          ? _buildLoadingSkeleton()
          : _products.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                    itemCount: _products.length + (_isLoadingMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _products.length) {
                        return const ProductCardSkeleton();
                      }
                      
                      final product = _products[index];
                      return _buildProductCard(product, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No New Arrivals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new products',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark) {
    String imageUrl = '';
    if (product.images.isNotEmpty) {
      final firstImage = product.images[0];
      if (firstImage is String) {
        imageUrl = firstImage;
      } else if (firstImage is Map<String, dynamic>) {
        imageUrl = firstImage['url']?.toString() ?? 
                   firstImage['path']?.toString() ?? 
                   firstImage['image']?.toString() ?? '';
      }
    }
    final displayImageUrl = imageUrl.isEmpty
        ? 'https://via.placeholder.com/300x300/4A90E2/FFFFFF?text=${Uri.encodeComponent(product.name)}'
        : imageUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product.toJson(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2633) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: Image.network(
                    displayImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 50);
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (product.discountPercentage > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${product.discountPercentage.toStringAsFixed(0)}%',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.brand != null && product.brand is Map<String, dynamic>)
                    Text(
                      (product.brand as Map<String, dynamic>)['name'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.specialPrice != null && product.specialPrice! > 0)
                              Text(
                                '${product.currency} ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '${product.currency} ${product.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _isAddingToCart ? null : () => _addToCart(product),
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _isAddingToCart 
                                ? AppColors.primary.withOpacity(0.5)
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
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
      ),      ),    );
  }
}
