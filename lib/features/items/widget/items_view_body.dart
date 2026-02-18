import 'package:coreflow/features/items/view/items_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'item_card.dart';
import 'empty_state.dart';
import 'error_state.dart';

class ItemsViewBody extends StatefulWidget {
  const ItemsViewBody({super.key});

  @override
  State<ItemsViewBody> createState() => _ItemsViewBodyState();
}

class _ItemsViewBodyState extends State<ItemsViewBody> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  bool _isSearchOpen = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      _searchController.clear();
      _searchQuery = '';
      context.read<ItemsViewModel>().filterItems('');
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    context.read<ItemsViewModel>().filterItems(value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    context.read<ItemsViewModel>().filterItems('');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemsViewModel>();
    final dashboardVm = context.read<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: CustomSearchAppBar(
        isSearchOpen: _isSearchOpen,
        onSearchToggle: _toggleSearch,
        searchQuery: _searchQuery,
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onClearSearch: _clearSearch,
        scaffoldKey: _scaffoldKey,
      ),

      body: _buildContent(vm),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildContent(ItemsViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LoginColors.primary),
      );
    }

    if (vm.errorMessage != null) {
      return ErrorState(message: vm.errorMessage!);
    }

    if (vm.filteredItems.isEmpty) {
      return const EmptyState();
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: vm.filteredItems.length,
        itemBuilder: (_, i) => ItemCard(item: vm.filteredItems[i]),
      ),
    );
  }
}
