import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class VendorSelectorPage extends StatefulWidget {
  final int companyId;

  const VendorSelectorPage({super.key, required this.companyId});

  @override
  State<VendorSelectorPage> createState() => _VendorSelectorPageState();
}

class _VendorSelectorPageState extends State<VendorSelectorPage> {
  final AuthRepository _repository = AuthRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Vendor> _allVendors = [];
  List<Vendor> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vendors = await _repository.getActiveVendors(widget.companyId);
      final active = vendors.where((v) => v.isActive).toList();
      setState(() {
        _allVendors = active;
        _filtered = active;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load vendors';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _allVendors;
      } else {
        _filtered = _allVendors.where((v) {
          return v.displayName.toLowerCase().contains(q) ||
              v.vendorCompanyName.toLowerCase().contains(q) ||
              (v.email?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Select Vendor',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 15, color: LoginColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: LoginColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: LoginColors.textTertiary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: LoginColors.textTertiary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: LoginColors.fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: LoginColors.borderLight,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: LoginColors.borderLight,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: LoginColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: LoginColors.textTertiary),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: LoginColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadVendors,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_rounded,
                size: 48, color: LoginColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No vendors match your search'
                  : 'No active vendors found',
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVendors,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final vendor = _filtered[index];
          return _VendorTile(
            vendor: vendor,
            onTap: () => Navigator.pop(context, vendor),
          );
        },
      ),
    );
  }
}

class _VendorTile extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;

  const _VendorTile({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    String avatarText = '?';
    if (vendor.displayName.isNotEmpty) {
      avatarText = vendor.displayName[0].toUpperCase();
    } else if (vendor.vendorCompanyName.isNotEmpty) {
      avatarText = vendor.vendorCompanyName[0].toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 1,
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: LoginColors.borderLight, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: LoginColors.primaryLight.withOpacity(0.12),
        highlightColor: LoginColors.primaryLight.withOpacity(0.06),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Text(
                  avatarText,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    if (vendor.vendorCompanyName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        vendor.vendorCompanyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: LoginColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: LoginColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
