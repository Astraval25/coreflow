import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeEmptyView extends StatelessWidget {
  final int companyId;
  final String searchQuery;

  const EmployeeEmptyView({
    super.key,
    required this.companyId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.trim().isNotEmpty;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSearching ? 'No employees found' : 'No employees added yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push(CfRoutes.employeeCreate(companyId)),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    isSearching ? 'Add Employee' : 'Add First Employee',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
