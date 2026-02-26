import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/module_model.dart';
import '../../providers/module_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_model.dart';
import '../../widgets/custom_snackbar.dart';

class ModuleDetailScreen extends StatefulWidget {
  const ModuleDetailScreen({super.key});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final moduleArg = ModalRoute.of(context)!.settings.arguments as Module;
    final moduleProvider = context.watch<ModuleProvider>();
    
    // Find the latest module data from the provider
    final module = moduleProvider.modules.firstWhere(
      (m) => m.id == moduleArg.id, 
      orElse: () => moduleArg,
    );

    final deadlineProvider = context.watch<DeadlineProvider>();
    final moduleDeadlines = deadlineProvider.deadlines.where((d) => d.moduleId == module.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context, 
              AppRoutes.editModule, 
              arguments: module
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, module),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(module),
            const SizedBox(height: 32),
            Text('Connected Deadlines', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (moduleDeadlines.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No deadlines for this module.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...moduleDeadlines.map((d) => _buildDeadlineItem(d)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Module module) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(Icons.credit_card, 'Credits', '${module.creditHours}'),
              _buildVerticalDivider(),
              _buildDetailItem(Icons.timer, 'Weekly', '${module.weeklyHours}h'),
              _buildVerticalDivider(),
              _buildDetailItem(Icons.trending_up, 'Level', module.difficulty),
            ],
          ),
          if (module.description != null && module.description!.isNotEmpty) ...[
            const Divider(height: 48),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(module.description!, style: const TextStyle(fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _buildDeadlineItem(Deadline deadline) {
    final status = deadline.isCompleted ? 'COMPLETED' : 'PENDING';
    final statusColor = deadline.isCompleted ? AppColors.success : AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(deadline.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Module module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text('Are you sure you want to delete ${module.title}? All connected deadlines will remain but lose their module association.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // setState(() => _isDeleting = true);
              final success = await context.read<ModuleProvider>().deleteModule(module.id);
              if (success && context.mounted) {
                CustomSnackBar.show(context, 'Module deleted');
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
