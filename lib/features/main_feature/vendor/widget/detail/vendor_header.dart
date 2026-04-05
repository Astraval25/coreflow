import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorHeader extends StatefulWidget {
  final VendorsDetailData vendor;
  final VoidCallback onToggleStatus;
  static const double _horizontalPadding = 20;

  const VendorHeader({
    super.key,
    required this.vendor,
    required this.onToggleStatus,
  });

  @override
  State<VendorHeader> createState() => _VendorHeaderState();
}

class _VendorHeaderState extends State<VendorHeader> {
  bool _expanded = false;

  String _value(String? input) {
    final value = input?.trim() ?? '';
    return value.isEmpty ? '-' : value;
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VendorHeader._horizontalPadding,
        16,
        VendorHeader._horizontalPadding,
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
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: LoginColors.primary.withValues(alpha: 0.14),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.displayName,
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
                        onPressed: () => setState(() => _expanded = !_expanded),
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
                  if (vendor.vendorCompany != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        final companyId = vendor.vendorCompany!.companyId;
                        if (companyId != null) {
                          context.push(CfRoutes.marketplaceCompany(companyId));
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
                              vendor.vendorCompany!.companyName ?? '-',
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
                            color: LoginColors.success.withValues(alpha:0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    _BasicInfoRow(label: 'Email', value: _value(vendor.email)),
                    _BasicInfoRow(label: 'Phone', value: _value(vendor.phone)),
                    _BasicInfoRow(label: 'PAN', value: _value(vendor.pan)),
                    _BasicInfoRow(label: 'GST', value: _value(vendor.gst)),
                    _BasicInfoRow(
                      label: 'Language',
                      value: _value(vendor.lang),
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
