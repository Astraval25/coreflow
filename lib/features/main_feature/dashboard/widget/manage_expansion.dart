// ignore_for_file: use_build_context_synchronously

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void _closeDrawerAndNavigate(
  BuildContext context, {
  required String path,
  required String currentLocation,
  bool push = false,
}) {
  final navigator = Navigator.of(context);
  final router = GoRouter.of(context);

  navigator.pop();

  if (currentLocation == path) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (push) {
      router.push(path);
    } else {
      router.go(path);
    }
  });
}

class DashboardMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const DashboardMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(currentLocation, 'dashboard');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.dashboard_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('dashboard');
          if (!isSelected && vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.dashboard(vm.companyId!),
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class SalesMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const SalesMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(currentLocation, 'sales');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Sales',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('sales');
          if (!isSelected && vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.sales(vm.companyId!),
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class PurchaseMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const PurchaseMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(currentLocation, 'purchase');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.inventory_2_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Purchase',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('purchase');
          if (!isSelected && vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.purchase(vm.companyId!),
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class PaymentMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const PaymentMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(
      currentLocation,
      'payment-made',
    );

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.payments_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('payment-made');
          if (!isSelected && vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.paymentMade(vm.companyId!),
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class PayReceivedMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const PayReceivedMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(
      currentLocation,
      'payment-received',
    );

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Received',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('payment-received');
          if (!isSelected && vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.paymentReceived(vm.companyId!),
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
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
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isManageRoute =
        CfRoutes.isSectionActive(currentLocation, 'customers') ||
        CfRoutes.isSectionActive(currentLocation, 'vendors') ||
        CfRoutes.isSectionActive(currentLocation, 'employees') ||
        CfRoutes.isSectionActive(currentLocation, 'work-definitions') ||
        CfRoutes.isSectionActive(currentLocation, 'employee-work-logs') ||
        CfRoutes.isSectionActive(currentLocation, 'employee-leave-requests') ||
        CfRoutes.isSectionActive(currentLocation, 'employee-salary') ||
        CfRoutes.isSectionActive(currentLocation, 'items');
    final isExpanded = vm.isCustomersExpanded || isManageRoute;

    return _MenuTileContainer(
      isSelected: isExpanded,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: LoginColors.textTertiary,
            collapsedIconColor: LoginColors.textTertiary,
            textColor: LoginColors.textPrimary,
            collapsedTextColor: LoginColors.textPrimary,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: vm.toggleCustomersExpanded,
          minTileHeight: 0,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpanded
                  ? LoginColors.primary.withValues(alpha: 0.1)
                  : LoginColors.fieldFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.manage_accounts_rounded,
              size: 20,
              color: isExpanded
                  ? LoginColors.primary
                  : LoginColors.textTertiary,
            ),
          ),
          title: Text(
            'Manage',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
              color: isExpanded ? LoginColors.primary : LoginColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          trailing: Icon(
            isExpanded
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_right_rounded,
            size: 20,
            color: isExpanded ? LoginColors.primary : LoginColors.textTertiary,
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 8,
          ),
          children: const [
            SubMenuItem(
              title: 'Customers',
              icon: Icons.people_alt_rounded,
              iconColor: Color(0xFF3B82F6), // Blue
              menuKey: 'customers',
              menuKeys: 'customersadd',
            ),
            SubMenuItem(
              title: 'Vendors',
              icon: Icons.storefront_rounded,
              iconColor: Color(0xFFF59E0B), // Amber
              menuKey: 'vendors',
              menuKeys: 'vendoradd',
            ),
            SubMenuItem(
              title: 'Employees',
              icon: Icons.badge_rounded,
              iconColor: Color(0xFF8B5CF6), // Violet
              menuKey: 'employees',
              menuKeys: 'employeesadd',
            ),
            SubMenuItem(
              title: 'Work Definitions',
              icon: Icons.workspaces_rounded,
              iconColor: Color(0xFFEC4899), // Pink
              menuKey: 'work-definitions',
              menuKeys: '',
            ),
            SubMenuItem(
              title: 'Work Logs',
              icon: Icons.post_add_rounded,
              iconColor: Color(0xFF0EA5E9), // Sky
              menuKey: 'employee-work-logs',
              menuKeys: '',
            ),
            SubMenuItem(
              title: 'Leave Requests',
              icon: Icons.event_note_rounded,
              iconColor: Color(0xFFF97316), // Orange
              menuKey: 'employee-leave-requests',
              menuKeys: '',
            ),
            SubMenuItem(
              title: 'Salary',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: Color(0xFF14B8A6), // Teal
              menuKey: 'employee-salary',
              menuKeys: '',
            ),
            SubMenuItem(
              title: 'Items',
              icon: Icons.inventory_2_rounded,
              iconColor: Color(0xFF10B981), // Emerald
              menuKey: 'items',
              menuKeys: 'itemsadd',
            ),
          ],
        ),
      ),
    );
  }
}

class SubMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String menuKey;
  final String menuKeys;

  const SubMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.menuKey,
    required this.menuKeys,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final vm = context.watch<DashboardViewModel>();
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(currentLocation, menuKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? iconColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withValues(alpha: 0.12)
                : iconColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? iconColor : iconColor.withValues(alpha: 0.7),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? iconColor : LoginColors.textPrimary,
          ),
        ),
        trailing: menuKeys.isNotEmpty
            ? GestureDetector(
                onTap: () => _handleAddTap(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? iconColor.withValues(alpha: 0.15)
                        : LoginColors.fieldFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isSelected ? iconColor : LoginColors.textTertiary,
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => _handleMainTap(context),
      ),
    );
  }

  Future<void> _handleMainTap(BuildContext context) async {
    final vm = context.read<DashboardViewModel>();
    var companyId = vm.companyId;
    if (companyId == null) {
      final authData = await TokenStorage.getFullAuthData();
      final id = authData?['companyId'];
      if (id is int) companyId = id;
    }
    if (companyId == null) return;

    final targetPath = switch (menuKey) {
      'customers' => CfRoutes.customers(companyId),
      'vendors' => CfRoutes.vendors(companyId),
      'employees' => CfRoutes.employees(companyId),
      'work-definitions' => CfRoutes.workDefinitions(companyId),
      'employee-work-logs' => CfRoutes.employeeWorkLogs(companyId),
      'employee-leave-requests' => CfRoutes.employeeLeaveRequests(companyId),
      'employee-salary' => CfRoutes.employeeSalary(companyId),
      'items' => CfRoutes.items(companyId),
      _ => CfRoutes.customers(companyId),
    };
    final currentLocation = GoRouterState.of(context).matchedLocation;

    vm.setSelectedMenu(menuKey);
    if (!context.mounted) return;

    _closeDrawerAndNavigate(
      context,
      path: targetPath,
      currentLocation: currentLocation,
    );
  }

  Future<void> _handleAddTap(BuildContext context) async {
    final vm = context.read<DashboardViewModel>();
    var companyId = vm.companyId;
    if (companyId == null) {
      final authData = await TokenStorage.getFullAuthData();
      final id = authData?['companyId'];
      if (id is int) companyId = id;
    }
    if (companyId == null) return;
    vm.setSelectedMenu(menuKeys);

    if (!context.mounted) return;

    final path = switch (menuKeys) {
      'vendoradd' => CfRoutes.vendorCreate(companyId),
      'customersadd' => CfRoutes.customerCreate(companyId),
      'employeesadd' => CfRoutes.employeeCreate(companyId),
      'itemsadd' => CfRoutes.itemCreate(companyId),
      _ => CfRoutes.customers(companyId),
    };

    final currentLocation = GoRouterState.of(context).matchedLocation;
    _closeDrawerAndNavigate(
      context,
      path: path,
      currentLocation: currentLocation,
    );
  }
}

// ignore: unused_element
class _QuickAddTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String route;
  final String menuKey;

  const _QuickAddTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.route,
    required this.menuKey,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isSelected = vm.selectedMenu == menuKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? iconColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withValues(alpha: 0.12)
                : iconColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? iconColor : iconColor.withValues(alpha: 0.7),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? iconColor : LoginColors.textPrimary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => _handleAddTap(context),
      ),
    );
  }

  Future<void> _handleAddTap(BuildContext context) async {
    final authData = await TokenStorage.getFullAuthData();
    final companyIdRaw = authData?['companyId'];
    final companyId = companyIdRaw is int
        ? companyIdRaw
        : int.tryParse(companyIdRaw?.toString() ?? '');
    if (companyId == null) return;

    final vm = context.read<DashboardViewModel>();
    vm.setSelectedMenu(menuKey);

    if (!context.mounted) return;

    final path = route.replaceFirst('{companyId}', companyId.toString());
    final currentLocation = GoRouterState.of(context).matchedLocation;
    _closeDrawerAndNavigate(
      context,
      path: path,
      currentLocation: currentLocation,
    );
  }
}

class MarketplaceMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const MarketplaceMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = currentLocation.startsWith(CfRoutes.marketplace);

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.store_mall_directory_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('marketplace');
          if (!isSelected) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.marketplace,
              currentLocation: currentLocation,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ReportMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const ReportMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isSectionActive(currentLocation, 'report');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.bar_chart_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Report',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          vm.setSelectedMenu('report');
          if (vm.companyId != null) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.reportCustomers(vm.companyId!),
              currentLocation: currentLocation,
              push: true,
            );
            return;
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const SettingsMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = CfRoutes.isUserSection(currentLocation, 'settings');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withValues(alpha: 0.12)
                : LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.settings_rounded,
            color: isSelected ? LoginColors.primary : LoginColors.textTertiary,
            size: 20,
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () async {
          vm.setSelectedMenu('settings');
          final authData = await TokenStorage.getFullAuthData();
          final userId = int.tryParse(authData?['userId']?.toString() ?? '');
          if (userId != null && context.mounted) {
            _closeDrawerAndNavigate(
              context,
              path: CfRoutes.settings(userId),
              currentLocation: currentLocation,
            );
            return;
          }
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _MenuTileContainer extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const _MenuTileContainer({required this.isSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? LoginColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
