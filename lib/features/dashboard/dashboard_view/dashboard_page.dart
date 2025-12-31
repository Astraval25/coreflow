import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, String? role});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..loadUserData(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          vm.companyName ?? 'Select Company',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        centerTitle: true,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.logout_rounded,
        //       color: Colors.redAccent,
        //       size: 26,
        //     ),
        //     tooltip: 'Logout',
        //     onPressed: vm.isLoading ? null : () => vm.logout(context),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      drawer: const AppDrawer(),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(),
    );
  }
}
