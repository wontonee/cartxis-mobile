import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import '../../widgets/price_text.dart';

class ProductListScreen extends StatefulWidget {
  final String category;

  const ProductListScreen({
    super.key,
    this.category = 'Sneakers',
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isGridView = true;
  String selectedSort = 'Price: Low to High';
  List<String> selectedFilters = ['Nike'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildControlsStrip(isDark),
            Expanded(
              child: _buildProductGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182430) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
          Expanded(
            child: Text(
              widget.category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined),
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsStrip(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF182430) : Colors.white,
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
          // Main Actions Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter & Sort
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune,
                            size: 20,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort,
                            size: 20,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedSort,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade200 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // View Toggle
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isGridView = true),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isGridView
                                ? (isDark ? Colors.grey.shade700 : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isGridView
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            Icons.grid_view,
                            size: 20,
                            color: isGridView
                                ? AppColors.primary
                                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => isGridView = false),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: !isGridView
                                ? (isDark ? Colors.grey.shade700 : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: !isGridView
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            Icons.view_list,
                            size: 20,
                            color: !isGridView
                                ? AppColors.primary
                                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildFilterChip('Nike', true, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Adidas', false, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Puma', false, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Under \$150', false, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('New Arrival', false, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductGrid(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return _buildProductCard(product, isDark);
          },
        ),
        const SizedBox(height: 20),
        // Loading indicator
        Center(
          child: Column(
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading more products...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: {'product': product},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 50);
                    },
                  ),
                ),
              ),
              // Wishlist Button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    product['isFavorite']
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: product['isFavorite']
                        ? Colors.red
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              // Badge
              if (product['badge'] != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product['badge'] == 'NEW'
                          ? AppColors.primary
                          : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product['badge'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Product Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product['rating'].toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            product['category'],
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          if (product['originalPrice'] != null)
            DiscountedPriceText(
              originalPrice: double.parse(product['originalPrice'].toString()),
              discountedPrice: double.parse(product['price'].toString()),
              fontSize: 14,
              discountedPriceColor: AppColors.primary,
            )
          else
            StyledPriceText(
              amount: double.parse(product['price'].toString()),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
        ],
      ),
      ),
    );
  }
}

// Sample product data
final List<Map<String, dynamic>> _products = [
  {
    'name': 'Nike Air Max 270',
    'category': "Men's Shoes",
    'price': '120.00',
    'rating': 4.5,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB2Ldkpx0e8NjvBShgYilXkRu7RJKI4yotaM2nAgz3H9h7GURx9uHkl_-oDIP9DciztHVDynO4rkbsm5iB6IJHMvxB9CWU-c2-06hsPUJaAvNpi3lMLcentjC1XXRzzif9iqmhbo_0NaKw_5jDWpwjXZUrR7ZOFxvn3a-NjF-CRCNkUGMJUS4CWO6udtpM1Ji_9vVcGXW-Y5HVr8VklJw224sKQBENXf8E7v9E1DVQJKR-VlxH0LdlAjEJtfjdfB9SuKoPK_91rm3iT',
    'badge': 'NEW',
    'isFavorite': false,
  },
  {
    'name': 'Adidas Ultraboost',
    'category': 'Running',
    'price': '180.00',
    'rating': 4.8,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPHLscxrJxEbaJYnQeBCF8YUCmq-GZlNR7YsdJIU1rYfKUQxOz3zRKf30w7sTA6SZZiG_o0mK_DhBqtZmKDBb5KuRzDA5J_sLd_bNagPlvNUAnTTuFfI5b8ApvpHWaWKGEMGpEAWy9ugA6yd-t2abD1XhELatkACm9oerH_Latncd3mbufUa7QqEaoip8rKhtC-e6G8LtrE-kKSiUtjdSClU_Ch9n9aiY3r_lF3bUQ7qRGZRYkiKamGkr0tRamG40YfMBYq86gMzCG',
    'isFavorite': true,
  },
  {
    'name': 'Puma RS-X3 Puzzle',
    'category': 'Casual',
    'price': '110.00',
    'originalPrice': '135.00',
    'rating': 4.2,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbhcTGJeiNUoHhGo_l1z8xP7W4SctgUU6Tx2z4ojKf24m1OcEchzRyOsJs-iM-rC8922QL2dQFVfwtMnP7nQmFh3z08tRNQbwbGjM3714Monxa92SMwTJKz_aK6zdi14AWt_HYhFlyprzt2XcJi0uABoPwhrNMxY3UUgYW5lOiOoDCb6kG7kOsX1uPu5BKgVMGymvBYTGpRYSO6gu64YRUmFC2DL5oCTS0vRdR8kuxleAy2_SWAPqBjVZUWRa_A3hkxyPwupbjr4Wy',
    'badge': '-20%',
    'isFavorite': false,
  },
  {
    'name': 'New Balance 574',
    'category': 'Classic',
    'price': '85.00',
    'rating': 4.6,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAEl9pxS6rDwN255GqteY9QncKk-m317QgBxEbh3Jlbd_Y42keudDcDdrRjbML0HbM8sOj9_7R09I_lOvxQux7ABLtiS-f-oKYSrLJk5RX1skFVIK2JDbWgWPBIZ1zC0gXLE5-F7O4BxfLyWPsdqx31K9X15PBfoxvShJcfev2q5TbdExC7RcrFvn_3MEdKKXJ0DwYJOZa_bJxlopF8rIIjk2uS3HOdvUi9PkALB7OP74t3vcz01X9HouM_pw5rm9eAsgIoPm251g0b',
    'isFavorite': false,
  },
  {
    'name': 'Reebok Club C 85',
    'category': 'Tennis',
    'price': '75.00',
    'rating': 4.7,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXVLncWXGbryQL6XfrlaXG1aFNTTI0cIcX5-yMY0AzUi7fpZyOXl1CLcIzcFQ8cqDp_7KWjKW_Qzt2QqvYe3zhCG67NMgxJItwnGOvsjtt9oPEVPChqtYXjTX92MMH_OrYvk46L7Z3zIJ-4F0WcDYfQdmGmD9lBsND5Syj4u9emtU7Edqjg4Ffa9cvucyKtVcGRfhnv9QRo3DM5rjIsCQukZ0zZ4D4FNG30GVSLR63N8GewQuGjxCYVT0ixvc8o0tZu2U-RRHq_3z5',
    'isFavorite': false,
  },
  {
    'name': 'Vans Old Skool',
    'category': 'Skate',
    'price': '65.00',
    'rating': 4.9,
    'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAwEkMWuB3iCwa9wbHwAa1RZ4Ush83mOPEd5lJh2Hd_XW9-1TW6ELIctENb9Dfg4rlfe7kKWWM8YXmqoVLQCnCDIIq1KvJtIjwHbDBf1fBVWuA6taiKYqVUFjgx_LJwnbyHw5ueqYXgDRCTi0_qEiMJv1JnqNbyaWauJCkf6T7_QXQGgKOsAoec-9NyImq-wurGrqz6-LC7TqQ36yfuB8Ssn9Q0bLRbpoHWGdt1RXywSeAH2oAbrugaGzCEI7vZN9SFm_4ANirkIsgb',
    'isFavorite': false,
  },
];
