import 'package:flutter/material.dart';


class RefreshableView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshableView({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}
