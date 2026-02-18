import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';

class VendorListItem extends StatelessWidget {
  final dynamic vendor;
  final int companyId;

  const VendorListItem({
    super.key,
    required this.vendor,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    String avatarText = '?';
    if (vendor.displayName.isNotEmpty) {
      avatarText = vendor.displayName[0].toUpperCase();
    } else if (vendor.vendorCompanyName.isNotEmpty) {
      avatarText = vendor.vendorCompanyName[0].toUpperCase();
    }

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
          await context.push('/vendors/$companyId/${vendor.vendorId}');
          if (context.mounted) {
            context.read<ActiveVendorViewModel>().refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar ──
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Text(
                  avatarText,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                      vendor.displayName,
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
                    if (vendor.vendorCompanyName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vendor.vendorCompanyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: LoginColors.textSecondary,
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
                        if (vendor.email != null && vendor.email!.isNotEmpty)
                          _buildTag(
                            vendor.email!,
                            LoginColors.textTertiary,
                            Icons.email_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
