class ReferralModel {
  final String id;
  final String referrer; // relation ID -> users
  final String referee; // relation ID -> users
  final String referralCode;
  final String status; // "invited", "registered", "completed"
  final bool rewardGranted;
  final DateTime created;
  final DateTime updated;

  const ReferralModel({
    required this.id,
    required this.referrer,
    required this.referee,
    required this.referralCode,
    required this.status,
    this.rewardGranted = false,
    required this.created,
    required this.updated,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String? ?? '',
      referrer: json['referrer'] as String? ?? '',
      referee: json['referee'] as String? ?? '',
      referralCode: json['referral_code'] as String? ?? '',
      status: json['status'] as String? ?? 'invited',
      rewardGranted: json['reward_granted'] as bool? ?? false,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referrer': referrer,
      'referee': referee,
      'referral_code': referralCode,
      'status': status,
      'reward_granted': rewardGranted,
    };
  }

  ReferralModel copyWith({
    String? id,
    String? referrer,
    String? referee,
    String? referralCode,
    String? status,
    bool? rewardGranted,
    DateTime? created,
    DateTime? updated,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referrer: referrer ?? this.referrer,
      referee: referee ?? this.referee,
      referralCode: referralCode ?? this.referralCode,
      status: status ?? this.status,
      rewardGranted: rewardGranted ?? this.rewardGranted,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'ReferralModel(id: $id, code: $referralCode)';
  }
}
