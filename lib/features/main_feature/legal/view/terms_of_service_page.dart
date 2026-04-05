import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: _buildAppBar(context),
      body: const _TermsOfServiceBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Terms of Service',
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
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: LoginColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () => _handleBack(context),
      ),
    );
  }

  void _handleBack(BuildContext context) async {
    if (context.canPop()) {
      context.pop();
    } else {
      final authData = await TokenStorage.getFullAuthData();
      final userId = int.tryParse(authData?['userId']?.toString() ?? '');
      if (userId != null && context.mounted) context.go(CfRoutes.settings(userId));
    }
  }
}

class _TermsOfServiceBody extends StatelessWidget {
  const _TermsOfServiceBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection('Acceptance of Terms', [
            'By downloading, installing, or using CoreFlow, you agree to be bound by these Terms of Service.',
            'If you do not agree to these terms, please do not use our application.',
            'These terms constitute a legally binding agreement between you and CoreFlow.',
            'We may update these terms from time to time, and your continued use constitutes acceptance of any changes.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Description of Service', [
            'CoreFlow is a comprehensive business management application designed to help businesses manage their operations.',
            'Our services include but are not limited to: inventory management, customer relationship management, vendor management, sales tracking, payment processing, and business analytics.',
            'We provide cloud-based storage and synchronization of your business data across multiple devices.',
            'The service is provided "as is" and we reserve the right to modify or discontinue features at any time.',
          ]),
          const SizedBox(height: 20),
          _buildSection('User Accounts and Registration', [
            'You must create an account to use CoreFlow\'s services.',
            'You are responsible for maintaining the confidentiality of your account credentials.',
            'You must provide accurate and complete information during registration.',
            'You are responsible for all activities that occur under your account.',
            'You must notify us immediately of any unauthorized use of your account.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Acceptable Use Policy', [
            'You may use CoreFlow only for lawful business purposes.',
            'You agree not to use the service to store or transmit illegal, harmful, or offensive content.',
            'You will not attempt to gain unauthorized access to our systems or other users\' accounts.',
            'You will not use the service to spam, harass, or harm others.',
            'You will not reverse engineer, decompile, or attempt to extract source code from our application.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Data Ownership and Usage Rights', [
            'You retain ownership of all data you input into CoreFlow.',
            'You grant us a license to use your data solely to provide our services to you.',
            'We will not access, use, or disclose your data except as necessary to provide services or as required by law.',
            'You are responsible for backing up your important data.',
            'You may export your data at any time in standard formats.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Payment Terms', [
            'CoreFlow offers both free and paid subscription plans.',
            'Paid subscriptions are billed in advance on a monthly or annual basis.',
            'All fees are non-refundable except as required by law.',
            'We reserve the right to change our pricing with 30 days\' notice.',
            'Failure to pay may result in suspension or termination of your account.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Intellectual Property Rights', [
            'CoreFlow and all related trademarks, logos, and intellectual property are owned by us.',
            'You are granted a limited, non-exclusive license to use the application.',
            'You may not copy, modify, distribute, or create derivative works of our software.',
            'Any feedback or suggestions you provide may be used by us without compensation.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Privacy and Data Protection', [
            'Your privacy is important to us. Please review our Privacy Policy for details on how we collect and use your information.',
            'We implement appropriate security measures to protect your data.',
            'We comply with applicable data protection laws and regulations.',
            'You have rights regarding your personal data as outlined in our Privacy Policy.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Service Availability and Support', [
            'We strive to maintain high service availability but cannot guarantee 100% uptime.',
            'We may perform maintenance that temporarily affects service availability.',
            'Support is provided through our designated channels during business hours.',
            'We reserve the right to limit support based on your subscription level.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Limitation of Liability', [
            'CoreFlow is provided "as is" without warranties of any kind.',
            'We are not liable for any indirect, incidental, or consequential damages.',
            'Our total liability is limited to the amount you paid for the service in the past 12 months.',
            'Some jurisdictions do not allow limitation of liability, so these limits may not apply to you.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Termination', [
            'You may terminate your account at any time through your account settings.',
            'We may terminate or suspend your account for violation of these terms.',
            'Upon termination, your access to the service will cease immediately.',
            'You may request a copy of your data within 30 days of termination.',
          ]),
          const SizedBox(height: 20),
          _buildSection('Dispute Resolution', [
            'Any disputes will be resolved through binding arbitration rather than court proceedings.',
            'Arbitration will be conducted under the rules of the American Arbitration Association.',
            'You waive your right to participate in class action lawsuits.',
            'These terms are governed by the laws of [Your Jurisdiction].',
          ]),
          const SizedBox(height: 20),
          _buildSection('Miscellaneous', [
            'If any provision of these terms is found unenforceable, the remaining provisions will remain in effect.',
            'Our failure to enforce any right or provision does not constitute a waiver.',
            'These terms constitute the entire agreement between you and CoreFlow.',
            'We may assign our rights and obligations under these terms to third parties.',
          ]),
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
                  color: LoginColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: LoginColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Terms of Service',
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
            'Effective date: ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 12,
              color: LoginColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These Terms of Service govern your use of CoreFlow and constitute a binding legal agreement between you and CoreFlow. Please read them carefully.',
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
          ...content.map(
            (item) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.primary.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LoginColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LoginColors.primary.withValues(alpha: 0.1),
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
                'Questions About These Terms?',
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
            'If you have any questions about these Terms of Service, please contact us:',
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
          _buildContactItem(
            Icons.location_on_rounded,
            'BSNL Office Beside, Selvamaruthoor\nThisayanvilai, Tirnelveli TN 627657',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: LoginColors.primary),
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
