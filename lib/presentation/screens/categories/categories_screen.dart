import 'dart:async';

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
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories({String? search}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final categories = await _categoryService.getCategories(search: search);
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _expandedCategoryIndex = null;
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
    _searchDebounce?.cancel();
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
                  onChanged: (value) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
                      if (!mounted) return;
                      _loadCategories(search: value);
                    });
                  },
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
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 40),
                                        Expanded(
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
                                        Icon(
                                          Icons.chevron_right,
                                          size: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
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
