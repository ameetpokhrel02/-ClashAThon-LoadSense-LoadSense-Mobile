import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/module_provider.dart';
import '../../models/module_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class AddModuleScreen extends StatefulWidget {
  const AddModuleScreen({super.key});

  @override
  State<AddModuleScreen> createState() => _AddModuleScreenState();
}

class _AddModuleScreenState extends State<AddModuleScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _hoursController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _difficulty = 'Medium';

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final module = Module(
        id: '',
        title: _nameController.text.trim(),
        moduleCode: _codeController.text.trim().toUpperCase(),
        creditHours: double.parse(_creditsController.text),
        weeklyHours: double.parse(_hoursController.text),
        difficulty: _difficulty,
        description: _descController.text.trim(),
      );

      final success = await context.read<ModuleProvider>().createModule(module);
      if (success && mounted) {
        CustomSnackBar.show(context, 'Module added successfully');
        Navigator.pop(context);
      } else if (mounted) {
        CustomSnackBar.show(context, context.read<ModuleProvider>().error ?? 'Failed to add module', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Module')),
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
                label: 'Save Module',
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
