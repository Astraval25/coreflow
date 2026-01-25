import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/customers/widget/detail/customer_header.dart';
import 'package:coreflow/features/customers/widget/detail/customer_detail_body.dart';
import 'package:coreflow/features/customers/widget/detail/customer_empty_state.dart';
import 'package:coreflow/features/customers/widget/detail/customer_error_state.dart';
import '../view_model/customer_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';
import '../../dashboard/widget/menu.dart';

class CustomerDetailContent extends StatelessWidget {
  const CustomerDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardVM = context.read<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
        leading: Builder(
          builder: (scaffoldContext) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            );
          },
        ),
        title: Consumer<CustomerDetailViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading || vm.customer == null) {
              return const Text(
                'Customer Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              );
            }
            return Text(
              vm.customer!.customerName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            );
          },
        ),
        actions: [
          Consumer<CustomerDetailViewModel>(
            builder: (context, vm, child) {
              if (vm.customer == null || vm.isLoading) {
                return const SizedBox(width: 10);
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      await context.push(
                        '/customers/${vm.companyId}/${vm.customerId}/edit',
                      );
                      // Reload detail after coming back from edit
                      vm.loadCustomerDetail();
                      break;
                    case 'otherAction':
                      if (vm.customer != null) {
                        vm.isActive
                            ? vm.deactivateCustomer(context)
                            : vm.activateCustomer(context);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        Text(
                          'Edit',
                          style: TextStyle(color: LoginColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'otherAction',
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          // Small typo fix in label text
                          vm.isActive ? 'Make inactive' : 'Make active',
                          style: const TextStyle(
                            color: LoginColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVM),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.customer == null) {
            return const Center(
              child: CircularProgressIndicator(color: LoginColors.primary),
            );
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

          return Column(
            children: [
              CustomerHeader(
                customer: vm.customer!,
                onToggleStatus: () => vm.isActive
                    ? vm.deactivateCustomer(context)
                    : vm.activateCustomer(context),
              ),
              Expanded(child: CustomerDetailBody(customer: vm.customer!)),
            ],
          );
        },
      ),
    );
  }
}
