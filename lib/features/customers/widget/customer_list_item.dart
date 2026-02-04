import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/customers/view_model/customers_view_model.dart';

class CustomerListItem extends StatelessWidget {
  final dynamic customer;
  final int companyId;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    String avatarText = '?';
    if (customer.displayName.isNotEmpty) {
      avatarText = customer.displayName[0].toUpperCase();
    } else if (customer.customerCompanyName.isNotEmpty) {
      avatarText = customer.customerCompanyName[0].toUpperCase();
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
          customer.displayName,
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
          await context.push('/customers/$companyId/${customer.customerId}');
          final viewModel = Provider.of<ActiveCustomersViewModel>(
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

    if (customer.customerCompanyName.isNotEmpty) {
      subtitleChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            customer.customerCompanyName,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    if (customer.email != null && customer.email!.isNotEmpty) {
      subtitleChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            customer.email!,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtitleChildren,
    );
  }
}
