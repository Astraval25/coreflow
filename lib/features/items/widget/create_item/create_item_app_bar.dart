import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CreateItemAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;

  const CreateItemAppBar({super.key, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Create Item',
        style: TextStyle(
          color: LoginColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      foregroundColor: LoginColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: LoginColors.background,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: onMenuTap,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
