import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                      'Privacy Policy',
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
                      'Effective Date: December 27, 2025',
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
                      title: 'Introduction',
                      content:
                          'At Vortex, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '1. Information We Collect',
                      content:
                          'We may collect information about you in a variety of ways:\n\nPersonal Data:\n• Name, email address, and contact information\n• Billing and shipping addresses\n• Phone number\n• Payment information (processed securely)\n\nUsage Data:\n• Device information and unique identifiers\n• Log data and analytics\n• Location data (with your permission)\n• Browsing history and preferences\n• Purchase history',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '2. How We Use Your Information',
                      content:
                          'We use the information we collect to:\n\n• Process and fulfill your orders\n• Send you order confirmations and updates\n• Improve our services and user experience\n• Personalize your shopping experience\n• Send promotional communications (with consent)\n• Respond to customer service requests\n• Detect and prevent fraud\n• Comply with legal obligations',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '3. Disclosure of Your Information',
                      content:
                          'We may share information we have collected about you in certain situations:\n\nWith Service Providers:\nWe share information with third-party service providers who perform services on our behalf, such as payment processing, shipping, and analytics.\n\nFor Business Transfers:\nWe may share or transfer your information in connection with a merger, sale, or acquisition.\n\nWith Your Consent:\nWe may disclose your information for any other purpose with your consent.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '4. Data Security',
                      content:
                          'We use administrative, technical, and physical security measures to protect your personal information. However, no security system is impenetrable, and we cannot guarantee the security of our systems 100%.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '5. Your Privacy Rights',
                      content:
                          'Depending on your location, you may have certain rights regarding your personal information:\n\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Request restriction of processing\n• Data portability\n• Withdraw consent',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '6. Cookies and Tracking Technologies',
                      content:
                          'We use cookies and similar tracking technologies to track activity and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '7. Third-Party Links',
                      content:
                          'Our app may contain links to third-party websites. We are not responsible for the privacy practices or content of these third-party sites. We encourage you to read their privacy policies.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '8. Children\'s Privacy',
                      content:
                          'Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child, please contact us.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '9. Data Retention',
                      content:
                          'We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '10. International Data Transfers',
                      content:
                          'Your information may be transferred to and maintained on computers located outside of your state or country where data protection laws may differ. By using our service, you consent to this transfer.',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '11. Updates to This Policy',
                      content:
                          'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Effective Date."',
                      isDark: isDark,
                    ),

                    _buildSection(
                      title: '12. Contact Us',
                      content:
                          'If you have questions or comments about this Privacy Policy, please contact us at:\n\nEmail: privacy@vortex.com\nPhone: +1 (800) 123-4567\nAddress: 123 Commerce Street, San Francisco, CA 94102',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Privacy Notice Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFFCD34D),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your privacy is important to us. We are committed to protecting your personal information and being transparent about our data practices.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF78350F),
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
