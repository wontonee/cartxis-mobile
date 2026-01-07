import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/data/models/category_model.dart';
import 'package:vortex_app/data/services/category_service.dart';
import '../../widgets/skeleton_loader.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  int? _expandedCategoryIndex;
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildTopBar(isDark),
          Expanded(
            child: _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) => const CategoryCardSkeleton(),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildBrowseAll(isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8)).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(bool isDark) {
    final topCategories = [
      {
        'name': 'Electronics',
        'items': '1.2k items',
        'badge': 'NEW',
        'badgeColor': AppColors.primary,
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwy9NAhZyCWnN0oCRAduhbcsadh8p0SvRoBJsaNCD94L55oWceWLKaV4N5TTeeTJVmr0Sa8_wVycJH_BIpJTi05ZJFjCplYJb7i3a_yDTkhP_gydms6cG9lBycMxrvrpQ4nehrNUaIVegsX5_erZS1EbBLUaQxYD_SjJ7zh6pg7jotOQAqHBxrqdCNogDa7_yNBgAPGssvKoLHtsXW9h_Dx58OYqvJf2KCJN5uGphv4-BPeBNuv5miV0gylLy1juzq6V8vgluH6y5Y',
      },
      {
        'name': 'Fashion',
        'items': '350+ items',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrcLTIuvNUFTUrnpoVJRqHCBOdQrq09boMuchOwmjxFN_H3EqUcTRHwWrBAXXeNwKOF0cFd_9V3A4Q72yfKfCileUM-XZAifhTOOinIoS_el28iqaZYFZsRQF2Q06fEfw6AdN_exbhwboOfVwRm5iTnMupaIcNf_H0fHtn9opzA6av9o3Qt8U1U7t5Iqm9Wrzu1mc-0dNhi7z9Nvw_hJoOLnYFvbTIMuTIb9i78kAhk2IngDB6zgE-QZfCdgiOwI5MsDojO2t0LCMv',
      },
      {
        'name': 'Home',
        'items': '85 items',
        'badge': 'SALE',
        'badgeColor': Colors.orange,
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB-gDJtBAFGx7qfLnKPiSQLR0xaHgkvsQT5G9LYopl_LLmCWH6Zsa_VviM9gQi1o5QbsejuYp5qoTca9aCyTkfUNKl06SF6IB1O8mfa4Dy05Cwgoj9tS8RniHqyPvS-vdhrUUIbSZ5TRmWvYYI1Zq47ZlB2fH1To27Ma_SH9KANubrR3tnCfb_50HgEeSXMCHHDnMmtwbdR9iLlCJURHTi_Z-gBM2KAt_tAHHhlobI2_NwEHaGVb2Ftccs5iDl4BQA8ikJu3ILtqjpO',
      },
      {
        'name': 'Sports',
        'items': '42 items',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDffIWs1fsndTGJIQ0lF10DMMPfQDWT8_LUcHHjBFY3uQr1zMXG0a2qqcnm-UbQKgng3YNc4aPTJC-OssXS-KCP9JpKUkD3jUEqVv7aan-6xc4YqoJIDM2dWYT0QsPKZSI_UtjgwsV3Lk2PnxYi52oRZdSenc9AqtsSnPjsQ_AKPBeCZWFOdT24Yj8jLytn_mt2rn4L8IDyouYALcPqMJEVvdxuJsn61QrDxqi3cC1reOrKzx8KPO0jI-ZTciMvipkqxd2ZLjN20qmG',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Categories',
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
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: topCategories.length,
            itemBuilder: (context, index) {
              final category = topCategories[index];
              return _buildTopCategoryCard(category, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryCard(Map<String, dynamic> category, bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                category['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    child: const Icon(Icons.image, size: 40),
                  );
                },
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category['badge'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: category['badgeColor'] ?? AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category['badge'],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (category['badge'] != null) const SizedBox(height: 4),
                    Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category['items'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseAll(bool isDark) {
    // Get parent categories (no parent_id)
    final parentCategories = _categories.where((cat) => cat.parentId == null).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Browse All',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
          ),
          ...List.generate(parentCategories.length, (index) {
            final category = parentCategories[index];
            final isExpanded = _expandedCategoryIndex == index;
            final hasSubcategories = category.children.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF182430) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Main Category
                    InkWell(
                      onTap: hasSubcategories
                          ? () {
                              setState(() {
                                _expandedCategoryIndex = isExpanded ? null : index;
                              });
                            }
                          : () {
                              // Navigate to category products screen
                              Navigator.pushNamed(
                                context,
                                '/category-products',
                                arguments: {
                                  'categoryId': category.id,
                                  'categoryName': category.name,
                                },
                              );
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isExpanded
                                    ? AppColors.primary.withOpacity(0.1)
                                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(category.slug),
                                size: 24,
                                color: isExpanded
                                    ? AppColors.primary
                                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                              ),
                            ),
                            Icon(
                              hasSubcategories
                                  ? (isExpanded ? Icons.expand_less : Icons.expand_more)
                                  : Icons.chevron_right,
                              color: hasSubcategories && isExpanded
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Subcategories
                    if (isExpanded && hasSubcategories)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800.withOpacity(0.5)
                              : const Color(0xFFFAFAFA),
                          border: Border(
                            top: BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                            ),
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            ...List.generate(
                              category.children.length,
                              (subIndex) {
                                final subcategory = category.children[subIndex];
                                final isLast = subIndex == category.children.length - 1;

                                return InkWell(
                                  onTap: () {
                                    // Navigate to subcategory products screen
                                    Navigator.pushNamed(
                                      context,
                                      '/category-products',
                                      arguments: {
                                        'categoryId': subcategory.id,
                                        'categoryName': subcategory.name,
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: isLast
                                          ? null
                                          : Border(
                                              bottom: BorderSide(
                                                color: isDark
                                                    ? Colors.grey.shade700.withOpacity(0.5)
                                                    : Colors.grey.shade100,
                                              ),
                                            ),
                                    ),
                                    child: Text(
                                      subcategory.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to map category slugs to Material icons
  IconData _getCategoryIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'clothing':
      case 'fashion':
        return Icons.checkroom;
      case 'home-garden':
      case 'home & garden':
      case 'home & living':
        return Icons.chair;
      case 'sports-outdoors':
      case 'sports & outdoors':
        return Icons.fitness_center;
      case 'books':
        return Icons.menu_book;
      case 'accessories':
        return Icons.watch;
      case 'beauty-personal-care':
      case 'beauty & personal care':
        return Icons.face;
      case 'toys-games':
      case 'toys & games':
        return Icons.toys;
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
}
