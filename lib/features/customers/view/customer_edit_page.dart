import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:coreflow/features/customers/widget/edit/billing_address_card.dart';
import 'package:coreflow/features/customers/widget/edit/customer_info_section.dart';
import 'package:coreflow/features/customers/widget/edit/save_customer_button.dart';
import 'package:coreflow/features/customers/widget/edit/shipping_address_card.dart';

import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/customers/view_model/customer_edit_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/customer/customer_edit_request.dart';

class CustomerEditPage extends StatelessWidget {
  final int companyId;
  final int customerId;

  const CustomerEditPage({
    super.key,
    required this.companyId,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CustomerEditViewModel(AuthRepository())
                ..loadCustomerDetails(companyId, customerId),
        ),
      ],
      child: CustomerEditScreen(companyId: companyId, customerId: customerId),
    );
  }
}

class CustomerEditScreen extends StatefulWidget {
  final int companyId;
  final int customerId;

  const CustomerEditScreen({
    super.key,
    required this.companyId,
    required this.customerId,
  });

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _sameAsBilling = false;
  bool _isFormPopulated = false;

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _controllers = _CustomerControllers();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _populateForm(CustomerDetailData? data) {
    if (data == null || _isFormPopulated) return;
    _isFormPopulated = true;

    final c = _controllers;
    c.customerName.text = data.customerName;
    c.displayName.text = data.displayName;
    c.email.text = data.email ?? '';
    c.phone.text = data.phone ?? '';
    c.pan.text = data.pan ?? '';
    c.gst.text = data.gst ?? '';
    c.advance.text = data.advanceAmount?.toStringAsFixed(2) ?? '';

    _sameAsBilling = data.sameAsBillingAddress;

    final billing = data.billingAddress;
    if (billing != null) {
      c.billingAttention.text = billing.attentionName ?? '';
      c.billingLine1.text = billing.line1 ?? '';
      c.billingLine2.text = billing.line2 ?? '';
      c.billingCity.text = billing.city ?? '';
      c.billingState.text = billing.state ?? '';
      c.billingPincode.text = billing.pincode.toString();
      c.billingPhone.text = billing.phone ?? '';
      c.billingEmail.text = billing.email ?? '';
    }

    final shipping = data.shippingAddress;
    if (shipping != null) {
      c.shippingAttention.text = shipping.attentionName ?? '';
      c.shippingLine1.text = shipping.line1 ?? '';
      c.shippingLine2.text = shipping.line2 ?? '';
      c.shippingCity.text = shipping.city ?? '';
      c.shippingState.text = shipping.state ?? '';
      c.shippingPincode.text = shipping.pincode.toString();
      c.shippingPhone.text = shipping.phone ?? '';
      c.shippingEmail.text = shipping.email ?? '';
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveCustomer(CustomerEditViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final req = CustomerEditRequest(
      customerName: _controllers.customerName.text.trim(),
      displayName: _controllers.displayName.text.trim(),
      email: _controllers.email.text.trim().isNotEmpty
          ? _controllers.email.text.trim()
          : null,
      phone: _controllers.phone.text.trim().isNotEmpty
          ? _controllers.phone.text.trim()
          : null,
      lang: 'en',
      pan: _controllers.pan.text.trim().isNotEmpty
          ? _controllers.pan.text.trim()
          : null,
      gst: _controllers.gst.text.trim().isNotEmpty
          ? _controllers.gst.text.trim()
          : null,
      advanceAmount: double.tryParse(_controllers.advance.text) ?? 0.0,
      sameAsBillingAddress: _sameAsBilling,
      billingAddress: _sameAsBilling
          ? null
          : BillingAddress(
              attentionName:
                  _controllers.billingAttention.text.trim().isNotEmpty
                  ? _controllers.billingAttention.text.trim()
                  : null,
              country: 'India',
              line1: _controllers.billingLine1.text.trim(),
              line2: _controllers.billingLine2.text.trim().isNotEmpty
                  ? _controllers.billingLine2.text.trim()
                  : null,
              city: _controllers.billingCity.text.trim(),
              state: _controllers.billingState.text.trim(),
              pincode: int.tryParse(_controllers.billingPincode.text) ?? 0,
              phone: _controllers.billingPhone.text.trim().isNotEmpty
                  ? _controllers.billingPhone.text.trim()
                  : null,
              email: _controllers.billingEmail.text.trim().isNotEmpty
                  ? _controllers.billingEmail.text.trim()
                  : null,
            ),
      shippingAddress: ShippingAddress(
        attentionName: _controllers.shippingAttention.text.trim().isNotEmpty
            ? _controllers.shippingAttention.text.trim()
            : null,
        country: 'India',
        line1: _controllers.shippingLine1.text.trim(),
        line2: _controllers.shippingLine2.text.trim().isNotEmpty
            ? _controllers.shippingLine2.text.trim()
            : null,
        city: _controllers.shippingCity.text.trim(),
        state: _controllers.shippingState.text.trim(),
        pincode: int.tryParse(_controllers.shippingPincode.text) ?? 0,
        phone: _controllers.shippingPhone.text.trim().isNotEmpty
            ? _controllers.shippingPhone.text.trim()
            : null,
        email: _controllers.shippingEmail.text.trim().isNotEmpty
            ? _controllers.shippingEmail.text.trim()
            : null,
      ),
    );

    final success = await vm.updateCustomer(
      widget.companyId,
      widget.customerId,
      req,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Customer updated successfully'),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Failed to update customer'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<CustomerEditViewModel, DashboardViewModel>(
      builder: (context, editVM, dashboardVM, _) {
        if (editVM.customerDetails != null && !_isFormPopulated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _populateForm(editVM.customerDetails);
          });
        }

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            title: const Text('Edit Customer'),
            elevation: 0,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          body: editVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: CustomScrollView(
                    slivers: [
                      SliverSafeArea(
                        sliver: SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // ── Header Hint ──
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: colorScheme.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Update customer details & addresses",
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Customer Info
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CustomerInfoSection(
                                    customerName: _controllers.customerName,
                                    displayName: _controllers.displayName,
                                    email: _controllers.email,
                                    phone: _controllers.phone,
                                    pan: _controllers.pan,
                                    gst: _controllers.gst,
                                    advance: _controllers.advance,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Shipping Address
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ShippingAddressCard(
                                    attention: _controllers.shippingAttention,
                                    line1: _controllers.shippingLine1,
                                    line2: _controllers.shippingLine2,
                                    city: _controllers.shippingCity,
                                    state: _controllers.shippingState,
                                    pincode: _controllers.shippingPincode,
                                    phone: _controllers.shippingPhone,
                                    email: _controllers.shippingEmail,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Billing Address + Checkbox
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: BillingAddressCard(
                                    sameAsBillingAddress: _sameAsBilling,
                                    onSameChanged: (v) => setState(
                                      () => _sameAsBilling = v ?? false,
                                    ),
                                    attention: _controllers.billingAttention,
                                    line1: _controllers.billingLine1,
                                    line2: _controllers.billingLine2,
                                    city: _controllers.billingCity,
                                    state: _controllers.billingState,
                                    pincode: _controllers.billingPincode,
                                    phone: _controllers.billingPhone,
                                    email: _controllers.billingEmail,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Save Button
                              SaveCustomerButton(
                                onPressed: () => _saveCustomer(editVM),
                                isSaving: editVM.isSaving,
                              ),

                              const SizedBox(height: 24),

                              // Error
                              if (editVM.error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          editVM.error!,
                                          style: TextStyle(
                                            color: colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// ── Helper class to group controllers (cleaner code) ────────────────────────────
class _CustomerControllers {
  final customerName = TextEditingController();
  final displayName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final pan = TextEditingController();
  final gst = TextEditingController();
  final advance = TextEditingController();

  final billingAttention = TextEditingController();
  final billingLine1 = TextEditingController();
  final billingLine2 = TextEditingController();
  final billingCity = TextEditingController();
  final billingState = TextEditingController();
  final billingPincode = TextEditingController();
  final billingPhone = TextEditingController();
  final billingEmail = TextEditingController();

  final shippingAttention = TextEditingController();
  final shippingLine1 = TextEditingController();
  final shippingLine2 = TextEditingController();
  final shippingCity = TextEditingController();
  final shippingState = TextEditingController();
  final shippingPincode = TextEditingController();
  final shippingPhone = TextEditingController();
  final shippingEmail = TextEditingController();

  void dispose() {
    customerName.dispose();
    displayName.dispose();
    email.dispose();
    phone.dispose();
    pan.dispose();
    gst.dispose();
    advance.dispose();

    billingAttention.dispose();
    billingLine1.dispose();
    billingLine2.dispose();
    billingCity.dispose();
    billingState.dispose();
    billingPincode.dispose();
    billingPhone.dispose();
    billingEmail.dispose();

    shippingAttention.dispose();
    shippingLine1.dispose();
    shippingLine2.dispose();
    shippingCity.dispose();
    shippingState.dispose();
    shippingPincode.dispose();
    shippingPhone.dispose();
    shippingEmail.dispose();
  }
}
