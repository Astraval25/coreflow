import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/features/customers/widget/detail/customer_address_tile.dart';
import 'package:coreflow/features/customers/widget/detail/customer_info_tile.dart';
import 'package:flutter/material.dart';

class CustomerSectionHeader extends StatelessWidget {
  final String title;

  const CustomerSectionHeader({
    super.key,
    required this.title,
  });

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

class CustomerBasicInfoSection extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerBasicInfoSection({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionHeader(title: 'Basic Information'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              CustomerInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: customer.email,
              ),
              CustomerInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: customer.phone,
              ),
              CustomerInfoTile(
                icon: Icons.badge_outlined,
                label: 'PAN',
                value: customer.pan,
              ),
              CustomerInfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'GST',
                value: customer.gst,
              ),
              CustomerInfoTile(
                icon: Icons.language_rounded,
                label: 'Language',
                value: customer.lang,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class CustomerAddressSection extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerAddressSection({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final Address? shippingToShow =
        (customer.sameAsBillingAddress || customer.shippingAddress == null)
        ? customer.billingAddress
        : customer.shippingAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionHeader(title: 'Address Details'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerAddressTile(
                title: 'Billing Address',
                address: customer.billingAddress,
              ),
              if (shippingToShow != null) ...[
                const SizedBox(height: 8),
                CustomerAddressTile(
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
