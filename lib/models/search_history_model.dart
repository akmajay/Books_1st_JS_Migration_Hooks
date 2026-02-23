class SearchHistoryModel {
  final String id;
  final String user; // relation ID -> users
  final String query;
  final DateTime created;
  final DateTime updated;

  const SearchHistoryModel({
    required this.id,
    required this.user,
    required this.query,
    required this.created,
    required this.updated,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String? ?? '',
      user: json['user'] as String? ?? '',
      query: json['query'] as String? ?? '',
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'query': query,
    };
  }

  SearchHistoryModel copyWith({
    String? id,
    String? user,
    String? query,
    DateTime? created,
    DateTime? updated,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      user: user ?? this.user,
      query: query ?? this.query,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'SearchHistoryModel(id: $id, query: $query)';
  }
}
