import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF101922).withOpacity(0.95)
                    : const Color(0xFFF6F7F8).withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'About Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Brand Section
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    Center(
                      child: Text(
                        'Vortex',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0D141B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Version
                    Center(
                      child: Text(
                        'Version 2.4.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // About Section
                    _buildSection(
                      title: 'Our Story',
                      content:
                          'Vortex is a leading e-commerce platform dedicated to providing customers with an exceptional shopping experience. Founded in 2020, we\'ve grown to serve millions of customers worldwide with our commitment to quality, affordability, and customer satisfaction.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: 'Our Mission',
                      content:
                          'To revolutionize online shopping by offering a seamless, secure, and personalized shopping experience that connects customers with products they love.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: 'Our Values',
                      content:
                          '• Customer First: Your satisfaction is our priority\n• Quality: Only the best products make it to our platform\n• Innovation: Constantly improving our services\n• Trust: Building lasting relationships through transparency\n• Sustainability: Committed to eco-friendly practices',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Stats Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatItem('5M+', 'Happy Customers', isDark),
                          const SizedBox(height: 16),
                          _buildStatItem('50K+', 'Products', isDark),
                          const SizedBox(height: 16),
                          _buildStatItem('100+', 'Countries', isDark),
                          const SizedBox(height: 16),
                          _buildStatItem('24/7', 'Customer Support', isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Social Media Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Follow Us',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0D141B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialIcon(Icons.facebook, isDark),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.camera_alt, isDark),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.mail, isDark),
                              const SizedBox(width: 12),
                              _buildSocialIcon(Icons.language, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Copyright
                    Center(
                      child: Text(
                        '© 2025 Vortex. All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D141B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}
