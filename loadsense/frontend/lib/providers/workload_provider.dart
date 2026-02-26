import 'package:flutter/foundation.dart';
import '../models/workload_model.dart';
import '../services/workload_service.dart';

class WorkloadProvider extends ChangeNotifier {
  final WorkloadService _service = WorkloadService();

  List<WorkloadEntry> _entries = [];
  List<WorkloadAlert> _alerts = [];
  WorkloadSummary? _summary;
  CalendarStats? _calendarStats;
  bool _isLoading = false;
  String? _error;

  List<WorkloadEntry> get entries => _entries;
  List<WorkloadAlert> get alerts => _alerts;
  WorkloadSummary? get summary => _summary;
  CalendarStats? get calendarStats => _calendarStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> calculate() async {
    try {
      await _service.calculate();
    } catch (_) {}
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 1. Calculate (Safe to fail silently)
      try {
        await calculate();
      } catch (e) {
        debugPrint('Workload Calculate Non-Fatal Error: $e');
      }

      // 2. Fetch all components in parallel, protecting against individual failures
      await Future.wait([
        _service.getAll().then((v) {
          _entries = v;
          return v;
        }).catchError((e) {
          debugPrint('Workload Entries Error: $e');
          return <WorkloadEntry>[];
        }),
        _service.getAlerts().then((v) {
          _alerts = v;
          return v;
        }).catchError((e) {
          debugPrint('Workload Alerts Error: $e');
          return <WorkloadAlert>[];
        }),
        _service.getSummary().then((v) {
          _summary = v;
          return v;
        }).catchError((e) {
          debugPrint('Workload Summary Error: $e');
          _error = 'Failed to load summary: ${e.toString()}';
          return WorkloadSummary(
            totalWeeklyHours: 0,
            totalModules: 0,
            totalDeadlines: 0,
            overallStatus: 'normal',
            averageHours: 0,
          );
        }),
        _service.getCalendarStats().then((v) {
          _calendarStats = v;
          return v;
        }).catchError((e) {
          debugPrint('Workload Calendar Error: $e');
          return CalendarStats(dailyHours: {});
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
