import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/module_provider.dart'; // Added this import
import '../../widgets/shimmer_loader.dart';
import '../../widgets/screen_header.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final bool showBackButton;
  const DashboardScreen({super.key, this.showBackButton = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
      context.read<DeadlineProvider>().fetchDeadlines();
      context.read<ReminderProvider>().fetchReminders();
      context.read<ModuleProvider>().fetchModules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final moduleProvider = context.watch<ModuleProvider>();
    final deadlineProvider = context.watch<DeadlineProvider>();
    final user = auth.user;

    final totalModules = moduleProvider.modules.length;
    final totalDeadlines = deadlineProvider.deadlines.length;
    final completedDeadlines = deadlineProvider.deadlines.where((d) => d.isCompleted).length;
    final completionRate = totalDeadlines == 0 ? 100 : (completedDeadlines / totalDeadlines * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            dashboard.fetchDashboard(),
            deadlineProvider.fetchDeadlines(),
            moduleProvider.fetchModules(),
          ]);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                showBackButton: widget.showBackButton,
                showUserInfo: true,
                user: user,
                stats: [
                  HeaderStatCard(
                    label: 'Active Modules', 
                    value: '$totalModules', 
                    icon: Icons.track_changes_rounded
                  ),
                  HeaderStatCard(
                    label: 'Upcoming Deadlines', 
                    value: '$totalDeadlines', 
                    icon: Icons.calendar_today_outlined
                  ),
                  HeaderStatCard(
                    label: 'Weekly Load', 
                    value: '${dashboard.summary?.currentLoad.toInt() ?? 0}', 
                    icon: Icons.access_time_rounded
                  ),
                  HeaderStatCard(
                    label: 'Completion', 
                    value: '$completionRate%', 
                    icon: Icons.trending_up_rounded
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dashboard.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dashboard.error!,
                                      style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () {
                                    context.read<DashboardProvider>().fetchDashboard();
                                    context.read<ModuleProvider>().fetchModules();
                                    context.read<DeadlineProvider>().fetchDeadlines();
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Alerts', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (dashboard.isLoading)
                      const ShimmerCard(height: 80)
                    else if (dashboard.alerts.isEmpty)
                      _buildDefaultAlert()
                    else
                      ...dashboard.alerts.map((alert) => _buildAlertItem(alert)),

                    const SizedBox(height: 24),
                    _buildAIPlanCard(),

                    const SizedBox(height: 32),
                    _buildUpcomingDeadlinesSection(context),

                    const SizedBox(height: 32),
                    _buildBottomActions(context),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAlert() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F2), // Light orange wash
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Caught Up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    'Your schedule looks clear.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F2), // Pale orange background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Study Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Get personalized recommendations',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.insights),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Generate', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlinesSection(BuildContext context) {
    final deadlineProvider = context.watch<DeadlineProvider>();
    final upcoming = deadlineProvider.upcomingDeadlines.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Deadlines', style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.deadlines),
              child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (deadlineProvider.isLoading && upcoming.isEmpty)
          const ShimmerCard(height: 100)
        else if (upcoming.isEmpty)
          const Center(child: Text('No upcoming deadlines'))
        else
          ...upcoming.map((d) => _buildUpcomingDeadlineCard(d)),
      ],
    );
  }

  Widget _buildUpcomingDeadlineCard(dynamic deadline) {
    // Dummy progress for visualization as per screenshot
    double progress = 0.65;
    if (deadline.title.toLowerCase().contains('problem')) progress = 0.8;
    if (deadline.title.toLowerCase().contains('lab')) progress = 0.4;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deadline.moduleName ?? 'General',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                DateFormat('MMM d').format(deadline.dueDate),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            deadline.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Workload',
            icon: Icons.trending_up,
            onTap: () => Navigator.pushNamed(context, AppRoutes.workload),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: 'Insights',
            icon: Icons.check_circle_outline,
            onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(alert) {
    final color = AppColors.primary;
    final bgColor = const Color(0xFFFFF5F2);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.type == 'critical' ? 'High Workload Alert' : 'Deadline Approaching',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    alert.message,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
