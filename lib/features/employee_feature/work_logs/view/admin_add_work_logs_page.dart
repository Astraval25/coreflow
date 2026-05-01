import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/work_logs/view_model/admin_work_logs_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminAddWorkLogsPage extends StatefulWidget {
  final Employee employee;
  final String logDate;
  final List<WorkDefinitionData> workDefinitions;
  final List<WorkLogData> existingLogs;
  final AdminWorkLogsViewModel viewModel;

  const AdminAddWorkLogsPage({
    super.key,
    required this.employee,
    required this.logDate,
    required this.workDefinitions,
    required this.existingLogs,
    required this.viewModel,
  });

  @override
  State<AdminAddWorkLogsPage> createState() => _AdminAddWorkLogsPageState();
}

class _AdminAddWorkLogsPageState extends State<AdminAddWorkLogsPage> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};
  bool _autoApprove = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final work in widget.workDefinitions) {
      final existing = _existingLogFor(work.workDefId);
      final quantity = existing?.quantity;
      _qtyControllers[work.workDefId] = TextEditingController(
        text: quantity == null
            ? ''
            : quantity % 1 == 0
            ? quantity.toInt().toString()
            : quantity.toString(),
      );
      _remarksControllers[work.workDefId] = TextEditingController(
        text: existing?.employeeRemarks ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  WorkLogData? _existingLogFor(int workDefId) {
    for (final log in widget.existingLogs) {
      if (log.employeeId == widget.employee.employeeId &&
          log.workDefId == workDefId &&
          log.logDate == widget.logDate) {
        return log;
      }
    }
    return null;
  }

  int get _newEntryCount {
    var count = 0;
    for (final work in widget.workDefinitions) {
      if (_existingLogFor(work.workDefId) != null) continue;
      final quantity = double.tryParse(
        _qtyControllers[work.workDefId]?.text.trim() ?? '',
      );
      if (quantity != null && quantity > 0) count++;
    }
    return count;
  }

  double get _estimatedAmount {
    var total = 0.0;
    for (final work in widget.workDefinitions) {
      if (_existingLogFor(work.workDefId) != null) continue;
      final quantity = double.tryParse(
        _qtyControllers[work.workDefId]?.text.trim() ?? '',
      );
      if (quantity != null && quantity > 0) {
        total += quantity * (work.ratePerUnit ?? 0);
      }
    }
    return total;
  }

  Future<void> _save() async {
    final requests = <CreateWorkLogRequest>[];
    final invalidWorkNames = <String>[];

    for (final work in widget.workDefinitions) {
      if (_existingLogFor(work.workDefId) != null) continue;

      final text = _qtyControllers[work.workDefId]?.text.trim() ?? '';
      if (text.isEmpty) continue;

      final quantity = double.tryParse(text);
      if (quantity == null || quantity <= 0) {
        invalidWorkNames.add(work.workName);
        continue;
      }

      final remarks = _remarksControllers[work.workDefId]?.text.trim() ?? '';
      requests.add(
        CreateWorkLogRequest(
          employeeId: widget.employee.employeeId,
          workDefId: work.workDefId,
          logDate: widget.logDate,
          quantity: quantity,
          employeeRemarks: remarks.isEmpty ? null : remarks,
        ),
      );
    }

    if (invalidWorkNames.isNotEmpty) {
      _showMessage(
        'Enter a valid quantity for ${invalidWorkNames.join(', ')}',
        isError: true,
      );
      return;
    }

    if (requests.isEmpty) {
      _showMessage('Enter at least one work quantity', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final ok = await widget.viewModel.createWorkLogsBatch(
      requests,
      autoApprove: _autoApprove,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context, true);
      return;
    }

    _showMessage(
      widget.viewModel.error ?? 'Failed to save work logs',
      isError: true,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Add Work Logs',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        backgroundColor: LoginColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(_isSaving ? 'Saving' : 'Save'),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _headerCard(),
          const SizedBox(height: 12),
          _autoApproveCard(),
          const SizedBox(height: 12),
          ...widget.workDefinitions.map(_workDefinitionRow),
          const SizedBox(height: 80), 
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false, 
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            border: Border(top: BorderSide(color: LoginColors.borderLight)),
          ),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_alt_rounded),
            label: Text(_isSaving ? 'Saving Work Logs...' : 'Save Work Logs'),
            style: FilledButton.styleFrom(
              backgroundColor: LoginColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: LoginColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.badge_rounded, color: LoginColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.employee.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.employee.employeeCode} - ${widget.logDate}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryPill('New logs', '$_newEntryCount'),
              const SizedBox(width: 8),
              _summaryPill('Est. amount', _estimatedAmount.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: LoginColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LoginColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _autoApproveCard() {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: SwitchListTile(
        value: _autoApprove,
        onChanged: _isSaving
            ? null
            : (value) => setState(() => _autoApprove = value),
        title: Text(
          'Auto accept after save',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Created logs will be approved immediately.',
          style: TextStyle(fontSize: 12, color: LoginColors.textSecondary),
        ),
        activeThumbColor: LoginColors.primary,
        secondary: Icon(
          Icons.verified_rounded,
          color: _autoApprove ? LoginColors.primary : LoginColors.textTertiary,
        ),
      ),
    );
  }

  Widget _workDefinitionRow(WorkDefinitionData work) {
    final existing = _existingLogFor(work.workDefId);
    final isLocked = existing != null;
    final qtyController = _qtyControllers[work.workDefId]!;
    final remarksController = _remarksControllers[work.workDefId]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? _statusColor(existing.status).withValues(alpha: 0.3)
              : LoginColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work.workName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${work.workCode} - Rate ${work.ratePerUnit ?? 0}/${work.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (existing != null) _statusChip(existing.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  enabled: !isLocked && !_isSaving,
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: LoginColors.textPrimary,
                  ),
                  decoration: _inputDecoration('Qty', work.unit),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  enabled: !isLocked && !_isSaving,
                  controller: remarksController,
                  decoration: _inputDecoration('Remarks', 'Optional'),
                ),
              ),
            ],
          ),
          if (existing != null &&
              (existing.employeeRemarks ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              existing.employeeRemarks!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: LoginColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: LoginColors.fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        borderSide: BorderSide(color: LoginColors.primary, width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status.toUpperCase()) {
      'APPROVED' => LoginColors.success,
      'REJECTED' => LoginColors.error,
      _ => LoginColors.primary,
    };
  }
}
