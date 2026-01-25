import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';

class VendorListItem extends StatelessWidget {
  final dynamic vendor;
  final int companyId;

  const VendorListItem({
    super.key,
    required this.vendor,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    String avatarText = '?';
    if (vendor.displayName.isNotEmpty) {
      avatarText = vendor.displayName[0].toUpperCase();
    } else if (vendor.vendorCompanyName.isNotEmpty) {
      avatarText = vendor.vendorCompanyName[0].toUpperCase();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: primaryColor.withOpacity(0.15),
          child: Text(
            avatarText,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          vendor.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: _buildSubtitle(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () async {
          await context.push('/vendors/$companyId/${vendor.vendorId}');
          final viewModel = Provider.of<ActiveVendorViewModel>(
            context,
            listen: false,
          );
          await viewModel.refresh();
        },
      ),
    );
  }

  Widget _buildSubtitle() {
    final subtitleChildren = <Widget>[];

    if (vendor.vendorCompanyName.isNotEmpty) {
      subtitleChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            vendor.vendorCompanyName,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    if (vendor.email != null && vendor.email!.isNotEmpty) {
      subtitleChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            vendor.email!,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      );
    }

    if (subtitleChildren.isEmpty) {
      subtitleChildren.add(
        Text(
          'No details available',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtitleChildren,
    );
  }
}
