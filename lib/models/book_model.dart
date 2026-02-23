class BookModel {
  final String id;
  final String title;
  final String author;
  final String? edition;
  final String? publisher;
  final String? description;
  final List<String> photos; // file names
  final double? mrp;
  final double sellingPrice;
  final String condition; // "like_new", "good", "fair"
  final List<String> conditionTags;
  final String category;
  final String? classYear;
  final String? board;
  final String? stream;
  final String status; // "active", "reserved", "sold", "archived", "draft"
  final bool isBundle;
  final String? bundleName;
  final double? bundleTotalMrp;
  final String? handoverArea;
  final DateTime? availableFrom;
  final int viewsCount;
  final int wishlistCount;
  final double? locationLat;
  final double? locationLon;
  final bool isPriority;
  final DateTime? autoArchiveDate;
  final String seller; // relation ID -> users
  final String? school; // relation ID -> schools
  final DateTime created;
  final DateTime updated;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.edition,
    this.publisher,
    this.description,
    required this.photos,
    this.mrp,
    required this.sellingPrice,
    required this.condition,
    this.conditionTags = const [],
    required this.category,
    this.classYear,
    this.board,
    this.stream,
    required this.status,
    this.isBundle = false,
    this.bundleName,
    this.bundleTotalMrp,
    this.handoverArea,
    this.availableFrom,
    this.viewsCount = 0,
    this.wishlistCount = 0,
    this.locationLat,
    this.locationLon,
    this.isPriority = false,
    this.autoArchiveDate,
    required this.seller,
    this.school,
    required this.created,
    required this.updated,
  });

  bool get isFree => sellingPrice == 0;

  int? get discountPercent {
    if (mrp != null && mrp! > 0) {
      return ((1 - sellingPrice / mrp!) * 100).round();
    }
    return null;
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      author: json['author'] as String? ?? 'Unknown Author',
      edition: json['edition'] as String?,
      publisher: json['publisher'] as String?,
      description: json['description'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mrp: (json['mrp'] as num?)?.toDouble(),
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'good',
      conditionTags: (json['condition_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: json['category'] as String? ?? 'other',
      classYear: json['class_year'] as String?,
      board: json['board'] as String?,
      stream: json['stream'] as String?,
      status: json['status'] as String? ?? 'active',
      isBundle: json['is_bundle'] as bool? ?? false,
      bundleName: json['bundle_name'] as String?,
      bundleTotalMrp: (json['bundle_total_mrp'] as num?)?.toDouble(),
      handoverArea: json['handover_area'] as String?,
      availableFrom: json['available_from'] != null && json['available_from'] != ''
          ? DateTime.tryParse(json['available_from'] as String)
          : null,
      viewsCount: json['views_count'] as int? ?? 0,
      wishlistCount: json['wishlist_count'] as int? ?? 0,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLon: (json['location_lon'] as num?)?.toDouble(),
      isPriority: json['is_priority'] as bool? ?? false,
      autoArchiveDate: json['auto_archive_date'] != null && json['auto_archive_date'] != ''
          ? DateTime.tryParse(json['auto_archive_date'] as String)
          : null,
      seller: json['seller'] as String? ?? '',
      school: json['school'] as String?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'edition': edition,
      'publisher': publisher,
      'description': description,
      'photos': photos,
      'mrp': mrp,
      'selling_price': sellingPrice,
      'condition': condition,
      'condition_tags': conditionTags,
      'category': category,
      'class_year': classYear,
      'board': board,
      'stream': stream,
      'status': status,
      'is_bundle': isBundle,
      'bundle_name': bundleName,
      'bundle_total_mrp': bundleTotalMrp,
      'handover_area': handoverArea,
      'available_from': availableFrom?.toIso8601String(),
      'views_count': viewsCount,
      'wishlist_count': wishlistCount,
      'location_lat': locationLat,
      'location_lon': locationLon,
      'is_priority': isPriority,
      'auto_archive_date': autoArchiveDate?.toIso8601String(),
      'seller': seller,
      'school': school,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? edition,
    String? publisher,
    String? description,
    List<String>? photos,
    double? mrp,
    double? sellingPrice,
    String? condition,
    List<String>? conditionTags,
    String? category,
    String? classYear,
    String? board,
    String? stream,
    String? status,
    bool? isBundle,
    String? bundleName,
    double? bundleTotalMrp,
    String? handoverArea,
    DateTime? availableFrom,
    int? viewsCount,
    int? wishlistCount,
    double? locationLat,
    double? locationLon,
    bool? isPriority,
    DateTime? autoArchiveDate,
    String? seller,
    String? school,
    DateTime? created,
    DateTime? updated,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      edition: edition ?? this.edition,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      mrp: mrp ?? this.mrp,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      condition: condition ?? this.condition,
      conditionTags: conditionTags ?? this.conditionTags,
      category: category ?? this.category,
      classYear: classYear ?? this.classYear,
      board: board ?? this.board,
      stream: stream ?? this.stream,
      status: status ?? this.status,
      isBundle: isBundle ?? this.isBundle,
      bundleName: bundleName ?? this.bundleName,
      bundleTotalMrp: bundleTotalMrp ?? this.bundleTotalMrp,
      handoverArea: handoverArea ?? this.handoverArea,
      availableFrom: availableFrom ?? this.availableFrom,
      viewsCount: viewsCount ?? this.viewsCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      locationLat: locationLat ?? this.locationLat,
      locationLon: locationLon ?? this.locationLon,
      isPriority: isPriority ?? this.isPriority,
      autoArchiveDate: autoArchiveDate ?? this.autoArchiveDate,
      seller: seller ?? this.seller,
      school: school ?? this.school,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, price: $sellingPrice, status: $status)';
  }
}
