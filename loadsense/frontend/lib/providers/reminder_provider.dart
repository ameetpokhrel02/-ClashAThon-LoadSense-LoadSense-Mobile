import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _service = ReminderService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _reminders = await _service.getReminders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      // Optimistic UI update
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final r = _reminders[index];
        _reminders[index] = Reminder(
          id: r.id,
          title: r.title,
          message: r.message,
          reminderTime: r.reminderTime,
          isRead: true,
        );
        notifyListeners();
      }
      await _service.markAsRead(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
