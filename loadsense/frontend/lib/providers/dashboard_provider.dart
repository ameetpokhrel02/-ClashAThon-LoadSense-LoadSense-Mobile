import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardSummary? _summary;
  List<DashboardAlert> _alerts = [];
  bool _isLoading = false;
  String? _error;

  DashboardSummary? get summary => _summary;
  List<DashboardAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 1. Recalculate (Safe to fail silently if backend is just slow)
      try {
        await _service.calculate();
      } catch (e) {
        debugPrint('Dashboard Recalculate Non-Fatal Error: $e');
      }

      // 2. Fetch Summary & Alerts in parallel, protecting against individual failures
      await Future.wait([
        _service.getSummary().then((v) {
          _summary = v;
          return v;
        }).catchError((e) {
          debugPrint('Dashboard Summary Error: $e');
          _error = 'Failed to load summary: ${e.toString()}';
          return DashboardSummary(upcomingWeeks: [], totalOverloadWeeks: 0);
        }),
        _service.getAlerts().then((v) {
          _alerts = v;
          return v;
        }).catchError((e) {
          debugPrint('Dashboard Alerts Error: $e');
          // Don't set global _error for alerts, just log it
          return <DashboardAlert>[];
        }),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
