class MessageModel {
  final String id;
  final String chat; // relation ID -> chats
  final String sender; // relation ID -> users
  final String receiver; // relation ID -> users
  final String? content;
  final String type; // "text", "image", "offer", "system"
  final String? image; // file name
  final double? offerAmount;
  final bool isRead;
  final DateTime? readAt;
  final bool isDelivered;
  final DateTime created;
  final DateTime updated;

  const MessageModel({
    required this.id,
    required this.chat,
    required this.sender,
    required this.receiver,
    this.content,
    required this.type,
    this.image,
    this.offerAmount,
    this.isRead = false,
    this.readAt,
    this.isDelivered = false,
    required this.created,
    required this.updated,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chat: json['chat'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      receiver: json['receiver'] as String? ?? '',
      content: json['content'] as String?,
      type: json['type'] as String? ?? 'text',
      image: json['image'] as String?,
      offerAmount: (json['offer_amount'] as num?)?.toDouble(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
      isDelivered: json['is_delivered'] as bool? ?? false,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat,
      'sender': sender,
      'receiver': receiver,
      'content': content,
      'type': type,
      'image': image,
      'offer_amount': offerAmount,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'is_delivered': isDelivered,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chat,
    String? sender,
    String? receiver,
    String? content,
    String? type,
    String? image,
    double? offerAmount,
    bool? isRead,
    DateTime? readAt,
    bool? isDelivered,
    DateTime? created,
    DateTime? updated,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chat: chat ?? this.chat,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      content: content ?? this.content,
      type: type ?? this.type,
      image: image ?? this.image,
      offerAmount: offerAmount ?? this.offerAmount,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDelivered: isDelivered ?? this.isDelivered,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, type: $type, content: $content)';
  }
}
