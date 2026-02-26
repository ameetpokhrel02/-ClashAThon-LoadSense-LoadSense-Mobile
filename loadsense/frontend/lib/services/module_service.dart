import '../core/constants.dart';
import '../models/module_model.dart';
import 'api_service.dart';

class ModuleService {
  Future<List<Module>> getModules() async {
    final data = await ApiService.get(ApiConstants.modules);
    final List list = _extractList(data, 'modules');
    return list.map((e) => Module.fromJson(e)).toList();
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

  Future<Module> getModule(String id) async {
    final data = await ApiService.get('${ApiConstants.modules}/$id');
    return Module.fromJson(data['data'] ?? data['module'] ?? data);
  }

  Future<Module> createModule(Module module) async {
    final data = await ApiService.post(ApiConstants.modules, module.toJson());
    return Module.fromJson(data['data'] ?? data['module'] ?? data);
  }

  Future<Module> updateModule(String id, Map<String, dynamic> updates) async {
    final data = await ApiService.patch('${ApiConstants.modules}/$id', updates);
    return Module.fromJson(data['data'] ?? data['module'] ?? data);
  }

  Future<void> deleteModule(String id) async {
    await ApiService.delete('${ApiConstants.modules}/$id');
  }
}
