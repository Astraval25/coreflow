import 'dart:io';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/create_item_request.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/features/main_feature/items/view_model/item_create_view_model.dart';
import 'package:coreflow/features/main_feature/items/widget/create_item/create_item_form_widgets.dart';
import 'package:coreflow/features/main_feature/items/widget/item_image_uploader.dart';
import 'package:coreflow/features/main_feature/items/widget/item_section_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateItemScreen extends StatelessWidget {
  final int companyId;

  const CreateItemScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CreateItemViewModel(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: CreateItemView(companyId: companyId),
    );
  }
}

class CreateItemView extends StatefulWidget {
  final int companyId;

  const CreateItemView({super.key, required this.companyId});

  @override
  State<CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<CreateItemView> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<String> _unitOptions = ['PCE', 'KG', 'ML'];

  final _itemNameController = TextEditingController();
  final _salesPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salesDescriptionController = TextEditingController();
  final _purchaseDescriptionController = TextEditingController();
  final _hsnController = TextEditingController();
  final _taxRateController = TextEditingController();

  String _itemType = 'GOODS';
  String? _selectedUnit;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    context.read<CreateItemViewModel>().resetState();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _salesPriceController.dispose();
    _purchasePriceController.dispose();
    _salesDescriptionController.dispose();
    _purchaseDescriptionController.dispose();
    _hsnController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Failed to pick image'),
            ],
          ),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final salesPriceText = _salesPriceController.text.trim();
    final purchasePriceText = _purchasePriceController.text.trim();
    final taxText = _taxRateController.text.trim();

    final request = CreateItemRequest(
      itemName: _itemNameController.text.trim(),
      itemType: _itemType,
      unit: _selectedUnit,
      salesDescription: _salesDescriptionController.text.trim().isEmpty
          ? null
          : _salesDescriptionController.text.trim(),
      baseSalesPrice: salesPriceText.isEmpty
          ? null
          : double.tryParse(salesPriceText),
      purchaseDescription: _purchaseDescriptionController.text.trim().isEmpty
          ? null
          : _purchaseDescriptionController.text.trim(),
      basePurchasePrice: purchasePriceText.isEmpty
          ? null
          : double.tryParse(purchasePriceText),
      hsnCode: _hsnController.text.trim().isEmpty
          ? null
          : _hsnController.text.trim(),
      taxRate: taxText.isEmpty ? null : double.tryParse(taxText),
    );

    final vm = context.read<CreateItemViewModel>();

    await vm.createItem(
      companyId: widget.companyId,
      request: request,
      imageFile: _selectedImage,
    );

    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Item Created Successfully'),
            ],
          ),
          backgroundColor: LoginColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final vm = context.watch<CreateItemViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Create Item',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              icon: vm.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(
                vm.isLoading ? 'Saving' : 'Save',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              onPressed: vm.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemSectionCard(
                    title: 'Basic Information',
                    icon: Icons.info_outline_rounded,
                    iconColor: LoginColors.primary,
                    children: [
                      CreateItemStyledTextField(
                        label: 'Item Name',
                        controller: _itemNameController,
                        icon: Icons.inventory_2_rounded,
                        iconColor: LoginColors.textTertiary,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      CreateItemTypeDropdown(
                        value: _itemType,
                        onChanged: (value) =>
                            setState(() => _itemType = value!),
                      ),
                      const SizedBox(height: 16),
                      CreateItemUnitDropdown(
                        selectedUnit: _selectedUnit,
                        unitOptions: _unitOptions,
                        onChanged: (value) =>
                            setState(() => _selectedUnit = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ItemSectionCard(
                    title: 'Pricing',
                    icon: Icons.monetization_on_outlined,
                    iconColor: LoginColors.primary,
                    children: [
                      CreateItemStyledTextField(
                        label: 'Sales Price',
                        controller: _salesPriceController,
                        icon: Icons.sell_rounded,
                        iconColor: LoginColors.textTertiary,
                        isNumber: true,
                        validatePrice: true,
                        hintText: '0.00',
                      ),
                      const SizedBox(height: 16),
                      CreateItemStyledTextField(
                        label: 'Purchase Price',
                        controller: _purchasePriceController,
                        icon: Icons.shopping_cart_rounded,
                        iconColor: LoginColors.textTertiary,
                        isNumber: true,
                        validatePrice: true,
                        hintText: '0.00',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ItemSectionCard(
                    title: 'Descriptions',
                    icon: Icons.description_outlined,
                    iconColor: LoginColors.primary,
                    children: [
                      CreateItemStyledTextField(
                        label: 'Sales Description',
                        controller: _salesDescriptionController,
                        icon: Icons.description_rounded,
                        iconColor: LoginColors.textTertiary,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      CreateItemStyledTextField(
                        label: 'Purchase Description',
                        controller: _purchaseDescriptionController,
                        icon: Icons.receipt_long_rounded,
                        iconColor: LoginColors.textTertiary,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ItemSectionCard(
                    title: 'Tax & HSN',
                    icon: Icons.receipt_outlined,
                    iconColor: LoginColors.primary,
                    children: [
                      CreateItemStyledTextField(
                        label: 'HSN Code',
                        controller: _hsnController,
                        icon: Icons.qr_code_2_rounded,
                        iconColor: LoginColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      CreateItemStyledTextField(
                        label: 'Tax Rate (%)',
                        controller: _taxRateController,
                        icon: Icons.percent_rounded,
                        iconColor: LoginColors.textTertiary,
                        isNumber: true,
                        validateTaxRate: true,
                        hintText: '0 - 100',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ItemSectionCard(
                    title: 'Item Image',
                    icon: Icons.image_outlined,
                    iconColor: LoginColors.primary,
                    children: [
                      ItemImageUploader(
                        selectedImage: _selectedImage,
                        onPickImage: _pickImage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  CreateItemSubmitButton(
                    isLoading: vm.isLoading,
                    onPressed: _submit,
                  ),
                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    CreateItemErrorMessage(message: vm.errorMessage!),
                  ],
                ],
              ),
            ),
          ),
          if (vm.isLoading) const CreateItemLoadingOverlay(),
        ],
      ),
    );
  }
}
