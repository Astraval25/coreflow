import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';

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
    final isActive = vendor.isActive;
    final statusColor = isActive ? LoginColors.success : LoginColors.error;

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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onToggleStatus,
              icon: Icon(
                isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                size: 16,
              ),
              label: Text(isActive ? 'Deactivate' : 'Activate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: statusColor,
                side: BorderSide(color: statusColor.withOpacity(0.45)),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
