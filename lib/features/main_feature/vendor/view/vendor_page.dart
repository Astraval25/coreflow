import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_view.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveVendorsPage extends StatelessWidget {
  final int companyId;

  const ActiveVendorsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ActiveVendorViewModel(AuthRepository())..loadVendor(companyId),
      child: ActiveVendorView(companyId: companyId),
    );
  }
}
