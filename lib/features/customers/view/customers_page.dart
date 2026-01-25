import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/customers/view/customers_view.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/customers/view_model/customers_view_model.dart';

class ActiveCustomersPage extends StatelessWidget {
  final int companyId;
  const ActiveCustomersPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ActiveCustomersViewModel(AuthRepository())
                ..loadCustomers(companyId),
        ),
      ],
      child: ActiveCustomersView(companyId: companyId),
    );
  }
}
