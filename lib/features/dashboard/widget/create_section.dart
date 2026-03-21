import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_widgets.dart';
import '../dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/theme/colors.dart';

class CreateSection extends StatelessWidget {
  final DashboardViewModel vm;
  final VoidCallback onPlay;

  const CreateSection({super.key, required this.vm, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 11),

          DashboardSectionHeader(title: 'Create', onTap: () {}, onPlay: onPlay),
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
                onTap: () => _showComingSoon(context),
              ),
              DashboardGridItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Purchase',
                onTap: () => _showComingSoon(context),
              ),
              DashboardGridItem(
                icon: Icons.payments_outlined,
                label: 'Payment',
                onTap: () => _showComingSoon(context),
              ),
              DashboardGridItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Received',
                onTap: () => _showComingSoon(context),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: LoginColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
