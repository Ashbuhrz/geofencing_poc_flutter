import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:intl/intl.dart';
import 'package:geofencingpoc/models/geofence_location.dart';
import 'package:geofencingpoc/models/attendance_status.dart';
import 'package:geofencingpoc/services/storage_service.dart';
import 'package:geofencingpoc/services/attendance_service.dart';

class GeofenceService {
  // Singleton pattern
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();

  final StorageService _storageService = StorageService();

  // Initialize geofence service
  Future<void> initialize() async {
    await NativeGeofenceManager.instance.initialize();
  }

  // Start geofencing with given coordinates and radius
  Future<bool> startGeofence(GeofenceLocation location) async {
    await removeAllGeofences();

    final geofence = Geofence(
      id: 'office_zone',
      location: Location(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      radiusMeters: location.radius,
      triggers: {GeofenceEvent.enter, GeofenceEvent.exit, GeofenceEvent.dwell},
      iosSettings: IosGeofenceSettings(initialTrigger: true),
      androidSettings: AndroidGeofenceSettings(
        initialTriggers: {GeofenceEvent.enter},
        expiration: const Duration(days: 7),
        loiteringDelay: const Duration(minutes: 1),
        notificationResponsiveness: const Duration(minutes: 5),
      ),
    );

    await NativeGeofenceManager.instance.createGeofence(
      geofence,
      geofenceTriggered,
    );

    // Save the current geofence location
    await _storageService.saveGeofenceLocation(location);

    return true;
  }

  // Get the number of active geofences
  Future<int> getActiveGeofenceCount() async {
    final List<ActiveGeofence> geofences =
        await NativeGeofenceManager.instance.getRegisteredGeofences();
    return geofences.length;
  }

  // Remove all geofences
  Future<bool> removeAllGeofences() async {
    await NativeGeofenceManager.instance.removeAllGeofences();
    return true;
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }
}

// Callback function for geofence events
@pragma('vm:entry-point')
Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
  try {
    debugPrint('Geofence event triggered: ${params.event}');
    
    // Initialize services
    final storageService = StorageService();
    final attendanceService = AttendanceService();
    
    // Initialize attendance service to load current state
    await attendanceService.initialize();
    
    // Get current state
    final currentState = attendanceService.currentState;
    final now = DateTime.now();
    
    debugPrint('Current attendance status: ${currentState.status}');
    
    // Handle different geofence events
    switch (params.event) {
      case GeofenceEvent.enter:
        debugPrint('Entered geofence area');
        // Auto check-in when entering the geofence
        if (currentState.status == AttendanceStatus.notCheckedIn) {
          debugPrint('Attempting auto check-in...');
          await attendanceService.autoCheckIn();
          debugPrint('Auto check-in completed');
        } else {
          debugPrint('Skipping auto check-in: Already checked in or in break');
        }
        break;
        
      case GeofenceEvent.exit:
        debugPrint('Exited geofence area');
        // Auto check-out when exiting the geofence
        if (currentState.status == AttendanceStatus.checkedIn) {
          debugPrint('Attempting auto check-out...');
          await attendanceService.autoCheckOut();
          debugPrint('Auto check-out completed');
        } else {
          debugPrint('Skipping auto check-out: Not checked in or already on break');
        }
        break;
        
      case GeofenceEvent.dwell:
        debugPrint('Dwelling in geofence area');
        break;
    }
    
    // Log the event
    final eventLog = '${params.event.toString().split('.').last} at ${DateFormat('HH:mm:ss').format(now)}';
    debugPrint('Saving event: $eventLog');
    await storageService.saveGeofenceEvent(eventLog);
    
  } catch (e, stackTrace) {
    // Log any errors that occur during geofence handling
    debugPrint('Error in geofenceTriggered: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
