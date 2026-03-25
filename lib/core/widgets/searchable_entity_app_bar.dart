import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchableEntityAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isSearchOpen;
  final VoidCallback onSearchToggle;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final String searchHint;
  final List<SearchableEntityTab>? tabs;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabSelected;
  final bool showSearchAction;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SearchableEntityAppBar({
    super.key,
    required this.isSearchOpen,
    required this.onSearchToggle,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.scaffoldKey,
    required this.title,
    required this.searchHint,
    this.tabs,
    this.selectedTabIndex = 0,
    this.onTabSelected,
    this.showSearchAction = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  static const double _searchBarHeight = 56.0;

  @override
  Size get preferredSize {
    // final hasTabs = tabs != null && tabs!.isNotEmpty;
    final extraHeight = showSearchAction && isSearchOpen ? _searchBarHeight : 0;
    return Size.fromHeight(kToolbarHeight + extraHeight);
  }

  @override
  Widget build(BuildContext context) {
    final hasTabs = tabs != null && tabs!.isNotEmpty;
    final bgColor =
        backgroundColor ??
        (hasTabs ? LoginColors.primary : LoginColors.background);
    final fgColor =
        foregroundColor ?? (hasTabs ? Colors.white : LoginColors.textPrimary);

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: !hasTabs,
      titleSpacing: hasTabs ? 4 : null,
      leadingWidth: 56,
      leading: IconButton(
        icon: hasTabs
            ? const Icon(Icons.menu_rounded, color: Colors.white)
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LoginColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LoginColors.borderLight, width: 1),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: LoginColors.textPrimary,
                  size: 20,
                ),
              ),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: isSearchOpen
          ? const SizedBox.shrink()
          : hasTabs
          ? _EntityTabs(
              tabs: tabs!,
              selectedTabIndex: selectedTabIndex,
              onTabSelected: onTabSelected,
            )
          : Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: LoginColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
      actions: [
        if (showSearchAction) ...[
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LoginColors.borderLight, width: 1),
              ),
              child: Icon(
                isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                color: LoginColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: onSearchToggle,
          ),
          const SizedBox(width: 12),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          showSearchAction && isSearchOpen ? _searchBarHeight : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showSearchAction && isSearchOpen
                  ? SizedBox(
                      height: _searchBarHeight,
                      child: _EntitySearchBar(
                        controller: searchController,
                        searchQuery: searchQuery,
                        onChanged: onSearchChanged,
                        onClear: onClearSearch,
                        hintText: searchHint,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchableEntityTab {
  final String label;

  const SearchableEntityTab({required this.label});
}

class _EntitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const _EntitySearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: LoginColors.textTertiary, fontSize: 14.5),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: LoginColors.textTertiary,
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: LoginColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: LoginColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: LoginColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: LoginColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: LoginColors.fieldFill,
        ),
      ),
    );
  }
}

class _EntityTabs extends StatelessWidget {
  final List<SearchableEntityTab> tabs;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabSelected;

  const _EntityTabs({
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final horizontalPadding = isCompact ? 2.0 : 4.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: List.generate(
              tabs.length,
              (index) => _TabChip(
                label: tabs[index].label,
                selected: selectedTabIndex == index,
                compact: isCompact,
                onTap: onTabSelected == null
                    ? null
                    : () => onTabSelected!(index),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: selected ? 1 : 0.72),
              fontSize: compact ? 14.0 : 15.0,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
