import 'package:flutter/material.dart';

import 'package:coreflow/features/customers/widget/detail/customer_header.dart';
import 'package:coreflow/features/customers/widget/detail/customer_financial_strip.dart';
import 'package:coreflow/features/customers/widget/detail/customer_info_tile.dart';
import 'package:coreflow/features/customers/widget/detail/customer_address_tile.dart';

import '../../../../domain/model/customer/customer_detail.dart';

class CustomerDetailBody extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerDetailBody({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 16),
          CustomerHeader(customer: customer),
          const SizedBox(height: 12),
          CustomerFinancialStrip(customer: customer),

          const SizedBox(height: 16),

          _SectionExpansion(
            title: 'Basic information',
            children: [
              if (customer.email != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: customer.email,
                ),
              ],
              if (customer.phone != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: customer.phone,
                ),
              ],
              if (customer.pan != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(label: 'PAN', value: customer.pan),
              ],
              if (customer.gst != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(label: 'GST', value: customer.gst),
              ],
              if (customer.lang != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(label: 'Language', value: customer.lang),
              ],
            ],
          ),

          _SectionExpansion(
            title: 'Address',
            children: [
              CustomerInfoTile(
                label: 'Same as billing',
                value: customer.sameAsBillingAddress ? 'Yes' : 'No',
              ),
              const Divider(height: 1),
              CustomerAddressTile(
                title: 'Billing address',
                address: customer.billingAddress,
              ),
              if (customer.shippingAddress != null &&
                  !customer.sameAsBillingAddress) ...[
                const Divider(height: 1),
                CustomerAddressTile(
                  title: 'Shipping address',
                  address: customer.shippingAddress,
                ),
              ],
            ],
          ),

          _SectionExpansion(
            title: 'Company',
            children: [
              CustomerInfoTile(
                icon: Icons.business_rounded,
                label: 'Company',
                value: customer.company.companyName,
              ),
              if (customer.customerCompany != null) ...[
                const Divider(height: 1),
                CustomerInfoTile(
                  label: 'Customer company ID',
                  value: customer.customerCompany!.companyId.toString(),
                ),
                const Divider(height: 1),
                CustomerInfoTile(
                  label: 'Customer company name',
                  value: customer.customerCompany!.companyName ?? '—',
                ),
              ],
            ],
          ),

          _SectionExpansion(
            title: 'Audit',
            children: [
              CustomerInfoTile(
                icon: Icons.person_add_rounded,
                label: 'Created by',
                value: customer.createdBy.toString(),
              ),
              const Divider(height: 1),
              CustomerInfoTile(label: 'Created on', value: customer.createdDt),
              const Divider(height: 1),
              CustomerInfoTile(
                icon: Icons.edit_note_rounded,
                label: 'Last modified by',
                value: customer.lastModifiedBy.toString(),
              ),
              const Divider(height: 1),
              CustomerInfoTile(
                label: 'Last modified on',
                value: customer.lastModifiedDt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionExpansion extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionExpansion({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        children: children,
      ),
    );
  }
}
