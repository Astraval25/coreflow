// ignore_for_file: use_build_context_synchronously

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DashboardMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const DashboardMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.selectedMenu == '/dashboard';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.dashboard_rounded,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 17,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
        dense: true,
        onTap: () {
          vm.setSelectedMenu('/dashboard');
          Navigator.pop(context);
          context.go('/dashboard');
        },
      ),
    );
  }
}

class ManageExpansion extends StatelessWidget {
  final DashboardViewModel vm;

  const ManageExpansion({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.manage_accounts_outlined, size: 25),
      title: Text(
        'Manage',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      trailing: Icon(
        vm.isCustomersExpanded
            ? Icons.keyboard_arrow_down_rounded
            : Icons.keyboard_arrow_right,
        size: 20,
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 0.05,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      initiallyExpanded: false, // ← keep collapsed when drawer opens
      onExpansionChanged: vm.toggleCustomersExpanded,
      children: [
        SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SubMenuItem(
                title: 'Customers',
                menuKey: '/customers',
                menuKeys: "/customersadd",
              ),
              SubMenuItem(
                title: 'Vendors',
                menuKey: '/vendors',
                menuKeys: "/vendoradd",
              ),
              SubMenuItem(
                title: 'Items',
                menuKey: '/items',
                menuKeys: "/itemsadd",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SubMenuItem extends StatelessWidget {
  final String title;
  final String menuKey;
  final String menuKeys;

  const SubMenuItem({
    super.key,
    required this.title,
    required this.menuKey,
    required this.menuKeys,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isSelectedMain = vm.selectedMenu == menuKey;
    final isSelectedAdd = menuKeys.isNotEmpty && vm.selectedMenu == menuKeys;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      decoration: BoxDecoration(
        color: isSelectedMain || isSelectedAdd
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isSelectedMain || isSelectedAdd
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelectedMain || isSelectedAdd
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        trailing: menuKeys.isNotEmpty
            ? GestureDetector(
                onTap: () => _handleAddTap(context),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.05),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        minVerticalPadding: 2,
        onTap: () => _handleMainTap(context),
      ),
    );
  }

  Future<void> _handleMainTap(BuildContext context) async {
    final authData = await TokenStorage.getFullAuthData();
    final companyId = authData?['companyId']?.toString();

    context.read<DashboardViewModel>().setSelectedMenu(menuKey);
    if (context.mounted) {
      Navigator.pop(context);
      context.push('/${menuKey.replaceFirst('/', '')}/$companyId');
    }
  }

  Future<void> _handleAddTap(BuildContext context) async {
    final authData = await TokenStorage.getFullAuthData();
    final companyId = authData?['companyId']?.toString();

    context.read<DashboardViewModel>().setSelectedMenu(menuKeys);
    if (context.mounted) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 50));

      if (menuKeys == '/vendoradd') {
        context.push('/vendors/$companyId/add');
      } else if (menuKeys == '/customersadd') {
        context.push('/customers/$companyId/add');
      } else {
        context.push('/$menuKeys');
      }
    }
  }
}
