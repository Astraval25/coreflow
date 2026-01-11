import 'package:flutter/material.dart';

class EmptyCustomersView extends StatelessWidget {
  final String searchQuery;
  const EmptyCustomersView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? 'No customers yet' : 'No customers match your search',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          if (searchQuery.isEmpty)
            Text(
              'Start by adding your first customer',
              style: TextStyle(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}
