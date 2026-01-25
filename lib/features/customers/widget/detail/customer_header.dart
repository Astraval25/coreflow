import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';

class CustomerHeader extends StatelessWidget {
  final CustomerDetailData customer;
  final VoidCallback onToggleStatus;

  const CustomerHeader({
    super.key,
    required this.customer,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = customer.isActive;

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
                  customer.displayName,
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
