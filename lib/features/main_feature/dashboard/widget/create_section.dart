import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/main_feature/history/view/history_page.dart';
import 'package:coreflow/features/main_feature/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/features/main_feature/purchase/view/create_purchase_order_page.dart';
import 'package:coreflow/features/main_feature/sales/view/create_sales_order_page.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_view_model/dashboard_view_model.dart';
import 'dashboard_widgets.dart';

class CreateSection extends StatefulWidget {
  final DashboardViewModel vm;

  const CreateSection({super.key, required this.vm});

  @override
  State<CreateSection> createState() => _CreateSectionState();
}

class _CreateSectionState extends State<CreateSection> {
  static const int _firstRowCount = 4;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    final firstRow = items.take(_firstRowCount).toList();
    final rest = items.skip(_firstRowCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 11),
        DashboardSectionHeader(
          title: 'Create',
          onTap: () {},
          trailing: rest.isNotEmpty
              ? TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(_expanded ? 'Show less' : 'Show more'),
                )
              : null,
        ),
        const SizedBox(height: 5),
        _buildGrid(firstRow),
        if (rest.isNotEmpty) ...[
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildGrid(rest),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ],
    );
  }

  Widget _buildGrid(List<DashboardGridItem> children) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: children,
    );
  }

  List<DashboardGridItem> _items(BuildContext context) {
    return [
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
          final companyId = widget.vm.companyId;
          if (companyId == null) {
            _showSelectCompany(context);
            return;
          }
          context.push(CfRoutes.customerCreate(companyId));
        },
      ),
      DashboardGridItem(
        icon: Icons.storefront_outlined,
        label: 'Vendor',
        onTap: () {
          final companyId = widget.vm.companyId;
          if (companyId == null) {
            _showSelectCompany(context);
            return;
          }
          context.push(CfRoutes.vendorCreate(companyId));
        },
      ),
      DashboardGridItem(
        icon: Icons.inventory_2_outlined,
        label: 'Item',
        onTap: () {
          final companyId = widget.vm.companyId;
          if (companyId == null) {
            _showSelectCompany(context);
            return;
          }
          context.push(CfRoutes.itemCreate(companyId));
        },
      ),
      DashboardGridItem(
        icon: Icons.history_rounded,
        label: 'History',
        onTap: () {
          final companyId = widget.vm.companyId;
          if (companyId == null) {
            _showSelectCompany(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryPage(companyId: companyId),
            ),
          );
        },
      ),
    ];
  }

  void _openSalesOrder(BuildContext context) {
    final companyId = widget.vm.companyId;
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
    final companyId = widget.vm.companyId;
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
    final companyId = widget.vm.companyId;
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
    final companyId = widget.vm.companyId;
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
        duration: const Duration(seconds: 2),
        content: const Text('Please select a company first.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: LoginColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
