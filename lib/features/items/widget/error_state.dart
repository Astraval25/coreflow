import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class ErrorState extends StatelessWidget {
  final String message;

  const ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: LoginColors.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}
