import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/insight_provider.dart';
import '../../providers/module_provider.dart';
import '../../models/insight_model.dart';
import '../../widgets/app_button.dart';

import '../../widgets/screen_header.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().fetchInsights();
      context.read<ModuleProvider>().fetchModules();
    });
  }

  void _generateAiPlan() {
    final modules = context.read<ModuleProvider>().modules;
    
    context.read<InsightProvider>().generateAiSuggestion({
      'modules': modules.map((m) => m.toJson()).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchInsights(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ScreenHeader(
              title: 'Academic Insights',
              subtitle: 'AI-Powered Analysis',
              showNotification: false,
              stats: summary != null ? [
                HeaderStatCard(
                  label: 'Risk Level',
                  value: summary.riskPattern.keys.firstWhere((k) => summary.riskPattern[k]! > 0, orElse: () => 'Normal').toUpperCase(),
                  icon: Icons.analytics_rounded,
                ),
                HeaderStatCard(
                  label: 'Total Tasks',
                  value: '${summary.deadlineTypeDistribution.values.fold(0, (a, b) => a + b)}',
                  icon: Icons.assignment_turned_in_rounded,
                ),
              ] : null,
            ),
            if (provider.isLoading)
              const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _buildBody(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(InsightProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          
          if (provider.summary != null) ...[
            _buildWeeklyWorkloadChart(provider.summary!.weeklyTrend),
            const SizedBox(height: 32),
            _buildDistributionSection(provider.summary!),
            const SizedBox(height: 32),
            _buildSmartInsightsSection(provider.summary!.smartInsights),
            const SizedBox(height: 32),
          ],

          // AI Suggestion Box
          _buildAiSuggestionBox(provider),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWeeklyWorkloadChart(List<WeeklyTrend> trend) {
    if (trend.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Workload Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 24, right: 24, left: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Only show titles for whole numbers (index values) to avoid duplicate labels
                      if (value != value.toInt()) return const SizedBox.shrink();
                      
                      final int index = value.toInt();
                      if (index < 0 || index >= trend.length) return const SizedBox.shrink();
                      
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM d').format(trend[index].weekStart),
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.loadScore)).toList(),
                  isCurved: true,
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionSection(InsightSummary summary) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPieCard(
                'Risk Profile',
                summary.riskPattern.entries
                    .where((e) => e.value > 0)
                    .map((e) => PieChartSectionData(
                          value: e.value.toDouble(),
                          title: '${e.value}',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          radius: 50,
                          color: _getRiskColor(e.key),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieCard(
                'Task Types',
                summary.deadlineTypeDistribution.entries
                    .where((e) => e.value > 0)
                    .map((e) => PieChartSectionData(
                          value: e.value.toDouble(),
                          title: '${e.value}',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          radius: 50,
                          color: _getTypeColor(e.key),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLegend(summary),
      ],
    );
  }

  Widget _buildPieCard(String title, List<PieChartSectionData> sections) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: sections.isEmpty
                ? const Center(child: Text('No data', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                : PieChart(
                    PieChartData(sections: sections, centerSpaceRadius: 25)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(InsightSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legend',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              ...summary.riskPattern.keys.where((k) => summary.riskPattern[k]! > 0).map((k) => _legendItem(k, _getRiskColor(k))),
              ...summary.deadlineTypeDistribution.keys
                  .where((k) => summary.deadlineTypeDistribution[k]! > 0)
                  .map((k) => _legendItem(k, _getTypeColor(k))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label[0].toUpperCase() + label.substring(1),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSmartInsightsSection(List<SmartInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Smart Analysis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (insights.isEmpty)
          const Text('Analyzing your workload... check back soon!')
        else
          ...insights.map((insight) => _buildSmartInsightCard(insight)),
      ],
    );
  }

  Widget _buildSmartInsightCard(SmartInsight insight) {
    final color = _getInsightColor(insight.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(_getInsightIcon(insight.type), color: color, size: 20),
        ),
        title: Text(insight.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(insight.message,
            style: const TextStyle(fontSize: 13, height: 1.4)),
      ),
    );
  }

  Widget _buildAiSuggestionBox(InsightProvider provider) {
    final plan = provider.studyPlan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.accentGradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text('Optimized Study Plan',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (plan != null) ...[
            // Workload Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        plan.workloadSummary['riskLevel'] == 'critical' 
                            ? Icons.report_problem_rounded 
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Risk Level: ${plan.workloadSummary['riskLevel']?.toString().toUpperCase()}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.workloadSummary['message'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Suggestions Section
            const Text('AI Suggestions:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 8),
            ...plan.suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Expanded(
                          child: Text(s,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14))),
                    ],
                  ),
                )),
            const Divider(color: Colors.white24, height: 32),
            // Priority Tasks
            const Text('Priority Focus:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            ...plan.priorityTasks.take(3).map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: t['priority'] == 'high' ? AppColors.error : AppColors.warning,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${t['type']} • Due ${t['formattedDueDate']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const Divider(color: Colors.white24, height: 32),

            // Weekly Schedule Section
            const Text('Day-by-Day Schedule:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            ...plan.weeklyPlan.map((day) => _buildDayPlan(day)),
          ] else
            const Text(
              'Let our AI analyze your modules and deadlines to create an optimized study schedule for you.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          const SizedBox(height: 24),
          AppButton(
            key: const Key('generate_ai_plan_btn'),
            label: plan == null ? 'Generate AI Plan' : 'Regenerate Plan',
            color: AppColors.primary,
            textColor: Colors.white,
            isLoading: provider.aiLoading,
            onPressed: _generateAiPlan,
          ),
        ],
      ),
    );
  }

  Widget _buildDayPlan(DailyPlan day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${day.day}, ${day.date}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${day.totalHours}h',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          if (day.tasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...day.tasks.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${t.task} (${t.hours}h) - ${t.course}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'moderate':
        return Colors.orange;
      case 'low':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('assignment')) return AppColors.primary;
    if (typeLower.contains('quiz')) return AppColors.secondary;
    if (typeLower.contains('exam') || typeLower.contains('final')) return AppColors.error;
    if (typeLower.contains('project')) return Colors.teal;
    if (typeLower.contains('viva')) return AppColors.warning;
    if (typeLower.contains('midterm')) return Colors.orange;
    if (typeLower.contains('reading')) return Colors.purple;
    
    return Colors.grey;
  }

  Color _getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return Icons.warning_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'info':
        return Icons.info_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }
}
