import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'company_header.dart';
import 'manage_expansion.dart';
import 'profile_row.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          CompanyHeader(vm: vm),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [ManageExpansion(vm: vm)],
            ),
          ),
          ProfileRow(vm: vm),
        ],
      ),
    );
  }
}
