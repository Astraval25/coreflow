import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessPopup({
  required BuildContext context,
  required String message,
  String title = 'Success',
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha:0.35),
    builder: (context) => SuccessPopup(title: title, message: message),
  );
}

class SuccessPopup extends StatefulWidget {
  final String title;
  final String message;

  const SuccessPopup({super.key, required this.title, required this.message});

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto close after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: LoginColors.surface.withValues(alpha:
                0.92,
              ), // Light transparent look
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: LoginColors.success.withValues(alpha:0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with nice glow
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoginColors.success.withValues(alpha:0.10),
                  ),
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LoginColors.success,
                        boxShadow: [
                          BoxShadow(
                            color: LoginColors.success.withValues(alpha:0.45),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.5,
                    height: 1.5,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
