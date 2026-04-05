import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorBottomOptionsPanel extends StatelessWidget {
  final VendorDetailViewModel vm;
  final VendorsDetailData vendor;

  const VendorBottomOptionsPanel({
    super.key,
    required this.vm,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          border: Border.all(color: LoginColors.borderLight),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.shopping_cart_rounded,
                  label: 'Create Purchase',
                  color: LoginColors.primary,
                  onTap: () => context.push(
                    CfRoutes.purchaseCreate(vm.companyId),
                    extra: {
                      'preSelectedVendor': {
                        'vendorId': vendor.vendorId,
                        'displayName': vendor.vendorName,
                        'vendorCompanyName': vendor.vendorCompany?.companyName ?? '',
                        'vendorCompanyId': vendor.vendorCompany?.companyId,
                        'email': vendor.email,
                        'isActive': vendor.isActive,
                        'dueAmount': '',
                      },
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.payment_rounded,
                  label: 'Make Payment',
                  color: LoginColors.success,
                  onTap: () => context.push(
                    CfRoutes.paymentMadeCreate(vm.companyId),
                    extra: {
                      'preSelectedVendor': {
                        'vendorId': vendor.vendorId,
                        'displayName': vendor.vendorName,
                        'vendorCompanyName': vendor.vendorCompany?.companyName ?? '',
                        'vendorCompanyId': vendor.vendorCompany?.companyId,
                        'email': vendor.email,
                        'isActive': vendor.isActive,
                        'dueAmount': '',
                      },
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
