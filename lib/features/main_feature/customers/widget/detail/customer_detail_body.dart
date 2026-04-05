import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_detail_sections.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_item_section.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_orders_payments_section.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_financial_strip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final vm = context.watch<CustomerDetailViewModel>();
    final isLinked = customer.customerCompany != null;

    return Column(
      children: [
        CustomerFinancialStrip(customer: customer),
        _buildLinkCompanyStrip(context, vm, isLinked),
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
                  _buildTabText('Transaction', 0),
                  _buildTabText('Items', 1),
                  _buildTabText('Address', 2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(_horizontal, 14, _horizontal, 120),
          child: Container(
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildSelectedSection(customer),
            ),
          ),
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
        backgroundColor: isSelected
            ? const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1)
            : const Color.fromARGB(0, 255, 255, 255),
        foregroundColor: const Color.fromARGB(
          0,
          255,
          255,
          255,
        ),
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
          const SizedBox(height: 1),
          AnimatedContainer(
            duration: Duration(milliseconds: 120),
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

  Widget _buildSelectedSection(CustomerDetailData customer) {
    switch (_selectedIndex) {
      case 0:
        return const CustomerOrdersPaymentsSection();
      case 1:
        return const CustomerItemSection();
      case 2:
        return CustomerAddressSection(customer: customer);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    CustomerDetailViewModel vm,
    bool isLinked,
  ) {
    if (isLinked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(_horizontal, 6, _horizontal, 0),
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LinkCompanySection(
          isLinked: false,
          isLoading: vm.isInvitationLoading,
          invitationCode: vm.invitationData?.invitationCode,
          onGenerateCode: () async {
            final response = await vm.sendInvitation();
            if (!context.mounted) return;
            if (response != null && !response.responseStatus) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(response.responseMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onGetExistingCode: () async {
            final response = await vm.getInvitationCode();
            if (!context.mounted) return;
            if (response == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('No existing invitation code found'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onAcceptCode: (code) async {
            final response = await vm.acceptInvitation(code);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    response?.responseStatus == true
                        ? 'Company linked successfully'
                        : response?.responseMessage ?? 'Failed to link company',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: response?.responseStatus == true
                      ? Colors.green
                      : Colors.red,
                ),
              );
            }
            return response?.responseStatus == true;
          },
        ),
      ),
    );
  }

}
