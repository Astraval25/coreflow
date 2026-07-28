import 'dart:io';
import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/company/company.dart';
import 'package:coreflow/features/main_feature/company/view_model/company_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CompanyFormPage extends StatefulWidget {
  final Company? company;

  const CompanyFormPage({super.key, this.company});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _industryController;
  late final TextEditingController _panController;
  late final TextEditingController _gstController;
  late final TextEditingController _hsnController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _publicDescriptionController;

  File? _pendingLogo;
  String? _currentFsId;

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.company?.companyName ?? '',
    );
    _industryController = TextEditingController(
      text: widget.company?.industry ?? '',
    );
    _panController = TextEditingController(text: widget.company?.pan ?? '');
    _gstController = TextEditingController(text: widget.company?.gstNo ?? '');
    _hsnController = TextEditingController(text: widget.company?.hsnCode ?? '');
    _shortNameController = TextEditingController(
      text: widget.company?.shortName ?? '',
    );
    _contactPersonController = TextEditingController(
      text: widget.company?.contactPerson ?? '',
    );
    _contactEmailController = TextEditingController(
      text: widget.company?.contactEmail ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: widget.company?.contactPhone ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.company?.website ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.company?.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.company?.addressLine2 ?? '',
    );
    _cityController = TextEditingController(text: widget.company?.city ?? '');
    _stateController = TextEditingController(text: widget.company?.state ?? '');
    _countryController = TextEditingController(
      text: widget.company?.country ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.company?.postalCode ?? '',
    );
    _publicDescriptionController = TextEditingController(
      text: widget.company?.publicDescription ?? '',
    );
    _currentFsId = widget.company?.fsId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _hsnController.dispose();
    _shortNameController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _websiteController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _publicDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() {
          _pendingLogo = File(picked.path);
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Failed to pick image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Company' : 'Create Company',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: LoginColors.surface,
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Company Logo', Icons.image_outlined),
                      const SizedBox(height: 14),
                      _buildLogoPicker(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Basic Details',
                        Icons.business_center_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _nameController,
                        label: 'Company Name',
                        hint: 'Enter company name',
                        icon: Icons.business_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Company name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _industryController,
                        label: 'Industry',
                        hint: 'e.g. Software Development, IT',
                        icon: Icons.category_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Industry is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _shortNameController,
                        label: 'Short Name',
                        hint: 'e.g. AdvTechSol',
                        icon: Icons.short_text_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Tax Information',
                        Icons.receipt_long_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _panController,
                        label: 'PAN',
                        hint: 'e.g. ABCDE1234F',
                        icon: Icons.credit_card_rounded,
                        capitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _gstController,
                        label: 'GST Number',
                        hint: 'e.g. 29ABCDE1234F1Z5',
                        icon: Icons.receipt_long_rounded,
                        capitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _hsnController,
                        label: 'HSN Code',
                        hint: 'e.g. 998314',
                        icon: Icons.numbers_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Contact Information',
                        Icons.contact_page_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _contactPersonController,
                        label: 'Contact Person',
                        hint: 'Enter contact person name',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _contactEmailController,
                        label: 'Contact Email',
                        hint: 'e.g. support@company.com',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _contactPhoneController,
                        label: 'Contact Phone',
                        hint: 'e.g. 9876543210',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _websiteController,
                        label: 'Website',
                        hint: 'e.g. https://company.com',
                        icon: Icons.language_rounded,
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Address Details',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _addressLine1Controller,
                        label: 'Address Line 1',
                        hint: 'Building / Street / Area',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _addressLine2Controller,
                        label: 'Address Line 2',
                        hint: 'Landmark / Industrial area',
                        icon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Enter city',
                        icon: Icons.location_city_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _stateController,
                        label: 'State',
                        hint: 'Enter state',
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Enter country',
                        icon: Icons.public_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        hint: 'Enter postal code',
                        icon: Icons.markunread_mailbox_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Public Profile',
                        Icons.public_rounded,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _publicDescriptionController,
                        label: 'Public Description',
                        hint:
                            'Short description to show on marketplace profile',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (vm.isSaving || vm.isUploadingLogo)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: LoginColors.primary.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: (vm.isSaving || vm.isUploadingLogo)
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Company' : 'Create Company',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: LoginColors.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    Widget preview;
    if (_pendingLogo != null) {
      preview = Image.file(
        _pendingLogo!,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
      );
    } else if (_currentFsId != null && _currentFsId!.isNotEmpty) {
      preview = Image.network(
        AppConfig.getFileUrl(_currentFsId!),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _logoPlaceholder(),
      );
    } else {
      preview = _logoPlaceholder();
    }

    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 96, height: 96, child: preview),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.photo_camera_rounded, size: 18),
            label: Text(
              (_currentFsId != null || _pendingLogo != null)
                  ? 'Change Logo'
                  : 'Add Logo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 96,
      height: 96,
      color: LoginColors.fieldFill,
      child: Icon(
        Icons.business_rounded,
        size: 40,
        color: LoginColors.textTertiary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: LoginColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          minLines: maxLines > 1 ? maxLines : 1,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: LoginColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: LoginColors.textTertiary,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 20, color: LoginColors.primary),
            filled: true,
            fillColor: LoginColors.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: LoginColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: LoginColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: LoginColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CompanyViewModel>();
    bool success;
    int? targetCompanyId;

    if (isEditing) {
      targetCompanyId = widget.company!.companyId;
      success = await vm.updateCompany(
        companyId: targetCompanyId,
        companyName: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        pan: _panController.text.trim(),
        gstNo: _gstController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        shortName: _shortNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        website: _websiteController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        publicDescription: _publicDescriptionController.text.trim(),
      );
    } else {
      success = await vm.createCompany(
        companyName: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        pan: _panController.text.trim(),
        gstNo: _gstController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        shortName: _shortNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        website: _websiteController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        publicDescription: _publicDescriptionController.text.trim(),
      );
      if (success) {
        targetCompanyId = vm.companies
            .where((c) => c.companyName == _nameController.text.trim())
            .map((c) => c.companyId)
            .fold<int?>(
              null,
              (prev, id) => (prev == null || id > prev) ? id : prev,
            );
      }
    }

    if (success && _pendingLogo != null && targetCompanyId != null) {
      await vm.uploadCompanyLogo(targetCompanyId, _pendingLogo!);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            isEditing
                ? 'Company updated successfully'
                : 'Company created successfully',
          ),
          backgroundColor: LoginColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(vm.errorMessage ?? 'Operation failed'),
          backgroundColor: LoginColors.error,
        ),
      );
    }
  }
}
