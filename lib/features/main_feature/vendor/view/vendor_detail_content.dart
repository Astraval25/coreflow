import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_detail_body.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_error_state.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_expand_more_option.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_item_section.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_address_tile.dart';
import 'package:coreflow/routing/cf_routes.dart';
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
              onTap: () => _openVendorProfileSheet(context, vendor),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
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
              if (vm.isLoading || vm.vendor == null) {
                return const SizedBox.shrink();
              }
              return _VendorBalanceChip(amount: vm.vendor!.dueAmount ?? 0);
            },
          ),
          const SizedBox(width: 6),
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
                      await context.push(
                        CfRoutes.vendorUpdate(vm.companyId, vm.vendorId),
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
        VendorDetailBody(vendor: vm.vendor!),
      ],
    );
  }

  void _openVendorProfileSheet(BuildContext context, VendorsDetailData vendor) {
    final vm = context.read<VendorDetailViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _VendorProfileSheet(vendor: vendor),
      ),
    );
  }
}

class _VendorProfileSheet extends StatelessWidget {
  final VendorsDetailData vendor;

  const _VendorProfileSheet({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.92;
    final Address? shippingToShow =
        (vendor.sameAsBillingAddress || vendor.shippingAddress == null)
        ? vendor.billingAddress
        : vendor.shippingAddress;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: LoginColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: LoginColors.primary.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: LoginColors.primaryDark,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vendor.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  _VendorProfileDetailsSection(vendor: vendor),
                  _VendorCompanyLinkSection(vendor: vendor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        VendorAddressTile(
                          title: 'Billing Address',
                          address: vendor.billingAddress,
                        ),
                        if (shippingToShow != null)
                          VendorAddressTile(
                            title: 'Shipping Address',
                            address: shippingToShow,
                          ),
                      ],
                    ),
                  ),
                  const VendorItemSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorProfileDetailsSection extends StatelessWidget {
  final VendorsDetailData vendor;

  const _VendorProfileDetailsSection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    String valueOrDash(String? value) {
      final cleaned = value?.trim() ?? '';
      return cleaned.isEmpty ? '-' : cleaned;
    }

    Widget tile({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: LoginColors.fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: LoginColors.primary),
            const SizedBox(width: 10),
            SizedBox(
              width: 78,
              child: Text(
                label,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                width: 50,
                decoration: BoxDecoration(
                  color: LoginColors.textPrimary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        tile(icon: Icons.email_outlined, label: 'Email', value: valueOrDash(vendor.email)),
        tile(icon: Icons.phone_outlined, label: 'Phone', value: valueOrDash(vendor.phone)),
        tile(icon: Icons.badge_outlined, label: 'PAN', value: valueOrDash(vendor.pan)),
        tile(icon: Icons.receipt_long_outlined, label: 'GST', value: valueOrDash(vendor.gst)),
        tile(icon: Icons.language_rounded, label: 'Language', value: valueOrDash(vendor.lang)),
      ],
    );
  }
}

class _VendorCompanyLinkSection extends StatelessWidget {
  final VendorsDetailData vendor;

  const _VendorCompanyLinkSection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final linkedCompany = vendor.vendorCompany;
    final linkedName = linkedCompany?.companyName?.trim() ?? '';
    final companyId = linkedCompany?.companyId;
    final hasLink = companyId != null && linkedName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFB07A00).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB07A00).withValues(alpha: 0.55)),
        ),
        child: InkWell(
          onTap: hasLink ? () => context.push(CfRoutes.marketplaceCompany(companyId)) : null,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, size: 18, color: Color(0xFFB07A00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLink ? linkedName : 'Company not linked',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A5A00),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasLink)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFF8A5A00),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorBalanceChip extends StatelessWidget {
  final double amount;

  const _VendorBalanceChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isAdvance = amount >= 0;
    final color = isAdvance ? LoginColors.success : LoginColors.error;
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        '${isAdvance ? 'Adv' : 'Due'} ${formatMoney(amount.abs())}',
        style: TextStyle(
          color: color.withValues(alpha: 0.92),
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
