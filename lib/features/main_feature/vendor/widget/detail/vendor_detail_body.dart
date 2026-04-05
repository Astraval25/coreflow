import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_address_tile.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_item_section.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_orders_payments_section.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/vendor_financial_strip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorDetailBody extends StatefulWidget {
  final VendorsDetailData vendor;

  const VendorDetailBody({super.key, required this.vendor});

  @override
  State<VendorDetailBody> createState() => _VendorDetailBodyState();
}

class _VendorDetailBodyState extends State<VendorDetailBody> {
  int _selectedIndex = 0;
  static const double _horizontal = 20;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;

    final vm = context.watch<VendorDetailViewModel>();
    final isLinked = vendor.vendorCompany != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorFinancialStrip(vendor: vendor),
        _buildLinkCompanyStrip(context, vm, vendor, isLinked),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabText('Transaction', 0),
                  _buildTabText('Items', 1),
                  _buildTabText('Address', 2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(_horizontal, 14, _horizontal, 120),
          child: Container(
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LoginColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.shadowLight.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildSelectedSection(vendor),
          ),
        ),
      ],
    );
  }

  Widget _buildTabText(String title, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? LoginColors.primaryDark
                    : LoginColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    VendorDetailViewModel vm,
    VendorsDetailData vendor,
    bool isLinked,
  ) {
    if (isLinked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(_horizontal, 6, _horizontal, 0),
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha:0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LinkCompanySection(
          isLinked: false,
          isLoading: vm.isInvitationLoading,
          invitationCode: vm.invitationData?.invitationCode,
          onGenerateCode: () async {
            final response = await vm.sendInvitation();
            if (context.mounted && response != null && !response.responseStatus) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text(response.responseMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onGetExistingCode: () async {
            final response = await vm.getInvitationCode();
            if (context.mounted && response == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('No existing invitation code found'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onAcceptCode: (code) async {
            final response = await vm.acceptInvitation(code);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text(
                    response?.responseStatus == true
                        ? 'Company linked successfully'
                        : response?.responseMessage ?? 'Failed to link company',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: response?.responseStatus == true
                      ? Colors.green
                      : Colors.red,
                ),
              );
            }
            return response?.responseStatus == true;
          },
        ),
      ),
    );
  }

  Widget _buildSelectedSection(VendorsDetailData vendor) {
    switch (_selectedIndex) {
      case 0:
        return const VendorOrdersPaymentsSection();
      case 1:
        return const VendorItemSection();
      case 2:
        return _AddressSection(vendor: vendor);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
              color: LoginColors.textPrimary.withValues(alpha:0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  final VendorsDetailData vendor;

  const _AddressSection({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final Address? shippingToShow =
        (vendor.sameAsBillingAddress || vendor.shippingAddress == null)
        ? vendor.billingAddress
        : vendor.shippingAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Address Details'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VendorAddressTile(
                title: 'Billing Address',
                address: vendor.billingAddress,
              ),
              if (shippingToShow != null) ...[
                const SizedBox(height: 8),
                VendorAddressTile(
                  title: 'Shipping Address',
                  address: shippingToShow,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

