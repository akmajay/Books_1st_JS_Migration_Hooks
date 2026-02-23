import 'package:flutter/foundation.dart';
import '../models/app_config_model.dart';
import 'pocketbase_service.dart';

/// Centralized app configuration fetched from PocketBase `app_config` singleton collection.
class AppConfigService extends ChangeNotifier {
  AppConfigService._();
  static final AppConfigService _instance = AppConfigService._();
  static AppConfigService get instance => _instance;

  AppConfigModel? _config;
  AppConfigModel get current => _config ?? _defaults();

  /// Fetches the singleton config record from the server.
  /// On failure, falls back to sensible defaults.
  Future<AppConfigModel> fetch() async {
    try {
      final pb = PocketBaseService.instance.pb;
      // Fetch the first available record (singleton)
      final records = await pb.collection('app_config').getList(page: 1, perPage: 1);
      
      if (records.items.isNotEmpty) {
        _config = AppConfigModel.fromJson({
          'id': records.items.first.id,
          'created': records.items.first.get<String>('created'),
          'updated': records.items.first.get<String>('updated'),
          ...records.items.first.data,
        });
        notifyListeners();
      } else {
        debugPrint('AppConfigService: No config record found. Using defaults.');
        _config = _defaults();
      }
    } catch (e) {
      debugPrint('AppConfigService ERROR: $e. Using defaults.');
      _config = _defaults();
    }
    return current;
  }

  AppConfigModel _defaults() {
    return AppConfigModel(
      id: '',
      minAppVersion: '1.0.0',
      latestAppVersion: '1.0.0',
      maintenanceMode: false,
      maintenanceMessage: '',
      maintenanceEta: '',
      playStoreUrl: '',
      termsUrl: 'https://books.jayganga.com/terms',
      privacyUrl: 'https://books.jayganga.com/privacy',
      supportEmail: 'support@jayganga.com',
      announcement: '',
      announcementType: 'info',
      created: DateTime.now(),
      updated: DateTime.now(),
    );
  }

  /// Version comparison logic
  bool isForceUpdateRequired(String currentVersion) {
    return _isOlderThan(currentVersion, current.minAppVersion);
  }

  bool isOptionalUpdateAvailable(String currentVersion) {
    return !isForceUpdateRequired(currentVersion) &&
        _isOlderThan(currentVersion, current.latestAppVersion);
  }

  static bool _isOlderThan(String current, String target) {
    try {
      final c = current.split('.').map(int.parse).toList();
      final t = target.split('.').map(int.parse).toList();
      for (var i = 0; i < 3; i++) {
        if (c[i] < t[i]) return true;
        if (c[i] > t[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
