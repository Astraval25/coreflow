import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_orders_payments_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorDetailBody extends StatefulWidget {
  final VendorsDetailData vendor;
  static const double _horizontal = 20;

  const VendorDetailBody({super.key, required this.vendor});

  @override
  State<VendorDetailBody> createState() => _VendorDetailBodyState();
}

class _VendorDetailBodyState extends State<VendorDetailBody> {
  VendorTransactionFilter _selectedFilter = VendorTransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final vm = context.watch<VendorDetailViewModel>();
    final isLinked = vendor.vendorCompany != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLinkCompanyStrip(context, vm, isLinked),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            VendorDetailBody._horizontal,
            6,
            VendorDetailBody._horizontal,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                'Orders & Payments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 120),
          child: VendorOrdersPaymentsSection(filter: _selectedFilter),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return PopupMenuButton<VendorTransactionFilter>(
      onSelected: (value) => setState(() => _selectedFilter = value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: VendorTransactionFilter.all, child: Text('All')),
        PopupMenuItem(
          value: VendorTransactionFilter.payments,
          child: Text('Payment'),
        ),
        PopupMenuItem(value: VendorTransactionFilter.orders, child: Text('Order')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labelFor(_selectedFilter),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: LoginColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(VendorTransactionFilter filter) {
    switch (filter) {
      case VendorTransactionFilter.all:
        return 'All';
      case VendorTransactionFilter.payments:
        return 'Payment';
      case VendorTransactionFilter.orders:
        return 'Order';
    }
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    VendorDetailViewModel vm,
    bool isLinked,
  ) {
    if (isLinked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VendorDetailBody._horizontal,
        6,
        VendorDetailBody._horizontal,
        6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha: 0.07),
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
            if (context.mounted &&
                response != null &&
                !response.responseStatus) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
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
                  duration: const Duration(seconds: 2),
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
}
