import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/features/company/view_model/company_view_model.dart';
import 'package:flutter/material.dart';
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

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.companyName ?? '');
    _industryController = TextEditingController(text: widget.company?.industry ?? '');
    _panController = TextEditingController(text: widget.company?.pan ?? '');
    _gstController = TextEditingController(text: widget.company?.gstNo ?? '');
    _hsnController = TextEditingController(text: widget.company?.hsnCode ?? '');
    _shortNameController = TextEditingController(text: widget.company?.shortName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _hsnController.dispose();
    _shortNameController.dispose();
    super.dispose();
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
              _buildField(
                controller: _nameController,
                label: 'Company Name',
                hint: 'Enter company name',
                icon: Icons.business_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Company name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _industryController,
                label: 'Industry',
                hint: 'e.g. Software Development, IT',
                icon: Icons.category_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Industry is required' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _shortNameController,
                label: 'Short Name',
                hint: 'e.g. AdvTechSol',
                icon: Icons.short_text_rounded,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.isSaving ? null : _submit,
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
                  child: vm.isSaving
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
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
              borderSide: const BorderSide(color: LoginColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CompanyViewModel>();
    bool success;

    if (isEditing) {
      success = await vm.updateCompany(
        companyId: widget.company!.companyId,
        companyName: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        pan: _panController.text.trim(),
        gstNo: _gstController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        shortName: _shortNameController.text.trim(),
      );
    } else {
      success = await vm.createCompany(
        companyName: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        pan: _panController.text.trim(),
        gstNo: _gstController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        shortName: _shortNameController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
            isEditing ? 'Company updated successfully' : 'Company created successfully',
          ),
          backgroundColor: LoginColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text(vm.errorMessage ?? 'Operation failed'),
          backgroundColor: LoginColors.error,
        ),
      );
    }
  }
}
