import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/items/view/item_detail_view.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        elevation: 7,
        shape: const CircleBorder(),
        onPressed: () {},
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

  static const double _searchBarHeight = 56.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (isSearchOpen ? _searchBarHeight : 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.surface,
      foregroundColor: LoginColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: isSearchOpen ? 0 : 1,
      shadowColor: LoginColors.shadowLight.withOpacity(0.2),

      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        color: LoginColors.textSecondary,
        tooltip: 'Menu',
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),

      title: isSearchOpen
          ? const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
            )
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
        preferredSize: Size.fromHeight(isSearchOpen ? _searchBarHeight : 0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isSearchOpen
              ? SizedBox(
                  height: _searchBarHeight,
                  child: _SearchBar(
                    controller: searchController,
                    searchQuery: searchQuery,
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;

  const _ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final priceColor = item.isActive
        ? LoginColors.primary
        : LoginColors.textTertiary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 1.0,
      color: LoginColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: LoginColors.border, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: LoginColors.primaryLight.withOpacity(0.12),
        highlightColor: LoginColors.primaryLight.withOpacity(0.08),
        onTap: () {
          final companyId = context.read<ItemsViewModel>().companyId;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemDetailView(companyId: companyId, itemId: item.itemId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LoginColors.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LoginColors.borderLight),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: LoginColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${item.itemId}  •  '
                      '${item.unit}  •  '
                      '${item.itemType}  •  '
                      '${item.isActive ? "Active" : "Inactive"}',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Price
              Text(
                currencyFormat.format(item.baseSalesPrice),
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: priceColor,
                ),
              ),
            ],
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
