import 'package:flutter/material.dart';

class VendorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int companyId;
  final bool isSearchOpen;
  final VoidCallback onSearchToggle;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const VendorAppBar({
    super.key,
    required this.companyId,
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.12),

      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),

      title: const Text(
        'Vendors',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter coming soon...')),
            );
          },
        ),
        IconButton(
          icon: Icon(isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
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
                  child: _VendorSearchBar(
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

class _VendorSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _VendorSearchBar({
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
          hintText: 'Search vendors...',
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
