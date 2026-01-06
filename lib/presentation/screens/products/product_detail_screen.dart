import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/presentation/widgets/price_text.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Image Carousel
              SliverToBoxAdapter(
                child: _buildImageCarousel(isDark),
              ),
              // Content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(isDark),
                              const SizedBox(height: 12),
                              _buildShortDescription(isDark),
                              const SizedBox(height: 20),
                              _buildQuantityAndActions(isDark),
                              const SizedBox(height: 20),
                              _buildAddToCartButton(isDark),
                              const SizedBox(height: 16),
                              Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
                              const SizedBox(height: 16),
                              _buildExpandableSections(isDark),
                              const SizedBox(height: 24),
                              _buildReviewsSection(isDark),
                              const SizedBox(height: 24),
                              _buildRelatedProducts(isDark),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Top App Bar
          _buildTopAppBar(isDark),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(bool isDark) {
    // Use images from product if available, otherwise use placeholder
    final productImages = widget.product['images'] as List<dynamic>?;
    final List<String> images = [];
    
    if (productImages != null && productImages.isNotEmpty) {
      for (var img in productImages) {
        if (img is String) {
          images.add(img);
        } else if (img is Map<String, dynamic>) {
          final url = img['url']?.toString() ?? 
                     img['path']?.toString() ?? 
                     img['image']?.toString() ?? '';
          if (url.isNotEmpty) images.add(url);
        }
      }
    }
    
    // If no valid images, use placeholders
    if (images.isEmpty) {
      images.addAll([
        'https://via.placeholder.com/400x400?text=Product+Image',
      ]);
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                color: isDark ? const Color(0xFF182430) : Colors.white,
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image, size: 50));
                  },
                ),
              );
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final productName = widget.product['name']?.toString() ?? 'Product Name';
    final price = (widget.product['price'] ?? widget.product['discountPrice'] ?? 0.0) as num;
    final originalPrice = widget.product['discountPrice'] != null 
        ? (widget.product['price'] ?? 0.0) as num
        : null;
    final rating = (widget.product['rating'] ?? 0.0) as num;
    final reviewsCount = (widget.product['reviewsCount'] ?? widget.product['reviews_count'] ?? 0) as num;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            StyledPriceText(
              amount: price.toDouble(),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            if (originalPrice != null && originalPrice > price) ...[
              const SizedBox(width: 12),
              StyledPriceText(
                amount: originalPrice.toDouble(),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                decoration: TextDecoration.lineThrough,
              ),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.amber.shade900.withOpacity(0.2) : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($reviewsCount reviews)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: (widget.product['stock'] as num? ?? 0) > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              (widget.product['stock'] as num? ?? 0) > 0 ? 'In Stock' : 'Out of Stock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: (widget.product['stock'] as num? ?? 0) > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '•',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(width: 16),
            Text(
              'SKU: ${widget.product['id']?.toString() ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortDescription(bool isDark) {
    final description = widget.product['description']?.toString() ?? 'No description available';
    
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
        height: 1.5,
      ),
    );
  }

  Widget _buildQuantityAndActions(bool isDark) {
    return Row(
      children: [
        // Quantity Selector
        Container(
          height: 48,
          width: 128,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isDark ? const Color(0xFF1C2630) : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                  icon: Icon(
                    Icons.remove,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Text(
                '$_quantity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                  icon: Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Favorite Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isDark ? const Color(0xFF1C2630) : Colors.white,
          ),
          child: IconButton(
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey.shade500,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Share Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isDark ? const Color(0xFF1C2630) : Colors.white,
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              color: Colors.grey.shade500,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 24),
            SizedBox(width: 8),
            Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSections(bool isDark) {
    return Column(
      children: [
        _buildExpandableCard(
          'Full Description',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The WH-1000XM5 headphones rewrite the rules for distraction-free listening. 2 processors control 8 microphones for unprecedented noise cancellation and exceptional call quality. With a newly developed driver, DSEE – Extreme and Hi-Res audio support the WH-1000XM5 headphones provide awe-inspiring audio quality.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Industry-leading noise cancellation',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Magnificent Sound, engineered to perfection',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Crystal clear hands-free calling',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Up to 30-hour battery life',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildExpandableCard(
          'Specifications',
          Column(
            children: [
              _buildSpecRow('Weight', '250g', isDark),
              _buildSpecRow('Battery Life', '30 Hours', isDark),
              _buildSpecRow('Bluetooth', 'Version 5.2', isDark),
              _buildSpecRow('Charging', 'USB-C', isDark, isLast: true),
            ],
          ),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildExpandableCard(
          'Shipping Info',
          Text(
            'Free shipping on orders over \$50. Standard shipping takes 3-5 business days. Express shipping options available at checkout. Returns accepted within 30 days of purchase.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          isDark,
        ),
      ],
    );
  }

  Widget _buildExpandableCard(String title, Widget content, bool isDark) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2630) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          iconColor: Colors.grey.shade400,
          collapsedIconColor: Colors.grey.shade400,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                ),
              ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isDark, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  style: BorderStyle.solid,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (120)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Review Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2630) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Rating Score
              Container(
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < 4 ? Icons.star : Icons.star_half,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Rating Bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar('5', 0.85, isDark),
                    const SizedBox(height: 6),
                    _buildRatingBar('4', 0.10, isDark),
                    const SizedBox(height: 6),
                    _buildRatingBar('3', 0.05, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Single Review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2630) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'JD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '2 days ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, color: Colors.amber, size: 14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Absolutely amazing sound quality! The noise cancelling is out of this world. Highly recommend.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(String rating, double percentage, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            rating,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProducts(bool isDark) {
    final relatedProducts = [
      {
        'name': 'Sony WF-1000XM4 Earbuds',
        'price': '278.00',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuASsJ6yykRpDRLE4FOJDbvUdGthZZJRE-O87yGTetaKqZ7PSp3CHJRWhB1OXHhxhc4gPZXwW0-TgBHFN6YhWs4yRMzGHQTQzVecA0RAOdaFbzbwtHeN4HrpYEoifcFQnTvhMVWkEGrcgHdWIhNUE53rb5VLtvgSTv-6I3NQDypzDNxb1So5pbAEA0k3Gu1-BvAzfLs7ft8EFNSD08F9RIu86SJUwHO-JU2jgDvetgC1BMIrg1K4kY2SgPDtPS48Vjig5lN0Io58Pv5i',
      },
      {
        'name': 'Bose QuietComfort 45',
        'price': '329.00',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBeLTVy4GSwzRAgAn0aRqR1WZskeSsx9RSV5JlTdf5PZInyrr8he3qHIeMb2ckfrMh_JRI2b4-qHlrv2mgGEBhbzh-DBswk1wbV8TUJGZlbmHlLc8b1FQ279zOohCPuvPYTFrTmHml8NqrQfNY6y0Up8_cUPmIIXeO0K_oQALUiT4B5oA30sNPWFqAetTWezQeAaFGqUNPzSWJT2MviRKjdyvsMUKSpRoXqgM-9U2zv7nAds2QgxNjX3YNDk7iu6RtiLJAO-_bip0cD',
      },
      {
        'name': 'Beats Solo3 Wireless',
        'price': '199.95',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB9jgMIml8VD93xDuDl4vJ3RgPBaPHjvC7zXTp7h9X0D0Eaq7sJdlwufHbqXVOt7LZ-lpqFWfcaTmmxPXymd3EZIN0IeD2OpHjaVaPUSWU9AtK4N_cd_UbWJKA-zLoS8XJnFMne5M03P11i4_3tb4pmSh_WDgTbJUdiVRhKitCS7XASkIsPgIfwi4Yvgtl1VSdSJnbbgothdYPHicsDBML9DEGIaLiKEoj5rx0gJZEn_0JtssamiQr3bx_uGBpIH1tyz9YoHc3rPa1K',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(right: index < relatedProducts.length - 1 ? 16 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C2630) : Colors.white,
                            border: Border.all(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image, size: 40);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['name']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StyledPriceText(
                      amount: double.parse(product['price'] ?? '0'),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
