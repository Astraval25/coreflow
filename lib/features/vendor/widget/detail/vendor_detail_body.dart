import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_address_tile.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_financial_strip.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/features/customers/widget/detail/customer_info_tile.dart';

class VendorDetailBody extends StatefulWidget {
  final VendorsDetailData vendor;

  const VendorDetailBody({super.key, required this.vendor});

  @override
  State<VendorDetailBody> createState() => _VendorDetailBodyState();
}

class _VendorDetailBodyState extends State<VendorDetailBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorFinancialStrip(vendor: vendor),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
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

        Padding(
          padding: const EdgeInsets.fromLTRB(1, 1, 1, 2),
          child: _buildSelectedSection(vendor),
        ),
      ],
    );
  }

  Widget _buildTabText(String title, int index) {
    final isSelected = _selectedIndex == index;

    return TextButton(
      onPressed: () {
        setState(() => _selectedIndex = index);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
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
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
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
    );
  }

  Widget _buildSelectedSection(VendorsDetailData vendor) {
    switch (_selectedIndex) {
      case 0:
        return _BasicInfoSection(vendor: vendor);
      case 1:
        return _AddressSection(vendor: vendor);
      case 2:
        return _CompanySection(vendor: vendor);
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
  final VendorsDetailData vendor;

  const _BasicInfoSection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                value: vendor.email,
              ),
              CustomerInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: vendor.phone,
              ),
              CustomerInfoTile(
                icon: Icons.badge_outlined,
                label: 'PAN',
                value: vendor.pan,
              ),
              CustomerInfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'GST',
                value: vendor.gst,
              ),
              CustomerInfoTile(
                icon: Icons.language_rounded,
                label: 'Language',
                value: vendor.lang,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  final VendorsDetailData vendor;

  const _AddressSection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Address Details'),
        const Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VendorAddressTile(
                title: 'Billing address',
                address: vendor.billingAddress,
              ),
              if (vendor.shippingAddress != null)
                VendorAddressTile(
                  title: vendor.sameAsBillingAddress
                      ? 'Shipping address'
                      : 'Shipping address',
                  address: vendor.shippingAddress!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanySection extends StatelessWidget {
  final VendorsDetailData vendor;

  const _CompanySection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Company Details'),
        const Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomerInfoTile(
                icon: Icons.business_rounded,
                label: 'Company',
                value: vendor.company.companyName ?? '—',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
