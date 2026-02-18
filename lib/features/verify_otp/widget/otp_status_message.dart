import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class OtpStatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const OtpStatusMessage({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = isError ? LoginColors.error : LoginColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: base.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: base.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: base,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: base,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
