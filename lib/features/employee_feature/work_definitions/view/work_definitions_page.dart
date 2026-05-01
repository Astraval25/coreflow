import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/core/widgets/status_toggle_tabs.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/work_definitions/view_model/work_definitions_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WorkDefinitionsPage extends StatelessWidget {
  final int companyId;

  const WorkDefinitionsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => WorkDefinitionsViewModel(EmployeeRepository()),
        ),
      ],
      child: _WorkDefinitionsView(companyId: companyId),
    );
  }
}

class _WorkDefinitionsView extends StatefulWidget {
  final int companyId;

  const _WorkDefinitionsView({required this.companyId});

  @override
  State<_WorkDefinitionsView> createState() => _WorkDefinitionsViewState();
}

class _WorkDefinitionsViewState extends State<_WorkDefinitionsView> {
  static const List<String> _workUnits = [
    'KG',
    'PC',
    'BOX',
    'LITER',
    'METER',
    'GRAM',
    'HOUR',
  ];

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkDefinitionsViewModel>().loadWorkDefinitions(
        widget.companyId,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _showCreateDialog(WorkDefinitionsViewModel vm) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    final rateController = TextEditingController();
    var selectedUnit = _workUnits.first;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Work Definition'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _textField(
                          controller: nameController,
                          label: 'Work Name',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter work name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: codeController,
                          label: 'Work Code',
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter work code'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: descriptionController,
                          label: 'Description',
                          minLines: 2,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: rateController,
                          label: 'Rate Per Unit',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter rate';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Enter a valid rate';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: _workUnits.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              selectedUnit = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await vm.createWorkDefinition(
                            CreateWorkDefinitionRequest(
                              workName: nameController.text.trim(),
                              workCode: codeController.text
                                  .trim()
                                  .toUpperCase(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              ratePerUnit: double.parse(
                                rateController.text.trim(),
                              ),
                              unit: selectedUnit,
                            ),
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(dialogContext).pop(true);
                          } else if (mounted) {
                            _showMessage(
                              vm.error ?? 'Failed to create work definition',
                              isError: true,
                            );
                          }
                        },
                  child: Text(vm.isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (created == true) {
      _showMessage(vm.message ?? 'Work definition created successfully');
    }
  }

  Future<void> _showEditDialog(
    WorkDefinitionsViewModel vm,
    WorkDefinitionData definition,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: definition.workName);
    final descriptionController = TextEditingController(
      text: definition.description ?? '',
    );
    final rateController = TextEditingController(
      text: definition.ratePerUnit?.toString() ?? '',
    );
    var selectedUnit = _workUnits.contains(definition.unit)
        ? definition.unit
        : _workUnits.first;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Work Definition'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _textField(
                          controller: nameController,
                          label: 'Work Name',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter work name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: definition.workCode,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Work Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: descriptionController,
                          label: 'Description',
                          minLines: 2,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _textField(
                          controller: rateController,
                          label: 'Rate Per Unit',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter rate';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Enter a valid rate';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: _workUnits.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              selectedUnit = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await vm.updateWorkDefinition(
                            definition.workDefId,
                            UpdateWorkDefinitionRequest(
                              workName: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              ratePerUnit: double.parse(
                                rateController.text.trim(),
                              ),
                              unit: selectedUnit,
                            ),
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(dialogContext).pop(true);
                          } else if (mounted) {
                            _showMessage(
                              vm.error ?? 'Failed to update work definition',
                              isError: true,
                            );
                          }
                        },
                  child: Text(vm.isSaving ? 'Saving...' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (updated == true) {
      _showMessage(vm.message ?? 'Work definition updated successfully');
    }
  }

  Future<void> _showRateHistory(
    WorkDefinitionsViewModel vm,
    WorkDefinitionData definition,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${definition.workName} Rate History'),
          content: SizedBox(
            width: 460,
            child: FutureBuilder<List<RateHistoryData>>(
              future: vm.getRateHistory(definition.workDefId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final history = snapshot.data ?? const <RateHistoryData>[];
                if (history.isEmpty) {
                  return const Text('No rate history available');
                }

                return SingleChildScrollView(
                  child: Column(
                    children: history.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LoginColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LoginColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _historyRow(
                              'Rate',
                              '${item.ratePerUnit?.toStringAsFixed(2) ?? '-'} / ${item.unit}',
                            ),
                            _historyRow('From', item.effectiveFrom),
                            _historyRow(
                              'To',
                              item.effectiveTo?.trim().isEmpty ?? true
                                  ? 'Present'
                                  : item.effectiveTo!,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeactivate(
    WorkDefinitionsViewModel vm,
    WorkDefinitionData definition,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate Work Definition'),
          content: Text(
            'Do you want to deactivate ${definition.workName} (${definition.workCode})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: vm.isSaving
                  ? null
                  : () async {
                      final ok = await vm.deactivateWorkDefinition(
                        definition.workDefId,
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        Navigator.of(dialogContext).pop(true);
                      } else if (mounted) {
                        _showMessage(
                          vm.error ?? 'Failed to deactivate work definition',
                          isError: true,
                        );
                      }
                    },
              child: Text(vm.isSaving ? 'Deactivating...' : 'Deactivate'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed == true) {
      _showMessage(vm.message ?? 'Work definition deactivated successfully');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : null,
      ),
    );
  }

  void _goToDashboard() {
    context.go(CfRoutes.dashboard(widget.companyId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkDefinitionsViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToDashboard();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawer: AppDrawer(vm: dashboardVm),
        appBar: SearchableEntityAppBar(
          isSearchOpen: _isSearchOpen,
          onSearchToggle: _toggleSearch,
          searchQuery: _searchQuery,
          searchController: _searchController,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onClearSearch: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
          scaffoldKey: _scaffoldKey,
          title: 'Work Definitions',
          searchHint: 'Search work definitions...',
        ),
        body: Column(
          children: [
            StatusToggleTabs(
              isActiveSelected: vm.showActiveOnly,
              activeLabel: 'Active',
              inactiveLabel: 'Inactive',
              onActiveTap: () {
                if (!vm.showActiveOnly) vm.toggleActiveFilter();
              },
              onInactiveTap: () {
                if (vm.showActiveOnly) vm.toggleActiveFilter();
              },
            ),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: LoginColors.surface,
                color: LoginColors.primary,
                onRefresh: vm.refresh,
                child: _buildBody(vm),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: LoginColors.primary,
          foregroundColor: Colors.white,
          onPressed: vm.isSaving ? null : () => _showCreateDialog(vm),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Work Definition'),
        ),
      ),
    );
  }

  Widget _buildBody(WorkDefinitionsViewModel vm) {
    if (vm.isLoading && !vm.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.hasError && !vm.hasData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                vm.error ?? 'Failed to load work definitions',
                textAlign: TextAlign.center,
                style: TextStyle(color: LoginColors.error),
              ),
            ),
          ),
        ],
      );
    }

    final query = _searchQuery.toLowerCase();
    final filtered = vm.workDefinitions.where((definition) {
      return definition.workName.toLowerCase().contains(query) ||
          definition.workCode.toLowerCase().contains(query) ||
          definition.unit.toLowerCase().contains(query) ||
          (definition.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.workspaces_outline,
            size: 56,
            color: LoginColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No work definitions found'
                : 'No work definitions match "$_searchQuery"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _workDefinitionCard(vm, filtered[index]),
    );
  }

  Widget _workDefinitionCard(
    WorkDefinitionsViewModel vm,
    WorkDefinitionData definition,
  ) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.workName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${definition.workCode}',
                      style: TextStyle(color: LoginColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditDialog(vm, definition);
                      break;
                    case 'history':
                      _showRateHistory(vm, definition);
                      break;
                    case 'deactivate':
                      _confirmDeactivate(vm, definition);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Rate History'),
                      ],
                    ),
                  ),
                  if (definition.isActive)
                    PopupMenuItem(
                      value: 'deactivate',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block_outlined,
                            size: 18,
                            color: LoginColors.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Deactivate',
                            style: TextStyle(color: LoginColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                '${definition.ratePerUnit?.toStringAsFixed(2) ?? '-'} / ${definition.unit}',
                Icons.currency_rupee_rounded,
              ),
              _statusChip(definition.isActive),
            ],
          ),
          if ((definition.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              definition.description!,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LoginColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    final color = isActive ? LoginColors.success : LoginColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _historyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: LoginColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
