import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/features/customers/widget/detail/body/customer_detail_sections.dart';
import 'package:coreflow/features/customers/widget/detail/body/customer_item_section.dart';
import 'package:coreflow/features/customers/widget/detail/customer_financial_strip.dart';
import 'package:flutter/material.dart';

class CustomerDetailBody extends StatefulWidget {
  final CustomerDetailData customer;

  const CustomerDetailBody({super.key, required this.customer});

  @override
  State<CustomerDetailBody> createState() => _CustomerDetailBodyState();
}

class _CustomerDetailBodyState extends State<CustomerDetailBody> {
  int _selectedIndex = 0;
  static const double _horizontal = 20;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return Column(
      children: [
        CustomerFinancialStrip(customer: customer),
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
            ),
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
        return CustomerBasicInfoSection(customer: customer);
      case 1:
        return const CustomerItemSection();
      case 2:
        return CustomerAddressSection(customer: customer);
      case 3:
        return CustomerCompanySection(customer: customer);
      default:
        return const SizedBox.shrink();
    }
  }
}
