import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/customers/widget/detail/customer_header.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/features/customers/widget/detail/customer_detail_body.dart';
import 'package:coreflow/features/customers/widget/detail/customer_error_state.dart';
import '../view_model/customer_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';

class CustomerDetailContent extends StatelessWidget {
  const CustomerDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);
    final dashboardVM = context.read<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
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
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                color: LoginColors.surface,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: LoginColors.borderLight),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      await context.push(
                        '/customers/${vm.companyId}/${vm.customerId}/edit',
                      );
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
                  PopupMenuItem(
                    value: 'edit',
                    textStyle: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: LoginColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(color: LoginColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'otherAction',
                    textStyle: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          vm.isActive ? Icons.circle : Icons.circle,
                          size: 18,
                          color: vm.isActive
                              ? const Color.fromARGB(255, 255, 0, 0)
                              : const Color.fromARGB(255, 0, 255, 0),
                        ),

                        const SizedBox(width: 8),
                        Text(
                          vm.isActive ? 'Make inactive' : 'Make active',
                          style: TextStyle(color: LoginColors.textPrimary),
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
          return RefreshIndicator(
            onRefresh: () async => vm.loadCustomerDetail(),
            backgroundColor: LoginColors.surface,
            color: LoginColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: _buildBody(context, vm),
              ),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = constraints.maxHeight;
            final vm = context.watch<CustomerDetailViewModel>();

            if (vm.isLoading && vm.customer == null) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: const Center(
                  child: CircularProgressIndicator(color: LoginColors.primary),
                ),
              );
            }

            if (vm.isError) {
              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: CustomerErrorState(
                  message: vm.errorMessage ?? 'Failed to load customer data',
                  onRetry: vm.loadCustomerDetail,
                ),
              );
            }

            // if (vm.customer == null) {
            //   return ConstrainedBox(
            //     constraints: BoxConstraints(minHeight: minHeight),
            //     child: const CustomerEmptyState(),
            //   );
            // }

            // Main content
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
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerDetailViewModel vm) {
    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LoginColors.borderLight, width: 1),
              ),
              child: Row(
                children: [
                  const Skeleton(height: 70, width: 70, borderRadius: 35),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 24, width: 180),
                        const SizedBox(height: 12),
                        const Skeleton(height: 16, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Body Skeletons
            const Skeleton(
              height: 200,
              width: double.infinity,
              borderRadius: 24,
            ),
            const SizedBox(height: 24),
            const Skeleton(
              height: 180,
              width: double.infinity,
              borderRadius: 24,
            ),
          ],
        ),
      );
    }

    if (vm.isError) {
      return CustomerErrorState(
        message: vm.errorMessage ?? 'Failed to load customer data',
        onRetry: vm.loadCustomerDetail,
      );
    }

    return Column(
      children: [
        CustomerHeader(
          customer: vm.customer!,
          onToggleStatus: () => vm.isActive
              ? vm.deactivateCustomer(context)
              : vm.activateCustomer(context),
        ),
        CustomerDetailBody(customer: vm.customer!),
      ],
    );
  }
}
