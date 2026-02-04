import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_address_tile.dart';
import 'package:coreflow/features/vendor/widget/detail/body/vendor_item_section.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_financial_strip.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_info_tile.dart';

class VendorDetailBody extends StatefulWidget {
  final VendorsDetailData vendor;

  const VendorDetailBody({super.key, required this.vendor});

  @override
  State<VendorDetailBody> createState() => _VendorDetailBodyState();
}

class _VendorDetailBodyState extends State<VendorDetailBody> {
  int _selectedIndex = 0;
  static const double _horizontal = 20;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorFinancialStrip(vendor: vendor),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabText('Basic Info', 0),
                  _buildTabText('Items', 1),
                  _buildTabText('Address', 2),
                  _buildTabText('Company', 3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(_horizontal, 14, _horizontal, 32),
          child: Container(
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LoginColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.shadowLight.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildSelectedSection(vendor),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSection(VendorsDetailData vendor) {
    switch (_selectedIndex) {
      case 0:
        return _BasicInfoSection(vendor: vendor);
      case 1:
        return const VendorItemSection();
      case 2:
        return _AddressSection(vendor: vendor);
      case 3:
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
            style: TextStyle(
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
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              VendorInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: vendor.email,
              ),
              VendorInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: vendor.phone,
              ),
              VendorInfoTile(
                icon: Icons.badge_outlined,
                label: 'PAN',
                value: vendor.pan,
              ),
              VendorInfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'GST',
                value: vendor.gst,
              ),
              VendorInfoTile(
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
    final Address? shippingToShow =
        (vendor.sameAsBillingAddress || vendor.shippingAddress == null)
        ? vendor.billingAddress
        : vendor.shippingAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Address Details'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VendorAddressTile(
                title: 'Billing Address',
                address: vendor.billingAddress,
              ),
              if (shippingToShow != null) ...[
                const SizedBox(height: 8),
                VendorAddressTile(
                  title: 'Shipping Address',
                  address: shippingToShow,
                ),
              ],
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
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VendorInfoTile(
                icon: Icons.business_rounded,
                label: 'Company',
                value: vendor.company.companyName,
              ),
              if (vendor.vendorCompany != null) ...[
                VendorInfoTile(
                  label: 'Vendor Company ID',
                  value: vendor.vendorCompany!.companyId?.toString() ?? '—',
                ),
                VendorInfoTile(
                  label: 'Vendor Company Name',
                  value: vendor.vendorCompany!.companyName ?? '—',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
