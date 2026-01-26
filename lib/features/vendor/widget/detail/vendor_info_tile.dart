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
    final theme = Theme.of(context);

    final displayValue = (value?.trim().isNotEmpty ?? false) ? value! : '—';

    final effectiveValueColor =
        valueColor ??
        (displayValue == '—'
            ? LoginColors.textTertiary
            : LoginColors.textPrimary);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null
          ? Icon(icon, color: LoginColors.textPrimary.withOpacity(0.75))
          : null,
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: LoginColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        displayValue,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: effectiveValueColor,
          fontWeight: displayValue == '—' ? FontWeight.normal : FontWeight.w600,
        ),
      ),
    );
  }
}
