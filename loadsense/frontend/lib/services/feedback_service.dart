import '../core/constants.dart';
import '../models/feedback_model.dart';
import 'api_service.dart';

class FeedbackService {
  Future<List<FeedbackRating>> getRatings() async {
    final data = await ApiService.get(ApiConstants.feedbackRatings);
    final List list = data['ratings'] ?? data['data'] ?? (data is List ? data : []);
    return list.map((e) => FeedbackRating.fromJson(e)).toList();
  }

  Future<FeedbackRating> createRating(int rating, String? comment) async {
    final data = await ApiService.post(ApiConstants.feedbackRatings, {
      'rating': rating,
      if (comment != null) 'feedback': comment,
    });
    return FeedbackRating.fromJson(data['rating'] ?? data);
  }
}
