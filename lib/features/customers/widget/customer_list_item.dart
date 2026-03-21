import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/customers/view_model/customers_view_model.dart';

class CustomerListItem extends StatelessWidget {
  final dynamic customer;
  final int companyId;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    String avatarText = '?';
    if (customer.displayName.isNotEmpty) {
      avatarText = customer.displayName[0].toUpperCase();
    } else if (customer.customerCompanyName.isNotEmpty) {
      avatarText = customer.customerCompanyName[0].toUpperCase();
    }

    // final bool isActive = customer.isActive;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: LoginColors.borderLight, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: LoginColors.primaryLight.withOpacity(0.12),
        highlightColor: LoginColors.primaryLight.withOpacity(0.06),
        onTap: () async {
          await context.push('/customers/$companyId/${customer.customerId}');
          if (context.mounted) {
            context.read<ActiveCustomersViewModel>().refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: customer.customerCompanyId != null
                    ? () => context.push('/marketplace/${customer.customerCompanyId}')
                    : null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: customer.customerCompanyId != null
                        ? LoginColors.success.withOpacity(0.15)
                        : primaryColor.withOpacity(0.15),
                    child: Text(
                      avatarText,
                      style: TextStyle(
                        color: customer.customerCompanyId != null
                            ? LoginColors.success
                            : primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Details ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                        letterSpacing: 0.05,
                        height: 1.2,
                      ),
                    ),
                    if (customer.customerCompanyName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.customerCompanyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: LoginColors.successLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (customer.email != null &&
                            customer.email!.isNotEmpty)
                          _buildTag(
                            customer.email!,
                            LoginColors.textTertiary,
                            Icons.email_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (customer.dueAmount.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(
                  customer.dueAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _getDueAmountColor(customer.dueAmount),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueAmountColor(String amount) {
    final parsed = double.tryParse(amount.replaceAll(',', ''));
    if (parsed == null || parsed == 0) return LoginColors.textSecondary;
    return parsed < 0 ? LoginColors.error : LoginColors.success;
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withOpacity(0.7)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
