import 'package:coreflow/core/storage/token_storage.dart';
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
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, vm, scaffoldKey),
          drawer: AppDrawer(vm: vm),
          body: const Center(child: Text('Dashboard Content Here')),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    DashboardViewModel vm,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return AppBar(
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
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.add, size: 28),
          tooltip: 'Add New',
          offset: const Offset(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          itemBuilder: (context) => [
            _buildPopupMenuItem(
              Icons.person_add_rounded,
              'Customer',
              'customer',
            ),
            _buildPopupMenuItem(Icons.business_rounded, 'Vendor', 'vendor'),
            _buildPopupMenuItem(Icons.inventory_2_rounded, 'Item', 'item'),
          ],
          onSelected: (String value) async {
            final authData = await TokenStorage.getFullAuthData();
            final companyId = authData?['companyId']?.toString() ?? '6';

            switch (value) {
              case 'customer':
                context.push('/customers/$companyId/add');
                break;
              case 'vendor':
                context.go('/venderadd');
                break;
              case 'item':
                context.go('/itemsadd');
                break;
            }
          },
        ),

        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon')),
            );
          },
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    IconData icon,
    String label,
    String route,
  ) {
    return PopupMenuItem(
      value: route,
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
