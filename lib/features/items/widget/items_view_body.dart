import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/features/items/view/create_item_screen.dart';
import 'package:coreflow/features/items/view_model/item_create_view_model.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'item_card.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/core/widgets/status_toggle_tabs.dart';

class ItemsViewBody extends StatefulWidget {
  const ItemsViewBody({super.key});

  @override
  State<ItemsViewBody> createState() => _ItemsViewBodyState();
}

class _ItemsViewBodyState extends State<ItemsViewBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
        context.read<ItemsViewModel>().filterItems('');
      } else {
        _searchController.clear();
      }
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
    context.watch<ThemeProvider>();
    final vm = context.watch<ItemsViewModel>();
    final dashboardVm = context.read<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: SearchableEntityAppBar(
        isSearchOpen: _isSearchOpen,
        onSearchToggle: _toggleSearch,
        searchQuery: _searchQuery,
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onClearSearch: _clearSearch,
        scaffoldKey: _scaffoldKey,
        title: 'Items',
        searchHint: 'Search items...',
      ),
      body: Column(
        children: [
          _buildTopToggleTabs(context),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: _buildContent(vm),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () async {
          final companyId = context.read<ItemsViewModel>().companyId;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => CreateItemViewModel(apiService: ApiService()),
                child: CreateItemScreen(companyId: companyId),
              ),
            ),
          );

          if (result == true && context.mounted) {
            context.read<ItemsViewModel>().fetchItems();
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LoginColors.primary, LoginColors.primaryDark],
            ),
          ),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildContent(ItemsViewModel vm) {
    if (vm.isLoading) {
      return KeyedSubtree(
        key: const ValueKey('items-loading'),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Skeleton(height: 60, width: 60, borderRadius: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 18, width: 140),
                        const SizedBox(height: 8),
                        const Skeleton(height: 14, width: 80),
                      ],
                    ),
                  ),
                  const Skeleton(height: 24, width: 60, borderRadius: 8),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return KeyedSubtree(
        key: ValueKey('items-error-${vm.errorMessage}'),
        child: ErrorState(message: vm.errorMessage!),
      );
    }

    if (vm.filteredItems.isEmpty) {
      return KeyedSubtree(
        key: ValueKey('items-empty-${vm.showActiveOnly}-${vm.searchQuery}'),
        child: const EmptyState(),
      );
    }

    return KeyedSubtree(
      key: ValueKey(
        'items-list-${vm.showActiveOnly}-${vm.searchQuery}-${vm.filteredItems.length}',
      ),
      child: RefreshIndicator(
        color: LoginColors.primary,
        backgroundColor: LoginColors.surface,
        onRefresh: vm.refresh,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: vm.filteredItems.length,
          itemBuilder: (context, index) {
            final item = vm.filteredItems[index];
            return _AnimatedItemEntry(
              key: ValueKey(
                'item-entry-${item.itemId}-${vm.showActiveOnly}-${vm.searchQuery}',
              ),
              index: index,
              child: ItemCard(item: item),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopToggleTabs(BuildContext context) {
    return Consumer<ItemsViewModel>(
      builder: (context, viewModel, child) {
        return StatusToggleTabs(
          isActiveSelected: viewModel.showActiveOnly,
          activeLabel: 'Active',
          inactiveLabel: 'Inactive',
          onActiveTap: () {
            if (!viewModel.showActiveOnly) viewModel.toggleActiveFilter();
          },
          onInactiveTap: () {
            if (viewModel.showActiveOnly) viewModel.toggleActiveFilter();
          },
        );
      },
    );
  }
}

class _AnimatedItemEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedItemEntry({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 220 + (index > 7 ? 7 : index) * 35);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}
