import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/company/marketplace_company.dart';
import 'package:coreflow/domain/model/main_model/company/marketplace_item.dart';
import 'package:flutter/material.dart';

class CompanyProfilePage extends StatefulWidget {
  final int companyId;

  const CompanyProfilePage({super.key, required this.companyId});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  MarketplaceCompany? _company;
  List<MarketplaceItem> _items = [];
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
      final repo = AuthRepository();
      final results = await Future.wait<dynamic>([
        repo.getMarketplaceCompanyById(widget.companyId),
        repo.getMarketplaceCompanyItems(widget.companyId),
      ]);

      final company = results[0] as MarketplaceCompany?;
      final items = results[1] as List<MarketplaceItem>;

      if (company == null) {
        _error = 'Company not found';
      } else {
        _company = company;
        _items = items;
      }
    } catch (e) {
      _error = 'Failed to load company';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          stretch: true,
          backgroundColor: DashboardColors.headerGradientStart,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
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
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: _notEmpty(company.fsId)
                          ? NetworkImage(AppConfig.getFileUrl(company.fsId!))
                          : null,
                      child: _notEmpty(company.fsId)
                          ? null
                          : Text(
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
                    if (_notEmpty(company.industry))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              children: [
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
                      icon: Icons.storefront_rounded,
                      label: _items.isEmpty
                          ? 'No Sellable Items'
                          : '${_items.length} Items',
                      color: _items.isEmpty
                          ? LoginColors.textTertiary
                          : LoginColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Company Information',
                  icon: Icons.business_rounded,
                  children: [
                    _buildDetailRow('Company Name', company.companyName),
                    if (_notEmpty(company.shortName))
                      _buildDetailRow('Short Name', company.shortName!),
                    if (_notEmpty(company.industry))
                      _buildDetailRow('Industry', company.industry!),
                  ],
                ),
                const SizedBox(height: 16),
                if (_notEmpty(company.publicDescription)) ...[
                  _buildSection(
                    title: 'Public Description',
                    icon: Icons.description_rounded,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          company.publicDescription!,
                          style: TextStyle(
                            fontSize: 14,
                            color: LoginColors.textPrimary,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                _buildSection(
                  title: 'Contact',
                  icon: Icons.phone_rounded,
                  children: [
                    if (_notEmpty(company.contactPerson))
                      _buildDetailRow('Person', company.contactPerson!),
                    if (_notEmpty(company.contactEmail))
                      _buildDetailRow('Email', company.contactEmail!),
                    if (_notEmpty(company.contactPhone))
                      _buildDetailRow('Phone', company.contactPhone!),
                    if (_notEmpty(company.website))
                      _buildDetailRow('Website', company.website!),
                    if (!_notEmpty(company.contactPerson) &&
                        !_notEmpty(company.contactEmail) &&
                        !_notEmpty(company.contactPhone) &&
                        !_notEmpty(company.website))
                      _buildDetailRow('Contact', 'Not provided'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Address',
                  icon: Icons.location_on_rounded,
                  children: [
                    _buildDetailRow(
                      'Address Line 1',
                      _valueOrFallback(company.addressLine1),
                    ),
                    _buildDetailRow(
                      'Address Line 2',
                      _valueOrFallback(company.addressLine2),
                    ),
                    _buildDetailRow('City', _valueOrFallback(company.city)),
                    _buildDetailRow('State', _valueOrFallback(company.state)),
                    _buildDetailRow(
                      'Country',
                      _valueOrFallback(company.country),
                    ),
                    _buildDetailRow(
                      'Postal Code',
                      _valueOrFallback(company.postalCode),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Sellable Items',
                  icon: Icons.inventory_2_rounded,
                  children: _items.isEmpty
                      ? [
                          _buildDetailRow(
                            'Availability',
                            'No sellable items listed',
                            valueColor: LoginColors.textSecondary,
                          ),
                        ]
                      : _items.map(_buildItemCard).toList(growable: false),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'References',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _buildDetailRow('Company ID', company.companyId.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(MarketplaceItem item) {
    final priceText = item.salesPrice == null
        ? '-'
        : '?${item.salesPrice!.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LoginColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: _notEmpty(item.fsId)
                ? Image.network(
                    AppConfig.getFileUrl(item.fsId!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: LoginColors.primary,
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: LoginColors.primary,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                if (_notEmpty(item.salesDescription)) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.salesDescription!,
                    style: TextStyle(
                      fontSize: 12,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip('Price: $priceText'),
                    if (_notEmpty(item.unit))
                      _buildInfoChip('Unit: ${item.unit}'),
                    if (item.taxRate != null)
                      _buildInfoChip(
                        'Tax: ${item.taxRate!.toStringAsFixed(2)}%',
                      ),
                    if (_notEmpty(item.hsnCode))
                      _buildInfoChip('HSN: ${item.hsnCode}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: LoginColors.textSecondary,
        ),
      ),
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
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
            color: LoginColors.shadowLight.withValues(alpha: 0.06),
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
                    color: LoginColors.primary.withValues(alpha: 0.1),
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

  bool _notEmpty(String? value) => value != null && value.trim().isNotEmpty;

  String _valueOrFallback(String? value) =>
      _notEmpty(value) ? value!.trim() : 'Not provided';
}
