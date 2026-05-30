import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_details_view_page.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_detail_body.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_error_state.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_expand_more_option.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
            final vendor = vm.vendor!;
            return InkWell(
              onTap: () => _openVendorDetailsPage(context, vendor),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        vendor.vendorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
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
              final phone = vm.vendor!.phone?.trim() ?? '';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phone.isNotEmpty) ...[
                    IconButton(
                      onPressed: () => _openWhatsApp(context, phone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _makeCall(context, phone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
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
                      if (value == 'edit') {
                        await context.push(
                          CfRoutes.vendorUpdate(vm.companyId, vm.vendorId),
                        );
                        vm.loadVendorDetail();
                      } else if (value == 'activate') {
                        await _changeVendorActiveStatus(
                          context,
                          vm,
                          makeActive: true,
                        );
                      } else if (value == 'deactivate') {
                        await _changeVendorActiveStatus(
                          context,
                          vm,
                          makeActive: false,
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final isActive = vm.vendor?.isActive ?? false;
                      return [
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
                                style: TextStyle(
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 6),
                        PopupMenuItem(
                          value: isActive ? 'deactivate' : 'activate',
                          textStyle: TextStyle(
                            color: isActive
                                ? LoginColors.error
                                : LoginColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.toggle_off_rounded
                                    : Icons.toggle_on_rounded,
                                size: 20,
                                color: isActive
                                    ? LoginColors.error
                                    : LoginColors.success,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isActive ? 'Set Inactive' : 'Set Active',
                                style: TextStyle(
                                  color: isActive
                                      ? LoginColors.error
                                      : LoginColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
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

    return Column(children: [VendorDetailBody(vendor: vm.vendor!)]);
  }

  void _openVendorDetailsPage(BuildContext context, VendorsDetailData vendor) {
    final vm = context.read<VendorDetailViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VendorDetailsViewPage(vendor: vendor),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final whatsappPhone = cleanPhone.startsWith('+')
        ? cleanPhone.substring(1)
        : cleanPhone;
    final launched = await launchUrl(
      Uri.parse('https://wa.me/$whatsappPhone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _makeCall(BuildContext context, String phone) async {
    final launched = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not start call')));
    }
  }

  Future<void> _changeVendorActiveStatus(
    BuildContext context,
    VendorDetailViewModel vm, {
    required bool makeActive,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(makeActive ? 'Set vendor active?' : 'Set vendor inactive?'),
        content: Text(
          makeActive
              ? 'This vendor will become active again.'
              : 'This vendor will be marked inactive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(makeActive ? 'Set Active' : 'Set Inactive'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = makeActive
        ? await vm.activateVendor()
        : await vm.deactivateVendor();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (makeActive ? 'Vendor set active' : 'Vendor set inactive')
              : (vm.errorMessage ?? 'Failed to update vendor status'),
        ),
        backgroundColor: success ? LoginColors.success : LoginColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
