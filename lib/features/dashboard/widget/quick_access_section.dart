import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'dashboard_widgets.dart';
import '../dashboard_view_model/dashboard_view_model.dart';

class QuickAccessSection extends StatelessWidget {
  final DashboardViewModel vm;

  const QuickAccessSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(title: 'Quick Access'),
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
              // form now we keep only customers, vendors, items and marketplace in quick access. rest can be accessed from menu
            // DashboardGridItem(   
            //   icon: Icons.receipt_long_outlined,
            //   label: 'Sales',
            //   color: Colors.blue,
            //   onTap: () => _goIfCompany(context, '/sales'),
            // ),
            // DashboardGridItem(
            //   icon: Icons.inventory_2_outlined,
            //   label: 'Purchase',
            //   color: Colors.orange,
            //   onTap: () => _goIfCompany(context, '/purchase'),
            // ),
            // DashboardGridItem(
            //   icon: Icons.payments_outlined,
            //   label: 'Payment',
            //   color: Colors.green,
            //   onTap: () => _goIfCompany(context, '/payment'),
            // ),
            // DashboardGridItem(
            //   icon: Icons.account_balance_wallet_outlined,
            //   label: 'Received',
            //   color: Colors.purple,
            //   onTap: () => _goIfCompany(context, '/pay-received'),
            // ),
              DashboardGridItem(
                icon: Icons.groups_outlined,
                label: 'Customers',
                color: Colors.indigo,
                onTap: () {
                _pushIfCompany(context, CfRoutes.customers(vm.companyId!));
                },
              ),
              DashboardGridItem(
                icon: Icons.store_outlined,
                label: 'Vendors',
                color: Colors.teal,
                onTap: () {
                _pushIfCompany(context, CfRoutes.vendors(vm.companyId!));
                },
              ),
              DashboardGridItem(
                icon: Icons.inventory_2_outlined,
                label: 'Items',
                color: Colors.deepPurple,
                onTap: () {
                _pushIfCompany(context, CfRoutes.items(vm.companyId!));
                },
              ),
              DashboardGridItem(
                icon: Icons.store_mall_directory_outlined,
                label: 'Marketplace',
                color: Colors.amber,
                onTap: () => context.go(CfRoutes.marketplace),
              ),
            ],
          ),
        ],
    );
  }

  // ignore: unused_element
  void _goIfCompany(BuildContext context, String route) {
    if (vm.companyId == null) {
      _showSelectCompany(context);
      return;
    }
    context.go(route);
  }

  void _pushIfCompany(BuildContext context, String route) {
    if (vm.companyId == null) {
      _showSelectCompany(context);
      return;
    }
    context.push(route);
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
