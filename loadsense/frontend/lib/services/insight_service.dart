import '../core/constants.dart';
import '../models/insight_model.dart';
import 'api_service.dart';

class InsightService {
  Future<InsightSummary> getInsights() async {
    final data = await ApiService.get(ApiConstants.insights);
    final insightData = (data is Map && data.containsKey('data')) ? data['data'] : data;
    return InsightSummary.fromJson(insightData);
  }
}
