import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/custom_button.dart';
import 'package:coreflow/core/widgets/custom_textfield.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: LoginColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Consumer<LoginViewModel>(
              builder: (context, viewModel, child) {
                return AutofillGroup(
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 72),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: LoginColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'CoreFlow',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: LoginColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildModeSwitcher(context, viewModel),
                        if (viewModel.errorMessage != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        if (viewModel.isEmployeeLogin)
                          CustomTextField(
                            controller: viewModel.identifierController,
                            labelText: 'Username',
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.person_outline,
                            validator: viewModel.validateIdentifier,
                            autofillHints: const [AutofillHints.username],
                            enabled: !viewModel.isLoading,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          )
                        else
                          CustomTextField(
                            controller: viewModel.phoneController,
                            labelText: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: viewModel.validatePhoneNumber,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            prefixText: '+91 ',
                            helperText: 'India mobile numbers only',
                            enabled: !viewModel.isLoading,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: viewModel.passwordController,
                          labelText: 'Password',
                          obscureText: viewModel.obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          validator: viewModel.validatePassword,
                          autofillHints: const [AutofillHints.password],
                          enabled: !viewModel.isLoading,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => viewModel.login(context),
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: LoginColors.textSecondary,
                            ),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(child: SizedBox()),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        CustomButton(
                          text: viewModel.isLoading
                              ? 'Signing In...'
                              : 'Sign In',
                          isLoading: viewModel.isLoading,
                          enabled: !viewModel.isLoading,
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.login(context),
                        ),
                        const SizedBox(height: 24),
                        if (!viewModel.isEmployeeLogin)
                          TextButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => context.go(CfRoutes.register),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: viewModel.isLoading
                                    ? Colors.grey
                                    : LoginColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(BuildContext context, LoginViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LoginColors.fieldFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              label: 'Admin Login',
              selected: viewModel.loginMode == LoginMode.admin,
              onTap: () => viewModel.setLoginMode(LoginMode.admin),
            ),
          ),
          Expanded(
            child: _modeButton(
              label: 'Employee Login',
              selected: viewModel.loginMode == LoginMode.employee,
              onTap: () => viewModel.setLoginMode(LoginMode.employee),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? LoginColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : LoginColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
