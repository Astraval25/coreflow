import 'package:flutter/material.dart';

class ResendOtpButton extends StatefulWidget {
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
  State<ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  bool _isClicked = false;

  void _handlePress() {
    if (widget.canResend && !_isClicked && widget.onPressed != null) {
      _isClicked = false;
      setState(() {});
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.canResend && !_isClicked;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.refresh,
          color: isEnabled ? Colors.orange.shade600 : Colors.grey,
          size: 20,
        ),
        label: Text(
          isEnabled ? 'Resend OTP' : 'Resend OTP in ${widget.timer}s',
          style: TextStyle(
            color: isEnabled ? Colors.orange.shade700 : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: isEnabled ? Colors.orange : Colors.grey,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isEnabled ? _handlePress : null,
      ),
    );
  }
}
