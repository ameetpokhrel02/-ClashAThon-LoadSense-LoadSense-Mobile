import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/module_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class EditDeadlineScreen extends StatefulWidget {
  final Deadline deadline;
  const EditDeadlineScreen({super.key, required this.deadline});

  @override
  State<EditDeadlineScreen> createState() => _EditDeadlineScreenState();
}

class _EditDeadlineScreenState extends State<EditDeadlineScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _hoursController;
  final _formKey = GlobalKey<FormState>();

  String? _selectedModuleId;
  String? _selectedModuleName;
  late DateTime _selectedDate;
  late String _priority;
  late String _type;

  final List<String> _deadlineTypes = [
    'Assignment',
    'Project',
    'Quiz',
    'Viva',
    'Midterm',
    'Final',
    'Exam',
    'Reading',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.deadline.title);
    _notesController = TextEditingController(text: widget.deadline.notes ?? '');
    _hoursController = TextEditingController(text: widget.deadline.estimatedHours.toString());
    _selectedDate = widget.deadline.dueDate;
    _priority = widget.deadline.priority;
    _type = widget.deadline.type.substring(0, 1).toUpperCase() + widget.deadline.type.substring(1);
    _selectedModuleId = widget.deadline.moduleId;
    _selectedModuleName = widget.deadline.moduleName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedModuleId == null) {
        CustomSnackBar.show(context, 'Please select a module', isError: true);
        return;
      }

      final updates = {
        'title': _titleController.text.trim(),
        'notes': _notesController.text.trim(),
        'dueDate': _selectedDate.toIso8601String(),
        'priority': _priority.toLowerCase(),
        'type': _type.toLowerCase(),
        'estimatedHours': int.tryParse(_hoursController.text) ?? 1,
        'course': _selectedModuleName ?? 'General',
      };

      final success = await context.read<DeadlineProvider>().updateDeadline(widget.deadline.id, updates);
      if (success && mounted) {
        CustomSnackBar.show(context, 'Deadline updated successfully');
        Navigator.pop(context);
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<DeadlineProvider>().error ?? 'Failed to update deadline', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final deadlineProvider = context.watch<DeadlineProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Deadline')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Deadline Title',
                hint: 'e.g. Final Report Submission',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Details about this task...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deadline Type', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          items: _deadlineTypes
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => _type = v!),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: AppTextField(
                      controller: _hoursController,
                      label: 'Est. Hours',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      validator: (v) => v != null && int.tryParse(v) != null ? null : 'Num',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Module Picker
              const Text('Module / Course', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: moduleProvider.modules.any((m) => m.id == _selectedModuleId) 
                    ? _selectedModuleId 
                    : null,
                items: moduleProvider.modules
                    .map((m) => DropdownMenuItem(value: m.id, child: Text(m.title)))
                    .toList(),
                onChanged: (v) {
                  final module = moduleProvider.modules.firstWhere((m) => m.id == v);
                  setState(() {
                    _selectedModuleId = v;
                    _selectedModuleName = module.title;
                  });
                },
                decoration: InputDecoration(
                  hintText: moduleProvider.isLoading ? 'Loading modules...' : 'Select a module',
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.utc(2020),
                    lastDate: DateTime.utc(2030),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEEE, MMM d, y').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              const Text('Risk / Priority', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: ['Low', 'Medium', 'High'].map((p) {
                  final isSelected = _priority.toLowerCase() == p.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _priority = p);
                      },
                      selectedColor: _getPriorityColor(p).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? _getPriorityColor(p) : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),
              AppButton(
                label: 'Update Deadline',
                onPressed: _save,
                isLoading: deadlineProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }
}
