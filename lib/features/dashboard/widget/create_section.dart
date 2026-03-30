import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/presentation/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/presentation/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/features/presentation/purchase/view/create_purchase_order_page.dart';
import 'package:coreflow/features/presentation/sales/view/create_sales_order_page.dart';
import 'dashboard_widgets.dart';
import '../dashboard_view_model/dashboard_view_model.dart';

class CreateSection extends StatelessWidget {
  final DashboardViewModel vm;
  // final VoidCallback onPlay;

  const CreateSection({super.key, required this.vm}); //, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 11),

          DashboardSectionHeader(title: 'Create', onTap: () {}), //, onPlay: onPlay),
          const SizedBox(height: 10),

          GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              DashboardGridItem(
                icon: Icons.receipt_long_outlined,
                label: 'Sales Order',
                onTap: () => _openSalesOrder(context),
              ),
              DashboardGridItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Purchase',
                onTap: () => _openPurchaseOrder(context),
              ),
              DashboardGridItem(
                icon: Icons.payments_outlined,
                label: 'Payment',
                onTap: () => _openSendPayment(context),
              ),
              DashboardGridItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Received',
                onTap: () => _openReceivePayment(context),
              ),
              DashboardGridItem(
                icon: Icons.person_add_outlined,
                label: 'Customer',
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/customers/${vm.companyId}/add');
                  }
                },
              ),
              DashboardGridItem(
                icon: Icons.storefront_outlined,
                label: 'Vendor',
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/vendors/${vm.companyId}/add');
                  }
                },
              ),
              DashboardGridItem(
                icon: Icons.inventory_2_outlined,
                label: 'Item',
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/items/${vm.companyId}/add');
                  }
                },
              ),
            ],
          ),
        ],
    );
  }

  void _openSalesOrder(BuildContext context) {
    final companyId = vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSalesOrderPage(companyId: companyId),
      ),
    );
  }

  void _openPurchaseOrder(BuildContext context) {
    final companyId = vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePurchaseOrderPage(companyId: companyId),
      ),
    );
  }

  void _openSendPayment(BuildContext context) {
    final companyId = vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePaymentSentPage(companyId: companyId),
      ),
    );
  }

  void _openReceivePayment(BuildContext context) {
    final companyId = vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReceivePaymentPage(companyId: companyId),
      ),
    );
  }

  void _showSelectCompany(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: const Text('Please select a company first.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: LoginColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
