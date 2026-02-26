import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/module_provider.dart';
import '../../models/module_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class EditModuleScreen extends StatefulWidget {
  final Module module;
  const EditModuleScreen({super.key, required this.module});

  @override
  State<EditModuleScreen> createState() => _EditModuleScreenState();
}

class _EditModuleScreenState extends State<EditModuleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _creditsController;
  late TextEditingController _hoursController;
  late TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  late String _difficulty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module.title);
    _codeController = TextEditingController(text: widget.module.moduleCode);
    _creditsController = TextEditingController(text: widget.module.creditHours.toString());
    _hoursController = TextEditingController(text: widget.module.weeklyHours.toString());
    _descController = TextEditingController(text: widget.module.description ?? '');
    _difficulty = widget.module.difficulty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _hoursController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final updates = {
        'title': _nameController.text.trim(),
        'moduleCode': _codeController.text.trim().toUpperCase(),
        'credits': double.parse(_creditsController.text).round(),
        'weeklyHours': double.parse(_hoursController.text),
        'difficulty': _difficulty,
        'description': _descController.text.trim(),
        'department': widget.module.department,
        'semester': widget.module.semester,
        'year': widget.module.year,
      };

      final success = await context.read<ModuleProvider>().updateModule(widget.module.id, updates);
      if (success && mounted) {
        CustomSnackBar.show(context, 'Module updated successfully');
        Navigator.pop(context);
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<ModuleProvider>().error ?? 'Failed to update module', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Module')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Module Title',
                hint: 'e.g. Data Structures & Algorithms',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _codeController,
                label: 'Module Code',
                hint: 'e.g. CS301',
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _creditsController,
                      label: 'Credit Hours',
                      keyboardType: TextInputType.number,
                      validator: (v) => v != null && double.tryParse(v) != null ? null : 'Invalid',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _hoursController,
                      label: 'Weekly Study Hours',
                      keyboardType: TextInputType.number,
                      validator: (v) => v != null && double.tryParse(v) != null ? null : 'Invalid',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Difficulty Level', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: ['Easy', 'Medium', 'Hard'].map((d) {
                  final isSelected = _difficulty == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _difficulty = d);
                      },
                      selectedColor: _getDiffColor(d).withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? _getDiffColor(d) : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _descController,
                label: 'Module Description',
                maxLines: 3,
              ),
              const SizedBox(height: 48),
              AppButton(
                label: 'Update Module',
                onPressed: _save,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDiffColor(String d) {
    if (d == 'Easy') return AppColors.success;
    if (d == 'Medium') return AppColors.warning;
    return AppColors.error;
  }
}
