import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

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
      elevation: isSearchOpen ? 0 : 1,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: isSearchOpen
          ? const SizedBox.shrink()
          : const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
      actions: [
        IconButton(
          icon: Icon(
            isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
          ),
          onPressed: onSearchToggle,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize:
            Size.fromHeight(isSearchOpen ? _searchBarHeight : 0),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
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
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
