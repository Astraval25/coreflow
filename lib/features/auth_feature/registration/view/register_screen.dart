import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/register_view_model.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<RegisterViewModel>(
              builder: (context, viewModel, child) {
                return Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.successMessage ??
                            'Register with company, phone and password',
                        style: TextStyle(
                          fontSize: 16,
                          color: viewModel.successMessage != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),

                      if (viewModel.successMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(viewModel.successMessage!)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      CustomTextField(
                        controller: viewModel.companyController,
                        labelText: 'Company Name',
                        validator: viewModel.validateCompany,
                        enabled: !viewModel.isLoading,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: viewModel.phoneNumberController,
                        labelText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: viewModel.validatePhoneNumber,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        prefixText: '+91 ',
                        helperText: 'India mobile numbers only',
                        enabled: !viewModel.isLoading,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: viewModel.passwordController,
                        labelText: 'Password',
                        obscureText: viewModel.obscurePassword,
                        validator: viewModel.validatePassword,
                        enabled: !viewModel.isLoading,
                        autofillHints: const [AutofillHints.newPassword],
                        suffixIcon: viewModel.isLoading
                            ? null
                            : IconButton(
                                icon: Icon(
                                  viewModel.obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: viewModel.togglePasswordVisibility,
                              ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: viewModel.confirmPasswordController,
                        labelText: 'Confirm Password',
                        obscureText: viewModel.obscurePassword,
                        validator: viewModel.validateConfirmPassword,
                        enabled: !viewModel.isLoading,
                        autofillHints: const [AutofillHints.newPassword],
                        suffixIcon: viewModel.isLoading
                            ? null
                            : IconButton(
                                icon: Icon(
                                  viewModel.obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: viewModel.togglePasswordVisibility,
                              ),
                      ),

                      if (viewModel.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
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
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      CustomButton(
                        text: viewModel.isLoading
                            ? 'Registering...'
                            : 'Register',
                        isLoading: viewModel.isLoading,
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.register(context),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go(CfRoutes.login),
                          child: const Text('Already have account? Login'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
