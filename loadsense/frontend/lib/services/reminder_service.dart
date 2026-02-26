import '../core/constants.dart';
import '../models/reminder_model.dart';
import 'api_service.dart';

class ReminderService {
  Future<List<Reminder>> getReminders() async {
    final data = await ApiService.get(ApiConstants.reminders);
    final List list = data['reminders'] ?? data['data'] ?? (data is List ? data : []);
    return list.map((e) => Reminder.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    await ApiService.put('${ApiConstants.reminders}/$id/read', {});
  }
}
