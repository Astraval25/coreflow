import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerBottomOptionsPanel extends StatefulWidget {
  final CustomerDetailViewModel vm;
  final CustomerDetailData customer;

  const CustomerBottomOptionsPanel({
    super.key,
    required this.vm,
    required this.customer,
  });

  @override
  State<CustomerBottomOptionsPanel> createState() =>
      _CustomerBottomOptionsPanelState();
}

class _CustomerBottomOptionsPanelState
    extends State<CustomerBottomOptionsPanel> {

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final customer = widget.customer;

    return Material(
      color: LoginColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          border: Border.all(color: LoginColors.borderLight),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                // decoration: BoxDecoration(
                //   color: LoginColors.textSecondary.withValues(alpha: 0.3),
                //   borderRadius: BorderRadius.circular(2),
                // ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.receipt_long_rounded,
                      label: 'Create Sale',
                      color: LoginColors.primary,
                      onTap: () => context.push(
                        CfRoutes.salesCreate(vm.companyId),
                        extra: {
                          'preSelectedCustomer': {
                            'customerId': customer.customerId,
                            'displayName': customer.customerName,
                            'customerCompanyName':
                                customer.customerCompany?.companyName ?? '',
                            'customerCompanyId':
                                customer.customerCompany?.companyId,
                            'email': customer.email,
                            'isActive': customer.isActive,
                            'dueAmount': '',
                          },
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'New Payment',
                      color: LoginColors.success,
                      onTap: () => context.push(
                        CfRoutes.paymentReceivedCreate(vm.companyId),
                        extra: {
                          'preSelectedCustomer': {
                            'customerId': customer.customerId,
                            'displayName': customer.customerName,
                            'customerCompanyName':
                                customer.customerCompany?.companyName ?? '',
                            'customerCompanyId':
                                customer.customerCompany?.companyId,
                            'email': customer.email,
                            'isActive': customer.isActive,
                            'dueAmount': '',
                          },
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
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
    );
  }
}
