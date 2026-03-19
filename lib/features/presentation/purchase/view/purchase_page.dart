import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/presentation/purchase/view/purchase_order_detail_page.dart';
import 'package:coreflow/features/presentation/purchase/viewmodel/purchase_order_view_model.dart';
import 'package:coreflow/features/presentation/purchase/widgets/purchase_body_message.dart';
import 'package:coreflow/features/presentation/purchase/widgets/purchase_empty_state.dart';
import 'package:coreflow/features/presentation/purchase/widgets/purchase_loading_body.dart';
import 'package:coreflow/features/presentation/purchase/widgets/purchase_order_card.dart';
import 'package:coreflow/features/presentation/purchase/widgets/purchase_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: LoginColors.background,
          drawerEnableOpenDragGesture: true,
          drawer: AppDrawer(vm: dashboardVm),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
        );
      },
    );
  }

  Widget _buildBody(PurchaseOrderViewModel vm) {
    final tabFilteredOrders = vm.orders
        .where((order) => _matchesSelectedTab(order.orderStatus))
        .toList();

    if (vm.isLoading) {
      return const PurchaseLoadingBody();
    }

    if (vm.errorMessage != null && vm.orders.isEmpty) {
      return PurchaseBodyMessage(
        icon: Icons.error_outline_rounded,
        title: 'Purchase & Expenses',
        subtitle: vm.errorMessage!,
      );
    }

    if (tabFilteredOrders.isEmpty) {
      return const PurchaseBodyMessage(
        icon: Icons.shopping_cart_outlined,
        title: 'Purchase & Expenses',
        subtitle: 'No purchase orders found.',
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
    return FloatingActionButton(
      backgroundColor: LoginColors.primary,
      foregroundColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create purchase order coming soon.')),
        );
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}

enum _PurchaseTopTab { orders, bills, paidOrders }
