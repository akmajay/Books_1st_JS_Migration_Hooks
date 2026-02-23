class ReviewModel {
  final String id;
  final String transaction; // relation ID -> transactions
  final String reviewer; // relation ID -> users
  final String reviewedUser; // relation ID -> users
  final int rating; // 1-5
  final String? comment;
  final List<String>? tags;
  final DateTime created;
  final DateTime updated;

  const ReviewModel({
    required this.id,
    required this.transaction,
    required this.reviewer,
    required this.reviewedUser,
    required this.rating,
    this.comment,
    this.tags,
    required this.created,
    required this.updated,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      transaction: json['transaction'] as String? ?? '',
      reviewer: json['reviewer'] as String? ?? '',
      reviewedUser: json['reviewed_user'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction,
      'reviewer': reviewer,
      'reviewed_user': reviewedUser,
      'rating': rating,
      'comment': comment,
      'tags': tags,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? transaction,
    String? reviewer,
    String? reviewedUser,
    int? rating,
    String? comment,
    List<String>? tags,
    DateTime? created,
    DateTime? updated,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      transaction: transaction ?? this.transaction,
      reviewer: reviewer ?? this.reviewer,
      reviewedUser: reviewedUser ?? this.reviewedUser,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating)';
  }
}
