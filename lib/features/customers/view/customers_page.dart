import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/customers/view_model/active_customers_view_model.dart';
import 'package:coreflow/features/customers/widget/active_customers_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveCustomersPage extends StatelessWidget {
  final int companyId;
  const ActiveCustomersPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ActiveCustomersViewModel(AuthRepository())
            ..loadActiveCustomers(companyId),
      child: ActiveCustomersView(companyId: companyId),
    );
  }
}
