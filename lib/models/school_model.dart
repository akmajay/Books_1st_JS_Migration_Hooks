class SchoolModel {
  final String id;
  final String name;
  final String city;
  final String? area;
  final String type; // "school", "coaching", "college"
  final String? board;
  final bool isActive;
  final DateTime created;
  final DateTime updated;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.city,
    this.area,
    required this.type,
    this.board,
    this.isActive = true,
    required this.created,
    required this.updated,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      area: json['area'] as String?,
      type: json['type'] as String? ?? 'school',
      board: json['board'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'area': area,
      'type': type,
      'board': board,
      'is_active': isActive,
    };
  }

  SchoolModel copyWith({
    String? id,
    String? name,
    String? city,
    String? area,
    String? type,
    String? board,
    bool? isActive,
    DateTime? created,
    DateTime? updated,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      area: area ?? this.area,
      type: type ?? this.type,
      board: board ?? this.board,
      isActive: isActive ?? this.isActive,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'SchoolModel(id: $id, name: $name, city: $city, type: $type)';
  }
}
