import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class UpdateItemAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UpdateItemAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Edit Item',
        style: TextStyle(
          color: LoginColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      foregroundColor: LoginColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: LoginColors.background,
    );
  }
}
