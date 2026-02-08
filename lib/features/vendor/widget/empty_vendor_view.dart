import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmptyVendorView extends StatelessWidget {
  final String searchQuery;
  final int companyId;

  const EmptyVendorView({
    super.key,
    required this.searchQuery,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bool isSearching = searchQuery.trim().isNotEmpty;
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopToggleTabs(context),
              const SizedBox(height: 90),

              // Illustration circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(isDark ? 0.12 : 0.09),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.business_rounded,
                  size: 80,
                  color: colorScheme.primary.withOpacity(0.70),
                ),
              ),

              const SizedBox(height: 48),

              // Main headline
              Text(
                isSearching ? 'No matches found' : 'No vendors added yet',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.1,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtext
              Text(
                isSearching
                    ? 'No vendors match “$searchQuery”.\nTry a different search or add a new vendor.'
                    : 'Start building your vendor list by adding your first supplier.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.48,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Primary CTA - Add First Vendor
              if (!isSearching)
                FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add First Vendor'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    minimumSize: const Size(220, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  onPressed: () => context.push('/vendors/$companyId/add'),
                ),

              // Secondary CTA - When searching
              if (isSearching) ...[
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add New Vendor'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    minimumSize: const Size(220, 52),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.7),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context.push('/vendors/$companyId/add'),
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: () {
                    // Usually handled by parent widget (search field clear)
                    // Or you can use context.read<SearchController>().clear();
                  },
                  child: Text(
                    'Clear search',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopToggleTabs(BuildContext context) {
    return Consumer<ActiveVendorViewModel>(
      builder: (context, viewModel, child) {
        const double gapBetweenTabs = 6.0;
        const double indicatorHeight = 3.0;
        const double horizontalPadding = 6.0;

        final bool isActiveSelected = viewModel.showActiveOnly;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double tabWidth =
                (constraints.maxWidth -
                    2 * horizontalPadding -
                    gapBetweenTabs) /
                2;

            final double indicatorLeft = isActiveSelected
                ? horizontalPadding
                : horizontalPadding + tabWidth + gapBetweenTabs;

            return Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 30),
                    curve: Curves.easeInOut,
                    left: indicatorLeft,
                    bottom: 0,
                    child: Container(
                      width: tabWidth,
                      height: indicatorHeight,
                      decoration: BoxDecoration(
                        color: isActiveSelected
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TabItem(
                        label: 'Active',
                        count: isActiveSelected
                            ? viewModel.vendor.length
                            : viewModel.activeVendorCount,
                        isSelected: isActiveSelected,
                        color: const Color(0xFF4CAF50),
                        tabWidth: tabWidth,
                        onTap: () {
                          if (!isActiveSelected) viewModel.toggleActiveFilter();
                        },
                      ),
                      SizedBox(width: gapBetweenTabs),
                      _TabItem(
                        label: 'Inactive',
                        count: !isActiveSelected
                            ? viewModel.vendor.length
                            : viewModel.inactiveVendorCount,
                        isSelected: !isActiveSelected,
                        color: const Color(0xFFE53935),
                        tabWidth: tabWidth,
                        onTap: () {
                          if (isActiveSelected) viewModel.toggleActiveFilter();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final double tabWidth;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.tabWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: tabWidth,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? color : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
