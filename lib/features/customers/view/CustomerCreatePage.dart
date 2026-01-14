import 'package:coreflow/domain/model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/customer/create_customer_request.dart';
import 'package:coreflow/features/customers/widget/edit/billing_address_card.dart';
import 'package:coreflow/features/customers/widget/edit/customer_info_section.dart';
import 'package:coreflow/features/customers/widget/edit/save_customer_button.dart';
import 'package:coreflow/features/customers/widget/edit/shipping_address_card.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/customers/view_model/customer_edit_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:go_router/go_router.dart';

class CustomerCreatePage extends StatelessWidget {
  final int companyId;

  const CustomerCreatePage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerEditViewModel(AuthRepository()),
        ),
      ],
      child: CustomerCreateScreen(companyId: companyId),
    );
  }
}

class CustomerCreateScreen extends StatefulWidget {
  final int companyId;

  const CustomerCreateScreen({super.key, required this.companyId});

  @override
  State<CustomerCreateScreen> createState() => _CustomerCreateScreenState();
}

class _CustomerCreateScreenState extends State<CustomerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _sameAsBillingAddress = false;

  final _languageController = TextEditingController(text: 'en');

  // Customer info controllers
  final _customerNameController = TextEditingController();
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

  @override
  void dispose() {
    _languageController.dispose();

    // Dispose all other controllers
    _customerNameController.dispose();
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

  Future<void> _saveCustomer(CustomerEditViewModel viewModel) async {
    viewModel.clearError();

    if (!_formKey.currentState!.validate()) return;

    final request = CreateCustomerRequest(
      customerName: _customerNameController.text,
      displayName: _displayNameController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      lang: _languageController.text.isNotEmpty
          ? _languageController.text
          : 'en',
      pan: _panController.text.isNotEmpty ? _panController.text : null,
      gst: _gstController.text.isNotEmpty ? _gstController.text : null,
      advanceAmount: double.tryParse(_advanceController.text) ?? 0.0,
      sameAsBillingAddress: _sameAsBillingAddress,
      billingAddress: !_sameAsBillingAddress
          ? BillingAddress(
              attentionName: _billingAttentionController.text.isNotEmpty
                  ? _billingAttentionController.text
                  : null,
              country: 'India',
              line1: _billingLine1Controller.text,
              line2: _billingLine2Controller.text.isNotEmpty
                  ? _billingLine2Controller.text
                  : null,
              city: _billingCityController.text,
              state: _billingStateController.text,
              pincode: int.tryParse(_billingPincodeController.text) ?? 0,
              phone: _billingPhoneController.text.isNotEmpty
                  ? _billingPhoneController.text
                  : null,
              email: _billingEmailController.text.isNotEmpty
                  ? _billingEmailController.text
                  : null,
            )
          : null,
      shippingAddress: ShippingAddress(
        attentionName: _shippingAttentionController.text.isNotEmpty
            ? _shippingAttentionController.text
            : null,
        country: 'India',
        line1: _shippingLine1Controller.text,
        line2: _shippingLine2Controller.text.isNotEmpty
            ? _shippingLine2Controller.text
            : null,
        city: _shippingCityController.text,
        state: _shippingStateController.text,
        pincode: int.tryParse(_shippingPincodeController.text) ?? 0,
        phone: _shippingPhoneController.text.isNotEmpty
            ? _shippingPhoneController.text
            : null,
        email: _shippingEmailController.text.isNotEmpty
            ? _shippingEmailController.text
            : null,
      ),
    );

    final success = await viewModel.createNewCustomer(
      widget.companyId,
      request,
    );

    if (success && mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer created successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerEditViewModel, DashboardViewModel>(
      builder: (context, editVM, dashboardVM, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Create customer'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
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
                        CustomerInfoSection(
                          formKey: _formKey,
                          customerName: _customerNameController,
                          displayName: _displayNameController,
                          email: _emailController,
                          phone: _phoneController,
                          pan: _panController,
                          gst: _gstController,
                          advance: _advanceController,
                          language: _languageController,
                        ),
                        const SizedBox(height: 32),

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
                        const SizedBox(height: 32),

                        BillingAddressCard(
                          sameAsBillingAddress: _sameAsBillingAddress,
                          onSameChanged: (value) {
                            setState(
                              () => _sameAsBillingAddress = value ?? false,
                            );
                          },
                          attention: _billingAttentionController,
                          line1: _billingLine1Controller,
                          line2: _billingLine2Controller,
                          city: _billingCityController,
                          state: _billingStateController,
                          pincode: _billingPincodeController,
                          phone: _billingPhoneController,
                          email: _billingEmailController,
                        ),
                        const SizedBox(height: 40),

                        SaveCustomerButton(
                          onPressed: () => _saveCustomer(editVM),
                          isSaving: editVM.isSaving,
                        ),
                        const SizedBox(height: 20),

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
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
