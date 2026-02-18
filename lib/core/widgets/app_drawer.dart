import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/company_header.dart';
import 'package:coreflow/features/dashboard/widget/manage_expansion.dart';
import 'package:coreflow/features/dashboard/widget/profile_row.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final DashboardViewModel vm;

  const AppDrawer({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: LoginColors.surface,
      child: Column(
        children: [
          CompanyHeader(vm: vm),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DashboardMenuItem(vm: vm),
                ManageExpansion(vm: vm),
                SalesMenuItem(vm: vm),
                PurchaseMenuItem(vm: vm),
                PaymentMenuItem(vm: vm),
                PayReceivedMenuItem(vm: vm),
                // QuickAddExpansion(vm: vm),
              ],
            ),
          ),
          ProfileRow(vm: vm),
        ],
      ),
    );
  }
}
