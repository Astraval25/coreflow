import 'package:coreflow/domain/model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/vendors/create_vendors_request.dart';
import 'package:coreflow/features/customers/widget/edit_create/billing_address_card.dart';
import 'package:coreflow/features/customers/widget/edit_create/shipping_address_card.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/vendor/view_model/vendor_edit_view_model.dart';
import 'package:coreflow/features/vendor/widget/edit_create/save_customer_button.dart';
import 'package:coreflow/features/vendor/widget/edit_create/vendor_info_def_section.dart';
import 'package:coreflow/features/vendor/widget/edit_create/vendor_info_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:go_router/go_router.dart';

class VendorCreatePage extends StatelessWidget {
  final int companyId;

  const VendorCreatePage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorEditViewModel(AuthRepository()),
        ),
      ],
      child: VendorCreateScreen(companyId: companyId),
    );
  }
}

class VendorCreateScreen extends StatefulWidget {
  final int companyId;

  const VendorCreateScreen({super.key, required this.companyId});

  @override
  State<VendorCreateScreen> createState() => _VendorCreateScreenState();
}

class _VendorCreateScreenState extends State<VendorCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _sameAsShippingAddress = false;

  final _languageController = TextEditingController(text: 'en');

  final _vendorNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panController = TextEditingController();
  final _gstController = TextEditingController();
  final _advanceController = TextEditingController();

  // Billing controllers
  final _billingAttentionController = TextEditingController();
  final _billingLine1Controller = TextEditingController();
  final _billingLine2Controller = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingStateController = TextEditingController();
  final _billingPincodeController = TextEditingController();
  final _billingPhoneController = TextEditingController();
  final _billingEmailController = TextEditingController();

  // Shipping controllers
  final _shippingAttentionController = TextEditingController();
  final _shippingLine1Controller = TextEditingController();
  final _shippingLine2Controller = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingStateController = TextEditingController();
  final _shippingPincodeController = TextEditingController();
  final _shippingPhoneController = TextEditingController();
  final _shippingEmailController = TextEditingController();

  bool _hasEditedDisplayName = false;

  bool _isShippingEqualToBilling() {
    return _shippingAttentionController.text.trim() ==
            _billingAttentionController.text.trim() &&
        _shippingLine1Controller.text.trim() ==
            _billingLine1Controller.text.trim() &&
        _shippingLine2Controller.text.trim() ==
            _billingLine2Controller.text.trim() &&
        _shippingCityController.text.trim() ==
            _billingCityController.text.trim() &&
        _shippingStateController.text.trim() ==
            _billingStateController.text.trim() &&
        _shippingPincodeController.text.trim() ==
            _billingPincodeController.text.trim() &&
        _shippingPhoneController.text.trim() ==
            _billingPhoneController.text.trim() &&
        _shippingEmailController.text.trim() ==
            _billingEmailController.text.trim();
  }

  void _updateSameAsBillingFromData() {
    final equals = _isShippingEqualToBilling();
    if (_sameAsShippingAddress != equals) {
      setState(() {
        _sameAsShippingAddress = equals;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _vendorNameController.addListener(_syncDisplayNameIfNotEdited);

    _displayNameController.addListener(() {
      if (_displayNameController.text.trim().isNotEmpty) {
        _hasEditedDisplayName = true;
      }
    });

    final shippingControllers = [
      _shippingAttentionController,
      _shippingLine1Controller,
      _shippingLine2Controller,
      _shippingCityController,
      _shippingStateController,
      _shippingPincodeController,
      _shippingPhoneController,
      _shippingEmailController,
    ];

    for (final c in shippingControllers) {
      c.addListener(_updateSameAsBillingFromData);
    }
  }

  void _syncDisplayNameIfNotEdited() {
    if (!_hasEditedDisplayName && _displayNameController.text.trim().isEmpty) {
      _displayNameController.text = _vendorNameController.text.trim();
      _displayNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _displayNameController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _vendorNameController.removeListener(_syncDisplayNameIfNotEdited);
    _displayNameController.removeListener(() {});

    final shippingControllers = [
      _shippingAttentionController,
      _shippingLine1Controller,
      _shippingLine2Controller,
      _shippingCityController,
      _shippingStateController,
      _shippingPincodeController,
      _shippingPhoneController,
      _shippingEmailController,
    ];

    for (final c in shippingControllers) {
      c.removeListener(_updateSameAsBillingFromData);
    }

    _languageController.dispose();
    _vendorNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _advanceController.dispose();

    _billingAttentionController.dispose();
    _billingLine1Controller.dispose();
    _billingLine2Controller.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingPincodeController.dispose();
    _billingPhoneController.dispose();
    _billingEmailController.dispose();

    _shippingAttentionController.dispose();
    _shippingLine1Controller.dispose();
    _shippingLine2Controller.dispose();
    _shippingCityController.dispose();
    _shippingStateController.dispose();
    _shippingPincodeController.dispose();
    _shippingPhoneController.dispose();
    _shippingEmailController.dispose();

    super.dispose();
  }

  Future<void> _saveVendor(VendorEditViewModel viewModel) async {
    viewModel.clearError();

    if (!_formKey.currentState!.validate()) return;

    final request = CreateVendorsRequest(
      vendorName: _vendorNameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      lang: _languageController.text.trim().isNotEmpty
          ? _languageController.text.trim()
          : 'en',
      pan: _panController.text.trim().isNotEmpty
          ? _panController.text.trim()
          : null,
      gst: _gstController.text.trim().isNotEmpty
          ? _gstController.text.trim()
          : null,
      dueAmount: double.tryParse(_advanceController.text.trim()) ?? 0.0,
      sameAsBillingAddress: _sameAsShippingAddress,

      // billingAddress is NOT null when checkbox is checked
      billingAddress: _sameAsShippingAddress
          ? BillingAddress(
              attentionName: _billingAttentionController.text.trim().isNotEmpty
                  ? _billingAttentionController.text.trim()
                  : null,
              country: 'India',
              line1: _billingLine1Controller.text.trim(),
              line2: _billingLine2Controller.text.trim().isNotEmpty
                  ? _billingLine2Controller.text.trim()
                  : null,
              city: _billingCityController.text.trim(),
              state: _billingStateController.text.trim(),
              pincode: int.tryParse(_billingPincodeController.text.trim()) ?? 0,
              phone: _billingPhoneController.text.trim().isNotEmpty
                  ? _billingPhoneController.text.trim()
                  : null,
              email: _billingEmailController.text.trim().isNotEmpty
                  ? _billingEmailController.text.trim()
                  : null,
            )
          : null,

      shippingAddress: _sameAsShippingAddress
          ? ShippingAddress(
              attentionName: _billingAttentionController.text.trim().isNotEmpty
                  ? _billingAttentionController.text.trim()
                  : null,
              country: 'India',
              line1: _billingLine1Controller.text.trim(),
              line2: _billingLine2Controller.text.trim().isNotEmpty
                  ? _billingLine2Controller.text.trim()
                  : null,
              city: _billingCityController.text.trim(),
              state: _billingStateController.text.trim(),
              pincode: int.tryParse(_billingPincodeController.text.trim()) ?? 0,
              phone: _billingPhoneController.text.trim().isNotEmpty
                  ? _billingPhoneController.text.trim()
                  : null,
              email: _billingEmailController.text.trim().isNotEmpty
                  ? _billingEmailController.text.trim()
                  : null,
            )
          : ShippingAddress(
              attentionName: _shippingAttentionController.text.trim().isNotEmpty
                  ? _shippingAttentionController.text.trim()
                  : null,
              country: 'India',
              line1: _shippingLine1Controller.text.trim(),
              line2: _shippingLine2Controller.text.trim().isNotEmpty
                  ? _shippingLine2Controller.text.trim()
                  : null,
              city: _shippingCityController.text.trim(),
              state: _shippingStateController.text.trim(),
              pincode:
                  int.tryParse(_shippingPincodeController.text.trim()) ?? 0,
              phone: _shippingPhoneController.text.trim().isNotEmpty
                  ? _shippingPhoneController.text.trim()
                  : null,
              email: _shippingEmailController.text.trim().isNotEmpty
                  ? _shippingEmailController.text.trim()
                  : null,
            ),
    );

    final success = await viewModel.createNewVendor(widget.companyId, request);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor created successfully')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VendorEditViewModel, DashboardViewModel>(
      builder: (context, editVM, dashboardVM, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Create Vendor'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilledButton.icon(
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  onPressed: editVM.isSaving ? null : () => _saveVendor(editVM),
                ),
              ),
            ],
          ),
          drawerEnableOpenDragGesture: false,
          drawer: AppDrawer(vm: dashboardVM),
          body: editVM.isSaving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        VendorInfoSections(
                          formKey: _formKey,
                          vendorName: _vendorNameController,
                          displayName: _displayNameController,
                        ),
                        const SizedBox(height: 24),
                        ExpansionTile(
                          title: Text(
                            'Vendor information',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16,
                          ),
                          children: [
                            VendorInfoSection(
                              formKey: _formKey,
                              email: _emailController,
                              phone: _phoneController,
                              pan: _panController,
                              gst: _gstController,
                              dueAmount: _advanceController,
                              language: _languageController,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ExpansionTile(
                          title: Text(
                            'Billing Address',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16,
                          ),
                          children: [
                            BillingAddressCard(
                              attention: _billingAttentionController,
                              line1: _billingLine1Controller,
                              line2: _billingLine2Controller,
                              city: _billingCityController,
                              state: _billingStateController,
                              pincode: _billingPincodeController,
                              phone: _billingPhoneController,
                              email: _billingEmailController,
                            ),
                          ],
                        ),
                        const SizedBox(height: 21),
                        ExpansionTile(
                          title: Text(
                            'Shipping Address',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16,
                          ),
                          children: [
                            CheckboxListTile(
                              title: const Text('Same as billing'),
                              value: _sameAsShippingAddress,
                              onChanged: (value) {
                                final newValue = value ?? false;
                                setState(() {
                                  _sameAsShippingAddress = newValue;
                                  if (newValue) {
                                    _shippingAttentionController.text =
                                        _billingAttentionController.text;
                                    _shippingLine1Controller.text =
                                        _billingLine1Controller.text;
                                    _shippingLine2Controller.text =
                                        _billingLine2Controller.text;
                                    _shippingCityController.text =
                                        _billingCityController.text;
                                    _shippingStateController.text =
                                        _billingStateController.text;
                                    _shippingPincodeController.text =
                                        _billingPincodeController.text;
                                    _shippingPhoneController.text =
                                        _billingPhoneController.text;
                                    _shippingEmailController.text =
                                        _billingEmailController.text;
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            ShippingAddressCard(
                              attention: _shippingAttentionController,
                              line1: _shippingLine1Controller,
                              line2: _shippingLine2Controller,
                              city: _shippingCityController,
                              state: _shippingStateController,
                              pincode: _shippingPincodeController,
                              phone: _shippingPhoneController,
                              email: _shippingEmailController,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SaveVendorButton(
                          onPressed: () => _saveVendor(editVM),
                          isSaving: editVM.isSaving,
                        ),
                        const SizedBox(height: 40),
                        if (editVM.error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    editVM.error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
