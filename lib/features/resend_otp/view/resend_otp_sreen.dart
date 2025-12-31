import 'package:coreflow/core/widgets/custom_button.dart';
import 'package:coreflow/core/widgets/custom_textfield.dart';
import 'package:coreflow/features/resend_otp/view%20model/resend_otp_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResendOtpScreen extends StatelessWidget {
  const ResendOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResendOtpViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<ResendOtpViewModel>(
              builder: (context, viewModel, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (viewModel.emailController.text.isEmpty) {
                    final uri = GoRouterState.of(context).uri;
                    final emailParam = uri.queryParameters['email'];
                    if (emailParam != null && emailParam.isNotEmpty) {
                      viewModel.setEmail(emailParam);
                    }
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 150),
                    const Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    CustomTextField(
                      controller: viewModel.emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: viewModel.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (viewModel.successMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.successMessage!,
                              style: TextStyle(color: Colors.green.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    CustomButton(
                      text: viewModel.isLoading ? 'Sending...' : 'Resend OTP',
                      isLoading: viewModel.isLoading,
                      onPressed: () => viewModel.resendOtp(context),
                    ),
                    const SizedBox(height: 19),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Back to Login'),
                    ),
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
