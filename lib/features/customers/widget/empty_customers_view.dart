import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyCustomersView extends StatelessWidget {
  final String searchQuery;
  final int companyId;

  const EmptyCustomersView({
    super.key,
    required this.searchQuery,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSearching = searchQuery.trim().isNotEmpty;

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
                  isSearching ? 'No matches found' : 'No customers added yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 26),

                ElevatedButton.icon(
                  onPressed: () => context.push(CfRoutes.customerCreate(companyId)),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    isSearching ? 'Add Customer' : 'Add First Customer',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
