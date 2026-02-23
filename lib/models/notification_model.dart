class NotificationModel {
  final String id;
  final String user; // relation ID -> users
  final String title;
  final String body;
  final String type; // "chat", "offer", "price_drop", "recommendation", "referral", "system", "inactivity", "seller_reminder"
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime created;
  final DateTime updated;

  const NotificationModel({
    required this.id,
    required this.user,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.data,
    required this.created,
    required this.updated,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      user: json['user'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? user,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? created,
    DateTime? updated,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title)';
  }
}
