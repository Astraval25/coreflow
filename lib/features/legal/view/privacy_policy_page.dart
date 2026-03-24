import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: _buildAppBar(context),
      body: const _PrivacyPolicyBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Privacy Policy',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LoginColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginColors.borderLight, width: 1),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: LoginColors.textPrimary, size: 18),
        ),
        onPressed: () => _handleBack(context),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings');
    }
  }
}

class _PrivacyPolicyBody extends StatelessWidget {
  const _PrivacyPolicyBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            'Information We Collect',
            [
              'Account Information: When you create a CoreFlow account, we collect your name, email address, phone number, and company details.',
              'Business Data: We collect and store your business information including customer data, vendor information, inventory details, sales records, and payment information.',
              'Usage Information: We collect information about how you use our app, including features accessed, time spent, and interaction patterns.',
              'Device Information: We may collect device-specific information such as device model, operating system version, and unique device identifiers.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'How We Use Your Information',
            [
              'Provide Services: To deliver CoreFlow\'s business management features including inventory tracking, customer management, and financial reporting.',
              'Account Management: To create and maintain your account, authenticate users, and provide customer support.',
              'Business Analytics: To generate insights and reports about your business performance and help you make informed decisions.',
              'Communication: To send you important updates, notifications about your account, and respond to your inquiries.',
              'Improvement: To analyze usage patterns and improve our app\'s functionality and user experience.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Information Sharing',
            [
              'We do not sell, trade, or rent your personal information to third parties.',
              'Service Providers: We may share information with trusted third-party service providers who assist us in operating our app and providing services to you.',
              'Legal Requirements: We may disclose information when required by law, court order, or government request.',
              'Business Transfers: In the event of a merger, acquisition, or sale of assets, your information may be transferred as part of the transaction.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Data Security',
            [
              'We implement industry-standard security measures to protect your information from unauthorized access, alteration, disclosure, or destruction.',
              'All data transmission is encrypted using SSL/TLS protocols.',
              'We regularly update our security practices and conduct security audits.',
              'Access to your data is restricted to authorized personnel only.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Data Retention',
            [
              'We retain your information for as long as your account is active or as needed to provide you services.',
              'You may request deletion of your account and associated data at any time.',
              'Some information may be retained for legal compliance, fraud prevention, or legitimate business purposes.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Your Rights',
            [
              'Access: You can access and review your personal information stored in your CoreFlow account.',
              'Correction: You can update or correct your personal information through your account settings.',
              'Deletion: You can request deletion of your account and personal information.',
              'Portability: You can export your business data in standard formats.',
              'Opt-out: You can opt-out of non-essential communications.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Cookies and Tracking',
            [
              'We use cookies and similar technologies to enhance your experience and analyze app usage.',
              'You can control cookie preferences through your device settings.',
              'Some features may not function properly if cookies are disabled.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Third-Party Services',
            [
              'CoreFlow may integrate with third-party services for payment processing, analytics, and other features.',
              'These services have their own privacy policies, and we encourage you to review them.',
              'We are not responsible for the privacy practices of third-party services.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Children\'s Privacy',
            [
              'CoreFlow is not intended for use by children under 13 years of age.',
              'We do not knowingly collect personal information from children under 13.',
              'If we become aware of such collection, we will take steps to delete the information.',
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Changes to Privacy Policy',
            [
              'We may update this privacy policy from time to time.',
              'We will notify you of significant changes through the app or via email.',
              'Continued use of CoreFlow after changes constitutes acceptance of the updated policy.',
            ],
          ),
          const SizedBox(height: 20),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LoginColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.privacy_tip_rounded,
                  color: LoginColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 12,
              color: LoginColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This Privacy Policy explains how CoreFlow collects, uses, and protects your information when you use our business management application.',
            style: TextStyle(
              fontSize: 14,
              color: LoginColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: LoginColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: LoginColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LoginColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_support_rounded,
                  color: LoginColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you have any questions about this Privacy Policy or our data practices, please contact us:',
            style: TextStyle(
              fontSize: 14,
              color: LoginColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem(Icons.email_rounded, 'admin@astraval.com'),
          const SizedBox(height: 8),
          _buildContactItem(Icons.phone_rounded, '+91 9043368684'),
          const SizedBox(height: 8),
          _buildContactItem(Icons.location_on_rounded, 'BSNL Office Beside, Selvamaruthoor\nThisayanvilai, Tirnelveli TN 627657'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: LoginColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: LoginColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
