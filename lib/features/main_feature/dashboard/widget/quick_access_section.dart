import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/storage/dashboard_bottom_nav_storage.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard_view_model/dashboard_view_model.dart';
import 'dashboard_widgets.dart';

class QuickAccessSection extends StatefulWidget {
  final DashboardViewModel vm;

  const QuickAccessSection({super.key, required this.vm});

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  static const int _firstRowCount = 4;
  bool _expanded = false;
  List<String> _pinnedActionIds = [];
  int? _lastCompanyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPinnedActions();
    });
  }

  @override
  void didUpdateWidget(covariant QuickAccessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm.companyId != widget.vm.companyId) {
      _loadPinnedActions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    final firstRow = items.take(_firstRowCount).toList();
    final rest = items.skip(_firstRowCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Quick Access',
          trailing: rest.isNotEmpty
              ? TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(_expanded ? 'Show less' : 'Show more'),
                )
              : null,
        ),
        const SizedBox(height: 5),
        _buildGrid(firstRow),
        if (rest.isNotEmpty) ...[
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildGrid(rest),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ],
    );
  }

  Widget _buildGrid(List<DashboardGridItem> children) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.85,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: children,
    );
  }

  List<DashboardGridItem> _items(BuildContext context) {
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
        id: 'customers',
        icon: Icons.groups_outlined,
        label: 'Customers',
        color: Colors.indigo,
        badgeCount: widget.vm.customerUnreadCount,
        routeBuilder: CfRoutes.customers,
      ),
      _QuickAccessItem(
        id: 'vendors',
        icon: Icons.store_outlined,
        label: 'Vendors',
        color: Colors.teal,
        badgeCount: widget.vm.vendorUnreadCount,
        routeBuilder: CfRoutes.vendors,
      ),
      _QuickAccessItem(
        id: 'items',
        icon: Icons.inventory_2_outlined,
        label: 'Items',
        color: Colors.deepPurple,
        routeBuilder: CfRoutes.items,
      ),
      _QuickAccessItem(
        id: 'employees',
        icon: Icons.badge_outlined,
        label: 'Employees',
        color: Colors.amber,
        badgeCount: widget.vm.employeeUnreadCount,
        routeBuilder: CfRoutes.employees,
      ),
      _QuickAccessItem(
        id: 'sales_orders',
        icon: Icons.receipt_long_outlined,
        label: 'Sales Orders',
        color: Colors.blue,
        routeBuilder: CfRoutes.sales,
      ),
      _QuickAccessItem(
        id: 'purchase_orders',
        icon: Icons.shopping_cart_outlined,
        label: 'Purchase Orders',
        color: Colors.orange,
        routeBuilder: CfRoutes.purchase,
      ),
      _QuickAccessItem(
        id: 'payment_made',
        icon: Icons.payments_outlined,
        label: 'Payment Made',
        color: Colors.green,
        routeBuilder: CfRoutes.paymentMade,
      ),
      _QuickAccessItem(
        id: 'payment_received',
        icon: Icons.account_balance_wallet_outlined,
        label: 'Payment Received',
        color: Colors.purple,
        routeBuilder: CfRoutes.paymentReceived,
      ),
      _QuickAccessItem(
        id: 'expenses',
        icon: Icons.receipt_long_rounded,
        label: 'Expenses',
        color: Colors.redAccent,
        routeBuilder: CfRoutes.expenses,
      ),
    ];

    final sortedItems = <_QuickAccessItem>[
      ...items.where((item) => !_pinnedActionIds.contains(item.id)),
      ...items.where((item) => _pinnedActionIds.contains(item.id)),
    ];

    return sortedItems
        .map(
          (item) => DashboardGridItem(
            icon: item.icon,
            label: item.label,
            color: item.color,
            badgeCount: item.badgeCount,
            isPinned: _pinnedActionIds.contains(item.id),
            showPinnedIndicator: true,
            onTap: () => _pushIfCompany(context, item.routeBuilder),
            onLongPress: () => _togglePin(item.id, item.label),
          ),
        )
        .toList();
  }

  Future<void> _loadPinnedActions() async {
    final companyId = widget.vm.companyId;
    if (companyId == null) return;
    if (_lastCompanyId == companyId && _pinnedActionIds.isNotEmpty) return;
    _lastCompanyId = companyId;
    final ids = await DashboardBottomNavStorage.loadPinnedActionIds(companyId);
    if (!mounted) return;
    setState(() {
      _pinnedActionIds = ids;
    });
  }

  Future<void> _togglePin(String actionId, String label) async {
    final companyId = widget.vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }

    final next = List<String>.from(_pinnedActionIds);
    final pinned = next.contains(actionId);
    if (pinned) {
      next.remove(actionId);
    } else {
      if (next.length >= DashboardBottomNavStorage.maxPinnedActions) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can pin up to 4 shortcuts in bottom nav'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      next.add(actionId);
    }

    await DashboardBottomNavStorage.savePinnedActionIds(companyId, next);
    if (!mounted) return;
    setState(() {
      _pinnedActionIds = next;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pinned
              ? '$label removed from bottom nav'
              : '$label pinned to bottom nav',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _pushIfCompany(
    BuildContext context,
    String Function(int companyId) routeBuilder,
  ) {
    final companyId = widget.vm.companyId;
    if (companyId == null) {
      _showSelectCompany(context);
      return;
    }
    context.push(routeBuilder(companyId));
  }

  void _showSelectCompany(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text('Please select a company first.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: LoginColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _QuickAccessItem {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final int badgeCount;
  final String Function(int companyId) routeBuilder;

  const _QuickAccessItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    this.badgeCount = 0,
    required this.routeBuilder,
  });
}
