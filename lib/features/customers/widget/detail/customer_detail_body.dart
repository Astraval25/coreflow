import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/features/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/customers/widget/detail/body/customer_detail_sections.dart';
import 'package:coreflow/features/customers/widget/detail/body/customer_item_section.dart';
import 'package:coreflow/features/customers/widget/detail/customer_financial_strip.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        _buildQuickActions(context),
        _buildLinkCompanyStrip(context, vm, customer, isLinked),
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
            : const Color.fromARGB(0, 255, 255, 255), // background on select
        foregroundColor: const Color.fromARGB(
          0,
          255,
          255,
          255,
        ), // keep text color controlled manually
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
        return CustomerBasicInfoSection(customer: customer);
      case 1:
        return const CustomerItemSection();
      case 2:
        return CustomerAddressSection(customer: customer);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final vm = context.read<CustomerDetailViewModel>();
    final customer = widget.customer;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(_horizontal, 6, _horizontal, 0),
      child: Row(
        children: [
          _buildActionButton(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'Create Sale',
            color: LoginColors.primary,
            onTap: () => context.push(
              CfRoutes.salesCreate(vm.companyId),
              extra: {
                'preSelectedCustomer': {
                  'customerId': customer.customerId,
                  'displayName': customer.customerName,
                  'customerCompanyName': customer.customerCompany?.companyName ?? '',
                  'customerCompanyId': customer.customerCompany?.companyId,
                  'email': customer.email,
                  'isActive': customer.isActive,
                  'dueAmount': '',
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Receive Payment',
            color: LoginColors.success,
            onTap: () => context.push(
              CfRoutes.paymentReceivedCreate(vm.companyId),
              extra: {
                'preSelectedCustomer': {
                  'customerId': customer.customerId,
                  'displayName': customer.customerName,
                  'customerCompanyName': customer.customerCompany?.companyName ?? '',
                  'customerCompanyId': customer.customerCompany?.companyId,
                  'email': customer.email,
                  'isActive': customer.isActive,
                  'dueAmount': '',
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    CustomerDetailViewModel vm,
    CustomerDetailData customer,
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
              color: LoginColors.shadowLight.withValues(alpha:0.07),
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
            if (context.mounted && response != null && !response.responseStatus) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text(response.responseMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onGetExistingCode: () async {
            final response = await vm.getInvitationCode();
            if (context.mounted && response == null) {
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
                  duration: Duration(seconds: 2),
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
