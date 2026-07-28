import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/features/main_feature/customers/view/customers_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customers_view_model.dart';

class ActiveCustomersPage extends StatelessWidget {
  final int companyId;
  const ActiveCustomersPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ActiveCustomersViewModel(AuthRepository())..loadCustomers(companyId),
      child: ActiveCustomersView(companyId: companyId),
    );
  }
}
