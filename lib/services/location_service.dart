import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized location service with GPS permission handling,
/// Haversine distance calculation, and 10-minute position caching.
class LocationService {
  static Position? _cachedPosition;
  static DateTime? _cachedAt;

  // ─── Get current location with permission handling ─────────

  /// Returns user's current GPS position, or null if unavailable.
  /// Caches result for 10 minutes to avoid redundant GPS calls.
  static Future<Position?> getCurrentLocation() async {
    // Return cached if less than 10 minutes old
    if (_cachedPosition != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(minutes: 10)) {
      return _cachedPosition;
    }

    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Check permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // Get position with medium accuracy (~100m, fast, low battery)
    try {
      _cachedPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _cachedAt = DateTime.now();

      // Persist to Hive for offline fallback
      await _saveToHive(_cachedPosition!);

      return _cachedPosition;
    } catch (_) {
      // Timeout or other error — fall back to last known
      return await getLastKnown();
    }
  }

  // ─── Last known location fallback chain ────────────────────

  /// Returns last known position: memory → Hive → Geolocator.
  static Future<Position?> getLastKnown() async {
    if (_cachedPosition != null) return _cachedPosition;
    final hivePos = await _loadFromHive();
    if (hivePos != null) return hivePos;
    
    // getLastKnownPosition is not supported on web
    if (kIsWeb) return null;
    
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  // ─── Permission status ────────────────────────────────────

  /// Returns the current permission status without requesting it.
  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Returns whether location services are enabled on the device.
  static Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings for permission changes.
  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Open device location settings.
  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  // ─── Haversine distance calculation ────────────────────────

  /// Calculate distance between two lat/lng pairs in **kilometers**
  /// using the Haversine formula (pure Dart, no external package).
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  // ─── Format distance for display ──────────────────────────

  /// Returns human-readable distance string.
  /// • <1 km → "800m away"
  /// • <10 km → "3.2 km"
  /// • ≥10 km → "23 km"
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()}m';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }

  /// Returns distance color: green ≤5km, orange ≤15km, grey >15km.
  static DistanceCategory categorize(double km) {
    if (km <= 5) return DistanceCategory.nearby;
    if (km <= 15) return DistanceCategory.moderate;
    return DistanceCategory.far;
  }

  // ─── Hive cache helpers ───────────────────────────────────

  static Future<void> _saveToHive(Position pos) async {
    try {
      final box = Hive.box('settings');
      await box.put('last_lat', pos.latitude);
      await box.put('last_lng', pos.longitude);
    } catch (_) {
      // Hive not available — ignore silently
    }
  }

  static Future<Position?> _loadFromHive() async {
    try {
      final box = Hive.box('settings');
      final lat = box.get('last_lat') as double?;
      final lng = box.get('last_lng') as double?;
      if (lat == null || lng == null) return null;
      return Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear the in-memory cache (useful for testing or force refresh).
  static void clearCache() {
    _cachedPosition = null;
    _cachedAt = null;
  }
}

/// Distance category for color-coding.
enum DistanceCategory { nearby, moderate, far }
