class TransactionModel {
  final String id;
  final String book; // relation ID -> books
  final String buyer; // relation ID -> users
  final String seller; // relation ID -> users
  final double agreedPrice;
  final String status; // "initiated", "confirmed", "handover_pending", "completed", "reviewed", "disputed"
  final String? handoverToken;
  final DateTime? tokenExpiresAt;
  final String? qrToken; // Legacy/Prompt 15 overlap
  final DateTime? qrGeneratedAt;
  final DateTime? completedAt;
  final bool isOfflineSyncPending;
  final DateTime created;
  final DateTime updated;

  const TransactionModel({
    required this.id,
    required this.book,
    required this.buyer,
    required this.seller,
    required this.agreedPrice,
    required this.status,
    this.handoverToken,
    this.tokenExpiresAt,
    this.qrToken,
    this.qrGeneratedAt,
    this.completedAt,
    this.isOfflineSyncPending = false,
    required this.created,
    required this.updated,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      book: json['book'] as String? ?? '',
      buyer: json['buyer'] as String? ?? '',
      seller: json['seller'] as String? ?? '',
      agreedPrice: (json['agreed_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'initiated',
      handoverToken: json['handover_token'] as String?,
      tokenExpiresAt: json['token_expires_at'] != null ? DateTime.tryParse(json['token_expires_at'] as String) : null,
      qrToken: json['qr_token'] as String?,
      qrGeneratedAt: json['qr_generated_at'] != null ? DateTime.tryParse(json['qr_generated_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      isOfflineSyncPending: json['is_offline_sync_pending'] as bool? ?? false,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'buyer': buyer,
      'seller': seller,
      'agreed_price': agreedPrice,
      'status': status,
      'handover_token': handoverToken,
      'token_expires_at': tokenExpiresAt?.toIso8601String(),
      'qr_token': qrToken,
      'qr_generated_at': qrGeneratedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_offline_sync_pending': isOfflineSyncPending,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? book,
    String? buyer,
    String? seller,
    double? agreedPrice,
    String? status,
    String? handoverToken,
    DateTime? tokenExpiresAt,
    String? qrToken,
    DateTime? qrGeneratedAt,
    DateTime? completedAt,
    bool? isOfflineSyncPending,
    DateTime? created,
    DateTime? updated,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      book: book ?? this.book,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      status: status ?? this.status,
      handoverToken: handoverToken ?? this.handoverToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      qrToken: qrToken ?? this.qrToken,
      qrGeneratedAt: qrGeneratedAt ?? this.qrGeneratedAt,
      completedAt: completedAt ?? this.completedAt,
      isOfflineSyncPending: isOfflineSyncPending ?? this.isOfflineSyncPending,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, status: $status, agreedPrice: $agreedPrice)';
  }
}
