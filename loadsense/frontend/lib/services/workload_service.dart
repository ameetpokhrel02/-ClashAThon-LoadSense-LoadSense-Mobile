import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/workload_model.dart';
import 'api_service.dart';

class WorkloadService {
  Future<void> calculate() async {
    await ApiService.post(ApiConstants.workloadCalculate, {});
  }

  Future<List<WorkloadEntry>> getAll() async {
    final data = await ApiService.get(ApiConstants.workload);
    final List list = data['weeks'] ?? data['workload'] ?? data['data'] ?? (data is List ? data : []);
    return list.map((e) => WorkloadEntry.fromJson(e)).toList();
  }

  Future<List<WorkloadAlert>> getAlerts() async {
    final data = await ApiService.get(ApiConstants.workloadAlert);
    final List list = data['alerts'] ?? data['data'] ?? (data is List ? data : []);
    return list.map((e) => WorkloadAlert.fromJson(e)).toList();
  }

  Future<WorkloadSummary> getSummary() async {
    final data = await ApiService.get(ApiConstants.workloadSummary);
    // Support both flattened summary and dashboard-style week-based summary
    final summaryData = data['summary'] ?? (data['current_week'] != null ? data : data['data'] ?? data);
    return WorkloadSummary.fromJson(summaryData);
  }

  Future<CalendarStats> getCalendarStats() async {
    try {
      final data = await ApiService.get(ApiConstants.workloadCalendarStats);
      return CalendarStats.fromJson(data['data'] ?? data['stats'] ?? data);
    } catch (e) {
      debugPrint('Calendar stats error: $e');
      return CalendarStats(dailyHours: {});
    }
  }
}
