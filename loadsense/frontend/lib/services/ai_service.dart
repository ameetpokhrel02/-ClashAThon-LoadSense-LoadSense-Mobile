import '../core/constants.dart';
import 'api_service.dart';

class AiService {
  Future<Map<String, dynamic>> generateSuggestion(Map<String, dynamic> input) async {
    final data = await ApiService.post(ApiConstants.aiSuggestion, input);
    return data is Map<String, dynamic> ? data : {'suggestion': data.toString()};
  }
}
