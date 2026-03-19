import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/sales/sales_order.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/presentation/sales/viewmodel/sales_order_view_model.dart';
import 'package:coreflow/features/presentation/sales/view/sales_order_detail_page.dart';
import 'package:coreflow/features/presentation/sales/widgets/sales_body_message.dart';
import 'package:coreflow/features/presentation/sales/widgets/sales_empty_state.dart';
import 'package:coreflow/features/presentation/sales/widgets/sales_loading_body.dart';
import 'package:coreflow/features/presentation/sales/widgets/sales_order_card.dart';
import 'package:coreflow/features/presentation/sales/widgets/sales_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVm, child) {
        if (dashboardVm.isLoading) {
          return const SalesSkeleton();
        }

        final companyId = dashboardVm.companyId;
        if (companyId == null) {
          return const SalesEmptyState(
            title: 'Sales & Bills',
            subtitle: 'Company not selected.',
          );
        }

        return ChangeNotifierProvider<SalesOrderViewModel>(
          create: (_) => SalesOrderViewModel(
            repository: AuthRepository(),
            companyId: companyId,
          )..fetchSalesOrders(),
          child: const _SalesOrdersContent(),
        );
      },
    );
  }
}

class _SalesOrdersContent extends StatefulWidget {
  const _SalesOrdersContent();

  @override
  State<_SalesOrdersContent> createState() => _SalesOrdersContentState();
}

class _SalesOrdersContentState extends State<_SalesOrdersContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _disabledSearchController =
      TextEditingController();
  _SalesTopTab _selectedTopTab = _SalesTopTab.orders;

  @override
  void dispose() {
    _disabledSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Consumer<SalesOrderViewModel>(
      builder: (context, vm, child) {
        final filteredOrders = vm.filteredOrders;
        final companyId = dashboardVm.companyId;

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
              SearchableEntityTab(label: 'Invoices'),
              SearchableEntityTab(label: 'Paid Orders'),
            ],
            selectedTabIndex: _selectedTopTab.index,
            onTabSelected: (index) {
              setState(() => _selectedTopTab = _SalesTopTab.values[index]);
            },
          ),
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            child: _buildBody(vm, filteredOrders, companyId),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    SalesOrderViewModel vm,
    List<SalesOrder> filteredOrders,
    int? companyId,
  ) {
    final tabFilteredOrders = filteredOrders
        .where((order) => _matchesSelectedTab(order.orderStatus))
        .toList();

    if (vm.isLoading) {
      return const SalesLoadingBody();
    }

    if (vm.errorMessage != null && vm.orders.isEmpty) {
      return SalesBodyMessage(
        icon: Icons.error_outline_rounded,
        title: 'Sales & Bills',
        subtitle: vm.errorMessage!,
      );
    }

    if (tabFilteredOrders.isEmpty) {
      return const SalesBodyMessage(
        icon: Icons.receipt_long_outlined,
        title: 'Sales & Bills',
        subtitle: 'No sales orders found.',
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
          onTap: () => _openOrderDetail(order, companyId),
          child: AnimatedSalesOrderCard(order: order, index: index),
        );
      },
    );
  }

  Future<void> _openOrderDetail(SalesOrder order, int? companyId) async {
    if (companyId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SalesOrderDetailPage(companyId: companyId, orderId: order.orderId),
      ),
    );
  }

  bool _matchesSelectedTab(String orderStatus) {
    final normalizedStatus = orderStatus.trim().toUpperCase();

    switch (_selectedTopTab) {
      case _SalesTopTab.orders:
        return normalizedStatus == 'ORDER' ||
            normalizedStatus == 'ORDER_VIEWED';
      case _SalesTopTab.invoices:
        return normalizedStatus == 'ORDER_INVOICED';
      case _SalesTopTab.paidOrders:
        return normalizedStatus == 'ORDER_PAYED';
    }
  }

  Widget _buildCreateButton() {
    return FloatingActionButton(
      backgroundColor: LoginColors.primary,
      foregroundColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create sales order coming soon.')),
        );
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}

enum _SalesTopTab { orders, invoices, paidOrders }
