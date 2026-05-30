import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendor_contact_lookup.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/utils/vendor_contact_utils.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorOnboardingPage extends StatelessWidget {
  final int companyId;

  const VendorOnboardingPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: _VendorOnboardingView(companyId: companyId),
    );
  }
}

class _VendorOnboardingView extends StatefulWidget {
  final int companyId;

  const _VendorOnboardingView({required this.companyId});

  @override
  State<_VendorOnboardingView> createState() => _VendorOnboardingViewState();
}

class _VendorOnboardingViewState extends State<_VendorOnboardingView> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  final TextEditingController _manualPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isPermissionDenied = false;
  bool _isManualLookupLoading = false;
  String? _errorMessage;

  List<_ContactPhoneRow> _rows = const [];
  final Map<String, VendorContactLookupResult> _lookupByPhoneKey = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _manualPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isPermissionDenied = false;
      _rows = const [];
      _lookupByPhoneKey.clear();
    });

    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);
      if (!granted) {
        setState(() {
          _isPermissionDenied = true;
          _isLoading = false;
        });
        return;
      }

      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final rows = <_ContactPhoneRow>[];
      for (final contact in contacts) {
        final name = contact.displayName.trim();
        for (final phone in contact.phones) {
          final number = phone.number.trim();
          if (number.isEmpty) continue;
          rows.add(
            _ContactPhoneRow(
              name: name.isEmpty ? 'Unnamed contact' : name,
              phone: number,
            ),
          );
        }
      }

      rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final dedupedRows = _dedupeRows(rows);
      await _lookupRows(dedupedRows);

      if (!mounted) return;
      setState(() {
        _rows = dedupedRows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load contacts: $e';
      });
    }
  }

  List<_ContactPhoneRow> _dedupeRows(List<_ContactPhoneRow> rows) {
    final seen = <String>{};
    final deduped = <_ContactPhoneRow>[];
    for (final row in rows) {
      final key = '${row.name.toLowerCase()}|${row.phone.trim()}';
      if (seen.add(key)) {
        deduped.add(row);
      }
    }
    return deduped;
  }

  Future<void> _lookupRows(List<_ContactPhoneRow> rows) async {
    final phones = rows.map((row) => row.phone).toSet().toList(growable: false);
    if (phones.isEmpty) return;

    final results = await _authRepository.lookupVendorContacts(
      widget.companyId,
      phones,
    );

    final lookupByPhoneKey = <String, VendorContactLookupResult>{};
    for (final result in results) {
      final key = result.phoneKey;
      if (key == null || key.isEmpty) continue;
      lookupByPhoneKey[key] = result;
    }

    _lookupByPhoneKey
      ..clear()
      ..addAll(lookupByPhoneKey);
  }

  Future<void> _openCreateForm({
    required String phone,
    required String name,
    String? linkedAccountCompanyName,
  }) async {
    final created = await context.push<bool>(
      CfRoutes.vendorCreateForm(widget.companyId),
      extra: {
        'initialPhone': phone,
        'initialVendorName': name,
        'initialDisplayName': name,
        'linkedAccountCompanyName': linkedAccountCompanyName,
      },
    );

    if (created == true && mounted) {
      context.pop(true);
    }
  }

  Future<void> _openVendor(int vendorId) async {
    await context.push(CfRoutes.vendorDetail(widget.companyId, vendorId));
  }

  Future<void> _openWhatsAppInvite(String phone, String name) async {
    final digits = sanitizePhoneDigits(phone);
    if (digits.length < 10) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number for invite')),
      );
      return;
    }
    final uri = buildWhatsAppInviteUri(phone: phone);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp invite')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invitation opened in WhatsApp'),
        action: SnackBarAction(
          label: 'Create local',
          onPressed: () {
            _openCreateForm(phone: phone, name: name);
          },
        ),
      ),
    );
  }

  Future<void> _handleLookupAction(
    _ContactPhoneRow row,
    VendorContactLookupResult? lookup,
  ) async {
    final action = resolveLookupAction(
      lookup ??
          VendorContactLookupResult(
            validPhone: toLast10PhoneKey(row.phone) != null,
            hasAccount: false,
          ),
    );

    switch (action) {
      case VendorLookupAction.open:
        final vendorId = lookup?.existingVendorId;
        if (vendorId != null) {
          await _openVendor(vendorId);
        }
        break;
      case VendorLookupAction.create:
        await _openCreateForm(
          phone: row.phone,
          name: row.name,
          linkedAccountCompanyName: lookup?.accountCompanyName,
        );
        break;
      case VendorLookupAction.invite:
        await _openWhatsAppInvite(row.phone, row.name);
        break;
    }
  }

  Future<void> _manualLookupAndAct() async {
    final name = _manualNameController.text.trim();
    final phone = _manualPhoneController.text.trim();
    final phoneKey = toLast10PhoneKey(phone);
    if (phoneKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() {
      _isManualLookupLoading = true;
    });

    try {
      final results = await _authRepository.lookupVendorContacts(
        widget.companyId,
        [phone],
      );
      final lookup = results.isNotEmpty ? results.first : null;
      final row = _ContactPhoneRow(
        name: name.isEmpty ? phone : name,
        phone: phone,
      );
      await _handleLookupAction(row, lookup);
    } finally {
      if (mounted) {
        setState(() {
          _isManualLookupLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final query = _searchController.text.trim().toLowerCase();
    final filteredRows = _rows
        .where((row) {
          if (query.isEmpty) return true;
          return row.name.toLowerCase().contains(query) ||
              row.phone.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Scaffold(
      backgroundColor: LoginColors.background,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      appBar: AppBar(
        title: const Text('Create Vendor'),
        backgroundColor: LoginColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              _openCreateForm(phone: '', name: '');
            },
            child: const Text('Manual form'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadContacts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Search contacts by number and decide quickly: Open, Create, or Invite.',
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Search name or number',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildManualCard(),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              _buildStatusCard(
                icon: Icons.error_outline_rounded,
                text: _errorMessage!,
              )
            else if (_isPermissionDenied)
              _buildStatusCard(
                icon: Icons.contact_phone_outlined,
                text:
                    'Contacts permission denied. You can still use manual number lookup above.',
              )
            else if (filteredRows.isEmpty)
              _buildStatusCard(
                icon: Icons.person_search_outlined,
                text: 'No contacts found for your search.',
              )
            else
              ...filteredRows.map(_buildLookupRow),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual number fallback',
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _manualNameController,
            decoration: const InputDecoration(
              labelText: 'Vendor name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _manualPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isManualLookupLoading
                      ? null
                      : _manualLookupAndAct,
                  child: _isManualLookupLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lookup'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _openCreateForm(
                      phone: _manualPhoneController.text.trim(),
                      name: _manualNameController.text.trim(),
                    );
                  },
                  child: const Text('Create local'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLookupRow(_ContactPhoneRow row) {
    final phoneKey = toLast10PhoneKey(row.phone);
    final lookup = phoneKey != null ? _lookupByPhoneKey[phoneKey] : null;
    final action = resolveLookupAction(
      lookup ??
          VendorContactLookupResult(
            validPhone: phoneKey != null,
            hasAccount: false,
          ),
    );

    final label = switch (action) {
      VendorLookupAction.open => 'Open',
      VendorLookupAction.create => 'Create',
      VendorLookupAction.invite => 'Invite',
    };

    final actionColor = switch (action) {
      VendorLookupAction.open => LoginColors.primary,
      VendorLookupAction.create => LoginColors.success,
      VendorLookupAction.invite => LoginColors.accent,
    };

    final subtitleParts = <String>[
      row.phone,
      if (lookup?.hasAccount == true && lookup?.accountCompanyName != null)
        'Account: ${lookup!.accountCompanyName}',
      if (lookup?.existingVendorId != null)
        'Existing ID: ${lookup!.existingVendorId}',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: LoginColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: LoginColors.borderLight),
      ),
      child: ListTile(
        onTap: () => _handleLookupAction(row, lookup),
        title: Text(
          row.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitleParts.join(' | '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: LoginColors.textSecondary),
        ),
        trailing: TextButton(
          onPressed: () => _handleLookupAction(row, lookup),
          child: Text(
            label,
            style: TextStyle(color: actionColor, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LoginColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactPhoneRow {
  final String name;
  final String phone;

  const _ContactPhoneRow({required this.name, required this.phone});
}
