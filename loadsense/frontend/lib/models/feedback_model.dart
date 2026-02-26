class FeedbackRating {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  FeedbackRating({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackRating.fromJson(Map<String, dynamic> json) {
    return FeedbackRating(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] ?? json['feedback'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'feedback': comment,
      };
}
