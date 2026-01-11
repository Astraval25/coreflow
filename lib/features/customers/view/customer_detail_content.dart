import 'package:coreflow/features/customers/widget/detail/customer_detail_body.dart';
import 'package:coreflow/features/customers/widget/detail/customer_empty_state.dart';
import 'package:coreflow/features/customers/widget/detail/customer_error_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_model/customer_detail_view_model.dart';

class CustomerDetailContent extends StatelessWidget {
  const CustomerDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Customer details'),
        actions: [
          Consumer<CustomerDetailViewModel>(
            builder: (context, vm, child) {
              if (vm.customer == null || vm.isLoading) {
                return const SizedBox(width: 10);
              }
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  context.push(
                    '/customers/${vm.companyId}/${vm.customerId}/edit',
                  );
                },
                tooltip: 'Edit Customer',
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.isError) {
            return CustomerErrorState(
              message: vm.errorMessage ?? 'Failed to load customer data',
              onRetry: vm.loadCustomerDetail,
            );
          }

          if (!vm.hasData || vm.customer == null) {
            return const CustomerEmptyState();
          }

          return CustomerDetailBody(customer: vm.customer!);
        },
      ),
      drawer: const Drawer(),
    );
  }
}
