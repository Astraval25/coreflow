import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/main_feature/profile/view_moodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: LoginColors.background,
        appBar: _buildAppBar(context),
        body: _ProfileBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LoginColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginColors.borderLight, width: 1),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: LoginColors.textPrimary, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight, width: 1),
            ),
            child: Icon(Icons.refresh_rounded,
                color: LoginColors.textPrimary, size: 20),
          ),
          onPressed: () => context.read<ProfileViewModel>().refreshProfile(),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: LoginColors.primary,
              strokeWidth: 3,
            ),
          );
        }

        if (vm.hasError) {
          return _ErrorContent(error: vm.errorMessage ?? 'Unknown error');
        }

        return _ProfileContent(vm: vm);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileViewModel vm;
  const _ProfileContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final userName = vm.userName ?? 'User';
    final userEmail = vm.email ?? 'Not provided';
    final userRole = vm.displayRole;
    final userId = vm.userId?.toString() ?? 'Not available';

    return RefreshIndicator(
      onRefresh: () => vm.refreshProfile(),
      backgroundColor: LoginColors.surface,
      color: LoginColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            _buildHeader(userName, userRole),
            const SizedBox(height: 32),
            _buildInfoSection(context, userEmail, userId),
            const SizedBox(height: 24),
            _buildCompanySection(context),
            const SizedBox(height: 48),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String role) {
    return Column(
      children: [
        _AvatarWithGradient(name: name),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: LoginColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: LoginColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String email, String id) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Account Information'),
          const SizedBox(height: 16),
          _ProfileRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: email,
          ),
          const _Divider(),
          _ProfileRow(
            icon: Icons.fingerprint_rounded,
            label: 'User ID',
            value: id,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection(BuildContext context) {
    final companyName = vm.companyName ?? 'No company';
    final companyIds = vm.companyIds?.join(', ') ?? 'None';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Business Details'),
          const SizedBox(height: 16),
          _ProfileRow(
            icon: Icons.business_rounded,
            label: 'Active Company',
            value: companyName,
          ),
          const _Divider(),
          _ProfileRow(
            icon: Icons.view_comfortable_rounded,
            label: 'Linked Companies',
            value: companyIds,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ProfileViewModel>().logout(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Light Red
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Sign Out Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithGradient extends StatelessWidget {
  final String name;
  const _AvatarWithGradient({required this.name});

  @override
  Widget build(BuildContext context) {
    final color = _getAvatarColor(name);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha:0.8)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF0F172A),
      Color(0xFF0D9488),
      Color(0xFF2563EB),
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: LoginColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LoginColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: LoginColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: LoginColors.borderLight, height: 1),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String error;
  const _ErrorContent({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 64, color: LoginColors.error),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: LoginColors.error.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  context.read<ProfileViewModel>().refreshProfile(),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}
