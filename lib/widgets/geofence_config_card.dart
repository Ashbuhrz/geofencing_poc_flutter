import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geofencingpoc/models/geofence_location.dart';

class GeofenceConfigCard extends StatefulWidget {
  final Position currentLocation;
  final bool isGeofenceActive;
  final Function(GeofenceLocation) onStartGeofence;
  final VoidCallback onStopGeofence;

  const GeofenceConfigCard({
    Key? key,
    required this.currentLocation,
    required this.isGeofenceActive,
    required this.onStartGeofence,
    required this.onStopGeofence,
  }) : super(key: key);

  @override
  State<GeofenceConfigCard> createState() => _GeofenceConfigCardState();
}

class _GeofenceConfigCardState extends State<GeofenceConfigCard> {
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(text: widget.currentLocation.latitude.toString());
    _lngController = TextEditingController(text: widget.currentLocation.longitude.toString());
    _radiusController = TextEditingController(text: "10");
  }

  @override
  void didUpdateWidget(GeofenceConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation.latitude != widget.currentLocation.latitude ||
        oldWidget.currentLocation.longitude != widget.currentLocation.longitude) {
      _latController.text = widget.currentLocation.latitude.toString();
      _lngController.text = widget.currentLocation.longitude.toString();
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    setState(() {
      _latController.text = widget.currentLocation.latitude.toString();
      _lngController.text = widget.currentLocation.longitude.toString();
    });
  }

  void _startGeofence() {
    if (_latController.text.isNotEmpty && 
        _lngController.text.isNotEmpty && 
        _radiusController.text.isNotEmpty) {
      try {
        final location = GeofenceLocation(
          latitude: double.parse(_latController.text),
          longitude: double.parse(_lngController.text),
          radius: double.parse(_radiusController.text),
          name: 'Office',
        );
        widget.onStartGeofence(location);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid input values')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Office Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: 'Enter latitude',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: 'Enter longitude',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Radius (meters)',
                hintText: 'Enter radius in meters',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isGeofenceActive ? null : _startGeofence,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Start Geofencing'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey;
                          }
                          return Colors.green;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isGeofenceActive ? widget.onStopGeofence : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop Geofencing'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey;
                          }
                          return Colors.red;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
