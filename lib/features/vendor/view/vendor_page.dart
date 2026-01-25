import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/vendor/view/customers_view.dart';
import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ActiveVendorsPage extends StatelessWidget {
  final int companyId;

  const ActiveVendorsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ActiveVendorViewModel(AuthRepository())
                ..loadVendor(companyId),
        ),
      ],
      child: ActiveVendorView(companyId: companyId),
    );
  }
}

