import 'package:coreflow/features/customers/widget/customer_list_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: customers.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return CustomerListItem(customer: customer, companyId: companyId);
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    context.push('/customers/$companyId/add');
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
          ),
        ],
      ),
    );
  }
}
