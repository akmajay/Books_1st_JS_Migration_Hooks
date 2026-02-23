class BannerModel {
  final String id;
  final String title;
  final String image; // file name
  final String? link;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? sortOrder;
  final DateTime created;
  final DateTime updated;

  const BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.link,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.sortOrder,
    required this.created,
    required this.updated,
  });

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      link: json['link'] as String?,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'link': link,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? image,
    String? link,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? sortOrder,
    DateTime? created,
    DateTime? updated,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      link: link ?? this.link,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title)';
  }
}
