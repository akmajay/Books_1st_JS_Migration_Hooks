class BundleItemModel {
  final String id;
  final String bundle; // relation ID -> books
  final String itemTitle;
  final String? itemAuthor;
  final String? itemCondition; // "like_new", "good", "fair"
  final DateTime created;
  final DateTime updated;

  const BundleItemModel({
    required this.id,
    required this.bundle,
    required this.itemTitle,
    this.itemAuthor,
    this.itemCondition,
    required this.created,
    required this.updated,
  });

  factory BundleItemModel.fromJson(Map<String, dynamic> json) {
    return BundleItemModel(
      id: json['id'] as String? ?? '',
      bundle: json['bundle'] as String? ?? '',
      itemTitle: json['item_title'] as String? ?? '',
      itemAuthor: json['item_author'] as String?,
      itemCondition: json['item_condition'] as String?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bundle': bundle,
      'item_title': itemTitle,
      'item_author': itemAuthor,
      'item_condition': itemCondition,
    };
  }

  BundleItemModel copyWith({
    String? id,
    String? bundle,
    String? itemTitle,
    String? itemAuthor,
    String? itemCondition,
    DateTime? created,
    DateTime? updated,
  }) {
    return BundleItemModel(
      id: id ?? this.id,
      bundle: bundle ?? this.bundle,
      itemTitle: itemTitle ?? this.itemTitle,
      itemAuthor: itemAuthor ?? this.itemAuthor,
      itemCondition: itemCondition ?? this.itemCondition,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'BundleItemModel(id: $id, title: $itemTitle, bundle: $bundle)';
  }
}
