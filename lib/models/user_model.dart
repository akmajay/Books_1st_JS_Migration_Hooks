import '../config/env.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String phone;
  final String? userType; // "school_student" | "exam_aspirant" | "college_student"
  final String? classYear;
  final String? board; // "CBSE" | "ICSE" | "State Board" | "IB" | "Other"
  final String? stream; // "Science" | "Commerce" | "Arts" | "General"
  final String? examType; // "JEE" | "NEET" | "Bank" | "SSC" | "UPSC" | "State PSC" | "Other"
  final String? coachingInstitute;
  final String? collegeName;
  final String? collegeBranch;
  final String? collegeSemester;
  final String? school; // relation ID -> schools
  final double? locationLat;
  final double? locationLon;
  final String? city;
  final String? area;
  final String? bio;
  final List<String> badges; // ["helping_hand", "top_seller", ...]
  final double trustScore;
  final int reviewCount;
  final int totalSales;
  final int totalPurchases;
  final String? referralCode;
  final String? referredBy; // relation ID -> users
  final String? fcmToken;
  final Map<String, dynamic>? notificationPreferences;
  final bool isBanned;
  final String? banReason;
  final DateTime? lastActive;
  final bool onboardingComplete;
  final String preferredLanguage; // "en" | "hi"
  final int preferredRadius;
  final String darkMode; // "system" | "light" | "dark"
  final DateTime? priorityUntil;
  final DateTime created;
  final DateTime updated;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.phone,
    this.userType,
    this.classYear,
    this.board,
    this.stream,
    this.examType,
    this.coachingInstitute,
    this.collegeName,
    this.collegeBranch,
    this.collegeSemester,
    this.school,
    this.locationLat,
    this.locationLon,
    this.city,
    this.area,
    this.bio,
    this.badges = const [],
    this.trustScore = 0.0,
    this.reviewCount = 0,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.referralCode,
    this.referredBy,
    this.fcmToken,
    this.notificationPreferences,
    this.isBanned = false,
    this.banReason,
    this.lastActive,
    this.onboardingComplete = false,
    this.preferredLanguage = 'en',
    this.preferredRadius = 5,
    this.darkMode = 'system',
    this.priorityUntil,
    required this.created,
    required this.updated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String? ?? '',
      userType: json['user_type'] as String?,
      classYear: json['class_year'] as String?,
      board: json['board'] as String?,
      stream: json['stream'] as String?,
      examType: json['exam_type'] as String?,
      coachingInstitute: json['coaching_institute'] as String?,
      collegeName: json['college_name'] as String?,
      collegeBranch: json['college_branch'] as String?,
      collegeSemester: json['college_semester'] as String?,
      school: json['school'] as String?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLon: (json['location_lon'] as num?)?.toDouble(),
      city: json['city'] as String?,
      area: json['area'] as String?,
      bio: json['bio'] as String?,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      totalSales: json['total_sales'] as int? ?? 0,
      totalPurchases: json['total_purchases'] as int? ?? 0,
      referralCode: json['referral_code'] as String?,
      referredBy: json['referred_by'] as String?,
      fcmToken: json['fcm_token'] as String?,
      notificationPreferences: json['notification_preferences'] as Map<String, dynamic>?,
      isBanned: json['is_banned'] as bool? ?? false,
      banReason: json['ban_reason'] as String?,
      lastActive: json['last_active'] != null && json['last_active'] != ''
          ? DateTime.tryParse(json['last_active'] as String)
          : null,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      preferredRadius: (json['preferred_radius'] as num?)?.toInt() ?? 5,
      darkMode: json['dark_mode'] as String? ?? 'system',
      priorityUntil: json['priority_until'] != null && json['priority_until'] != ''
          ? DateTime.tryParse(json['priority_until'] as String)
          : null,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'user_type': userType,
      'class_year': classYear,
      'board': board,
      'stream': stream,
      'exam_type': examType,
      'coaching_institute': coachingInstitute,
      'college_name': collegeName,
      'college_branch': collegeBranch,
      'college_semester': collegeSemester,
      'school': school,
      'location_lat': locationLat,
      'location_lon': locationLon,
      'city': city,
      'area': area,
      'bio': bio,
      'badges': badges,
      'trust_score': trustScore,
      'review_count': reviewCount,
      'total_sales': totalSales,
      'total_purchases': totalPurchases,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'fcm_token': fcmToken,
      'notification_preferences': notificationPreferences,
      'is_banned': isBanned,
      'ban_reason': banReason,
      'last_active': lastActive?.toIso8601String(),
      'onboarding_complete': onboardingComplete,
      'preferred_language': preferredLanguage,
      'preferred_radius': preferredRadius,
      'dark_mode': darkMode,
      'priority_until': priorityUntil?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? phone,
    String? userType,
    String? classYear,
    String? board,
    String? stream,
    String? examType,
    String? coachingInstitute,
    String? collegeName,
    String? collegeBranch,
    String? collegeSemester,
    String? school,
    double? locationLat,
    double? locationLon,
    String? city,
    String? area,
    String? bio,
    List<String>? badges,
    double? trustScore,
    int? reviewCount,
    int? totalSales,
    int? totalPurchases,
    String? referralCode,
    String? referredBy,
    String? fcmToken,
    Map<String, dynamic>? notificationPreferences,
    bool? isBanned,
    String? banReason,
    DateTime? lastActive,
    bool? onboardingComplete,
    String? preferredLanguage,
    int? preferredRadius,
    String? darkMode,
    DateTime? priorityUntil,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      classYear: classYear ?? this.classYear,
      board: board ?? this.board,
      stream: stream ?? this.stream,
      examType: examType ?? this.examType,
      coachingInstitute: coachingInstitute ?? this.coachingInstitute,
      collegeName: collegeName ?? this.collegeName,
      collegeBranch: collegeBranch ?? this.collegeBranch,
      collegeSemester: collegeSemester ?? this.collegeSemester,
      school: school ?? this.school,
      locationLat: locationLat ?? this.locationLat,
      locationLon: locationLon ?? this.locationLon,
      city: city ?? this.city,
      area: area ?? this.area,
      bio: bio ?? this.bio,
      badges: badges ?? this.badges,
      trustScore: trustScore ?? this.trustScore,
      reviewCount: reviewCount ?? this.reviewCount,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      lastActive: lastActive ?? this.lastActive,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredRadius: preferredRadius ?? this.preferredRadius,
      darkMode: darkMode ?? this.darkMode,
      priorityUntil: priorityUntil ?? this.priorityUntil,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phone: $phone)';
  }

  String get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return '';
    return '${Env.pocketbaseUrl}/api/files/users/$id/$avatar';
  }
}
