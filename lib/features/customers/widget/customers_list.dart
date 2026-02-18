import 'package:coreflow/features/customers/widget/customer_list_item.dart';
import 'package:flutter/material.dart';

class CustomersList extends StatelessWidget {
  final List<dynamic> customers;
  final int companyId;

  const CustomersList({
    super.key,
    required this.customers,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _AnimatedCustomerEntry(
          key: ValueKey('customer-entry-${customer.customerId}-$index'),
          index: index,
          child: CustomerListItem(customer: customer, companyId: companyId),
        );
      },
    );
  }
}

class _AnimatedCustomerEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedCustomerEntry({
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
