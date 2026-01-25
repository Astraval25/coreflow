import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';

class VendorHeader extends StatelessWidget {
  final VendorsDetailData vendor;
  final VoidCallback onToggleStatus;

  const VendorHeader({
    super.key,
    required this.vendor,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: LoginColors.primary.withOpacity(0.15),
            child: Icon(
              Icons.person_rounded,
              size: 36,
              color: LoginColors.primaryDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onToggleStatus,
                  child: Row(mainAxisSize: MainAxisSize.min),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
