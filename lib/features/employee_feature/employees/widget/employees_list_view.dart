import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/features/employee_feature/employees/widget/employee_list_item.dart';
import 'package:flutter/material.dart';

class EmployeesListView extends StatelessWidget {
  final List<Employee> employees;
  final int companyId;

  const EmployeesListView({
    super.key,
    required this.employees,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return _AnimatedEmployeeEntry(
          key: ValueKey('employee-entry-${employee.employeeId}-$index'),
          index: index,
          child: EmployeeListItem(employee: employee, companyId: companyId),
        );
      },
    );
  }
}

class _AnimatedEmployeeEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedEmployeeEntry({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 210 + (index > 7 ? 7 : index) * 30);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
    );
  }
}
