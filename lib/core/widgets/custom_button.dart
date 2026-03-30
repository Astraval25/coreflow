import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final TextStyle? textStyleOverride;
  final IconData? icon;
  final double iconSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.textStyleOverride,
    this.icon,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: LoginColors.primary,
          disabledBackgroundColor: LoginColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha:0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon == null
            ? Text(
                text,
                style:
                    textStyleOverride ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style:
                        textStyleOverride ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
