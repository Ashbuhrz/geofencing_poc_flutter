/// A class that defines application-wide constants.
class AppConstants {
  // App information
  static const String appName = 'GeoAttendance';
  static const String appVersion = '1.0.0';
  
  // Default values
  static const double defaultGeofenceRadius = 100.0; // in meters
  
  // Storage keys
  static const String geofenceLocationKey = 'geofence_location';
  static const String geofenceEventsKey = 'geofence_events';
  
  // Time formats
  static const String dateTimeFormat = 'dd/MM/yyyy h:mm a';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'h:mm a';
}
