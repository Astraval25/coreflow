import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart'; 
import '../view_model/customer_detail_view_model.dart';
import 'customer_detail_content.dart';

class CustomerDetailView extends StatelessWidget {
  final int companyId;
  final int customerId;

  const CustomerDetailView({
    super.key,
    required this.companyId,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DashboardViewModel()..loadUserData(), 
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerDetailViewModel(
            companyId: companyId,
            customerId: customerId,
          )..loadCustomerDetail(),
        ),
      ],
      child: const CustomerDetailContent(),
    );
  }
}
