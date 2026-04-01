import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileRow extends StatelessWidget {
  final DashboardViewModel vm;

  const ProfileRow({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final userName = vm.userName ?? 'User';
    final userEmail = vm.email ?? 'No email provided';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        border: Border(
          top: BorderSide(color: LoginColors.borderLight, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          final authData = await TokenStorage.getFullAuthData();
          final userId = int.tryParse(authData?['userId']?.toString() ?? '');
          if (userId != null && context.mounted) {
            context.push(CfRoutes.profile(userId));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LoginColors.borderLight, width: 1),
          ),
          child: Row(
            children: [
              _buildAvatar(userName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: LoginColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: LoginColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: LoginColors.shadowLight.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: LoginColors.textTertiary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final color = _getAvatarColor(name);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha:0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF0F172A), // Slate 900
      Color(0xFF1E293B), // Slate 800
      Color(0xFF334155), // Slate 700
      Color(0xFF475569), // Slate 600
      Color(0xFF64748B), // Slate 500
      Color(0xFF0D9488), // Teal 600
      Color(0xFF0891B2), // Cyan 600
      Color(0xFF2563EB), // Blue 600
      Color(0xFF4F46E5), // Indigo 600
      Color(0xFF7C3AED), // Violet 600
      Color(0xFF9333EA), // Purple 600
      Color(0xFFC026D3), // Fuchsia 600
      Color(0xFFDB2777), // Pink 600
      Color(0xFFE11D48), // Rose 600
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
}
