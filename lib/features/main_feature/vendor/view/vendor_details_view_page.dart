import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_item_section.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_address_tile.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorDetailsViewPage extends StatelessWidget {
  final VendorsDetailData vendor;

  const VendorDetailsViewPage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);
    final Address? shippingToShow =
        (vendor.sameAsBillingAddress || vendor.shippingAddress == null)
        ? vendor.billingAddress
        : vendor.shippingAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vendor.vendorName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            _VendorProfileDetailsSection(vendor: vendor),
            const _VendorCompanyLinkSection(),
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
            Consumer<VendorDetailViewModel>(
              builder: (context, vm, _) {
                final currentVendor = vm.vendor ?? vendor;
                return _VendorWhatsAppActionTile(vendor: currentVendor);
              },
            ),
            Consumer<VendorDetailViewModel>(
              builder: (context, vm, _) {
                final currentVendor = vm.vendor ?? vendor;
                return _VendorBlockActionTile(vm: vm, vendor: currentVendor);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorWhatsAppActionTile extends StatelessWidget {
  final VendorsDetailData vendor;

  const _VendorWhatsAppActionTile({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final phone = vendor.phone?.trim() ?? '';
    final isEnabled = phone.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isEnabled ? () => _openWhatsApp(context, phone) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_rounded,
                  color: isEnabled
                      ? const Color(0xFF25D366)
                      : LoginColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'View on WhatsApp',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isEnabled
                          ? LoginColors.textPrimary
                          : LoginColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: LoginColors.textSecondary,
                ),
              ],
            ),
          ),
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
}

class _VendorBlockActionTile extends StatelessWidget {
  final VendorDetailViewModel vm;
  final VendorsDetailData vendor;

  const _VendorBlockActionTile({required this.vm, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final isConnected = vendor.isFullyConnected;
    final isPending = vendor.connectionStatus == 'PENDING';
    final canAcceptAgain =
        !isConnected && vendor.connectionStatus == 'REJECTED';
    final canTap = isConnected || canAcceptAgain;
    final isBusy = vm.isConnectionLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: (isBusy || !canTap)
              ? null
              : () => _onBlockToggle(context, isLinked: isConnected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.block_rounded : Icons.lock_open_rounded,
                  color: isConnected
                      ? LoginColors.error
                      : (canAcceptAgain
                            ? LoginColors.success
                            : LoginColors.textSecondary),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isConnected
                        ? 'Block Vendor'
                        : (canAcceptAgain
                              ? 'Accept Link Request'
                              : (isPending
                                    ? 'Link Request Pending'
                                    : 'No Linked Company')),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isConnected
                          ? LoginColors.error
                          : (canAcceptAgain
                                ? LoginColors.success
                                : LoginColors.textSecondary),
                    ),
                  ),
                ),
                if (isBusy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LoginColors.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: LoginColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBlockToggle(
    BuildContext context, {
    required bool isLinked,
  }) async {
    final isUnlinkFlow = isLinked;
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isUnlinkFlow ? 'Disconnect company link?' : 'Accept link request?',
        ),
        content: Text(
          isUnlinkFlow
              ? 'This will remove the current company link and show link request acceptance again.'
              : 'This will accept the pending/rejected link request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isUnlinkFlow ? 'Disconnect' : 'Accept'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    final success = await vm.undoConnectionDecision(
      isUnlinkFlow ? 'REJECTED' : 'ACCEPTED',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isUnlinkFlow
                    ? 'Company link disconnected'
                    : 'Link request accepted')
              : (vm.errorMessage ?? 'Failed to update status'),
        ),
        backgroundColor: success ? LoginColors.success : LoginColors.error,
        behavior: SnackBarBehavior.floating,
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
        tile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: valueOrDash(vendor.email),
        ),
        tile(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: valueOrDash(vendor.phone),
        ),
        tile(
          icon: Icons.badge_outlined,
          label: 'PAN',
          value: valueOrDash(vendor.pan),
        ),
        tile(
          icon: Icons.receipt_long_outlined,
          label: 'GST',
          value: valueOrDash(vendor.gst),
        ),
        tile(
          icon: Icons.language_rounded,
          label: 'Language',
          value: valueOrDash(vendor.lang),
        ),
      ],
    );
  }
}

class _VendorCompanyLinkSection extends StatelessWidget {
  const _VendorCompanyLinkSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorDetailViewModel>(
      builder: (context, vm, _) {
        final vendor = vm.vendor;
        if (vendor == null) return const SizedBox.shrink();

        final linkedCompany = vendor.vendorCompany;
        final linkedName = linkedCompany?.companyName?.trim() ?? '';
        final companyId = linkedCompany?.companyId;
        final hasLink = companyId != null && linkedName.isNotEmpty;
        final canSuggestLink =
            !hasLink &&
            vm.linkSuggestion?.hasAccount == true &&
            vendor.phone?.trim().isNotEmpty == true;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFB07A00).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFB07A00).withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: hasLink
                      ? () =>
                            context.push(CfRoutes.marketplaceCompany(companyId))
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 18,
                        color: Color(0xFFB07A00),
                      ),
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
                if (!hasLink && vm.isLinkSuggestionLoading) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Checking account by phone...',
                        style: TextStyle(
                          color: Color(0xFF8A5A00),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (canSuggestLink) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Account found (${vm.linkSuggestion?.accountCompanyName ?? 'CoreFlow company'}). Link now?',
                    style: const TextStyle(
                      color: Color(0xFF8A5A00),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: vm.isLinkingByPhone
                        ? null
                        : () async {
                            final shouldLink = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Confirm link'),
                                content: const Text(
                                  'Link this vendor to the matched CoreFlow account company?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('Link now'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLink != true) return;

                            final success = await vm.linkVendorByPhone();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Link request sent. Waiting for acceptance.'
                                      : (vm.errorMessage ??
                                            'Failed to link vendor'),
                                ),
                              ),
                            );
                          },
                    child: vm.isLinkingByPhone
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Link now'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
