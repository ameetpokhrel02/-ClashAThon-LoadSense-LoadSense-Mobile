import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().fetchReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchReminders(),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(ReminderProvider provider) {
    if (provider.isLoading && provider.reminders.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: ShimmerList());
    }

    if (provider.error != null && provider.reminders.isEmpty) {
      return ErrorState(message: provider.error!, onRetry: () => provider.fetchReminders());
    }

    if (provider.reminders.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No Notifications',
        subtitle: 'You are all caught up! No new reminders at the moment.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: provider.reminders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reminder = provider.reminders[index];
        return InkWell(
          onTap: () => provider.markAsRead(reminder.id),
          borderRadius: BorderRadius.circular(16),
          child: _buildReminderTile(reminder),
        );
      },
    );
  }

  Widget _buildReminderTile(reminder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reminder.isRead ? AppColors.surface : AppColors.primaryLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: reminder.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: reminder.isRead ? AppColors.surfaceVariant : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: reminder.isRead ? AppColors.textSecondary : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (reminder.reminderTime != null)
                      Text(
                        DateFormat('h:mm a').format(reminder.reminderTime!),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.message,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
