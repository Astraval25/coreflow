import 'package:flutter/material.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'company_header.dart';
import 'manage_expansion.dart';
import 'profile_row.dart';

class AppDrawer extends StatelessWidget {
  final DashboardViewModel vm;

  const AppDrawer({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          CompanyHeader(vm: vm),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DashboardMenuItem(vm: vm),


                ManageExpansion(vm: vm),
              ],
            ),
          ),

          ProfileRow(vm: vm),
        ],
      ),
    );
  }
}
