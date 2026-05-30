import 'dart:io';

import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/domain/model/main_model/company/company.dart';
import 'package:coreflow/features/main_feature/profile/view_moodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: LoginColors.background,
        appBar: _buildAppBar(context),
        body: const _ProfileBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: LoginColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LoginColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginColors.borderLight, width: 1),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: LoginColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight, width: 1),
            ),
            child: Icon(
              Icons.refresh_rounded,
              color: LoginColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () => context.read<ProfileViewModel>().refreshProfile(),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: LoginColors.primary,
              strokeWidth: 3,
            ),
          );
        }

        final hasCriticalLoadError =
            vm.hasError && vm.userId == null && vm.companyId == null;
        if (hasCriticalLoadError) {
          return _ErrorContent(error: vm.errorMessage ?? 'Unknown error');
        }

        return _ProfileContent(vm: vm);
      },
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final ProfileViewModel vm;
  const _ProfileContent({required this.vm});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late final TextEditingController _userNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  late final TextEditingController _companyNameController;
  late final TextEditingController _industryController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _panController;
  late final TextEditingController _gstNoController;
  late final TextEditingController _hsnCodeController;
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

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(
      text: widget.vm.userName?.trim() ?? '',
    );
    _firstNameController = TextEditingController(
      text: widget.vm.firstName?.trim() ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.vm.lastName?.trim() ?? '',
    );
    _emailController = TextEditingController(
      text: widget.vm.email?.trim() ?? '',
    );

    final company = widget.vm.companyDetail;
    _companyNameController = TextEditingController(
      text: company?.companyName.trim() ?? widget.vm.companyName?.trim() ?? '',
    );
    _industryController = TextEditingController(
      text: company?.industry.trim() ?? '',
    );
    _shortNameController = TextEditingController(
      text: company?.shortName?.trim() ?? '',
    );
    _panController = TextEditingController(text: company?.pan?.trim() ?? '');
    _gstNoController = TextEditingController(
      text: company?.gstNo?.trim() ?? '',
    );
    _hsnCodeController = TextEditingController(
      text: company?.hsnCode?.trim() ?? '',
    );
    _contactPersonController = TextEditingController(
      text: company?.contactPerson?.trim() ?? '',
    );
    _contactEmailController = TextEditingController(
      text: company?.contactEmail?.trim() ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: company?.contactPhone?.trim() ?? '',
    );
    _websiteController = TextEditingController(
      text: company?.website?.trim() ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: company?.addressLine1?.trim() ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: company?.addressLine2?.trim() ?? '',
    );
    _cityController = TextEditingController(text: company?.city?.trim() ?? '');
    _stateController = TextEditingController(
      text: company?.state?.trim() ?? '',
    );
    _countryController = TextEditingController(
      text: company?.country?.trim() ?? '',
    );
    _postalCodeController = TextEditingController(
      text: company?.postalCode?.trim() ?? '',
    );
    _publicDescriptionController = TextEditingController(
      text: company?.publicDescription?.trim() ?? '',
    );
    _pendingLogo = null;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _industryController.dispose();
    _shortNameController.dispose();
    _panController.dispose();
    _gstNoController.dispose();
    _hsnCodeController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final userName = vm.userName ?? 'User';
    final userRole = vm.displayRole;

    return RefreshIndicator(
      onRefresh: vm.refreshProfile,
      backgroundColor: LoginColors.surface,
      color: LoginColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            _buildHeader(userName, userRole),
            const SizedBox(height: 24),
            if (vm.hasError && vm.errorMessage != null)
              _InlineErrorBanner(
                message: vm.errorMessage!,
                onDismiss: vm.dismissError,
              ),
            if (vm.hasError && vm.errorMessage != null)
              const SizedBox(height: 16),
            _buildProfileSection(vm),
            const SizedBox(height: 16),
            _buildCompanySection(vm),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String role) {
    return Column(
      children: [
        _AvatarWithGradient(name: name),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: LoginColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: LoginColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(ProfileViewModel vm) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Profile Information'),
          const SizedBox(height: 16),
          _InputField(
            controller: _userNameController,
            label: 'Username *',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _firstNameController,
                  label: 'First Name',
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyPill(
                  label: 'User ID',
                  value: vm.userId?.toString() ?? '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyPill(
                  label: 'Phone',
                  value: vm.contactNo?.trim().isNotEmpty == true
                      ? vm.contactNo!.trim()
                      : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.isSavingProfile ? null : _saveProfile,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                disabledBackgroundColor: LoginColors.primary.withValues(
                  alpha: 0.4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: vm.isSavingProfile
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(vm.isSavingProfile ? 'Saving...' : 'Save Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection(ProfileViewModel vm) {
    final Company? company = vm.companyDetail;
    if (vm.companyId == null) {
      return _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Company Information'),
            SizedBox(height: 12),
            Text(
              'No active company found for this account.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Company Information'),
          const SizedBox(height: 16),
          _buildCompanyLogoUploader(vm, company),
          const SizedBox(height: 16),
          _ReadOnlyPill(label: 'Company ID', value: vm.companyId!.toString()),
          const SizedBox(height: 12),
          _InputField(
            controller: _companyNameController,
            label: 'Company Name *',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _industryController,
            label: 'Industry *',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _shortNameController,
                  label: 'Short Name',
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _panController,
                  label: 'PAN',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _gstNoController,
                  label: 'GST No',
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _hsnCodeController,
                  label: 'HSN Code',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _contactPersonController,
            label: 'Contact Person',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _contactEmailController,
                  label: 'Contact Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _contactPhoneController,
                  label: 'Contact Phone',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _websiteController,
            label: 'Website',
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _addressLine1Controller,
            label: 'Address Line 1',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _addressLine2Controller,
            label: 'Address Line 2',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _cityController,
                  label: 'City',
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _stateController,
                  label: 'State',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: _countryController,
                  label: 'Country',
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _publicDescriptionController,
            label: 'Public Description',
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.isSavingCompany ? null : _saveCompany,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                disabledBackgroundColor: LoginColors.primary.withValues(
                  alpha: 0.4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: vm.isSavingCompany
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.apartment_rounded),
              label: Text(
                vm.isSavingCompany ? 'Saving...' : 'Save Company Information',
              ),
            ),
          ),
          if (company == null) ...[
            const SizedBox(height: 10),
            Text(
              'Company details are loading from server. Tap save again if you updated values.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ProfileViewModel>().logout(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            SizedBox(width: 8),
            Text(
              'Sign Out Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final vm = widget.vm;
    final ok = await vm.updateProfile(
      userName: _userNameController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    if (ok) {
      _showSnackBar('Profile updated successfully', isError: false);
      return;
    }
    _showSnackBar(vm.errorMessage ?? 'Failed to update profile');
  }

  Widget _buildCompanyLogoUploader(ProfileViewModel vm, Company? company) {
    final hasLogo = company?.fsId?.trim().isNotEmpty == true;
    final logoPreview = _pendingLogo != null
        ? Image.file(_pendingLogo!, fit: BoxFit.cover)
        : hasLogo
        ? Image.network(
            AppConfig.getFileUrl(company!.fsId!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.white70,
            ),
          )
        : const Icon(Icons.business_outlined, size: 48, color: Colors.white70);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Logo',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 100,
                width: 100,
                color: LoginColors.primary.withValues(alpha: 0.15),
                child: logoPreview,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pendingLogo != null
                        ? 'New logo selected'
                        : 'Current company logo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _pendingLogo != null
                        ? 'Tap Upload Logo to save changes.'
                        : hasLogo
                        ? 'Tap Change Logo to update it.'
                        : 'No logo uploaded yet. Pick one to add your company branding.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(
                            _pendingLogo != null ? 'Change Logo' : 'Pick Logo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_pendingLogo != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: vm.isUploadingLogo
                            ? null
                            : _uploadCompanyLogo,
                        icon: vm.isUploadingLogo
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload_rounded),
                        label: Text(
                          vm.isUploadingLogo ? 'Uploading...' : 'Upload Logo',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
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

  Future<void> _uploadCompanyLogo() async {
    final vm = widget.vm;
    if (vm.companyId == null || _pendingLogo == null) return;

    final ok = await vm.uploadCompanyLogo(_pendingLogo!);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _pendingLogo = null;
      });
      _showSnackBar('Company logo updated successfully', isError: false);
      return;
    }
    _showSnackBar(vm.errorMessage ?? 'Failed to upload company logo');
  }

  Future<void> _saveCompany() async {
    final vm = widget.vm;
    final ok = await vm.updateCompanyInfo(
      companyName: _companyNameController.text,
      industry: _industryController.text,
      shortName: _shortNameController.text,
      pan: _panController.text,
      gstNo: _gstNoController.text,
      hsnCode: _hsnCodeController.text,
      contactPerson: _contactPersonController.text,
      contactEmail: _contactEmailController.text,
      contactPhone: _contactPhoneController.text,
      website: _websiteController.text,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      postalCode: _postalCodeController.text,
      publicDescription: _publicDescriptionController.text,
    );
    if (!mounted) return;
    if (ok) {
      _showSnackBar('Company information updated successfully', isError: false);
      return;
    }
    _showSnackBar(vm.errorMessage ?? 'Failed to update company information');
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? LoginColors.error : const Color(0xFF15803D),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final int maxLines;
  final TextInputAction textInputAction;

  const _InputField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = textInputAction == TextInputAction.newline && maxLines != 1 && keyboardType == TextInputType.text
        ? TextInputType.multiline
        : keyboardType;

    return TextFormField(
      controller: controller,
      keyboardType: effectiveKeyboardType,
      maxLines: maxLines,
      textInputAction: textInputAction,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: LoginColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: LoginColors.textSecondary,
        ),
        filled: true,
        fillColor: LoginColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LoginColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _ReadOnlyPill extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: LoginColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _InlineErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD7D7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: LoginColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LoginColors.error,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            splashRadius: 18,
            icon: const Icon(Icons.close_rounded, color: LoginColors.error),
          ),
        ],
      ),
    );
  }
}

class _AvatarWithGradient extends StatelessWidget {
  final String name;
  const _AvatarWithGradient({required this.name});

  @override
  Widget build(BuildContext context) {
    final color = _getAvatarColor(name);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF0F172A),
      Color(0xFF0D9488),
      Color(0xFF2563EB),
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: LoginColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String error;
  const _ErrorContent({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: LoginColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: LoginColors.error.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  context.read<ProfileViewModel>().refreshProfile(),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}
