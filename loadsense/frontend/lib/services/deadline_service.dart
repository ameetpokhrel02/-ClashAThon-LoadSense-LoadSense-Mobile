import '../core/constants.dart';
import '../models/deadline_model.dart';
import 'api_service.dart';

class DeadlineService {
  Future<List<Deadline>> getDeadlines() async {
    final data = await ApiService.get(ApiConstants.deadlines);
    final List list = _extractList(data, 'deadlines');
    return list.map((e) => Deadline.fromJson(e)).toList();
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

  Future<Deadline> createDeadline(Deadline deadline) async {
    final data = await ApiService.post(ApiConstants.deadlines, deadline.toJson());
    return Deadline.fromJson(data['deadline'] ?? data);
  }

  Future<Deadline> updateDeadline(String id, Map<String, dynamic> updates) async {
    final data = await ApiService.patch('${ApiConstants.deadlines}/$id', updates);
    return Deadline.fromJson(data['deadline'] ?? data);
  }

  Future<void> deleteDeadline(String id) async {
    await ApiService.delete('${ApiConstants.deadlines}/$id');
  }
}
