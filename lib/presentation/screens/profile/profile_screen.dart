import 'package:flutter/material.dart';
import 'package:vortex_app/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vortex_app/data/services/auth_service.dart';
import 'package:vortex_app/data/models/user_model.dart';
import 'package:vortex_app/core/network/api_client.dart';
import 'package:vortex_app/core/network/api_exception.dart';
import 'package:vortex_app/core/config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  final _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('DEBUG: Loading user profile...');
      final user = await _authService.getProfile();
      print('DEBUG: Profile loaded successfully!');
      print('DEBUG: Name: ${user.name}');
      print('DEBUG: Email: ${user.email}');  
      print('DEBUG: Avatar: ${user.avatar}');
      print('DEBUG: AvatarUrl: ${user.avatarUrl}');
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('DEBUG: Profile loading error: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Failed to load profile: $e';
        if (e is ApiException) {
          errorMessage = 'API Error: ${e.message}\nCode: ${e.code}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    // In a real app, this would trigger a theme change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode ${value ? 'enabled' : 'disabled'}. Restart app to apply.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Clear auth data using auth service
      await _authService.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showComingSoon('More options'),
                      icon: const Icon(Icons.more_vert),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                              // Avatar with Edit Button
                              Stack(
                                children: [
                                  Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: _user?.avatarUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                '${_user!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: _user?.avatarUrl == null ? AppColors.primary : null,
                                    ),
                                    child: _user?.avatarUrl == null
                                        ? Center(
                                            child: Text(
                                              _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                          ],
                        ),
                              const SizedBox(height: 16),

                              // Name and Email
                              Text(
                                _user?.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              if (_user?.phone != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _user!.phone!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),

                              // Edit Profile Button
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(context, '/edit-profile');
                                  // Reload profile if changes were made
                                  if (result == true && mounted) {
                                    _loadUserProfile();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 4,
                                  shadowColor: AppColors.primary.withOpacity(0.3),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Account Section
                        _buildSectionHeader('ACCOUNT', isDark),
                        _buildMenuItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'My Orders',
                          onTap: () => Navigator.pushNamed(context, '/order-list'),
                          isDark: isDark,
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Addresses',
                          onTap: () => Navigator.pushNamed(context, '/address-management'),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Support Section
                        _buildSectionHeader('SUPPORT', isDark),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () => Navigator.pushNamed(context, '/help-support'),
                          isDark: isDark,
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About Us',
                          onTap: () => Navigator.pushNamed(context, '/about-us'),
                          isDark: isDark,
                        ),
                        _buildMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: () => Navigator.pushNamed(context, '/terms-conditions'),
                          isDark: isDark,
                        ),
                        _buildMenuItem(
                          icon: Icons.security_outlined,
                          title: 'Privacy Policy',
                          onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                          isDark: isDark,
                        ),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _logout,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                    backgroundColor: AppColors.primary.withOpacity(0.05),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Version 2.4.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
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
            ],
          ),
        );
      }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: (isDark ? Colors.white : const Color(0xFF0F172A)).withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}
