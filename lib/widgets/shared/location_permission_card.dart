import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';

/// A card prompting the user to enable location. Handles all 5 permission states:
/// never asked, denied, denied forever, service disabled, granted (hidden).
class LocationPermissionCard extends StatefulWidget {
  /// Called when the user grants location permission.
  final VoidCallback? onLocationGranted;

  const LocationPermissionCard({super.key, this.onLocationGranted});

  @override
  State<LocationPermissionCard> createState() => _LocationPermissionCardState();
}

class _LocationPermissionCardState extends State<LocationPermissionCard> {
  _PermState _state = _PermState.loading;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final serviceOn = await LocationService.isServiceEnabled();
    if (!serviceOn) {
      if (mounted) setState(() => _state = _PermState.serviceOff);
      return;
    }

    final perm = await LocationService.checkPermission();
    if (!mounted) return;
    setState(() {
      switch (perm) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          _state = _PermState.granted;
        case LocationPermission.denied:
          _state = _PermState.denied;
        case LocationPermission.deniedForever:
          _state = _PermState.deniedForever;
        case LocationPermission.unableToDetermine:
          _state = _PermState.neverAsked;
      }
    });
  }

  Future<void> _onTap() async {
    switch (_state) {
      case _PermState.neverAsked:
      case _PermState.denied:
        final pos = await LocationService.getCurrentLocation();
        if (pos != null) {
          widget.onLocationGranted?.call();
        }
        await _checkStatus();
      case _PermState.deniedForever:
        await LocationService.openAppSettings();
        // Recheck after returning from settings
        await Future.delayed(const Duration(seconds: 1));
        await _checkStatus();
      case _PermState.serviceOff:
        await LocationService.openLocationSettings();
        await Future.delayed(const Duration(seconds: 1));
        await _checkStatus();
      case _PermState.granted:
      case _PermState.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _PermState.granted || _state == _PermState.loading) {
      return const SizedBox.shrink();
    }

    final (String message, String buttonText, IconData icon) = switch (_state) {
      _PermState.neverAsked => (
          'Enable location to see books near you',
          'Enable',
          Icons.location_on_outlined,
        ),
      _PermState.denied => (
          'Location denied. Tap to enable in settings.',
          'Open Settings',
          Icons.location_off_outlined,
        ),
      _PermState.deniedForever => (
          'Location permanently denied.',
          'Open Settings',
          Icons.location_disabled,
        ),
      _PermState.serviceOff => (
          'Location services are disabled.',
          'Turn On',
          Icons.gps_off,
        ),
      _ => ('', '', Icons.error),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '📍 $message',
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _onTap,
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

enum _PermState { loading, neverAsked, denied, deniedForever, serviceOff, granted }
