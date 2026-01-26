import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/features/customers/widget/detail/customer_financial_strip.dart';
import 'package:coreflow/features/customers/widget/detail/customer_info_tile.dart';
import 'package:coreflow/features/customers/widget/detail/customer_address_tile.dart';
import '../../../../domain/model/customer/customer_detail.dart';

class CustomerDetailBody extends StatefulWidget {
  final CustomerDetailData customer;

  const CustomerDetailBody({super.key, required this.customer});

  @override
  State<CustomerDetailBody> createState() => _CustomerDetailBodyState();
}

class _CustomerDetailBodyState extends State<CustomerDetailBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return Column(
      children: [
        CustomerFinancialStrip(customer: customer),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabText('Basic Info', 0),
              _buildTabText('Address', 1),
              _buildTabText('Company', 2),
            ],
          ),
        ),

        const Divider(height: 1, color: LoginColors.border),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
            child: _buildSelectedSection(customer),
          ),
        ),
      ],
    );
  }

  Widget _buildTabText(String title, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? LoginColors.primaryDark
                    : LoginColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 44 : 0,
              decoration: BoxDecoration(
                color: LoginColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSection(CustomerDetailData customer) {
    switch (_selectedIndex) {
      case 0:
        return _BasicInfoSection(customer: customer);
      case 1:
        return _AddressSection(customer: customer);
      case 2:
        return _CompanySection(customer: customer);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: LoginColors.textPrimary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  final CustomerDetailData customer;

  const _BasicInfoSection({required this.customer});

  @override
  Widget build(BuildContext context) {
    Text(
      'Customer Details',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   border: Border.all(color: LoginColors.border),
      //   boxShadow: [
      //     BoxShadow(
      //       color: LoginColors.shadowLight.withOpacity(0.08),
      //       blurRadius: 10,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Basic Information'),
          const Divider(height: 1, thickness: 1, color: LoginColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                CustomerInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: customer.email,
                  valueColor: customer.email?.trim().isNotEmpty == true
                      ? LoginColors.textPrimary
                      : null,
                ),
                CustomerInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: customer.phone,
                  valueColor: customer.phone?.trim().isNotEmpty == true
                      ? LoginColors.textPrimary
                      : null,
                ),
                CustomerInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'PAN',
                  value: customer.pan,
                  valueColor: customer.pan?.trim().isNotEmpty == true
                      ? LoginColors.textPrimary
                      : null,
                ),
                CustomerInfoTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'GST',
                  value: customer.gst,
                  valueColor: customer.gst?.trim().isNotEmpty == true
                      ? LoginColors.textPrimary
                      : null,
                ),
                CustomerInfoTile(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  value: customer.lang,
                  valueColor: customer.lang?.trim().isNotEmpty == true
                      ? LoginColors.textPrimary
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  final CustomerDetailData customer;

  const _AddressSection({required this.customer});

  @override
  Widget build(BuildContext context) {
    // Decide which address to show as shipping
    final Address? shippingToShow =
        (customer.sameAsBillingAddress || customer.shippingAddress == null)
        ? customer.billingAddress
        : customer.shippingAddress;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Address Details'),
          const Divider(height: 1, thickness: 1, color: LoginColors.border),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Billing address
                CustomerAddressTile(
                  title: 'Billing address',
                  address: customer.billingAddress,
                ),

                if (shippingToShow != null) ...[
                  const SizedBox(height: 28),
                  CustomerAddressTile(
                    title: customer.sameAsBillingAddress
                        ? 'Shipping address'
                        : 'Shipping address',
                    address: shippingToShow,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  final CustomerDetailData customer;

  const _CompanySection({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Company Details'),
          const Divider(height: 1, thickness: 1, color: LoginColors.border),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerInfoTile(
                  icon: Icons.business_rounded,
                  label: 'Company',
                  value: customer.company.companyName ?? '—',
                  valueColor: customer.company.companyName != null
                      ? LoginColors.textPrimary
                      : null,
                ),
                if (customer.customerCompany != null) ...[
                  CustomerInfoTile(
                    label: 'Customer company ID',
                    value: customer.customerCompany!.companyId.toString(),
                    valueColor: LoginColors.textPrimary,
                  ),
                  CustomerInfoTile(
                    label: 'Customer company name',
                    value: customer.customerCompany!.companyName ?? '—',
                    valueColor: customer.customerCompany!.companyName != null
                        ? LoginColors.textPrimary
                        : null,
                  ),
                ] else
                  CustomerInfoTile(label: 'Customer company name', value: '—'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
