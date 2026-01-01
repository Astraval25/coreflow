import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
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
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.add, size: 28),
            tooltip: 'Add New',
            offset: const Offset(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: '/customersadd',
                child: Row(
                  children: const [
                    Icon(Icons.person_add_rounded, size: 22),
                    SizedBox(width: 12),
                    Text('Customer', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/venderadd',
                child: Row(
                  children: const [
                    Icon(Icons.business_rounded, size: 22),
                    SizedBox(width: 12),
                    Text('Vendor', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/itemsadd',
                child: Row(
                  children: const [
                    Icon(Icons.inventory_2_rounded, size: 22),
                    SizedBox(width: 12),
                    Text('Item', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
            onSelected: (String route) {
              context.go(route);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {},
            tooltip: 'Notifications',
          ),

          const SizedBox(width: 12),
        ],
      ),
      drawer: const AppDrawer(),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text('Dashboard Content', style: TextStyle(fontSize: 18)),
            ),
    );
  }
}
