import 'package:coreflow/features/vendor/widget/vendor_list_item.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class VendorsList extends StatelessWidget {
  final List<Vendor> vendors;
  final int companyId;
  final Set<int> pinnedVendorIds;
  final ValueChanged<int> onTogglePin;

  const VendorsList({
    super.key,
    required this.vendors,
    required this.companyId,
    required this.pinnedVendorIds,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return _AnimatedVendorEntry(
          key: ValueKey('vendor-entry-${vendor.vendorId}-$index'),
          index: index,
          child: VendorListItem(
            vendor: vendor,
            companyId: companyId,
            isPinned: pinnedVendorIds.contains(vendor.vendorId),
            onTogglePin: () => onTogglePin(vendor.vendorId),
          ),
        );
      },
    );
  }
}

class _AnimatedVendorEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedVendorEntry({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 210 + (index > 7 ? 7 : index) * 30);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
    );
  }
}
