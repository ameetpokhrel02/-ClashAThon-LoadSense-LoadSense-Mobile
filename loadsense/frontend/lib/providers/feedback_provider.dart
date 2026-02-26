import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  List<FeedbackRating> _ratings = [];
  bool _isLoading = false;
  String? _error;

  List<FeedbackRating> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRatings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _ratings = await _service.getRatings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback(int rating, String? comment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _service.createRating(rating, comment);
      _ratings.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
