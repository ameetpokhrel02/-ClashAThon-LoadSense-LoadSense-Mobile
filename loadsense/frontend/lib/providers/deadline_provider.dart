import 'package:flutter/foundation.dart';
import '../models/deadline_model.dart';
import '../services/deadline_service.dart';

class DeadlineProvider extends ChangeNotifier {
  final DeadlineService _service = DeadlineService();

  List<Deadline> _deadlines = [];
  bool _isLoading = false;
  String? _error;

  List<Deadline> get deadlines => _deadlines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Deadline> get upcomingDeadlines => _deadlines
      .where((d) => !d.isCompleted)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<Deadline> get overdueDeadlines => _deadlines.where((d) => d.isOverdue).toList();

  List<Deadline> get completedDeadlines => _deadlines.where((d) => d.isCompleted).toList();

  Future<void> fetchDeadlines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _deadlines = await _service.getDeadlines();
      _deadlines.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDeadline(Deadline deadline) async {
    try {
      final created = await _service.createDeadline(deadline);
      _deadlines.add(created);
      _deadlines.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDeadline(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _service.updateDeadline(id, updates);
      final idx = _deadlines.indexWhere((d) => d.id == id);
      if (idx != -1) _deadlines[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDeadline(String id) async {
    try {
      await _service.deleteDeadline(id);
      _deadlines.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
