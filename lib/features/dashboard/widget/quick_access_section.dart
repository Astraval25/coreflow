import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dashboard_widgets.dart';
import '../dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/theme/colors.dart';

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
              DashboardGridItem(
                icon: Icons.groups_outlined,
                label: 'Customers',
                color: Colors.indigo,
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/customers/${vm.companyId}');
                  }
                },
              ),
              DashboardGridItem(
                icon: Icons.store_outlined,
                label: 'Vendors',
                color: Colors.teal,
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/vendors/${vm.companyId}');
                  }
                },
              ),
              DashboardGridItem(
                icon: Icons.inventory_2_outlined,
                label: 'Items',
                color: Colors.deepPurple,
                onTap: () {
                  if (vm.companyId != null) {
                    context.push('/items/${vm.companyId}');
                  }
                },
              ),
              DashboardGridItem(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Reports',
                color: Colors.amber,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: LoginColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
    );
  }
}
