import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_view_model/dashboard_view_model.dart';
import 'dashboard_widgets.dart';

class QuickAccessSection extends StatefulWidget {
  final DashboardViewModel vm;

  const QuickAccessSection({super.key, required this.vm});

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  static const int _firstRowCount = 4;
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    final firstRow = items.take(_firstRowCount).toList();
    final rest = items.skip(_firstRowCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Quick Access',
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
        icon: Icons.groups_outlined,
        label: 'Customers',
        color: Colors.indigo,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.customers(id)),
      ),
      DashboardGridItem(
        icon: Icons.store_outlined,
        label: 'Vendors',
        color: Colors.teal,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.vendors(id)),
      ),
      DashboardGridItem(
        icon: Icons.inventory_2_outlined,
        label: 'Items',
        color: Colors.deepPurple,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.items(id)),
      ),
      DashboardGridItem(
        icon: Icons.store_mall_directory_outlined,
        label: 'Marketplace',
        color: Colors.amber,
        onTap: () => context.go(CfRoutes.marketplace),
      ),
      DashboardGridItem(
        icon: Icons.receipt_long_outlined,
        label: 'Sales',
        color: Colors.blue,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.sales(id)),
      ),
      DashboardGridItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Purchase',
        color: Colors.orange,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.purchase(id)),
      ),
      DashboardGridItem(
        icon: Icons.payments_outlined,
        label: 'Payment',
        color: Colors.green,
        onTap: () => _pushIfCompany(context, (id) => CfRoutes.paymentMade(id)),
      ),
      DashboardGridItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Received',
        color: Colors.purple,
        onTap: () =>
            _pushIfCompany(context, (id) => CfRoutes.paymentReceived(id)),
      ),
    ];
  }

  void _pushIfCompany(
    BuildContext context,
    String Function(int companyId) routeBuilder,
  ) {
    final companyId = widget.vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    context.push(routeBuilder(companyId));
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
