import 'dart:async';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WorkSaveState { idle, invalid, pending, saving, saved, error }

/// Today's work-based input section. Owns its own per-work-def text
/// controllers, debounce timers and save states.
class PortalWorkBasedSection extends StatefulWidget {
  final EmployeePortalViewModel vm;
  const PortalWorkBasedSection({super.key, required this.vm});

  @override
  State<PortalWorkBasedSection> createState() => _PortalWorkBasedSectionState();
}

class _PortalWorkBasedSectionState extends State<PortalWorkBasedSection> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, Timer> _debounceTimers = {};
  final Map<int, WorkSaveState> _saveStates = {};

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    for (final t in _debounceTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int workDefId) {
    return _qtyControllers.putIfAbsent(
      workDefId,
      () => TextEditingController(),
    );
  }

  void _onQtyChanged(WorkDefinitionData work, {bool isUpdate = false}) {
    final vm = widget.vm;
    final id = work.workDefId;
    _debounceTimers[id]?.cancel();
    final text = _controllerFor(id).text.trim();

    if (text.isEmpty) {
      setState(() => _saveStates[id] = WorkSaveState.idle);
      return;
    }
    final qty = double.tryParse(text);
    if (qty == null || qty <= 0) {
      setState(() => _saveStates[id] = WorkSaveState.invalid);
      return;
    }

    setState(() => _saveStates[id] = WorkSaveState.pending);
    _debounceTimers[id] = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      setState(() => _saveStates[id] = WorkSaveState.saving);
      final ok = isUpdate
          ? await vm.updateWorkLog(
              workDefId: id,
              logDate: vm.today,
              quantity: qty,
            )
          : await vm.createWorkLog(
              workDefId: id,
              logDate: vm.today,
              quantity: qty,
            );
      if (!mounted) return;
      setState(() {
        _saveStates[id] = ok ? WorkSaveState.saved : WorkSaveState.error;
      });
      // Keep entered value visible — after reload, the row becomes
      // "editable existing" and the controller text already matches.
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        if (vm.workDefinitions.isEmpty)
          const PortalEmptyCard(
            icon: Icons.workspaces_outline,
            title: 'No work types available',
            subtitle: 'Ask your admin to set up work types.',
          )
        else
          ...vm.workDefinitions.map((w) => _workDefRow(vm, w)),
      ],
    );
  }

  Widget _workDefRow(EmployeePortalViewModel vm, WorkDefinitionData work) {
    final existing = vm.findLogForToday(work.workDefId);
    final locked = vm.isTodayLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              work.workName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: existing != null &&
                    existing.status.toUpperCase() == 'APPROVED'
                ? _submittedRow(existing)
                : existing != null
                    ? _editableRow(work, existing)
                    : locked
                        ? _disabledLockRow()
                        : _qtyInputRow(work),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              work.unit,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submittedRow(WorkLogData log) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: LoginColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '${log.quantity ?? '-'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: LoginColors.success,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _editableRow(WorkDefinitionData work, WorkLogData existing) {
    final controller = _controllerFor(work.workDefId);
    if (controller.text.isEmpty && existing.quantity != null) {
      final q = existing.quantity!;
      controller.text = q % 1 == 0 ? q.toInt().toString() : q.toString();
    }
    return _workInputField(
      controller: controller,
      hintText: work.unit,
      onChanged: (_) => _onQtyChanged(work, isUpdate: true),
    );
  }

  Widget _disabledLockRow() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'Locked',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: LoginColors.textSecondary,
        ),
      ),
    );
  }

  Widget _qtyInputRow(WorkDefinitionData work) {
    final controller = _controllerFor(work.workDefId);
    return _workInputField(
      controller: controller,
      hintText: work.unit,
      onChanged: (_) => _onQtyChanged(work),
    );
  }

  Widget _workInputField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LoginColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: LoginColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: LoginColors.background,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
