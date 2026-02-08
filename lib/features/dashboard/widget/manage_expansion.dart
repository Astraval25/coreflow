// ignore_for_file: use_build_context_synchronously

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/core/theme/colors.dart';
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

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        leading: Icon(
          Icons.dashboard_rounded,
          color: isSelected ? LoginColors.primary : LoginColors.textSecondary,
          size: 24,
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
    return Theme(
      // Make expansion tile look cleaner and match brand
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: LoginColors.textSecondary,
          collapsedIconColor: LoginColors.textSecondary,
          textColor: LoginColors.textPrimary,
          collapsedTextColor: LoginColors.textPrimary,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: vm.toggleCustomersExpanded,
        leading: Icon(
          Icons.manage_accounts_outlined,
          size: 24,
          color: vm.isCustomersExpanded
              ? LoginColors.primary
              : LoginColors.textSecondary,
        ),
        title: Text(
          'Manage',
          style: TextStyle(
            fontSize: 16,
            fontWeight: vm.isCustomersExpanded
                ? FontWeight.w600
                : FontWeight.w500,
            color: vm.isCustomersExpanded
                ? LoginColors.primary
                : LoginColors.textPrimary,
          ),
        ),
        trailing: Icon(
          vm.isCustomersExpanded
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_right_rounded,
          size: 20,
          color: vm.isCustomersExpanded
              ? LoginColors.primary
              : LoginColors.textSecondary,
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
        children: const [
          SubMenuItem(
            title: 'Customers',
            menuKey: '/customers',
            menuKeys: '/customersadd',
          ),
          SubMenuItem(
            title: 'Vendors',
            menuKey: '/vendors',
            menuKeys: '/vendoradd',
          ),
          SubMenuItem(title: 'Items', menuKey: '/items', menuKeys: '/itemsadd'),
        ],
      ),
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
    final isSelected =
        vm.selectedMenu == menuKey || vm.selectedMenu == menuKeys;

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        dense: true,
        leading: const SizedBox(width: 24), // indent sub-items nicely
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
          ),
        ),
        trailing: menuKeys.isNotEmpty
            ? GestureDetector(
                onTap: () => _handleAddTap(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: LoginColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: LoginColors.primary,
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onTap: () => _handleMainTap(context),
      ),
    );
  }

  Future<void> _handleMainTap(BuildContext context) async {
    final authData = await TokenStorage.getFullAuthData();
    final companyId = authData?['companyId']?.toString() ?? '';

    context.read<DashboardViewModel>().setSelectedMenu(menuKey);
    if (!context.mounted) return;

    Navigator.pop(context);
    context.push('/${menuKey.replaceFirst('/', '')}/$companyId');
  }

  Future<void> _handleAddTap(BuildContext context) async {
    final authData = await TokenStorage.getFullAuthData();
    final companyId = authData?['companyId']?.toString() ?? '';

    final vm = context.read<DashboardViewModel>();
    vm.setSelectedMenu(menuKeys);

    if (!context.mounted) return;

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 80));

    final path = switch (menuKeys) {
      '/vendoradd' => '/vendors/$companyId/add',
      '/customersadd' => '/customers/$companyId/add',
      _ => '/${menuKeys.replaceFirst('/', '')}',
    };

    context.push(path);
  }
}

// ── Reusable selected/highlight wrapper ───────────────────────────────────────
class _MenuTileContainer extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const _MenuTileContainer({required this.isSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? LoginColors.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
