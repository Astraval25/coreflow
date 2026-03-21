import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:flutter/material.dart';

class CompanyProfilePage extends StatefulWidget {
  final int companyId;

  const CompanyProfilePage({super.key, required this.companyId});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  MarketplaceCompany? _company;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final companies = await AuthRepository().getAllCompanies();
      final match = companies.where((c) => c.companyId == widget.companyId);
      if (match.isNotEmpty) {
        _company = match.first;
      } else {
        _error = 'Company not found';
      }
    } catch (e) {
      _error = 'Failed to load company';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LoginColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: LoginColors.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: LoginColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCompany,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildProfile(_company!),
    );
  }

  Widget _buildProfile(MarketplaceCompany company) {
    final initial = company.companyName.isNotEmpty
        ? company.companyName[0].toUpperCase()
        : '?';

    return CustomScrollView(
      slivers: [
        // ── Gradient App Bar ──
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          stretch: true,
          backgroundColor: DashboardColors.headerGradientStart,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DashboardColors.headerGradientStart,
                    DashboardColors.headerGradientEnd,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      company.companyName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    if (company.industry != null &&
                        company.industry!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          company.industry!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Body ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              children: [
                // Status & GST badges
                Row(
                  children: [
                    _buildBadge(
                      icon: company.isActive
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      label: company.isActive ? 'Active' : 'Inactive',
                      color: company.isActive
                          ? LoginColors.success
                          : LoginColors.error,
                    ),
                    const SizedBox(width: 10),
                    _buildBadge(
                      icon: company.isGstVerified
                          ? Icons.verified_rounded
                          : Icons.gpp_maybe_outlined,
                      label: company.isGstVerified
                          ? 'GST Verified'
                          : 'GST Not Verified',
                      color: company.isGstVerified
                          ? LoginColors.success
                          : LoginColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Company details card
                _buildSection(
                  title: 'Company Information',
                  icon: Icons.business_rounded,
                  children: [
                    _buildDetailRow('Company Name', company.companyName),
                    if (company.shortName != null)
                      _buildDetailRow('Short Name', company.shortName!),
                    if (company.industry != null)
                      _buildDetailRow('Industry', company.industry!),
                  ],
                ),
                const SizedBox(height: 16),

                // Tax & Compliance card
                _buildSection(
                  title: 'Tax & Compliance',
                  icon: Icons.receipt_long_rounded,
                  children: [
                    _buildDetailRow(
                      'GST Number',
                      company.gstNo ?? 'Not provided',
                      valueColor: company.gstNo == null
                          ? LoginColors.textTertiary
                          : null,
                    ),
                    _buildDetailRow(
                      'PAN',
                      "Verified" ?? 'Not Verified',
                      valueColor: company.pan == null
                          ? LoginColors.textTertiary
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Meta info card
                _buildSection(
                  title: 'Other Details',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _buildDetailRow('Company ID', company.companyId.toString()),
                    _buildDetailRow(
                      'Company Joining Date',
                      _formatDate(company.createdDt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LoginColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LoginColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: LoginColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: LoginColors.borderLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? LoginColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
