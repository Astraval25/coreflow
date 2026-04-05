import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:flutter/material.dart';

class CustomerSelectorPage extends StatefulWidget {
  final int companyId;

  const CustomerSelectorPage({super.key, required this.companyId});

  @override
  State<CustomerSelectorPage> createState() => _CustomerSelectorPageState();
}

class _CustomerSelectorPageState extends State<CustomerSelectorPage> {
  final AuthRepository _repository = AuthRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> _allCustomers = [];
  List<Customer> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final customers = await _repository.getCustomers(widget.companyId);
      final active = customers.where((c) => c.isActive).toList();
      setState(() {
        _allCustomers = active;
        _filtered = active;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load customers';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _allCustomers;
      } else {
        _filtered = _allCustomers.where((c) {
          return c.displayName.toLowerCase().contains(q) ||
              c.customerCompanyName.toLowerCase().contains(q) ||
              (c.email?.toLowerCase().contains(q) ?? false);
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
          'Select Customer',
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
                hintText: 'Search customers...',
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
              onPressed: _loadCustomers,
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
            Icon(Icons.person_search_rounded,
                size: 48, color: LoginColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No customers match your search'
                  : 'No active customers found',
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final customer = _filtered[index];
          return _CustomerTile(
            customer: customer,
            onTap: () => Navigator.pop(context, customer),
          );
        },
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerTile({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    String avatarText = '?';
    if (customer.displayName.isNotEmpty) {
      avatarText = customer.displayName[0].toUpperCase();
    } else if (customer.customerCompanyName.isNotEmpty) {
      avatarText = customer.customerCompanyName[0].toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 1,
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: LoginColors.borderLight, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: LoginColors.primaryLight.withValues(alpha: 0.12),
        highlightColor: LoginColors.primaryLight.withValues(alpha: 0.06),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
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
                      customer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    if (customer.customerCompanyName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        customer.customerCompanyName,
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
