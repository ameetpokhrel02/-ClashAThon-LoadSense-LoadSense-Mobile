import '../core/constants.dart';
import '../models/dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  Future<void> calculate() async {
    await ApiService.post(ApiConstants.dashboardCalculate, {});
  }

  Future<List<DashboardAlert>> getAlerts() async {
    final data = await ApiService.get(ApiConstants.dashboardAlert);
    final List list = _extractList(data, 'alerts');
    return list.map((e) => DashboardAlert.fromJson(e)).toList();
  }

  List _extractList(dynamic data, String key) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      if (data[key] is List) return data[key];
      if (data['data'] is List) return data['data'];
      if (data['data'] is Map && data['data'][key] is List) return data['data'][key];
    }
    return [];
  }

  Future<DashboardSummary> getSummary() async {
    final data = await ApiService.get(ApiConstants.dashboardSummary);
    final summaryData = data['summary'] ?? (data['data'] is Map ? data['data'] : data);
    
    if (summaryData is! Map<String, dynamic>) {
      return DashboardSummary(upcomingWeeks: [], totalOverloadWeeks: 0);
    }
    
    return DashboardSummary.fromJson(Map<String, dynamic>.from(summaryData));
  }
}
