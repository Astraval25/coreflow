import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ResendOtpButton extends StatelessWidget {
  final bool canResend;
  final int timer;
  final VoidCallback? onPressed;

  const ResendOtpButton({
    super.key,
    required this.canResend,
    required this.timer,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = canResend && onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.refresh_rounded,
          color: isEnabled ? LoginColors.primary : LoginColors.textTertiary,
          size: 20,
        ),
        label: Text(
          isEnabled ? 'Resend OTP' : 'Resend OTP in ${timer}s',
          style: TextStyle(
            color: isEnabled ? LoginColors.primary : LoginColors.textTertiary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: isEnabled ? LoginColors.primary : LoginColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }
}
