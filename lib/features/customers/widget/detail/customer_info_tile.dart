import 'package:flutter/material.dart';

class CustomerInfoTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;

  const CustomerInfoTile({
    super.key,
    this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue =
        (value?.trim().isNotEmpty ?? false) ? value! : '—';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null
          ? Icon(icon, color: theme.colorScheme.onSurfaceVariant)
          : null,
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(displayValue, style: theme.textTheme.bodyMedium),
    );
  }
}
