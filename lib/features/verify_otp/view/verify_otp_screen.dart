import 'dart:async';
import 'package:coreflow/features/verify_otp/widget/otp_pin_boxes.dart'
    show OtpPinBoxes;
import 'package:coreflow/features/verify_otp/widget/otp_status_message.dart';
import 'package:coreflow/features/verify_otp/widget/resend_otp_button.dart';
import 'package:coreflow/features/verify_otp/widget/verify_otp_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_model/verify_otp_view_model.dart';
import '../../../core/widgets/custom_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, String? userPath});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  int _resendTimer = 30;
  Timer? _timer;
  bool _emailSet = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyOtpViewModel(),
      child: AutofillGroup(
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Consumer<VerifyOtpViewModel>(
                builder: (context, vm, _) {
                  if (!_emailSet) {
                    _emailSet = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final uri = GoRouterState.of(context).uri;
                      final emailParam = uri.queryParameters['email'];

                      if (emailParam != null && emailParam.isNotEmpty) {
                        vm.setUserPath(emailParam);
                      }
                    });
                  }

                  return Column(
                    children: [
                      VerifyOtpHeader(userPath: vm.userPath),

                      const SizedBox(height: 48),

                      /// OTP INPUT
                      OtpPinBoxes(viewModel: vm),

                      const SizedBox(height: 32),

                      /// ERROR
                      if (vm.errorMessage != null &&
                          vm.errorMessage!.isNotEmpty)
                        OtpStatusMessage(
                          message: vm.errorMessage!,
                          isError: true,
                        ),

                      /// SUCCESS
                      if (vm.successMessage != null &&
                          vm.successMessage!.isNotEmpty)
                        OtpStatusMessage(message: vm.successMessage!),

                      /// VERIFY BUTTON
                      CustomButton(
                        text: vm.isLoading ? 'Verifying...' : 'Verify OTP',
                        isLoading: vm.isLoading,
                        onPressed: vm.isLoading
                            ? null
                            : () {
                                TextInput.finishAutofillContext();
                                vm.verifyOtp(context);
                              },
                      ),

                      const SizedBox(height: 16),

                      /// RESEND BUTTON
                      ResendOtpButton(
                        canResend: context
                            .watch<VerifyOtpViewModel>()
                            .canResend, // false initially
                        timer: context
                            .watch<VerifyOtpViewModel>()
                            .resendTimer, // 30 initially
                        onPressed:
                            context.watch<VerifyOtpViewModel>().canResend &&
                                !context
                                    .watch<VerifyOtpViewModel>()
                                    .isResendLoading
                            ? () =>
                                  context.read<VerifyOtpViewModel>().resendOtp()
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
