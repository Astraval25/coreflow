import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/features/employee_feature/employees/view/employees_view.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employees_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeesPage extends StatelessWidget {
  final int companyId;

  const EmployeesPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EmployeesViewModel(EmployeeRepository())
                ..loadEmployees(companyId),
        ),
      ],
      child: EmployeesView(companyId: companyId),
    );
  }
}
