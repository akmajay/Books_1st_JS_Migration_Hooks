class ChatModel {
  final String id;
  final String buyer; // relation ID -> users
  final String seller; // relation ID -> users
  final String book; // relation ID -> books
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSender; // relation ID -> users
  final int unreadCount;
  final bool isActive;
  final bool isDeletedByBuyer;
  final bool isDeletedBySeller;
  final double? agreedPrice;
  final double? offerAmount;
  final String offerStatus; // "none", "pending", "accepted", "declined", "expired"
  final DateTime? offerExpiresAt;
  final DateTime created;
  final DateTime updated;

  const ChatModel({
    required this.id,
    required this.buyer,
    required this.seller,
    required this.book,
    required this.lastMessage,
    this.lastMessageAt,
    this.lastSender,
    this.unreadCount = 0,
    this.isActive = true,
    this.isDeletedByBuyer = false,
    this.isDeletedBySeller = false,
    this.agreedPrice,
    this.offerAmount,
    this.offerStatus = 'none',
    this.offerExpiresAt,
    required this.created,
    required this.updated,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      buyer: json['buyer'] as String? ?? '',
      seller: json['seller'] as String? ?? '',
      book: json['book'] as String? ?? '',
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt: json['last_message_at'] != null && json['last_message_at'] != ''
          ? DateTime.tryParse(json['last_message_at'] as String)
          : null,
      lastSender: json['last_sender'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isDeletedByBuyer: json['is_deleted_by_buyer'] as bool? ?? false,
      isDeletedBySeller: json['is_deleted_by_seller'] as bool? ?? false,
      agreedPrice: (json['agreed_price'] as num?)?.toDouble(),
      offerAmount: (json['offer_amount'] as num?)?.toDouble(),
      offerStatus: json['offer_status'] as String? ?? 'none',
      offerExpiresAt: json['offer_expires_at'] != null && json['offer_expires_at'] != ''
          ? DateTime.tryParse(json['offer_expires_at'] as String)
          : null,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyer': buyer,
      'seller': seller,
      'book': book,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_sender': lastSender,
      'unread_count': unreadCount,
      'is_active': isActive,
      'is_deleted_by_buyer': isDeletedByBuyer,
      'is_deleted_by_seller': isDeletedBySeller,
      'agreed_price': agreedPrice,
      'offer_amount': offerAmount,
      'offer_status': offerStatus,
      'offer_expires_at': offerExpiresAt?.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    String? buyer,
    String? seller,
    String? book,
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? isActive,
    double? offerAmount,
    String? offerStatus,
    DateTime? offerExpiresAt,
    DateTime? created,
    DateTime? updated,
  }) {
    return ChatModel(
      id: id ?? this.id,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      book: book ?? this.book,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isActive: isActive ?? this.isActive,
      offerAmount: offerAmount ?? this.offerAmount,
      offerStatus: offerStatus ?? this.offerStatus,
      offerExpiresAt: offerExpiresAt ?? this.offerExpiresAt,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, buyer: $buyer, seller: $seller, book: $book)';
  }
}
