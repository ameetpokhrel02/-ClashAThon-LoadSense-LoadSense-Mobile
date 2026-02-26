import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import '../../models/deadline_model.dart';
import '../../widgets/screen_header.dart';

class DeadlinesScreen extends StatefulWidget {
  final bool showBackButton;
  const DeadlinesScreen({super.key, this.showBackButton = false});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeadlineProvider>().fetchDeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeadlineProvider>();
    final overdue = provider.overdueDeadlines;
    final totalHours = provider.deadlines.fold(0, (sum, d) => sum + d.estimatedHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchDeadlines(),
        child: _buildBody(provider, overdue, totalHours),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_deadline_fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addDeadline),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(DeadlineProvider provider, List<Deadline> overdue, int totalHours) {
    if (provider.isLoading && provider.deadlines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerList(),
      );
    }

    if (provider.error != null && provider.deadlines.isEmpty) {
      return ErrorState(message: provider.error!, onRetry: () => provider.fetchDeadlines());
    }

    if (provider.deadlines.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: 'No Deadlines Yet',
        subtitle: 'Add your assignments or tasks to keep track of them.',
        actionLabel: 'Add First Deadline',
        onAction: () => Navigator.pushNamed(context, AppRoutes.addDeadline),
      );
    }

    final upcoming = provider.upcomingDeadlines;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ScreenHeader(
          title: 'Deadlines',
          subtitle: 'Track your tasks',
          showNotification: false,
          showBackButton: widget.showBackButton,
          action: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addDeadline),
          ),
          stats: [
            HeaderStatCard(
              label: 'Total',
              value: '${provider.deadlines.length}',
              icon: Icons.assignment_outlined,
            ),
            HeaderStatCard(
              label: 'Overdue',
              value: '${overdue.length}',
              icon: Icons.alarm_on_outlined,
            ),
            HeaderStatCard(
              label: 'Pending',
              value: '${provider.upcomingDeadlines.length}',
              icon: Icons.calendar_today_outlined,
            ),
            HeaderStatCard(
              label: 'Completed',
              value: '${provider.completedDeadlines.length}',
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
        const SizedBox(height: 32),
        if (overdue.isNotEmpty) ...[
          _buildSectionHeader('Overdue', AppColors.error),
          ...overdue.map((d) => _buildDeadlineTile(d)),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader('Upcoming Deadlines', AppColors.primary),
        ...upcoming.map((d) => _buildDeadlineTile(d)),
        if (provider.completedDeadlines.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Completed', AppColors.success),
          ...provider.completedDeadlines.map((d) => _buildDeadlineTile(d)),
        ],
            ],
          ),
        ),
        const SizedBox(height: 80), // Fab space
      ],
    );
  }


  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDeadlineTile(Deadline deadline) {
    final isOverdue = deadline.isOverdue;
    final priorityColor = _getPriorityColor(deadline.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context, 
          AppRoutes.deadlineDetail, 
          arguments: deadline
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${deadline.type.toUpperCase()} • ${deadline.priority.toUpperCase()}',
                      style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(deadline.dueDate),
                    style: TextStyle(
                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                deadline.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    deadline.moduleName ?? 'General',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${deadline.estimatedHours}h',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusChip(deadline.isCompleted ? 'completed' : 'pending'),
                  const Spacer(),
                  if (!deadline.isCompleted)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.textDisabled),
                      onPressed: () => _markCompleted(deadline),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _deleteDeadline(deadline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.primary;
    if (status == 'completed') color = AppColors.success;
    if (status == 'pending') color = AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
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

  void _markCompleted(Deadline deadline) {
    context.read<DeadlineProvider>().updateDeadline(deadline.id, {'is_completed': true});
  }

  void _deleteDeadline(Deadline deadline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deadline'),
        content: const Text('Are you sure you want to delete this deadline?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DeadlineProvider>().deleteDeadline(deadline.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
