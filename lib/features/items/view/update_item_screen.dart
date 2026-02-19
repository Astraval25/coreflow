import 'dart:io';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/domain/model/items/update_item_request.dart';
import 'package:coreflow/features/items/view_model/item_update_view_model.dart';
import 'package:coreflow/features/items/widget/item_image_uploader.dart';
import 'package:coreflow/features/items/widget/item_section_card.dart';
import 'package:coreflow/features/items/widget/update_item/update_item_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateItemScreen extends StatefulWidget {
  final int companyId;
  final Item item;

  const UpdateItemScreen({
    super.key,
    required this.companyId,
    required this.item,
  });

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  static const List<String> _unitOptions = ['PCE', 'KG', 'ML'];

  late TextEditingController _itemNameController;
  late TextEditingController _salesPriceController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salesDescriptionController;
  late TextEditingController _purchaseDescriptionController;
  late TextEditingController _hsnController;
  late TextEditingController _taxRateController;

  String _itemType = 'GOODS';
  String? _selectedUnit;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _itemNameController = TextEditingController(text: item.itemName);
    _salesPriceController = TextEditingController(
      text: item.baseSalesPrice.toString(),
    );
    _purchasePriceController = TextEditingController(
      text: item.basePurchasePrice?.toString() ?? '',
    );
    _salesDescriptionController = TextEditingController(
      text: item.salesDescription ?? '',
    );
    _purchaseDescriptionController = TextEditingController(
      text: item.purchaseDescription ?? '',
    );
    _hsnController = TextEditingController(text: item.hsnCode ?? '');
    _taxRateController = TextEditingController(
      text: item.taxRate?.toString() ?? '',
    );
    _itemType = item.itemType;
    _selectedUnit = item.unit.trim().isEmpty
        ? null
        : item.unit.trim().toUpperCase();
    context.read<UpdateItemViewModel>().resetState(notify: false);
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

    final request = UpdateItemRequest(
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

    final vm = context.read<UpdateItemViewModel>();
    await vm.updateItem(
      companyId: widget.companyId,
      itemId: widget.item.itemId,
      request: request,
      imageFile: _selectedImage,
    );

    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Item Updated Successfully'),
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
    } else if (vm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(vm.errorMessage!)),
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdateItemViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Item',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
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
                      UpdateItemStyledTextField(
                        label: 'Item Name',
                        controller: _itemNameController,
                        icon: Icons.inventory_2_rounded,
                        iconColor: LoginColors.textTertiary,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      UpdateItemTypeDropdown(
                        value: _itemType,
                        onChanged: (value) =>
                            setState(() => _itemType = value!),
                      ),
                      const SizedBox(height: 16),
                      UpdateItemUnitDropdown(
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
                      UpdateItemStyledTextField(
                        label: 'Sales Price',
                        controller: _salesPriceController,
                        icon: Icons.sell_rounded,
                        iconColor: LoginColors.textTertiary,
                        isNumber: true,
                        validateNonNegative: true,
                        hintText: '0.00',
                      ),
                      const SizedBox(height: 16),
                      UpdateItemStyledTextField(
                        label: 'Purchase Price',
                        controller: _purchasePriceController,
                        icon: Icons.shopping_cart_rounded,
                        iconColor: LoginColors.textTertiary,
                        isNumber: true,
                        validateNonNegative: true,
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
                      UpdateItemStyledTextField(
                        label: 'Sales Description',
                        controller: _salesDescriptionController,
                        icon: Icons.description_rounded,
                        iconColor: LoginColors.textTertiary,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      UpdateItemStyledTextField(
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
                      UpdateItemStyledTextField(
                        label: 'HSN Code',
                        controller: _hsnController,
                        icon: Icons.qr_code_2_rounded,
                        iconColor: LoginColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      UpdateItemStyledTextField(
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
                  UpdateItemSubmitButton(
                    isLoading: vm.isLoading,
                    onPressed: _submit,
                  ),
                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    UpdateItemErrorMessage(message: vm.errorMessage!),
                  ],
                ],
              ),
            ),
          ),
          if (vm.isLoading) const UpdateItemLoadingOverlay(),
        ],
      ),
    );
  }
}
