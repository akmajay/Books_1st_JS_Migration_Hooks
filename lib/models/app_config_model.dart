class AppConfigModel {
  final String id;
  final String minAppVersion;
  final String latestAppVersion;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String maintenanceEta;
  final String playStoreUrl;
  final String termsUrl;
  final String privacyUrl;
  final String supportEmail;
  final String announcement;
  final String announcementType;
  final DateTime created;
  final DateTime updated;

  const AppConfigModel({
    required this.id,
    required this.minAppVersion,
    required this.latestAppVersion,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.maintenanceEta,
    required this.playStoreUrl,
    required this.termsUrl,
    required this.privacyUrl,
    required this.supportEmail,
    required this.announcement,
    required this.announcementType,
    required this.created,
    required this.updated,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      id: json['id'] as String? ?? '',
      minAppVersion: json['min_app_version'] as String? ?? '1.0.0',
      latestAppVersion: json['latest_app_version'] as String? ?? '1.0.0',
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceMessage: json['maintenance_message'] as String? ?? '',
      maintenanceEta: json['maintenance_eta'] as String? ?? '',
      playStoreUrl: json['play_store_url'] as String? ?? '',
      termsUrl: json['terms_url'] as String? ?? 'https://books.jayganga.com/terms',
      privacyUrl: json['privacy_url'] as String? ?? 'https://books.jayganga.com/privacy',
      supportEmail: json['support_email'] as String? ?? 'support@jayganga.com',
      announcement: json['announcement'] as String? ?? '',
      announcementType: json['announcement_type'] as String? ?? 'info',
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_app_version': minAppVersion,
      'latest_app_version': latestAppVersion,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
      'maintenance_eta': maintenanceEta,
      'play_store_url': playStoreUrl,
      'terms_url': termsUrl,
      'privacy_url': privacyUrl,
      'support_email': supportEmail,
      'announcement': announcement,
      'announcement_type': announcementType,
    };
  }

  AppConfigModel copyWith({
    String? id,
    String? minAppVersion,
    String? latestAppVersion,
    bool? maintenanceMode,
    String? maintenanceMessage,
    String? maintenanceEta,
    String? playStoreUrl,
    String? termsUrl,
    String? privacyUrl,
    String? supportEmail,
    String? announcement,
    String? announcementType,
    DateTime? created,
    DateTime? updated,
  }) {
    return AppConfigModel(
      id: id ?? this.id,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      latestAppVersion: latestAppVersion ?? this.latestAppVersion,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      maintenanceEta: maintenanceEta ?? this.maintenanceEta,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
      supportEmail: supportEmail ?? this.supportEmail,
      announcement: announcement ?? this.announcement,
      announcementType: announcementType ?? this.announcementType,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'AppConfigModel(id: $id, v: $latestAppVersion, maintenance: $maintenanceMode)';
  }
}
