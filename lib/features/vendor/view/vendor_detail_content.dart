import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_detail_body.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_empty_state.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_error_state.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_model/vendor_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';
import '../../dashboard/widget/menu.dart';

class VendorDetailContent extends StatelessWidget {
  const VendorDetailContent({super.key});

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
        title: Consumer<VendorDetailViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading || vm.vendor == null) {
              return const Text(
                'Vendor Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              );
            }
            return Text(
              vm.vendor!.vendorName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            );
          },
        ),
        actions: [
          Consumer<VendorDetailViewModel>(
            builder: (context, vm, child) {
              if (vm.vendor == null || vm.isLoading) {
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
                        '/vendors/${vm.companyId}/${vm.vendorId}/edit',
                      );

                      vm.loadVendorDetail();
                      break;
                    case 'otherAction':
                      if (vm.vendor != null) {
                        vm.isActive
                            ? vm.deactivateVendor(context)
                            : vm.activateVendor(context);
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
      body: Consumer<VendorDetailViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.vendor == null) {
            return const Center(
              child: CircularProgressIndicator(color: LoginColors.primary),
            );
          }

          if (vm.isError) {
            return VendorErrorState(
              message: vm.errorMessage ?? 'Failed to load vendor data',
              onRetry: vm.loadVendorDetail,
            );
          }

          if (!vm.hasData || vm.vendor == null) {
            return const VendorEmptyState();
          }

          return Column(
            children: [
              VendorHeader(
                vendor: vm.vendor!,
                onToggleStatus: () async {
                  if (vm.isActive) {
                    await vm.deactivateVendor(context);
                  } else {
                    await vm.activateVendor(context);
                  }
                },
              ),
              Expanded(child: VendorDetailBody(vendor: vm.vendor!)),
            ],
          );
        },
      ),
    );
  }
}

