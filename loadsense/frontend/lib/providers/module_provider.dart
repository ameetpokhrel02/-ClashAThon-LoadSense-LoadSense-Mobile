import 'package:flutter/foundation.dart';
import '../models/module_model.dart';
import '../services/module_service.dart';

class ModuleProvider extends ChangeNotifier {
  final ModuleService _service = ModuleService();

  List<Module> _modules = [];
  bool _isLoading = false;
  String? _error;

  List<Module> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _modules = await _service.getModules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createModule(Module module) async {
    try {
      final created = await _service.createModule(module);
      _modules.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateModule(String id, Map<String, dynamic> updates) async {
    try {
      final updatedResponse = await _service.updateModule(id, updates);
      final idx = _modules.indexWhere((m) => m.id == id);
      if (idx != -1) {
        // Merge user updates with server response to protect fields the backend might ignore
        final current = _modules[idx];
        _modules[idx] = Module(
          id: updatedResponse.id,
          title: updatedResponse.title,
          moduleCode: updatedResponse.moduleCode,
          creditHours: updatedResponse.creditHours,
          weeklyHours: updates['weeklyHours'] ?? updatedResponse.weeklyHours,
          difficulty: updates['difficulty'] ?? updatedResponse.difficulty,
          description: updates['description'] ?? updatedResponse.description,
          userId: updatedResponse.userId,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteModule(String id) async {
    try {
      await _service.deleteModule(id);
      _modules.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
