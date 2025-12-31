import 'package:flutter/material.dart';
import '../view_model/verify_otp_view_model.dart';

class OtpPinBoxes extends StatefulWidget {
  final VerifyOtpViewModel viewModel;
  const OtpPinBoxes({super.key, required this.viewModel});

  @override
  State<OtpPinBoxes> createState() => _OtpPinBoxesState();
}

class _OtpPinBoxesState extends State<OtpPinBoxes> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? Colors.blue
                  : Colors.grey.shade300,
              width: _focusNodes[index].hasFocus ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            enabled: !widget.viewModel.isLoading,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              widget.viewModel.otpController.text =
                  _controllers.map((e) => e.text).join();
            },
          ),
        );
      }),
    );
  }
}
