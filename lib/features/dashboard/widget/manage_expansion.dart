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
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = currentLocation.startsWith('/dashboard');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withOpacity(0.12)
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
          vm.setSelectedMenu('/dashboard');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/dashboard')) {
            context.go('/dashboard');
          }
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
    final isSelected = currentLocation.startsWith('/sales');

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
          vm.setSelectedMenu('/sales');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/sales')) {
            context.go('/sales');
          }
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
    final isSelected = currentLocation.startsWith('/purchase');

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
          vm.setSelectedMenu('/purchase');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/purchase')) {
            context.go('/purchase');
          }
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
    final isSelected = currentLocation.startsWith('/payment');

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
          vm.setSelectedMenu('/payment');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/payment')) {
            context.go('/payment');
          }
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
    final isSelected = currentLocation.startsWith('/pay-received');

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
          vm.setSelectedMenu('/pay-received');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/pay-received')) {
            context.go('/pay-received');
          }
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
        currentLocation.startsWith('/customers') ||
        currentLocation.startsWith('/vendors') ||
        currentLocation.startsWith('/items');
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
                  ? LoginColors.primary.withOpacity(0.1)
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
              menuKey: '/customers',
              menuKeys: '/customersadd',
            ),
            SubMenuItem(
              title: 'Vendors',
              icon: Icons.storefront_rounded,
              iconColor: Color(0xFFF59E0B), // Amber
              menuKey: '/vendors',
              menuKeys: '/vendoradd',
            ),
            SubMenuItem(
              title: 'Items',
              icon: Icons.inventory_2_rounded,
              iconColor: Color(0xFF10B981), // Emerald
              menuKey: '/items',
              menuKeys: '/itemsadd',
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
    final vm = context.watch<DashboardViewModel>();
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final normalizedMenuKey = menuKey.replaceFirst('/', '');
    final isSelected = currentLocation.startsWith('/$normalizedMenuKey');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? iconColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withOpacity(0.12)
                : iconColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? iconColor : iconColor.withOpacity(0.7),
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
                        ? iconColor.withOpacity(0.15)
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
    var companyId = vm.companyId?.toString() ?? '';
    if (companyId.isEmpty) {
      final authData = await TokenStorage.getFullAuthData();
      companyId = authData?['companyId']?.toString() ?? '';
    }
    if (companyId.isEmpty) return;
    final targetPath = '/${menuKey.replaceFirst('/', '')}/$companyId';
    final currentLocation = GoRouterState.of(context).matchedLocation;

    vm.setSelectedMenu(menuKey);
    if (!context.mounted) return;

    Navigator.pop(context);
    if (currentLocation != targetPath) {
      context.go(targetPath);
    }
  }

  Future<void> _handleAddTap(BuildContext context) async {
    final vm = context.read<DashboardViewModel>();
    var companyId = vm.companyId?.toString() ?? '';
    if (companyId.isEmpty) {
      final authData = await TokenStorage.getFullAuthData();
      companyId = authData?['companyId']?.toString() ?? '';
    }
    if (companyId.isEmpty) return;
    vm.setSelectedMenu(menuKeys);

    if (!context.mounted) return;

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 80));

    final path = switch (menuKeys) {
      '/vendoradd' => '/vendors/$companyId/add',
      '/customersadd' => '/customers/$companyId/add',
      '/itemsadd' => '/items/$companyId/add',
      _ => '/${menuKeys.replaceFirst('/', '')}',
    };

    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (currentLocation != path) {
      context.go(path);
    }
  }
}

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
        color: isSelected ? iconColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withOpacity(0.12)
                : iconColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? iconColor : iconColor.withOpacity(0.7),
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
    final companyId = authData?['companyId']?.toString() ?? '';
    if (companyId.isEmpty) return;

    final vm = context.read<DashboardViewModel>();
    vm.setSelectedMenu(menuKey);

    if (!context.mounted) return;
    Navigator.pop(context);

    final path = route.replaceFirst('{companyId}', companyId);
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (currentLocation != path) {
      context.go(path);
    }
  }
}

class MarketplaceMenuItem extends StatelessWidget {
  final DashboardViewModel vm;

  const MarketplaceMenuItem({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSelected = currentLocation.startsWith('/marketplace');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withOpacity(0.12)
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
          vm.setSelectedMenu('/marketplace');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/marketplace')) {
            context.go('/marketplace');
          }
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
    final isSelected = currentLocation.startsWith('/report');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withOpacity(0.12)
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
          vm.setSelectedMenu('/report');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report - Coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
    final isSelected = currentLocation.startsWith('/settings');

    return _MenuTileContainer(
      isSelected: isSelected,
      child: ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? LoginColors.primary.withOpacity(0.12)
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
        onTap: () {
          vm.setSelectedMenu('/settings');
          Navigator.pop(context);
          if (!currentLocation.startsWith('/settings')) {
            context.go('/settings');
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
            ? LoginColors.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
