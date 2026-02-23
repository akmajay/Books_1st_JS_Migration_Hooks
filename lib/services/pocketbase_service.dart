import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';

/// Singleton PocketBase client with persistent auth store.
///
/// Auth tokens are stored in [SharedPreferences] and survive app restarts.
class PocketBaseService {
  PocketBaseService._();

  static PocketBaseService? _instance;
  static late PocketBase _pb;
  static bool _initialized = false;

  /// Returns the singleton instance.
  static PocketBaseService get instance {
    _instance ??= PocketBaseService._();
    return _instance!;
  }

  /// Initialize the PocketBase client with persistent auth store.
  ///
  /// Must be called once before using [pb], typically in `main.dart`.
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    final authStore = AsyncAuthStore(
      save: (String data) async {
        await prefs.setString('pb_auth', data);
      },
      initial: prefs.getString('pb_auth'),
    );

    // Logging active URL for debugging
    final url = Env.pocketbaseUrl;
    debugPrint('Initializing PocketBase with URL: $url');

    _pb = PocketBase(
      url,
      authStore: authStore,
    );

    _initialized = true;
  }

  /// The PocketBase client instance.
  ///
  /// Throws if [initialize] has not been called.
  PocketBase get pb {
    if (!_initialized) {
      throw StateError(
        'PocketBaseService not initialized. Call initialize() first.',
      );
    }
    return _pb;
  }

  /// Check if the PocketBase server is reachable and healthy.
  Future<bool> isServerHealthy() async {
    try {
      final response = await _pb.health.check();
      final isHealthy = response.code == 200;
      debugPrint('PocketBase Health Check: ${isHealthy ? 'SUCCESS' : 'FAILED (${response.code})'}');
      return isHealthy;
    } catch (e) {
      debugPrint('PocketBase Health Check ERROR: $e');
      return false;
    }
  }

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => _pb.authStore.isValid;

  /// Clear the current auth session.
  void logout() {
    _pb.authStore.clear();
  }

  /// Generate full file URL for a PocketBase record field.
  String getFileUrl(RecordModel record, String fileName) {
    if (fileName.isEmpty) return '';
    return '${Env.pocketbaseUrl}/api/files/${record.collectionId}/${record.id}/$fileName';
  }
}

/// Global convenience accessor for the PocketBase client.
PocketBase get pb => PocketBaseService.instance.pb;
