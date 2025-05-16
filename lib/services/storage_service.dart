import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geofencingpoc/models/geofence_location.dart';
import 'package:geofencingpoc/models/attendance_event.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Keys for SharedPreferences
  static const String _geofenceEventsKey = 'geofence_events';
  static const String _geofenceLocationKey = 'geofence_location';
  static const String _attendanceEventsKey = 'attendance_events';

  // Save a geofence event (legacy format)
  Future<void> saveGeofenceEvent(String event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> events = prefs.getStringList(_geofenceEventsKey) ?? [];
    events.add(event);
    await prefs.setStringList(_geofenceEventsKey, events);
  }

  // Load all geofence events (legacy format)
  Future<List<String>> loadGeofenceEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_geofenceEventsKey) ?? [];
  }

  // Clear all geofence events (legacy format)
  Future<void> clearGeofenceEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geofenceEventsKey);
  }

  // Save current geofence location
  Future<void> saveGeofenceLocation(GeofenceLocation location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String locationJson = jsonEncode(location.toJson());
    await prefs.setString(_geofenceLocationKey, locationJson);
  }

  // Load saved geofence location
  Future<GeofenceLocation?> loadGeofenceLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? locationJson = prefs.getString(_geofenceLocationKey);
    
    if (locationJson != null) {
      final Map<String, dynamic> locationMap = jsonDecode(locationJson);
      return GeofenceLocation.fromJson(locationMap);
    }
    
    return null;
  }

  // Save attendance event
  Future<void> saveAttendanceEvent(AttendanceEvent event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventsJson = prefs.getStringList(_attendanceEventsKey) ?? [];
    
    // Convert event to JSON and add to list
    final String eventJson = jsonEncode(event.toJson());
    eventsJson.add(eventJson);
    
    await prefs.setStringList(_attendanceEventsKey, eventsJson);
  }

  // Load all attendance events
  Future<List<AttendanceEvent>> loadAttendanceEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> eventsJson = prefs.getStringList(_attendanceEventsKey) ?? [];
    
    // Convert JSON strings to AttendanceEvent objects
    return eventsJson.map((eventJson) {
      final Map<String, dynamic> eventMap = jsonDecode(eventJson);
      return AttendanceEvent.fromJson(eventMap);
    }).toList();
  }

  // Clear all attendance events
  Future<void> clearAttendanceEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attendanceEventsKey);
  }

  // Convert legacy events to new format
  Future<void> migrateGeofenceEventsToAttendanceEvents() async {
    final List<String> legacyEvents = await loadGeofenceEvents();
    
    for (final legacyEvent in legacyEvents) {
      final AttendanceEvent event = AttendanceEvent.fromLegacyString(legacyEvent);
      await saveAttendanceEvent(event);
    }
  }
}
