import 'package:flutter/foundation.dart';
import '../models/insight_model.dart';
import '../services/insight_service.dart';
import '../services/ai_service.dart';

class InsightProvider extends ChangeNotifier {
  final InsightService _insightService = InsightService();
  final AiService _aiService = AiService();

  InsightSummary? _summary;
  StudyPlan? _studyPlan;
  bool _isLoading = false;
  bool _aiLoading = false;
  String? _error;

  InsightSummary? get summary => _summary;
  StudyPlan? get studyPlan => _studyPlan;
  bool get isLoading => _isLoading;
  bool get aiLoading => _aiLoading;
  String? get error => _error;

  Future<void> fetchInsights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _insightService.getInsights();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching insights: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateAiSuggestion(Map<String, dynamic> input) async {
    _aiLoading = true;
    notifyListeners();
    try {
      final result = await _aiService.generateSuggestion(input);
      if (result['success'] == true && result['data'] != null) {
        _studyPlan = StudyPlan.fromJson(result['data']);
      } else {
        debugPrint('AI Suggestion failed: ${result['message']}');
      }
    } catch (e) {
      _error = 'Could not generate suggestion: $e';
      debugPrint('Error generating AI suggestion: $e');
    } finally {
      _aiLoading = false;
      notifyListeners();
    }
  }
}
