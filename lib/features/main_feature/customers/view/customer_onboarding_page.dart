import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_contact_lookup.dart';
import 'package:coreflow/features/main_feature/customers/utils/customer_contact_utils.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerOnboardingPage extends StatelessWidget {
  final int companyId;

  const CustomerOnboardingPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: _CustomerOnboardingView(companyId: companyId),
    );
  }
}

class _CustomerOnboardingView extends StatefulWidget {
  final int companyId;

  const _CustomerOnboardingView({required this.companyId});

  @override
  State<_CustomerOnboardingView> createState() =>
      _CustomerOnboardingViewState();
}

class _CustomerOnboardingViewState extends State<_CustomerOnboardingView> {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  final TextEditingController _manualPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isPermissionDenied = false;
  bool _isManualLookupLoading = false;
  String? _errorMessage;

  List<_ContactPhoneRow> _rows = const [];
  final Map<String, CustomerContactLookupResult> _lookupByPhoneKey = {};

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

    final results = await _authRepository.lookupCustomerContacts(
      widget.companyId,
      phones,
    );

    final lookupByPhoneKey = <String, CustomerContactLookupResult>{};
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
      CfRoutes.customerCreateForm(widget.companyId),
      extra: {
        'initialPhone': phone,
        'initialCustomerName': name,
        'initialDisplayName': name,
        'linkedAccountCompanyName': linkedAccountCompanyName,
      },
    );

    if (created == true && mounted) {
      context.pop(true);
    }
  }

  Future<void> _openCustomer(int customerId) async {
    await context.push(CfRoutes.customerDetail(widget.companyId, customerId));
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
    CustomerContactLookupResult? lookup,
  ) async {
    final action = resolveLookupAction(
      lookup ??
          CustomerContactLookupResult(
            validPhone: toLast10PhoneKey(row.phone) != null,
            hasAccount: false,
          ),
    );

    switch (action) {
      case CustomerLookupAction.open:
        final customerId = lookup?.existingCustomerId;
        if (customerId != null) {
          await _openCustomer(customerId);
        }
        break;
      case CustomerLookupAction.create:
        await _openCreateForm(
          phone: row.phone,
          name: row.name,
          linkedAccountCompanyName: lookup?.accountCompanyName,
        );
        break;
      case CustomerLookupAction.invite:
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
      final results = await _authRepository.lookupCustomerContacts(
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
        title: const Text('Create Customer'),
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
            // _buildManualCard(),
            // const SizedBox(height: 12),
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
                    'Contact access required to show the contacts list. You can still use manual number lookup above.',
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

  Widget _buildLookupRow(_ContactPhoneRow row) {
    final phoneKey = toLast10PhoneKey(row.phone);
    final lookup = phoneKey != null ? _lookupByPhoneKey[phoneKey] : null;
    final action = resolveLookupAction(
      lookup ??
          CustomerContactLookupResult(
            validPhone: phoneKey != null,
            hasAccount: false,
          ),
    );

    final label = switch (action) {
      CustomerLookupAction.open => 'Open',
      CustomerLookupAction.create => 'Create',
      CustomerLookupAction.invite => 'Invite',
    };

    final actionColor = switch (action) {
      CustomerLookupAction.open => LoginColors.primary,
      CustomerLookupAction.create => LoginColors.success,
      CustomerLookupAction.invite => LoginColors.accent,
    };

    final subtitleParts = <String>[
      row.phone,
      if (lookup?.hasAccount == true && lookup?.accountCompanyName != null)
        'Account: ${lookup!.accountCompanyName}',
      if (lookup?.existingCustomerId != null)
        'Existing ID: ${lookup!.existingCustomerId}',
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
          subtitleParts.join(' • '),
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
