import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import '../view_model/vendor_detail_view_model.dart';
import 'vendor_detail_content.dart';

class VendorDetailView extends StatelessWidget {
  final int companyId;
  final int vendorId;

  const VendorDetailView({
    super.key,
    required this.companyId,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorDetailViewModel(
            companyId: companyId,
            vendorId: vendorId,
          )..loadVendorDetail(),
        ),
      ],
      child: const VendorDetailContent(), // ✅ no scroll here
    );
  }
}


