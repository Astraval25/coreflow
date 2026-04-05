import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/purchase/view/create_purchase_order_page.dart';
import 'package:coreflow/features/main_feature/purchase/view/purchase_order_detail_page.dart';
import 'package:coreflow/features/main_feature/purchase/viewmodel/purchase_order_view_model.dart';
import 'package:coreflow/features/main_feature/purchase/widgets/purchase_empty_state.dart';
import 'package:coreflow/features/main_feature/purchase/widgets/purchase_loading_body.dart';
import 'package:coreflow/features/main_feature/purchase/widgets/purchase_order_card.dart';
import 'package:coreflow/features/main_feature/purchase/widgets/purchase_skeleton.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const PurchaseSkeleton();
        }

        final companyId = vm.companyId;
        if (companyId == null) {
          return const PurchaseEmptyState(
            title: 'Purchase & Expenses',
            subtitle: 'Company not selected.',
          );
        }

        return ChangeNotifierProvider<PurchaseOrderViewModel>(
          create: (_) => PurchaseOrderViewModel(
            repository: AuthRepository(),
            companyId: companyId,
          )..fetchPurchaseOrders(),
          child: const _PurchaseOrdersContent(),
        );
      },
    );
  }
}

class _PurchaseOrdersContent extends StatefulWidget {
  const _PurchaseOrdersContent();

  @override
  State<_PurchaseOrdersContent> createState() => _PurchaseOrdersContentState();
}

class _PurchaseOrdersContentState extends State<_PurchaseOrdersContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _disabledSearchController =
      TextEditingController();
  _PurchaseTopTab _selectedTopTab = _PurchaseTopTab.orders;

  @override
  void dispose() {
    _disabledSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Consumer<PurchaseOrderViewModel>(
      builder: (context, vm, child) {
        return WillPopScope(
          onWillPop: _handleWillPop,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: LoginColors.background,
            drawerEnableOpenDragGesture: false,
            drawer: AppDrawer(vm: dashboardVm),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat,
            floatingActionButton: _buildCreateButton(),
            appBar: SearchableEntityAppBar(
              isSearchOpen: false,
              onSearchToggle: () {},
              searchQuery: '',
              searchController: _disabledSearchController,
              onSearchChanged: (_) {},
              onClearSearch: () {},
              scaffoldKey: _scaffoldKey,
              title: '',
              searchHint: '',
              showSearchAction: false,
              tabs: const [
                SearchableEntityTab(label: 'Orders'),
                SearchableEntityTab(label: 'Bills'),
                SearchableEntityTab(label: 'Paid Orders'),
              ],
              selectedTabIndex: _selectedTopTab.index,
              onTabSelected: (index) {
                setState(() => _selectedTopTab = _PurchaseTopTab.values[index]);
              },
            ),
            body:
                RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
          ),
        );
      },
    );
  }

  Future<bool> _handleWillPop() async {
    final vm = context.read<DashboardViewModel>();
    if (vm.companyId != null) context.go(CfRoutes.dashboard(vm.companyId!));
    return false;
  }

  Widget _buildBody(PurchaseOrderViewModel vm) {
    final tabFilteredOrders = vm.orders
        .where((order) => _matchesSelectedTab(order.orderStatus))
        .toList();

    if (vm.isLoading) {
      return const PurchaseLoadingBody();
    }

    if (vm.errorMessage != null && vm.orders.isEmpty) {
      return _buildEmptyState(
        title: 'Purchase & Expenses',
        subtitle: vm.errorMessage!,
        svgAsset: 'assets/svgs/empty_purchase.svg',
        actionLabel: 'Retry',
        actionIcon: Icons.refresh_rounded,
        onAction: () => vm.refresh(),
      );
    }

    if (tabFilteredOrders.isEmpty) {
      return _buildEmptyState(
        title: 'Purchase & Expenses',
        subtitle: 'No purchase orders found.',
        svgAsset: 'assets/svgs/empty_purchase.svg',
        actionLabel: 'New Purchase',
        actionIcon: Icons.add_rounded,
        onAction: () => _openCreateOrder(vm.companyId),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: tabFilteredOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = tabFilteredOrders[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openOrderDetail(vm.companyId, order.orderId),
          child: PurchaseOrderCard(order: order),
        );
      },
    );
  }

  Future<void> _openOrderDetail(int companyId, int orderId) async {
    if (orderId <= 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PurchaseOrderDetailPage(companyId: companyId, orderId: orderId),
      ),
    );
  }

  Future<void> _openCreateOrder(int companyId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePurchaseOrderPage(companyId: companyId),
      ),
    );
    if (result == true && mounted) {
      context.read<PurchaseOrderViewModel>().refresh();
    }
  }

  bool _matchesSelectedTab(String orderStatus) {
    final normalizedStatus = orderStatus.trim().toUpperCase();

    switch (_selectedTopTab) {
      case _PurchaseTopTab.orders:
        return normalizedStatus == 'ORDER' ||
            normalizedStatus == 'ORDER_VIEWED';
      case _PurchaseTopTab.bills:
        return normalizedStatus == 'ORDER_INVOICED';
      case _PurchaseTopTab.paidOrders:
        return normalizedStatus == 'ORDER_PAYED';
    }
  }

  Widget _buildCreateButton() {
    final companyId = context.read<DashboardViewModel>().companyId;
    return FloatingActionButton.extended(
      backgroundColor: LoginColors.primary,
      foregroundColor: Colors.white,
      onPressed: () async {
        if (companyId == null) return;
        await _openCreateOrder(companyId);
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'New Purchase',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required String svgAsset,
    String? actionLabel,
    IconData actionIcon = Icons.add_rounded,
    VoidCallback? onAction,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxHeight - 120)
            .clamp(0.0, double.infinity);
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            SizedBox(
              height: height,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      svgAsset,
                      height: 170,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: LoginColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: FilledButton.icon(
                          onPressed: onAction,
                          icon: Icon(actionIcon, size: 18),
                          label: Text(
                            actionLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: LoginColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _PurchaseTopTab { orders, bills, paidOrders }
