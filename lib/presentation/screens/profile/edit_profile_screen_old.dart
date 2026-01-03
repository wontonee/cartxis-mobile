import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/network/api_exception.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = await _authService.getProfile();
      
      if (mounted) {
        setState(() {
          _user = user;
          
          // Parse first name and last name from full name
          final nameParts = user.name.split(' ');
          _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
          _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
          
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          _selectedGender = user.gender;
          
          // Parse date of birth if available
          if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(user.dateOfBirth!);
            } catch (e) {
            }
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Failed to load profile';
        if (e is ApiException) {
          errorMessage = e.message;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1F2937) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_firstNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter first name')),
        );
        return;
      }
      if (_lastNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter last name')),
        );
        return;
      }

      // Validate password fields if any are filled
      if (_currentPasswordController.text.isNotEmpty ||
          _newPasswordController.text.isNotEmpty ||
          _confirmPasswordController.text.isNotEmpty) {
        if (_currentPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter current password')),
          );
          return;
        }
        if (_newPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter new password')),
          );
          return;
        }
        if (_newPasswordController.text.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Password must be at least 8 characters long')),
          );
          return;
        }
        if (_newPasswordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }
      }

      try {
        setState(() {
          _isSaving = true;
        });

        // Format date of birth if available
        String? dateOfBirth;
        if (_selectedDate != null) {
          dateOfBirth = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        }

        // Update profile
        final updatedUser = await _authService.updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          dateOfBirth: dateOfBirth,
          gender: _selectedGender,
        );

        if (mounted) {
          setState(() {
            _isSaving = false;
            _user = updatedUser;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to profile screen
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          String errorMessage = 'Failed to update profile';
          if (e is ApiException) {
            errorMessage = e.message;
            if (e.errors != null) {
              final errors = e.errors!.values.map((e) => e.join(', ')).join('\n');
              errorMessage = '$errorMessage\n$errors';
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72), // Spacer to balance Cancel button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photo Section
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF1F2937)
                                            : Colors.white,
                                        width: 4,
                                      ),
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://avatar.iran.liara.run/public/girl',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF1F2937)
                                              : Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Photo picker coming soon')),
                                  );
                                },
                                child: Text(
                                  'Change Photo',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Personal Information Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 16),
                              child: Text(
                                'PERSONAL INFORMATION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Container(
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
                                  // First Name
                                  _buildTextField(
                                    label: 'First Name',
                                    controller: _firstNameController,
                                    isDark: isDark,
                                    isFirst: true,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Last Name
                                  _buildTextField(
                                    label: 'Last Name',
                                    controller: _lastNameController,
                                    isDark: isDark,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Email (Read-only)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF111827).withOpacity(0.3)
                                          : const Color(0xFFF9FAFB).withOpacity(0.5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? const Color(0xFF9CA3AF)
                                                    : const Color(0xFF6B7280),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _emailController.text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDark
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Phone
                                  _buildTextField(
                                    label: 'Phone',
                                    controller: _phoneController,
                                    isDark: isDark,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Date of Birth
                                  InkWell(
                                    onTap: _selectDate,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date of Birth',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedDate != null
                                                    ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                                                    : 'Select date',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _selectedDate != null
                                                      ? (isDark ? Colors.white : const Color(0xFF0D141B))
                                                      : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                                                ),
                                              ),
                                              Icon(
                                                Icons.calendar_month,
                                                color: isDark
                                                    ? const Color(0xFF9CA3AF)
                                                    : const Color(0xFF6B7280),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Gender
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: _selectedGender,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          hint: Text(
                                            'Select gender',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark
                                                  ? const Color(0xFF6B7280)
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.expand_more,
                                            color: isDark
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF6B7280),
                                          ),
                                          dropdownColor: isDark
                                              ? const Color(0xFF1F2937)
                                              : Colors.white,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0D141B),
                                          ),
                                          items: ['male', 'female', 'other']
                                              .map((gender) =>
                                                  DropdownMenuItem<String>(
                                                    value: gender,
                                                    child: Text(gender[0].toUpperCase() + gender.substring(1)),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedGender = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Change Password Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 16),
                              child: Text(
                                'CHANGE PASSWORD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Container(
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
                                  // Current Password
                                  _buildPasswordField(
                                    label: 'Current Password',
                                    controller: _currentPasswordController,
                                    obscureText: _obscureCurrentPassword,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureCurrentPassword =
                                            !_obscureCurrentPassword;
                                      });
                                    },
                                    isDark: isDark,
                                    isFirst: true,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // New Password
                                  _buildPasswordField(
                                    label: 'New Password',
                                    controller: _newPasswordController,
                                    obscureText: _obscureNewPassword,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureNewPassword = !_obscureNewPassword;
                                      });
                                    },
                                    isDark: isDark,
                                    placeholder: 'Enter new password',
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                  ),

                                  // Confirm Password
                                  _buildPasswordField(
                                    label: 'Confirm Password',
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    isDark: isDark,
                                    placeholder: 'Re-enter new password',
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 12),
                              child: Text(
                                'Password must be at least 8 characters long and include special characters.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Space for sticky button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Sticky Footer Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    TextInputType? keyboardType,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0D141B),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: 'Enter your $label',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isDark,
    String placeholder = '••••••••',
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0D141B),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
