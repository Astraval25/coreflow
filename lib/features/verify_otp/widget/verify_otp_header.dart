import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class VerifyOtpHeader extends StatelessWidget {
  final String? userPath;

  const VerifyOtpHeader({super.key, this.userPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LoginColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_rounded,
            size: 42,
            color: LoginColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userPath != null ? 'Code sent to your email' : 'Enter your 6-digit code',
          style: TextStyle(
            fontSize: 14,
            color: LoginColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (userPath != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: LoginColors.fieldFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: LoginColors.border),
            ),
            child: Text(
              userPath!,
              style: TextStyle(
                fontSize: 13,
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
