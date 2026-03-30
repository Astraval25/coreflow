import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class VendorInfoTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;
  final Color? valueColor;

  const VendorInfoTile({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (value?.trim().isNotEmpty ?? false) ? value! : '—';

    final effectiveValueColor =
        valueColor ??
        (displayValue == '—'
            ? LoginColors.textTertiary
            : LoginColors.textPrimary);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LoginColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: LoginColors.primary),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: LoginColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: effectiveValueColor,
                    fontWeight: displayValue == '—'
                        ? FontWeight.w500
                        : FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
