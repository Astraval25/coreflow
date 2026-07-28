import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WorkSaveState { idle, invalid, pending, saving, saved, error }

class PortalWorkBasedSection extends StatefulWidget {
  final EmployeePortalViewModel vm;
  final bool showSaveButton;
  final bool showTopSpacing;
  final bool showPinActions;
  final bool Function(int workDefId)? isPinned;
  final Future<void> Function(int workDefId)? onTogglePin;
  const PortalWorkBasedSection({
    super.key,
    required this.vm,
    this.showSaveButton = true,
    this.showTopSpacing = true,
    this.showPinActions = false,
    this.isPinned,
    this.onTogglePin,
  });

  @override
  State<PortalWorkBasedSection> createState() => PortalWorkBasedSectionState();
}

class PortalWorkBasedSectionState extends State<PortalWorkBasedSection> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, WorkSaveState> _saveStates = {};
  final Set<int> _dirtyWorkDefIds = {};
  final Set<int> _prefilledExistingWorkDefIds = {};

  bool get hasUnsavedChanges => _dirtyWorkDefIds.isNotEmpty;

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int workDefId) {
    return _qtyControllers.putIfAbsent(
      workDefId,
      () => TextEditingController(),
    );
  }

  void _onQtyChanged(WorkDefinitionData work) {
    final id = work.workDefId;
    final text = _controllerFor(id).text.trim();

    if (text.isEmpty) {
      setState(() {
        _saveStates[id] = WorkSaveState.idle;
        _dirtyWorkDefIds.remove(id);
      });
      return;
    }

    final qty = double.tryParse(text);
    if (qty == null || qty <= 0) {
      setState(() {
        _saveStates[id] = WorkSaveState.invalid;
        _dirtyWorkDefIds.add(id);
      });
      return;
    }

    setState(() {
      _saveStates[id] = WorkSaveState.pending;
      _dirtyWorkDefIds.add(id);
    });
  }

  Future<bool> saveAllDrafts() async {
    final vm = widget.vm;
    if (_dirtyWorkDefIds.isEmpty) return true;
    if (vm.isTodayLocked) return false;

    final idsToSave = List<int>.from(_dirtyWorkDefIds);
    var hasFailure = false;

    for (final id in idsToSave) {
      final work = vm.workDefinitions
          .where((w) => w.workDefId == id)
          .cast<WorkDefinitionData?>()
          .firstWhere((w) => w != null, orElse: () => null);
      if (work == null) continue;

      final text = _controllerFor(id).text.trim();
      final qty = double.tryParse(text);
      if (text.isEmpty || qty == null || qty <= 0) {
        hasFailure = true;
        if (mounted) {
          setState(() => _saveStates[id] = WorkSaveState.invalid);
        }
        continue;
      }

      if (mounted) {
        setState(() => _saveStates[id] = WorkSaveState.saving);
      }

      final existing = vm.findLogForToday(id);
      final ok = existing != null
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

      if (!mounted) return false;
      setState(() {
        _saveStates[id] = ok ? WorkSaveState.saved : WorkSaveState.error;
        if (ok) _dirtyWorkDefIds.remove(id);
      });
      if (!ok) hasFailure = true;
    }

    return !hasFailure;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final workDefinitions = List<WorkDefinitionData>.from(vm.workDefinitions);
    if (widget.showPinActions && widget.isPinned != null) {
      workDefinitions.sort((a, b) {
        final aPinned = widget.isPinned!(a.workDefId);
        final bPinned = widget.isPinned!(b.workDefId);
        if (aPinned != bPinned) return aPinned ? -1 : 1;
        return a.workName.toLowerCase().compareTo(b.workName.toLowerCase());
      });
    }
    final pinnedWorks = widget.showPinActions && widget.isPinned != null
        ? workDefinitions
              .where((w) => widget.isPinned!(w.workDefId))
              .toList(growable: false)
        : workDefinitions;
    final otherWorks = widget.showPinActions && widget.isPinned != null
        ? workDefinitions
              .where((w) => !widget.isPinned!(w.workDefId))
              .toList(growable: false)
        : const <WorkDefinitionData>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTopSpacing) const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Work Entries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LoginColors.textPrimary,
                ),
              ),
            ),
            if (widget.showSaveButton)
              FilledButton.icon(
                onPressed: vm.isSubmitting || vm.isTodayLocked
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await saveAllDrafts();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Work entries saved successfully'
                                  : (vm.error ?? 'Some entries failed to save'),
                            ),
                            backgroundColor: ok
                                ? LoginColors.success
                                : LoginColors.error,
                          ),
                        );
                      },
                icon: vm.isSubmitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded, size: 16),
                label: Text(vm.isSubmitting ? 'Saving' : 'Save'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (vm.workDefinitions.isEmpty)
          const PortalEmptyCard(
            icon: Icons.workspaces_outline,
            title: 'No work types available',
            subtitle: 'Ask your admin to set up work types.',
          )
        else ...[
          ...pinnedWorks.map((w) => _workDefRow(vm, w)),
          if (widget.showPinActions && otherWorks.isNotEmpty)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  'Show more works (${otherWorks.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textSecondary,
                  ),
                ),
                children: otherWorks.map((w) => _workDefRow(vm, w)).toList(),
              ),
            ),
          if (!widget.showPinActions)
            ...workDefinitions.map((w) => _workDefRow(vm, w)),
        ],
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
            child: Row(
              children: [
                Expanded(
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
                if (widget.showPinActions &&
                    widget.isPinned != null &&
                    widget.onTogglePin != null)
                  InkWell(
                    onTap: () => widget.onTogglePin!(work.workDefId),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        widget.isPinned!(work.workDefId)
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 18,
                        color: widget.isPinned!(work.workDefId)
                            ? LoginColors.accent
                            : LoginColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child:
                existing != null && existing.status.toUpperCase() == 'APPROVED'
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
    if (!_prefilledExistingWorkDefIds.contains(work.workDefId) &&
        controller.text.isEmpty &&
        existing.quantity != null) {
      final q = existing.quantity!;
      controller.text = q % 1 == 0 ? q.toInt().toString() : q.toString();
      _prefilledExistingWorkDefIds.add(work.workDefId);
    }
    return _workInputField(
      controller: controller,
      hintText: work.unit,
      onChanged: (_) => _onQtyChanged(work),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
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
