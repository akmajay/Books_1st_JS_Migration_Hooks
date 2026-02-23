class ReportModel {
  final String id;
  final String reporter; // relation ID -> users
  final String type; // "listing", "user", "bug"
  final String reason;
  final String? description;
  final String? screenshot; // file name
  final String? targetType;
  final String? targetId;
  final String status; // "pending", "reviewed", "actioned", "dismissed"
  final String? adminNotes;
  final DateTime created;
  final DateTime updated;

  const ReportModel({
    required this.id,
    required this.reporter,
    required this.type,
    required this.reason,
    this.description,
    this.screenshot,
    this.targetType,
    this.targetId,
    this.status = 'pending',
    this.adminNotes,
    required this.created,
    required this.updated,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      reporter: json['reporter'] as String? ?? '',
      type: json['type'] as String? ?? 'listing',
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      screenshot: json['screenshot'] as String?,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reporter': reporter,
      'type': type,
      'reason': reason,
      'description': description,
      'screenshot': screenshot,
      'target_type': targetType,
      'target_id': targetId,
      'status': status,
      'admin_notes': adminNotes,
    };
  }

  ReportModel copyWith({
    String? id,
    String? reporter,
    String? type,
    String? reason,
    String? description,
    String? screenshot,
    String? targetType,
    String? targetId,
    String? status,
    String? adminNotes,
    DateTime? created,
    DateTime? updated,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporter: reporter ?? this.reporter,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      screenshot: screenshot ?? this.screenshot,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, type: $type, status: $status)';
  }
}
