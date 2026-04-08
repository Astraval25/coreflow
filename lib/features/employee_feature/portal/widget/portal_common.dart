import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

String portalDisplayDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().padLeft(4, '0');
  return '$day-$month-$year';
}

String portalFormatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

Color portalStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
      return LoginColors.success;
    case 'REJECTED':
      return LoginColors.error;
    default:
      return LoginColors.primary;
  }
}

class PortalStatusBadge extends StatelessWidget {
  final String status;
  const PortalStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = portalStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class PortalEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const PortalEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: LoginColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: LoginColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
