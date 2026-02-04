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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bool isSearching = searchQuery.trim().isNotEmpty;
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(isDark ? 0.12 : 0.09),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.group_add_rounded,
                  size: 80,
                  color: colorScheme.primary.withOpacity(0.70),
                ),
              ),

              const SizedBox(height: 48),

              Text(
                isSearching ? 'No matches found' : 'No customers added yet',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.1,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                isSearching
                    ? 'No customers match “$searchQuery”.\nTry adjusting your search or add someone new.'
                    : 'Start building your customer list by adding your first contact.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.48,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // ── Primary CTA ───────────────────────────────────────────────
              if (!isSearching)
                FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add First Customer'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    minimumSize: const Size(220, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  onPressed: () => context.push('/customers/$companyId/add'),
                ),

              // ── Secondary CTA (when searching) ────────────────────────────
              if (isSearching) ...[
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add New Customer'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    minimumSize: const Size(220, 52),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.7),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context.push('/customers/$companyId/add'),
                ),

                const SizedBox(height: 32),

                TextButton(
                  onPressed: () {
                    // Optional: clear search field logic here
                    // Usually handled one level up
                  },
                  child: Text(
                    'Clear search',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
