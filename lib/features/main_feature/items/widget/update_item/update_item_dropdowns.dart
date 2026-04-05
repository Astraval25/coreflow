import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class UpdateItemTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const UpdateItemTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: TextStyle(fontSize: 16, color: LoginColors.textPrimary),
      decoration: _inputDecoration(
        labelText: 'Item type',
        icon: Icons.category_outlined,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: LoginColors.textSecondary,
      ),
      dropdownColor: LoginColors.surface,
      borderRadius: BorderRadius.circular(12),
      items: const [
        DropdownMenuItem(value: 'GOODS', child: Text('Goods')),
        DropdownMenuItem(value: 'SERVICE', child: Text('Service')),
      ],
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(fontSize: 14, color: LoginColors.textSecondary),
      hintStyle: TextStyle(fontSize: 14, color: LoginColors.textTertiary),
      prefixIcon: Icon(icon, size: _iconSize, color: LoginColors.textTertiary),
      filled: true,
      fillColor: LoginColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.primary, width: 1.4),
      ),
    );
  }
}

class UpdateItemUnitDropdown extends StatelessWidget {
  final String? selectedUnit;
  final List<String> unitOptions;
  final ValueChanged<String?> onChanged;

  const UpdateItemUnitDropdown({
    super.key,
    required this.selectedUnit,
    required this.unitOptions,
    required this.onChanged,
  });

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final List<String> dropdownOptions = [...unitOptions];
    if (selectedUnit != null &&
        selectedUnit!.isNotEmpty &&
        !dropdownOptions.contains(selectedUnit)) {
      dropdownOptions.insert(0, selectedUnit!);
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedUnit,
      style: TextStyle(fontSize: 16, color: LoginColors.textPrimary),
      decoration: _inputDecoration(
        labelText: 'Unit',
        icon: Icons.straighten_outlined,
        hintText: 'Select unit',
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: LoginColors.textSecondary,
      ),
      dropdownColor: LoginColors.surface,
      borderRadius: BorderRadius.circular(12),
      items: dropdownOptions
          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(fontSize: 14, color: LoginColors.textSecondary),
      hintStyle: TextStyle(fontSize: 14, color: LoginColors.textTertiary),
      prefixIcon: Icon(icon, size: _iconSize, color: LoginColors.textTertiary),
      filled: true,
      fillColor: LoginColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.primary, width: 1.4),
      ),
    );
  }
}
