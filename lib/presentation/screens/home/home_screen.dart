import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/services/product_service.dart';
import 'package:vortex_app/data/services/category_service.dart';
import 'package:vortex_app/data/services/cart_service.dart';
import 'package:vortex_app/data/models/product_model.dart';
import 'package:vortex_app/data/models/category_model.dart';
import '../../widgets/price_text.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCartChanged;
  
  const HomeScreen({super.key, this.onCartChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _cartService = CartService();
  
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _newProducts = [];
  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  
  bool _isLoadingFeatured = true;
  bool _isLoadingNew = true;
  bool _isLoadingAll = true;
  bool _isLoadingCategories = true;
  bool _isAddingToCart = false; // Prevent duplicate add to cart calls
  
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    await Future.wait([
      _loadFeaturedProducts(),
      _loadNewProducts(),
      _loadAllProducts(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      final categories = await _categoryService.getParentCategories();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      setState(() {
        _isLoadingFeatured = true;
      });

      final products = await _productService.getFeaturedProducts(
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          _featuredProducts = products;
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFeatured = false;
        });
      }
    }
  }

  Future<void> _loadNewProducts() async {
    try {
      setState(() {
        _isLoadingNew = true;
      });

      final response = await _productService.getNewProducts(
        page: 1,
        perPage: 10,
      );
      
      if (mounted) {
        setState(() {
          _newProducts = response.data;
          _isLoadingNew = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNew = false;
        });
      }
    }
  }

  Future<void> _loadAllProducts() async {
    try {
      setState(() {
        _isLoadingAll = true;
      });

      final response = await _productService.getProducts(
        page: _currentPage,
        perPage: 20,
        sort: 'created_at',
        order: 'desc',
      );
      
      if (mounted) {
        setState(() {
          if (_currentPage == 1) {
            _allProducts = response.data;
          } else {
            _allProducts.addAll(response.data);
          }
          _hasMore = response.meta.currentPage < response.meta.lastPage;
          _isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAll = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(ProductModel product) async {
    // Prevent duplicate calls
    if (_isAddingToCart) {
      return;
    }
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Show loading indicator
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

      widget.onCartChanged?.call();

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
      // Always reset the flag after operation completes
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          // Header with Search and Notification
          SafeArea(
            bottom: false,
            child: _buildHeader(isDark),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Banner Slider
                  _buildBannerSlider(),
                  
                  const SizedBox(height: 8),
                  
                  // Category Chips
                  _buildCategoryChips(isDark),
                  
                  const SizedBox(height: 8),
                  
                  // Featured Products
                  _buildFeaturedProducts(isDark),
                  
                  // Flash Sale
                  _buildFlashSale(isDark),
                  
                  // New Arrivals
                  _buildNewArrivals(isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.backgroundDark.withOpacity(0.95)
            : AppColors.backgroundLight.withOpacity(0.95),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2633) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _searchController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notification Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2633) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1A2633) : Colors.white,
                        width: 1.5,
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

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildBannerCard(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDZOJapra7fy6BAM2iHLk9hSxtELNcnNARwEiqlK9sD3o8I0_A38Nqual6NZ4N8pmVIQBJJkPLpu0pHB_8eLIzvEqMzvXxOTDxx0uLfV2sF1P-T1TMv_Py-B1ZP-hM8hLRF2BbBiKCmmxC3weWN0rTgwAoP8UJPklNM_GKD_cD2O8qWl_GGRfF5eMytCo8ZbG39l_a-OdMb7C-HdSyU7CCzshPBlzcXJtEGjw9nIhbW5Qwwny5mSKL1h5fiDv-ofgkeG95o4Y-J9hWm',
            'PROMO',
            'Summer Sale',
            'Up to 50% Off Electronics',
            Colors.black.withOpacity(0.6),
          ),
          const SizedBox(width: 16),
          _buildBannerCard(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCy0yJAkZq9Kf7iSGQAHsL1hW-VddU370wK0zu9ElzV0TGfbGcKLLu9mXoHSNxRBSmsXw-QsQ1UeC0MKs6N0r0Roa4WiGiAsmwsuF8Cou15aV0s8HS-dmH80W0RuHAGRj84j9R0jvSNjxII0zTuNUQGrTuXlGtUsEY8iiMMQUBoPYQxPylkdJuSRG85fUtX9jf-9YoFPbaFOTIXydlPjjcY6h9dKmziCjJOBlOGuaaftHPrNW6jkX1tR5d2xBvvYdEBmSFfRBHZRbK_',
            'NEW',
            'Fashion Week',
            'Trending Styles 2023',
            const Color(0xFF581C87).withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(
    String imageUrl,
    String badge,
    String title,
    String subtitle,
    Color overlayColor,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 50),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    overlayColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badge == 'PROMO' ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badge == 'PROMO' ? Colors.white : const Color(0xFF581C87),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to map category slugs to Material icons
  IconData _getCategoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      case 'home-garden':
      case 'home & garden':
        return Icons.home;
      case 'sports-outdoors':
      case 'sports & outdoors':
        return Icons.sports_soccer;
      case 'books':
        return Icons.menu_book;
      case 'accessories':
        return Icons.watch;
      case 'yoga-mat':
      case 'yoga mat':
        return Icons.sports_gymnastics;
      case 'yoga-wheel':
      case 'yoga wheel':
        return Icons.album;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategoryChips(bool isDark) {
    if (_isLoadingCategories) {
      return SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) => const CategoryCardSkeleton(),
        ),
      );
    }

    // Add "All" category at the beginning
    final allCategories = [
      {'id': 0, 'name': 'All', 'slug': 'all', 'icon': Icons.grid_view},
      ..._categories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'slug': cat.slug,
        'icon': _getCategoryIcon(cat.slug),
      }),
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length > 6 ? 6 : allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = index == 0; // First item (All) is selected by default
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 18,
                    color: isSelected 
                        ? Colors.white 
                        : (isDark ? Colors.grey.shade500 : Colors.grey.shade700),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Colors.white 
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              onSelected: (bool value) {
                // TODO: Navigate to product list screen with category filter
                // Navigator.pushNamed(
                //   context,
                //   '/products',
                //   arguments: {'category': category['slug']},
                // );
              },
              backgroundColor: isDark ? const Color(0xFF1A2633) : Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
              ),
              shadowColor: isSelected ? AppColors.primary.withOpacity(0.3) : null,
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/products',
                    arguments: {'category': 'featured'},
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 290,
          child: _isLoadingFeatured
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => const ProductCardSkeleton(),
                )
              : _featuredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No featured products available',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _featuredProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final product = _featuredProducts[index];
                        
                        // Generate a placeholder image URL if images are empty
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
                        
                        // Use a colorful placeholder if no image
                        final displayImageUrl = imageUrl.isEmpty
                            ? 'https://via.placeholder.com/300x300/4A90E2/FFFFFF?text=${Uri.encodeComponent(product.name.length > 20 ? product.name.substring(0, 20) : product.name)}'
                            : imageUrl;
                        
                        return _buildProductCard(
                          displayImageUrl,
                          product.name,
                          product.finalPrice,
                          product.reviewsSummary.averageRating,
                          product.reviewsSummary.totalReviews,
                          isDark,
                          discount: product.discountPercentage > 0
                              ? '${product.discountPercentage.toInt()}% OFF'
                              : null,
                          originalPrice: product.specialPrice != null && product.specialPrice != product.price
                              ? product.price
                              : null,
                          product: product,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFlashSale(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Flash Sale ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  const Text(
                    '⚡️',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSaleCard(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDln0P5UV_2q44rv_3thoSG9YXGNY7S4qr4Db8ERTTYnniKfGACOaAjdvVG9mqVsM_BatGpUtCFMgQ6WixED3UOELtQNZZp2_jsKMwjJUOzm26FC1XYfuoQ5pXgN3IBavRRv8RBZlV-Ea4eonmytpHSLX5ht_QAhjsIEebSRThhw5Deuk6ETMtJVIcF_ZXJs8coxYv7I71L1dYISkLTqJGUKGh-RZzlo1q3idSTm-KRR-BhMyxLUvmWvwZmucFzcP9zD5WbdXUHWOoM',
                'Nike Air Max 270 Red',
                '\$112.00',
                '\$160.00',
                '-30%',
                isDark,
              ),
              const SizedBox(width: 16),
              _buildSaleCard(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD7bfyFfmndgJ9r4F6o8jkJbnoFRLVQnVdy7sstaC2AYyr3oCiOhzTm7akeYOuz8KXDz2t6RAl9vysYNAYWZdoJc3ittmjvcsGJV2YEfWq89VXLV4lQ3_MPYoK_1FmbwuERY8v1udWO93-ix-H_YS26cc4TElxnAsNRE2C1omL7RCPSAsIULIaWLQyBReqd_HlCMWR5tdjuHjfgpdC_9H4wkiJbxdvtBaR-DJPgSMO-0zc5B5kX2vKrrHuAN4x75V7cUDd9OFXQ6LQs',
                'Adidas Ultra Boost DNA',
                '\$144.00',
                '\$180.00',
                '-20%',
                isDark,
              ),
              const SizedBox(width: 16),
              _buildSaleCard(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBihTM4vUrzf0BiEKJTKuqNzn2s7KfUA0dJLwTsGYriH9ogHriP99IJM65lD72aKWPRDfG4JJDppM80uRLeGV4LcmNJeaUa8VHZQv0BMFY1xmlPUEQ2WfLa1jiXNofQTbIe7Fr6ECCDL--C5q5MRgFxLQkWvXEcTIYQ-uLQGmMagDuAtnuwRPtXmFWvdeZ8yssT5Y5gLQte6_Rw0NXHVBblSWoaPEBdsEuYZQOBY4ggDsaXNlEC0o8_iPbod0LUW5tLB6Tg0EKIXUR9',
                'Garmin Forerunner 245',
                '\$255.00',
                '\$300.00',
                '-15%',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewArrivals(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/products',
                    arguments: {'category': 'new'},
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: _isLoadingNew
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => const ProductCardSkeleton(),
                )
              : _newProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No new products available',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _newProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final product = _newProducts[index];
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
                        return _buildNewArrivalCard(
                          displayImageUrl,
                          product.name,
                          '${product.currency} ${product.finalPrice.toStringAsFixed(2)}',
                          isDark,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String imageUrl,
    String name,
    double price,
    double rating,
    int reviews,
    bool isDark, {
    String? discount,
    double? originalPrice,
    ProductModel? product,
  }) {
    return Container(
      width: 160,
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
          // Product Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 50);
                    },
                  ),
                ),
              ),
              if (discount != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 13,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviews)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (originalPrice != null)
                          StyledPriceText(
                            amount: originalPrice,
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        StyledPriceText(
                          amount: price,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _isAddingToCart || product == null 
                          ? null 
                          : () => _addToCart(product),
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
        ],
      ),
    );
  }

  Widget _buildSaleCard(
    String imageUrl,
    String name,
    String salePrice,
    String originalPrice,
    String discount,
    bool isDark,
  ) {
    return Container(
      width: 160,
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
                  height: 110,
                  width: double.infinity,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: Image.network(
                    imageUrl,
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
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      salePrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      originalPrice,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalCard(
    String imageUrl,
    String name,
    String price,
    bool isDark,
  ) {
    return Container(
      width: 160,
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
                  height: 110,
                  width: double.infinity,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  child: Image.network(
                    imageUrl,
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
                    color: Colors.blue.shade500,
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
