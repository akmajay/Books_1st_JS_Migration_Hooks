class AdvertisementModel {
  final String id;
  final String businessName;
  final String? logo; // file name
  final String? tagline;
  final String? link;
  final String? phone;
  final bool isActive;
  final int? sortOrder;
  final DateTime created;
  final DateTime updated;

  const AdvertisementModel({
    required this.id,
    required this.businessName,
    this.logo,
    this.tagline,
    this.link,
    this.phone,
    this.isActive = true,
    this.sortOrder,
    required this.created,
    required this.updated,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      logo: json['logo'] as String?,
      tagline: json['tagline'] as String?,
      link: json['link'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'logo': logo,
      'tagline': tagline,
      'link': link,
      'phone': phone,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  AdvertisementModel copyWith({
    String? id,
    String? businessName,
    String? logo,
    String? tagline,
    String? link,
    String? phone,
    bool? isActive,
    int? sortOrder,
    DateTime? created,
    DateTime? updated,
  }) {
    return AdvertisementModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      logo: logo ?? this.logo,
      tagline: tagline ?? this.tagline,
      link: link ?? this.link,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'AdvertisementModel(id: $id, business: $businessName)';
  }
}
