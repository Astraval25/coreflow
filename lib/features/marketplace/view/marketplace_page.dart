import 'package:coreflow/features/marketplace/view_model/marketplace_view_model.dart';
import 'package:coreflow/features/marketplace/view/marketplace_view.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketplaceViewModel()..loadCompanies(),
        ),
      ],
      child: const MarketplaceView(),
    );
  }
}
