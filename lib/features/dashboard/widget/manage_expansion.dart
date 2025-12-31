import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageExpansion extends StatelessWidget {
  final DashboardViewModel vm;

  const ManageExpansion({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.manage_accounts_outlined),
      title: Text(
        'Manage',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: vm.isCustomersExpanded
          ? const Icon(Icons.keyboard_arrow_down_rounded)
          : const Icon(Icons.keyboard_arrow_right),
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      initiallyExpanded: vm.isCustomersExpanded,
      onExpansionChanged: vm.toggleCustomersExpanded,
      children: const [
        SubMenuItem(title: 'Customers', menuKey: 'customers'),
        SubMenuItem(title: 'Vender', menuKey: 'vender'),
        SubMenuItem(title: 'Items', menuKey: 'items'),
      ],
    );
  }
}

class SubMenuItem extends StatelessWidget {
  final String title;
  final String menuKey;

  const SubMenuItem({super.key, required this.title, required this.menuKey});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isSelected = vm.selectedMenu == menuKey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          Icons.add,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        minVerticalPadding: 2,
        onTap: () {
          context.read<DashboardViewModel>().setSelectedMenu(menuKey);
          Navigator.pop(context);
        },
      ),
    );
  }
}
