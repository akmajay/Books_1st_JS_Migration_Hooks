class BlockedUserModel {
  final String id;
  final String blocker; // relation ID -> users
  final String blocked; // relation ID -> users
  final DateTime created;
  final DateTime updated;

  const BlockedUserModel({
    required this.id,
    required this.blocker,
    required this.blocked,
    required this.created,
    required this.updated,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      id: json['id'] as String? ?? '',
      blocker: json['blocker'] as String? ?? '',
      blocked: json['blocked'] as String? ?? '',
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blocker': blocker,
      'blocked': blocked,
    };
  }

  BlockedUserModel copyWith({
    String? id,
    String? blocker,
    String? blocked,
    DateTime? created,
    DateTime? updated,
  }) {
    return BlockedUserModel(
      id: id ?? this.id,
      blocker: blocker ?? this.blocker,
      blocked: blocked ?? this.blocked,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'BlockedUserModel(id: $id, blocked: $blocked)';
  }
}
