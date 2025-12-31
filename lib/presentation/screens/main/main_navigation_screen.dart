import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/presentation/screens/home/home_screen.dart';
import 'package:vortex_app/presentation/screens/categories/categories_screen.dart';
import 'package:vortex_app/presentation/screens/cart/cart_screen.dart';
import 'package:vortex_app/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:vortex_app/presentation/screens/profile/profile_screen.dart';
import 'package:vortex_app/data/services/cart_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  final CartService _cartService = CartService();

  List<Widget> get _screens => [
    HomeScreen(onCartChanged: _loadCartCount),
    const CategoriesScreen(),
    CartScreen(
      onCartChanged: _loadCartCount,
      onContinueShopping: () {
        setState(() {
          _selectedIndex = 0; // Switch to home tab
        });
      },
    ),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final count = await _cartService.getCartCount();
      if (mounted) {
        setState(() {
          _cartCount = count;
        });
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2633) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Home', 0, isDark),
              _buildNavItem(Icons.category_outlined, 'Categories', 1, isDark),
              _buildNavItemWithBadge(Icons.shopping_cart_outlined, 'Cart', 2, isDark, _cartCount > 0 ? '$_cartCount' : null),
              _buildNavItem(Icons.favorite_outline, 'Wishlist', 3, isDark),
              _buildNavItem(Icons.person_outline, 'Profile', 4, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    IconData icon,
    String label,
    int index,
    bool isDark,
    String? badgeCount,
  ) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _loadCartCount();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade400),
              ),
              if (badgeCount != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _loadCartCount();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? AppColors.primary 
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}
