import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/deadline_model.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/app_button.dart';

class DeadlineDetailScreen extends StatelessWidget {
  const DeadlineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deadline = ModalRoute.of(context)!.settings.arguments as Deadline;
    final provider = context.watch<DeadlineProvider>();
    
    // Find the latest version of this deadline from the provider
    final currentDeadline = provider.deadlines.firstWhere(
      (d) => d.id == deadline.id,
      orElse: () => deadline,
    );

    final isOverdue = currentDeadline.isOverdue;
    final statusColor = currentDeadline.isCompleted ? const Color.fromARGB(255, 34, 197, 72) : (isOverdue ? AppColors.error : AppColors.warning);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadline Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context, 
              AppRoutes.editDeadline, 
              arguments: currentDeadline
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, currentDeadline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentDeadline, statusColor),
            const SizedBox(height: 32),
            _buildInfoGrid(currentDeadline),
            const SizedBox(height: 32),
            if (currentDeadline.notes != null && currentDeadline.notes!.isNotEmpty) ...[
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  currentDeadline.notes!,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
            ],
            AppButton(
              label: currentDeadline.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
              onPressed: () => _toggleCompletion(context, currentDeadline),
              color: currentDeadline.isCompleted ? AppColors.textSecondary : AppColors.success,
              isLoading: provider.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Deadline deadline, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            deadline.isCompleted ? 'COMPLETED' : (deadline.isOverdue ? 'OVERDUE' : 'PENDING'),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          deadline.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          deadline.moduleName ?? 'General',
          style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(Deadline deadline) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildInfoTile(Icons.calendar_today, 'Due Date', DateFormat('MMM d, y').format(deadline.dueDate)),
        _buildInfoTile(Icons.timer_outlined, 'Estimate', '${deadline.estimatedHours} Hours'),
        _buildInfoTile(Icons.flag_outlined, 'Priority', deadline.priority.toUpperCase()),
        _buildInfoTile(Icons.category_outlined, 'Type', deadline.type.toUpperCase()),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleCompletion(BuildContext context, Deadline deadline) {
    context.read<DeadlineProvider>().updateDeadline(deadline.id, {'is_completed': !deadline.isCompleted});
  }

  void _showDeleteDialog(BuildContext context, Deadline deadline) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Deadline'),
        content: const Text('Are you sure you want to delete this deadline?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context.read<DeadlineProvider>().deleteDeadline(deadline.id);
              if (success && context.mounted) {
                CustomSnackBar.show(context, 'Deadline deleted');
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
