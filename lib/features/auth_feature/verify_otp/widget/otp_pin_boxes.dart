import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import '../view_model/verify_otp_view_model.dart';

class OtpPinBoxes extends StatefulWidget {
  final VerifyOtpViewModel viewModel;
  const OtpPinBoxes({super.key, required this.viewModel});

  @override
  State<OtpPinBoxes> createState() => _OtpPinBoxesState();
}

class _OtpPinBoxesState extends State<OtpPinBoxes> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateOtpValue() {
    widget.viewModel.otpController.text = _controllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final hasFocus = _focusNodes[index].hasFocus;
        return Container(
          width: 46,
          height: 56,
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasFocus ? LoginColors.primary : LoginColors.border,
              width: hasFocus ? 2 : 1.2,
            ),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            enabled: !widget.viewModel.isLoading,
            style: TextStyle(
              fontSize: 24,
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _updateOtpValue();
            },
          ),
        );
      }),
    );
  }
}
