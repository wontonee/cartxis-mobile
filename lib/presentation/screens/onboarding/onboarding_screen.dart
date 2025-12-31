import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:vortex_app/core/constants/app_sizes.dart';
import 'package:vortex_app/core/constants/app_strings.dart';
import 'package:vortex_app/core/theme/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Description,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjAU_2Ozb7daH2L0r9slCA0aed2zjrndnwrlxNN-cUkpr7zI90qqqXlo_l2l0aMkOH9AZy_Xg8c-kUeWjzNfty53liIeUz6N6nlV4lxNslE1mNqy4s1H7I4d5WAeVw41ndcubEnQ2iof6M0bBy3xDaoBP19gXy9v76H-A8H_uPvlEZsES7WfkFL_H2UtbTYa9HJU51gjcmvCUhq5iPxIeiiZgXnjfUbfIDcty1ruN6dUDoGpmaHI9QFLKt8bfpfuY4_whDrvHeG9ji',
    ),
    OnboardingData(
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Description,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD8WqJd0VHb3pjBKv5SOzJchiqy16O37kwRRG5DYLrNNUYl3ljf6vgLSFgA-xMk_PVH_ccrOOofmZMxAwt_EUvGC3Ccq5fFzkOIrBfKEiVWz1-PO1IFd4TADyr53ZU6sf1PTWF-3Q4m3_XI4XSpt_iaV9Gg0Udtry04Tz2R-zvg5TQ4HpntaWFs__T6HQ9ZY13SldZHEtQOiL-7F2GiLqT3WI-HiPzhvgdVoI2exSPJQV2YS6qIsbeOz3Yrw0ic9Sb8wajALOBcEHjB',
    ),
    OnboardingData(
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Description,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuByt1UpLex1YG87t0KlGL_BJTza9TwBwI-oAd5UPWaHbNewDmJhUYs-jT1LXnaTC-X7VlvBtwqMhDM-OHhFtJRV5jgUQlZ2y5jrYXC6YDR4pVSEJTSJTLzQFomN9Z02DuuJ7rflkLEa0fHR7VzshniUm1Wc3LTMlUnsVWyqFwKToxIMeHhfvOrpzyiOLM1NNXgf12vr5_zfKCtN7vCWA8dL4c1nHcBHkbMO0g5JwLyVY1zNWQcXHds4OVoUqk2eF0zIWioez1I--5gR',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _skip() {
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                  child: Text(
                    AppStrings.skip,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    isDark: isDark,
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.lg,
                right: AppSizes.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSizes.lg,
                top: AppSizes.md,
              ),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _PageIndicator(
                        isActive: index == _currentPage,
                        isDark: isDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? AppStrings.getStarted
                            : AppStrings.next,
                        style: AppTextStyles.button.copyWith(
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isDark;

  const _OnboardingPage({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Flexible(
            flex: 3,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 400,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                child: Stack(
                  children: [
                    Image.network(
                      data.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark 
                              ? AppColors.surfaceDark 
                              : AppColors.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.shopping_bag,
                              size: 100,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDark 
                                  ? Colors.black.withOpacity(0.1) 
                                  : Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Text Content
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.headline2.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final bool isDark;

  const _PageIndicator({
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : isDark 
                ? AppColors.darkDivider 
                : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
