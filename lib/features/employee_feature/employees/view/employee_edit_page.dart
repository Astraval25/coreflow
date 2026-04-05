import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_request.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employee_edit_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeEditPage extends StatelessWidget {
  final int companyId;
  final int employeeId;

  const EmployeeEditPage({
    super.key,
    required this.companyId,
    required this.employeeId,
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
              EmployeeEditViewModel(EmployeeRepository())
                ..loadEmployeeDetails(companyId, employeeId),
        ),
      ],
      child: _EmployeeEditScreen(companyId: companyId, employeeId: employeeId),
    );
  }
}

class _EmployeeEditScreen extends StatefulWidget {
  final int companyId;
  final int employeeId;

  const _EmployeeEditScreen({
    required this.companyId,
    required this.employeeId,
  });

  @override
  State<_EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<_EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPopulated = false;

  final _employeeCodeController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _joinedDateController = TextEditingController();

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _employeeNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _joinedDateController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinedDate() async {
    final current = DateTime.tryParse(_joinedDateController.text.trim());
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _joinedDateController.text = '$y-$m-$d';
    }
  }

  void _populateIfNeeded(EmployeeEditViewModel vm) {
    if (_isPopulated || vm.employeeDetails == null) return;
    final e = vm.employeeDetails!;
    _employeeCodeController.text = e.employeeCode;
    _employeeNameController.text = e.employeeName;
    _phoneController.text = e.phone ?? '';
    _emailController.text = e.email ?? '';
    _designationController.text = e.designation ?? '';
    _joinedDateController.text = e.joinedDt ?? '';
    _isPopulated = true;
  }

  Future<void> _save(EmployeeEditViewModel vm) async {
    vm.clearError();
    if (!_formKey.currentState!.validate()) return;

    final request = EmployeeEditRequest(
      employeeName: _employeeNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      designation: _designationController.text.trim().isEmpty
          ? null
          : _designationController.text.trim(),
      joinedDt: _joinedDateController.text.trim().isEmpty
          ? null
          : _joinedDateController.text.trim(),
    );

    final ok = await vm.updateEmployee(
      widget.companyId,
      widget.employeeId,
      request,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee updated successfully')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeEditViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    _populateIfNeeded(vm);

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Employee',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
      ),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LoginColors.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _card(
                      title: 'Basic Details',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _employeeCodeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Employee Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _employeeNameController,
                            label: 'Employee Name',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Employee name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _phoneController,
                            label: 'Phone',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _designationController,
                            label: 'Designation',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _joinedDateController,
                            readOnly: true,
                            onTap: _pickJoinedDate,
                            decoration: InputDecoration(
                              labelText: 'Joined Date',
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: vm.isSaving ? null : () => _save(vm),
                      icon: vm.isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(vm.isSaving ? 'Saving...' : 'Save Changes'),
                      style: FilledButton.styleFrom(
                        backgroundColor: LoginColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    if (vm.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.error!,
                        style: TextStyle(
                          color: LoginColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: LoginColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
