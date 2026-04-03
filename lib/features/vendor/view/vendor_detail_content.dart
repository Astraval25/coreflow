import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_detail_body.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_error_state.dart';
import 'package:coreflow/features/vendor/widget/detail/vendor_header.dart';
import 'package:coreflow/features/vendor/widget/detail/body/vendor_expand_more_option.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_model/vendor_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';

class VendorDetailContent extends StatelessWidget {
  const VendorDetailContent({super.key});

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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Consumer<VendorDetailViewModel>(
          builder: (context, vm, _) {
            return Text(
              vm.isLoading || vm.vendor == null
                  ? 'Vendor Details'
                  : vm.vendor!.vendorName,
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
            builder: (context, vm, _) {
              if (vm.vendor == null || vm.isLoading) {
                return const SizedBox(width: 10);
              }

              return PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.18),
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
                      context.pushReplacement(
                        '/vendors/${vm.companyId}/${vm.vendorId}/edit',
                      );
                      vm.loadVendorDetail();
                      break;

                    case 'otherAction':
                      vm.isActive
                          ? vm.deactivateVendor(context)
                          : vm.activateVendor(context);
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
                        Icon(
                          vm.isActive
                              ? Icons.block_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: vm.isActive
                              ? LoginColors.error
                              : LoginColors.success,
                        ),
                        const SizedBox(width: 10),
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

      body: Consumer<VendorDetailViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => vm.loadVendorDetail(),
                backgroundColor: LoginColors.surface,
                color: LoginColors.primary,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.maxScrollExtent <= 0) return false;
                    final triggerOffset =
                        notification.metrics.maxScrollExtent * 0.85;
                    if (notification.metrics.pixels >= triggerOffset) {
                      vm.loadMoreOrdersPaymentsIfNeeded();
                    }
                    return false;
                  },
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
                ),
              ),
              if (!vm.isLoading &&
                  !vm.isError &&
                  !vm.isNoData &&
                  vm.vendor != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VendorBottomOptionsPanel(vm: vm, vendor: vm.vendor!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VendorDetailViewModel vm) {
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
      return VendorErrorState(
        message: vm.errorMessage ?? 'Failed to load vendor data',
        onRetry: vm.loadVendorDetail,
      );
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
        VendorDetailBody(vendor: vm.vendor!),
      ],
    );
  }
}
