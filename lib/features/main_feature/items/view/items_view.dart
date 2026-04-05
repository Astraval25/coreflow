import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/items/view_model/items_view_model.dart';
import 'package:coreflow/features/main_feature/items/widget/items_view_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsPage extends StatelessWidget {
  final int companyId;

  const ItemsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ItemsViewModel(repository: AuthRepository(), companyId: companyId)
                ..fetchItems(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: const ItemsViewBody(),
    );
  }
}
