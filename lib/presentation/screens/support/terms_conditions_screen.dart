import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
                      'Terms & Conditions',
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
                    Text(
                      'Last Updated: December 27, 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: '1. Acceptance of Terms',
                      content:
                          'By accessing and using Vortex, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '2. Use License',
                      content:
                          'Permission is granted to temporarily download one copy of the materials on Vortex\'s app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to decompile or reverse engineer any software\n• Remove any copyright or proprietary notations\n• Transfer the materials to another person',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '3. Account Terms',
                      content:
                          'You are responsible for maintaining the security of your account and password. Vortex cannot and will not be liable for any loss or damage from your failure to comply with this security obligation.\n\nYou must provide accurate and complete information when creating your account. You are fully responsible for all activities that occur under your account.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '4. Products and Services',
                      content:
                          'All products and services are subject to availability. We reserve the right to discontinue any product at any time. Prices for our products are subject to change without notice.\n\nWe reserve the right to refuse service to anyone for any reason at any time.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '5. Order Processing',
                      content:
                          'We reserve the right to refuse or cancel your order at any time for reasons including but not limited to: product or service availability, errors in the description or price of the product or service, error in your order, or other reasons.\n\nIf we cancel your order, we will notify you by email and refund any payment you have made.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '6. Payment Terms',
                      content:
                          'Payment is due at the time of purchase. We accept various payment methods as displayed during checkout. You agree to provide current, complete, and accurate purchase and account information.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '7. Shipping and Delivery',
                      content:
                          'We will make every effort to deliver your order within the estimated time frame. However, we are not responsible for delays caused by circumstances beyond our control.\n\nTitle and risk of loss pass to you upon delivery to the carrier.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '8. Returns and Refunds',
                      content:
                          'Our return policy allows returns within 30 days of purchase. Items must be unused and in their original packaging. Please refer to our full Return Policy for detailed information.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '9. Limitation of Liability',
                      content:
                          'In no event shall Vortex or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use Vortex.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '10. Governing Law',
                      content:
                          'These terms and conditions are governed by and construed in accordance with the laws and you irrevocably submit to the exclusive jurisdiction of the courts.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '11. Changes to Terms',
                      content:
                          'We reserve the right to revise these terms at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms and conditions.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '12. Contact Information',
                      content:
                          'If you have any questions about these Terms and Conditions, please contact us at:\n\nEmail: legal@vortex.com\nPhone: +1 (800) 123-4567',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Acceptance Checkbox (for reference)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE8F4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFF137FEC).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF137FEC),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'By using Vortex, you acknowledge that you have read and understood these Terms and Conditions.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D141B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
