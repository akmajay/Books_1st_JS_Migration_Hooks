import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationStep extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSaved;

  const LocationStep({
    super.key,
    required this.initialData,
    required this.onSaved,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  bool _isDetecting = false;
  String? _detectedCity;
  String? _detectedArea;
  double? _lat;
  double? _lon;

  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  bool _isManual = false;

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.initialData['city'] ?? '';
    _areaController.text = widget.initialData['area'] ?? '';
    _lat = widget.initialData['location_lat'];
    _lon = widget.initialData['location_lon'];
    
    if (_cityController.text.isNotEmpty || _areaController.text.isNotEmpty) {
      _isManual = true; // Show manual fields if pre-filled
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition();
      _lat = position.latitude;
      _lon = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lon!);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _detectedCity = place.locality ?? place.subAdministrativeArea;
        _detectedArea = place.subLocality ?? place.name;

        _cityController.text = _detectedCity ?? '';
        _areaController.text = _detectedArea ?? '';
      }

      setState(() {
        _isDetecting = false;
        _isManual = false; // Show detected view
      });
    } catch (e) {
      setState(() {
        _isDetecting = false;
        _isManual = true; // Fallback to manual
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not detect location: $e')),
        );
      }
    }
  }

  void _onContinue() {
    if (_cityController.text.isEmpty || _areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your city and area.')),
      );
      return;
    }

    widget.onSaved({
      'location_lat': _lat,
      'location_lon': _lon,
      'city': _cityController.text,
      'area': _areaController.text,
      'preferred_radius': 5,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set your location',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'We use your approximate location to show books near you.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 48),
        if (!_isManual && _cityController.text.isNotEmpty)
          _buildDetectedCard()
        else
          _buildActionView(),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _onContinue,
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectedCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _areaController.text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(_cityController.text, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isManual = true),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionView() {
    return Column(
      children: [
        if (_isDetecting)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Detecting your location...'),
              ],
            ),
          )
        else ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _detectLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Detect My Location'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR MANUALLY ENTER', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _areaController,
            decoration: const InputDecoration(
              labelText: 'Area / Locality',
              prefixIcon: Icon(Icons.map),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
