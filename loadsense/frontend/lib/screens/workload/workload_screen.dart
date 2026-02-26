import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../models/workload_model.dart';
import '../../providers/workload_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';

import '../../widgets/screen_header.dart';

class WorkloadScreen extends StatefulWidget {
  const WorkloadScreen({super.key});

  @override
  State<WorkloadScreen> createState() => _WorkloadScreenState();
}

class _WorkloadScreenState extends State<WorkloadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkloadProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkloadProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAll(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ScreenHeader(
              title: 'Workload Analysis',
              subtitle: 'Performance Insights',
              showNotification: false,
            ),
            _buildBody(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WorkloadProvider provider) {
    if (provider.isLoading && provider.entries.isEmpty) {
      return const Padding(padding: EdgeInsets.all(20), child: ShimmerList());
    }

    if (provider.error != null && provider.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Analysis Unavailable',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => provider.fetchAll(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Make sure you have active modules and upcoming deadlines for analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (provider.entries.isEmpty && !provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: EmptyState(
          title: 'Not Enough Data',
          subtitle: 'Add some modules and deadlines to see your workload analysis.',
          icon: Icons.analytics_outlined,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.summary != null) ..._buildQuickStats(provider.summary!),
          _buildWorkloadGauge(provider.summary),
          const SizedBox(height: 32),
          Text('Weekly Hours Distribution', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildBarChart(provider.entries),
          const SizedBox(height: 32),
          Text('Recent Alerts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (provider.alerts.isEmpty)
            const Text('No workload alerts for this period.', style: TextStyle(color: AppColors.textSecondary))
          else
            ...provider.alerts.map((a) => _buildAlertTile(a)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildQuickStats(WorkloadSummary summary) {
    final color = _getStatusColor(summary.overallStatus);
    return [
      Row(
        children: [
          Expanded(
            child: _buildStatChip(
              icon: Icons.timer_outlined,
              label: 'Weekly Load',
              value: '${summary.totalWeeklyHours.toStringAsFixed(1)}h',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatChip(
              icon: Icons.speed_rounded,
              label: 'Status',
              value: summary.overallStatus,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadGauge(WorkloadSummary? summary) {
    if (summary == null) return const SizedBox();
    final value = summary.totalWeeklyHours;
    final status = summary.overallStatus;
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('Overall Weekly Load', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140.0,
                height: 140.0,
                child: CircularProgressIndicator(
                  value: (value / 60.0).clamp(0.0, 1.0),
                  strokeWidth: 12.0,
                  backgroundColor: AppColors.border,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text('${value.toStringAsFixed(1)}h', style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat('Modules', '${summary.totalModules}'),
              _buildSimpleStat('Deadlines', '${summary.totalDeadlines}'),
              _buildSimpleStat('Daily Avg', '${summary.averageHours.toStringAsFixed(1)}h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.0)),
      ],
    );
  }

  Widget _buildBarChart(List<WorkloadEntry> entries) {
    if (entries.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No data available')));

    // Compute the highest value in the data, then add 20% headroom so bars
    // never clip at the top. Floor at 60 so small data still looks proportional.
    final double maxData = entries.map((e) => e.totalHours).reduce((a, b) => a > b ? a : b);
    final double dynamicMaxY = (maxData * 1.2).clamp(60.0, double.infinity);

    return Container(
      height: 240.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: dynamicMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)}h',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (val, meta) {
                  if (val != val.toInt()) return const SizedBox.shrink();
                  
                  final int index = val.toInt();
                  if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                  
                  // Use "Wk N" labels for clean chart display (raw date strings are too long/ugly)
                  final String label = 'Wk ${index + 1}';

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 10.0, color: AppColors.textSecondary),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50.0, // Increased reserved size
                interval: 20.0, // Explicit interval
                getTitlesWidget: (val, meta) {
                  if (val == 0) return const SizedBox.shrink(); // Skip 0 label
                  if (val == meta.max) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toInt().toString(),
                      style: const TextStyle(fontSize: 10.0, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalHours,
                  color: _getStatusColor(e.value.status),
                  width: 16.0,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlertTile(WorkloadAlert alert) {
    final color = _getStatusColor(alert.level);
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: color),
        title: Text(alert.message, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14.0)),
        subtitle: Text('Total expected: ${alert.totalHours} hours', style: const TextStyle(fontSize: 12.0)),
      ),
    );
  }

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical': return AppColors.error;
      case 'high': return AppColors.warning;
      case 'normal': return AppColors.success;
      default: return AppColors.primary;
    }
  }
}
