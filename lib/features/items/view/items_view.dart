import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsPage extends StatelessWidget {
  final int companyId;

  const ItemsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ItemsViewModel(apiService: ApiService(), companyId: companyId)
                ..fetchItems(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: const _ItemsViewBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ItemsViewBody extends StatefulWidget {
  const _ItemsViewBody();

  @override
  State<_ItemsViewBody> createState() => _ItemsViewBodyState();
}

class _ItemsViewBodyState extends State<_ItemsViewBody> {
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
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
        context.read<ItemsViewModel>().filterItems('');
      } else {
        _searchController.clear(); // optional: start fresh
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
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {}, // TODO: navigate to add item screen
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildContent(ItemsViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: LoginColors.primary,
          strokeWidth: 3,
        ),
      );
    }

    if (vm.errorMessage != null) {
      return _ErrorState(message: vm.errorMessage!);
    }

    if (vm.filteredItems.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator.adaptive(
      color: LoginColors.primary,
      backgroundColor: LoginColors.surface,
      onRefresh: vm.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: vm.filteredItems.length,
        itemBuilder: (context, index) {
          return _ItemCard(item: vm.filteredItems[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom AppBar with expandable search (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isSearchOpen;
  final VoidCallback onSearchToggle;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomSearchAppBar({
    super.key,
    required this.isSearchOpen,
    required this.onSearchToggle,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.scaffoldKey,
  });

  static const double _searchHeight = 56.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (isSearchOpen ? _searchHeight : 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.surface,
      foregroundColor: LoginColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: isSearchOpen ? 0 : 1,
      shadowColor: LoginColors.shadowLight?.withOpacity(0.2),

      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        color: LoginColors.textSecondary,
        tooltip: 'Menu',
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),

      title: isSearchOpen
          ? const SizedBox.shrink()
          : const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
            ),

      actions: [
        IconButton(
          icon: Icon(isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
          tooltip: isSearchOpen ? 'Close search' : 'Search items',
          onPressed: onSearchToggle,
        ),
        const SizedBox(width: 8),
      ],

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isSearchOpen ? _searchHeight : 0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isSearchOpen
              ? SizedBox(
                  height: _searchHeight,
                  child: _SearchField(
                    controller: searchController,
                    query: searchQuery,
                    onChanged: onSearchChanged,
                    onClear: onClearSearch,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SearchBar(
        controller: controller,
        autoFocus: true,
        leading: const Icon(
          Icons.search_rounded,
          color: LoginColors.textSecondary,
        ),
        hintText: 'Search items...',
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: LoginColors.textTertiary),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: LoginColors.textPrimary),
        ),
        backgroundColor: WidgetStatePropertyAll(LoginColors.fieldFill),
        elevation: WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.focused)
              ? BorderSide(color: LoginColors.primary, width: 1.5)
              : BorderSide.none;
        }),
        trailing: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: onClear,
              tooltip: 'Clear',
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1.5,
      shadowColor: LoginColors.shadowLight?.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: LoginColors.border.withOpacity(0.45)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        title: Text(
          item.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.5,
            letterSpacing: 0.1,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'ID: ${item.itemId}    •    ${item.unit}    •    ${item.itemType ?? "Unknown"}',
            style: TextStyle(
              color: LoginColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ),
        trailing: Text(
          item.salesPrice.toStringAsFixed(2),
          style: TextStyle(
            color: LoginColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 96,
            color: LoginColors.textTertiary.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add a new item',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: LoginColors.textTertiary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: LoginColors.error.withOpacity(0.85),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LoginColors.error,
                fontSize: 16.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
