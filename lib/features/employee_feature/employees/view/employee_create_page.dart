import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/create_employee_request.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employee_edit_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeCreatePage extends StatelessWidget {
  final int companyId;

  const EmployeeCreatePage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeEditViewModel(EmployeeRepository()),
        ),
      ],
      child: _EmployeeCreateScreen(companyId: companyId),
    );
  }
}

class _EmployeeCreateScreen extends StatefulWidget {
  final int companyId;

  const _EmployeeCreateScreen({required this.companyId});

  @override
  State<_EmployeeCreateScreen> createState() => _EmployeeCreateScreenState();
}

class _EmployeeCreateScreenState extends State<_EmployeeCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _employeeCodeController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _joinedDateController = TextEditingController();
  final _monthlyAmountController = TextEditingController();

  String _salaryType = 'MONTHLY';

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _employeeNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _joinedDateController.dispose();
    _monthlyAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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

  Future<void> _save(EmployeeEditViewModel vm) async {
    vm.clearError();
    if (!_formKey.currentState!.validate()) return;

    final request = CreateEmployeeRequest(
      employeeCode: _employeeCodeController.text.trim(),
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
      salaryType: _salaryType,
      monthlyAmount: _salaryType == 'MONTHLY'
          ? double.tryParse(_monthlyAmountController.text.trim())
          : null,
    );

    final ok = await vm.createEmployee(widget.companyId, request);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee created successfully')),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeEditViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Create Employee',
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
      body: Form(
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
                    _textField(
                      controller: _employeeCodeController,
                      label: 'Employee Code',
                      hint: 'EMP-001',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Employee code is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _employeeNameController,
                      label: 'Employee Name',
                      hint: 'Ravi Kumar',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Employee name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: '9876543210',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'name@company.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _designationController,
                      label: 'Designation',
                      hint: 'Machine Operator',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _joinedDateController,
                      readOnly: true,
                      onTap: _pickJoinedDate,
                      decoration: InputDecoration(
                        labelText: 'Joined Date',
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _card(
                title: 'Salary',
                icon: Icons.account_balance_wallet_outlined,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _salaryType,
                      decoration: InputDecoration(
                        labelText: 'Salary Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'MONTHLY',
                          child: Text('MONTHLY'),
                        ),
                        DropdownMenuItem(
                          value: 'WORK_BASED',
                          child: Text('WORK_BASED'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _salaryType = value;
                          });
                        }
                      },
                    ),
                    if (_salaryType == 'MONTHLY') ...[
                      const SizedBox(height: 12),
                      _textField(
                        controller: _monthlyAmountController,
                        label: 'Monthly Amount',
                        hint: '25000',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (_salaryType != 'MONTHLY') return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Monthly amount is required';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
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
                label: Text(vm.isSaving ? 'Saving...' : 'Save Employee'),
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
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
