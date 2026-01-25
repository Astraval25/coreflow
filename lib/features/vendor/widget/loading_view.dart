import 'package:flutter/material.dart';

class LoadingDisplayView extends StatelessWidget {
  const LoadingDisplayView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
