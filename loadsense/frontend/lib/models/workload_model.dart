class WorkloadEntry {
  final String id;
  final String weekLabel;
  final double totalHours;
  final double level;
  final String status;

  WorkloadEntry({
    required this.id,
    required this.weekLabel,
    required this.totalHours,
    required this.level,
    required this.status,
  });

  factory WorkloadEntry.fromJson(Map<String, dynamic> json) {
    return WorkloadEntry(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      weekLabel: json['week_label'] ?? json['weekLabel'] ?? json['week'] ?? _getFallbackLabel(json),
      totalHours: _toDouble(json['load_score'] ?? json['totalHours'] ?? json['total_hours']),
      level: _toDouble(json['level'] ?? json['load_score'] ?? 0),
      status: (json['risk_level'] ?? json['status'] ?? 'normal').toString(),
    );
  }

  static String _getFallbackLabel(Map<String, dynamic> json) {
    if (json['week_start'] != null) {
      try {
        final date = DateTime.parse(json['week_start']);
        return '${date.day}/${date.month}';
      } catch (_) {}
    }
    return 'Week';
  }
}

class WorkloadAlert {
  final String message;
  final String level;
  final double totalHours;

  WorkloadAlert({required this.message, required this.level, required this.totalHours});

  factory WorkloadAlert.fromJson(Map<String, dynamic> json) {
    return WorkloadAlert(
      message: json['message']?.toString() ?? '',
      level: (json['level'] ?? json['risk_level'] ?? 'normal').toString(),
      totalHours: _toDouble(json['totalHours'] ?? json['total_hours'] ?? json['load_score']),
    );
  }
}

class WorkloadSummary {
  final double totalWeeklyHours;
  final int totalModules;
  final int totalDeadlines;
  final String overallStatus;
  final double averageHours;

  WorkloadSummary({
    required this.totalWeeklyHours,
    required this.totalModules,
    required this.totalDeadlines,
    required this.overallStatus,
    required this.averageHours,
  });

  factory WorkloadSummary.fromJson(Map<String, dynamic> json) {
    // Backend returns current_week as a sub-object
    final currentWeek = json['current_week'] ?? json;
    
    return WorkloadSummary(
      totalWeeklyHours: _toDouble(currentWeek['weekly_workload'] ?? currentWeek['totalWeeklyHours'] ?? currentWeek['load_score']),
      totalModules: _toInt(json['total_modules'] ?? json['totalModules']),
      totalDeadlines: _toInt(json['total_deadlines'] ?? json['totalDeadlines'] ?? currentWeek['deadline_count']),
      overallStatus: (json['workload_status'] ?? json['overallStatus'] ?? currentWeek['risk_level'] ?? 'normal').toString(),
      averageHours: _toDouble(json['average_hours'] ?? json['averageHours']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class CalendarStats {
  final Map<String, double> dailyHours;

  CalendarStats({required this.dailyHours});

  factory CalendarStats.fromJson(Map<String, dynamic> json) {
    final Map<String, double> hours = {};
    final data = json['dailyHours'] ?? json['daily_hours'] ?? json;
    
    if (data is Map) {
      data.forEach((key, value) {
        // Only parse if value is a number, otherwise skip (e.g. nested lists/maps)
        if (value is num) {
          hours[key.toString()] = value.toDouble();
        } else if (value is String) {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null) {
            hours[key.toString()] = doubleValue;
          }
        }
      });
    }
    return CalendarStats(dailyHours: hours);
  }
}
