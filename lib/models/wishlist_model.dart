class WishlistModel {
  final String id;
  final String user; // relation ID -> users
  final String book; // relation ID -> books
  final double? priceAtSave;
  final DateTime created;
  final DateTime updated;

  const WishlistModel({
    required this.id,
    required this.user,
    required this.book,
    this.priceAtSave,
    required this.created,
    required this.updated,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as String? ?? '',
      user: json['user'] as String? ?? '',
      book: json['book'] as String? ?? '',
      priceAtSave: (json['price_at_save'] as num?)?.toDouble(),
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'book': book,
      'price_at_save': priceAtSave,
    };
  }

  WishlistModel copyWith({
    String? id,
    String? user,
    String? book,
    double? priceAtSave,
    DateTime? created,
    DateTime? updated,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      user: user ?? this.user,
      book: book ?? this.book,
      priceAtSave: priceAtSave ?? this.priceAtSave,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'WishlistModel(id: $id, book: $book)';
  }
}
