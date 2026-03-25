import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorHeader extends StatelessWidget {
  final VendorsDetailData vendor;
  final VoidCallback onToggleStatus;
  static const double _horizontalPadding = 20;

  const VendorHeader({
    super.key,
    required this.vendor,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    // final isActive = vendor.isActive;
    // final statusColor = isActive ? LoginColors.success : LoginColors.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_horizontalPadding, 16, _horizontalPadding, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: LoginColors.primary.withOpacity(0.14),
              child: Icon(
                Icons.storefront_rounded,
                size: 31,
                color: LoginColors.primaryDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (vendor.vendorCompany != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        final companyId = vendor.vendorCompany!.companyId;
                        if (companyId != null) {
                          context.push('/marketplace/$companyId');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 14,
                            color: LoginColors.success,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor.vendorCompany!.companyName ?? '—',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: LoginColors.success,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: LoginColors.success.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
