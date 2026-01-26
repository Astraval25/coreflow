import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';
import 'package:coreflow/features/vendor/widget/vendor_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class VendorsList extends StatelessWidget {
  final List<dynamic> vendors;
  final int companyId;

  const VendorsList({
    super.key,
    required this.vendors,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopToggleTabs(context),
          Expanded(
            child: Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: vendors.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return VendorListItem(vendor: vendor, companyId: companyId);
                  },
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () async {
                        final result = await context.push<bool>(
                          '/vendors/$companyId/add',
                        );
                        if (result == true) {
                          context.read<ActiveVendorViewModel>().refresh();
                        }
                      },
                      splashColor: Colors.white24,
                      highlightColor: Colors.white12,
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
