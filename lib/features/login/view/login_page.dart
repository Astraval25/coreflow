import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/login_view_model.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Consumer<LoginViewModel>(
              builder: (context, viewModel, child) {
                return AutofillGroup(
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 100),

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

                        const SizedBox(height: 32),

                        Text(
                          'CoreFlow',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: LoginColors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (viewModel.errorMessage != null) ...[
                          const SizedBox(height: 16),
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

                        const SizedBox(height: 32),

                        CustomTextField(
                          controller: viewModel.emailController,
                          labelText: 'Email or username',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.person_outline,
                          validator: viewModel.validateEmail,
                          autofillHints: const [AutofillHints.email],
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

                        TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => context.push('/register'),
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
}
