class InsightSummary {
  final List<WeeklyTrend> weeklyTrend;
  final Map<String, int> riskPattern;
  final WeeklyTrend? currentWeek;
  final WeeklyTrend? previousWeek;
  final WeeklyTrend? peakWeek;
  final Map<String, dynamic> weekOverWeek;
  final int totalOverloadWeeks;
  final List<dynamic> alerts;
  final Map<String, int> deadlineTypeDistribution;
  final List<SmartInsight> smartInsights;

  InsightSummary({
    required this.weeklyTrend,
    required this.riskPattern,
    this.currentWeek,
    this.previousWeek,
    this.peakWeek,
    required this.weekOverWeek,
    required this.totalOverloadWeeks,
    required this.alerts,
    required this.deadlineTypeDistribution,
    required this.smartInsights,
  });

  factory InsightSummary.fromJson(Map<String, dynamic> json) {
    return InsightSummary(
      weeklyTrend: (json['weekly_trend'] as List? ?? [])
          .map((e) => WeeklyTrend.fromJson(e))
          .toList(),
      riskPattern: Map<String, int>.from(json['risk_pattern'] ?? {}),
      currentWeek: json['current_week'] != null ? WeeklyTrend.fromJson(json['current_week']) : null,
      previousWeek: json['previous_week'] != null ? WeeklyTrend.fromJson(json['previous_week']) : null,
      peakWeek: json['peak_week'] != null || json['peakWeek'] != null ? WeeklyTrend.fromJson(json['peak_week'] ?? json['peakWeek']) : null,
      weekOverWeek: Map<String, dynamic>.from(json['week_over_week'] ?? {}),
      totalOverloadWeeks: json['total_overload_weeks'] ?? 0,
      alerts: json['alerts'] ?? [],
      deadlineTypeDistribution: Map<String, int>.from(json['deadline_type_distribution'] ?? {}),
      smartInsights: (json['smart_insights'] as List? ?? [])
          .map((e) => SmartInsight.fromJson(e))
          .toList(),
    );
  }
}

class WeeklyTrend {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double loadScore;
  final String riskLevel;
  final int deadlineCount;

  WeeklyTrend({
    required this.weekStart,
    required this.weekEnd,
    required this.loadScore,
    required this.riskLevel,
    required this.deadlineCount,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) {
    return WeeklyTrend(
      weekStart: DateTime.parse(json['week_start']),
      weekEnd: DateTime.parse(json['week_end']),
      loadScore: (json['load_score'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      deadlineCount: json['deadline_count'] ?? 0,
    );
  }
}

class SmartInsight {
  final String type;
  final String title;
  final String message;

  SmartInsight({
    required this.type,
    required this.title,
    required this.message,
  });

  factory SmartInsight.fromJson(Map<String, dynamic> json) {
    return SmartInsight(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// Keeping the old Insight model for compatibility if needed, 
// but we'll primarily use InsightSummary now.
class Insight {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? recommendation;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.recommendation,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? json['content'] ?? json['message'] ?? '',
      type: json['type'] ?? 'general',
      recommendation: json['recommendation'],
    );
  }
}

class StudyPlan {
  final Map<String, dynamic> workloadSummary;
  final List<dynamic> priorityTasks;
  final List<String> suggestions;
  final List<DailyPlan> weeklyPlan;
  final String generatedAt;

  StudyPlan({
    required this.workloadSummary,
    required this.priorityTasks,
    required this.suggestions,
    required this.weeklyPlan,
    required this.generatedAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      workloadSummary: Map<String, dynamic>.from(json['workloadSummary'] ?? {}),
      priorityTasks: List<dynamic>.from(json['priorityTasks'] ?? []),
      suggestions: List<String>.from(json['aiSuggestions'] ?? []),
      weeklyPlan: (json['weeklyPlan'] as List? ?? [])
          .map((e) => DailyPlan.fromJson(e))
          .toList(),
      generatedAt: json['generatedAt'] ?? '',
    );
  }
}

class DailyPlan {
  final String day;
  final String date;
  final List<PlanTask> tasks;
  final double totalHours;

  DailyPlan({
    required this.day,
    required this.date,
    required this.tasks,
    required this.totalHours,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => PlanTask.fromJson(e))
          .toList(),
      totalHours: (json['totalHours'] ?? 0).toDouble(),
    );
  }
}

class PlanTask {
  final String task;
  final double hours;
  final String course;

  PlanTask({
    required this.task,
    required this.hours,
    required this.course,
  });

  factory PlanTask.fromJson(Map<String, dynamic> json) {
    return PlanTask(
      task: json['task'] ?? '',
      hours: (json['hours'] ?? 0).toDouble(),
      course: json['course'] ?? '',
    );
  }
}
