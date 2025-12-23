import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/registration/view/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' hide Create;

import '../view_model/login_view_model.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: LoginColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Consumer<LoginViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo (replace with your actual logo or icon)
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
                    const SizedBox(height: 48),

                    Text(
                      'CoreFlow',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: LoginColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),

                    CustomTextField(
                      controller: viewModel.emailController,
                      labelText: 'Email or username',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.person_outline,
                      validator: viewModel.validateEmail,
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: viewModel.passwordController,
                      labelText: 'Password',
                      obscureText: viewModel.obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      validator: viewModel.validatePassword,
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
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Forgot password logic
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: LoginColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: viewModel.isLoading ? 'Signing In...' : 'Sign In',
                      isLoading: viewModel.isLoading,
                      enabled: !viewModel.isLoading,
                      onPressed: () => viewModel.login(context),
                    ),
                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: LoginColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
