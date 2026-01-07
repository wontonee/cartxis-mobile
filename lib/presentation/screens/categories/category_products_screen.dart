import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/cart_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/price_text.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final ScrollController _scrollController = ScrollController();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedSort = 'created_at';
  String _selectedOrder = 'desc';
  bool _isAddingToCart = false;

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
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });

      final response = await _productService.getCategoryProducts(
        categoryId: widget.categoryId,
        page: _currentPage,
        perPage: 20,
        sort: _selectedSort,
        order: _selectedOrder,
      );

      if (mounted) {
        setState(() {
          _products = response.data;
          _hasMore = (response.meta.currentPage ?? 0) < (response.meta.lastPage ?? 0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        _currentPage++;
      });

      final response = await _productService.getCategoryProducts(
        categoryId: widget.categoryId,
        page: _currentPage,
        perPage: 20,
        sort: _selectedSort,
        order: _selectedOrder,
      );

      if (mounted) {
        setState(() {
          _products.addAll(response.data);
          _hasMore = (response.meta.currentPage ?? 0) < (response.meta.lastPage ?? 0);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--;
        });
      }
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Adding to cart...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      await _cartService.addToCart(
        productId: product.id,
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${product.name} added to cart'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(e.toString().contains('PRODUCT_UNAVAILABLE')
                      ? 'Product not available'
                      : 'Failed to add to cart'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF182430) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Price: Low to High', 'price', 'asc', isDark),
              _buildSortOption('Price: High to Low', 'price', 'desc', isDark),
              _buildSortOption('Name: A to Z', 'name', 'asc', isDark),
              _buildSortOption('Name: Z to A', 'name', 'desc', isDark),
              _buildSortOption('Newest First', 'created_at', 'desc', isDark),
              _buildSortOption('Oldest First', 'created_at', 'asc', isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String sort, String order, bool isDark) {
    final isSelected = _selectedSort == sort && _selectedOrder == order;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white : Colors.grey.shade900),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedSort = sort;
          _selectedOrder = order;
        });
        Navigator.pop(context);
        _loadProducts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF182430) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.grey.shade900,
          ),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: Icon(
              Icons.sort,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const ProductCardSkeleton(),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new items',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = _products[index];
          return _buildProductCard(product, isDark);
        },
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
                  height: 140,
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
                if (product.discountPercentage > 0)
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.brand != null)
                    Text(
                      product.brand is Map<String, dynamic> 
                          ? (product.brand['name']?.toString() ?? '')
                          : product.brand.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (product.specialPrice != null &&
                          product.specialPrice != product.price) ...[
                        Flexible(
                          child: PriceText(
                            amount: product.specialPrice!,
                            style: const TextStyle(
                              fontSize: 14,
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
                              fontSize: 11,
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
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
          ],
        ),
      ),
    );
  }
}
