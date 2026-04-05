import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerHeader extends StatefulWidget {
  final CustomerDetailData customer;
  final VoidCallback onToggleStatus;
  static const double _horizontalPadding = 20;

  const CustomerHeader({
    super.key,
    required this.customer,
    required this.onToggleStatus,
  });

  @override
  State<CustomerHeader> createState() => _CustomerHeaderState();
}

class _CustomerHeaderState extends State<CustomerHeader> {
  bool _expanded = false;

  String _value(String? input) {
    final v = input?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerHeader._horizontalPadding,
        16,
        CustomerHeader._horizontalPadding,
        10,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: LoginColors.primary.withValues(alpha: 0.14),
              child: Icon(
                Icons.person_rounded,
                size: 32,
                color: LoginColors.primaryDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: LoginColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _expanded = !_expanded),
                        icon: Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: LoginColors.textSecondary,
                        ),
                        splashRadius: 20,
                        tooltip: _expanded ? 'Collapse' : 'Expand',
                      ),
                    ],
                  ),
                  if (customer.customerCompany != null) ...[
                    const SizedBox(height: 3),
                    GestureDetector(
                      onTap: () {
                        final companyId = customer.customerCompany!.companyId;
                        if (companyId != null) {
                          context.push(CfRoutes.marketplaceCompany(companyId));
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 13,
                            color: LoginColors.success,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.customerCompany!.companyName ?? '-',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: LoginColors.success,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: LoginColors.success.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    _BasicInfoRow(label: 'Email', value: _value(customer.email)),
                    _BasicInfoRow(label: 'Phone', value: _value(customer.phone)),
                    _BasicInfoRow(label: 'PAN', value: _value(customer.pan)),
                    _BasicInfoRow(label: 'GST', value: _value(customer.gst)),
                    _BasicInfoRow(label: 'Language', value: _value(customer.lang)),
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

class _BasicInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _BasicInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 11.5,
                color: LoginColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
