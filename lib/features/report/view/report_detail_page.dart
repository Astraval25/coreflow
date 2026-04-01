import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/report/analytics_view_model/analytics_view_model.dart';
import 'package:coreflow/features/report/view/report_result_page.dart';

class ReportDetailPage extends StatelessWidget {
  final ReportType reportType;
  final int companyId;

  const ReportDetailPage({
    super.key,
    required this.reportType,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel(companyId: companyId),
      child: _ReportDetailView(reportType: reportType),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  final ReportType reportType;
  const _ReportDetailView({required this.reportType});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: LoginColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          reportType.label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _SectionLabel(label: 'Date Range'),
          _DateRangeDropdown(vm: vm),
          const SizedBox(height: 16),
          _SectionLabel(label: 'From'),
          _DatePickerTile(
            date: vm.startDate,
            onTap: () => _pickDate(context, vm, isStart: true),
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'To'),
          _DatePickerTile(
            date: vm.endDate,
            onTap: () => _pickDate(context, vm, isStart: false),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : () => _run(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Run Report',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    AnalyticsViewModel vm, {
    required bool isStart,
  }) async {
    final initial = isStart ? vm.startDate : vm.endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: LoginColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (isStart) {
      vm.setCustomDates(picked, vm.endDate);
    } else {
      vm.setCustomDates(vm.startDate, picked);
    }
  }

  Future<void> _run(BuildContext context, AnalyticsViewModel vm) async {
    await vm.runReport(reportType);
    if (!context.mounted) return;
    if (vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
        content: Text(vm.error!),
        backgroundColor: LoginColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ReportResultPage(reportType: reportType),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: LoginColors.textSecondary,
                fontWeight: FontWeight.w500)),
      );
}

class _DateRangeDropdown extends StatelessWidget {
  final AnalyticsViewModel vm;
  const _DateRangeDropdown({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: LoginColors.border))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsDateRange>(
          value: vm.selectedRange,
          isExpanded: true,
          dropdownColor: LoginColors.surface,
          style: TextStyle(fontSize: 16, color: LoginColors.textPrimary),
          onChanged: (v) { if (v != null) vm.setDateRange(v); },
          items: AnalyticsDateRange.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
              .toList(),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerTile({required this.date, required this.onTap});

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(color: LoginColors.border))),
        child: Text(_format(date),
            style: TextStyle(fontSize: 16, color: LoginColors.textPrimary)),
      ),
    );
  }
}
