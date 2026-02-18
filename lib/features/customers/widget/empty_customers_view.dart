import 'package:coreflow/core/theme/colors.dart';
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
        height: MediaQuery.of(context).size.height * 0.78,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),

                Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoginColors.primary.withOpacity(0.06),
                    border: Border.all(
                      color: LoginColors.primary.withOpacity(0.14),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    isSearching
                        ? Icons.search_off_rounded
                        : Icons.people_alt_outlined,
                    size: 66,
                    color: LoginColors.textTertiary.withOpacity(0.65),
                  ),
                ),

                const SizedBox(height: 28),

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

                const SizedBox(height: 10),

                Text(
                  isSearching
                      ? 'No customers match "$searchQuery".\nTry a different keyword.'
                      : 'Add your first customer to start creating invoices\nand tracking payments.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: LoginColors.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 26),

                ElevatedButton.icon(
                  onPressed: () => context.push('/customers/$companyId/add'),
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

                if (isSearching) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Clear search from the top bar to view all customers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: LoginColors.textTertiary,
                    ),
                  ),
                ],

                if (!isSearching) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: LoginColors.fieldFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: LoginColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Tip: You can switch Active / Inactive using top tabs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
