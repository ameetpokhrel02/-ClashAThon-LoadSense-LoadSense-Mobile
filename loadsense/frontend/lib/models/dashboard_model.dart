class DashboardSummary {
  final WeekSummary? currentWeek;
  final WeekSummary? peakWeek;
  final List<WeekSummary> upcomingWeeks;
  final int totalOverloadWeeks;

  DashboardSummary({
    this.currentWeek,
    this.peakWeek,
    required this.upcomingWeeks,
    required this.totalOverloadWeeks,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      currentWeek: json['current_week'] != null ? WeekSummary.fromJson(json['current_week']) : null,
      peakWeek: json['peak_week'] != null ? WeekSummary.fromJson(json['peak_week']) : null,
      upcomingWeeks: (json['upcoming_weeks'] as List? ?? [])
          .map((e) => WeekSummary.fromJson(e))
          .toList(),
      totalOverloadWeeks: json['total_overload_weeks'] ?? 0,
    );
  }

  // Calculated getters for UI compatibility
  int get currentDeadlines => currentWeek?.deadlineCount ?? 0;
  double get currentLoad => currentWeek?.loadScore ?? 0.0;
}

class WeekSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double loadScore;
  final String riskLevel;
  final int deadlineCount;

  WeekSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.loadScore,
    required this.riskLevel,
    required this.deadlineCount,
  });

  factory WeekSummary.fromJson(Map<String, dynamic> json) {
    return WeekSummary(
      weekStart: _parseDate(json['week_start']),
      weekEnd: _parseDate(json['week_end']),
      loadScore: _toDouble(json['load_score']),
      riskLevel: json['risk_level'] ?? 'low',
      deadlineCount: _toInt(json['deadline_count']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class DashboardAlert {
  final String message;
  final String type;
  final String? action;

  DashboardAlert({required this.message, required this.type, this.action});

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    return DashboardAlert(
      message: json['message']?.toString() ?? '',
      type: (json['type'] ?? json['risk_level'] ?? 'info').toString(),
      action: json['action']?.toString(),
    );
  }
}
