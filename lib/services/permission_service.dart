import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:geofencingpoc/models/permission_status.dart';


class PermissionService {
  // Singleton pattern
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check all required permissions
  Future<PermissionStatus> checkAllPermissions() async {
    bool locationGranted = await permission_handler.Permission.location.isGranted;
    bool backgroundGranted = await permission_handler.Permission.locationAlways.isGranted;
    bool backgroundRefresh = await permission_handler.Permission.backgroundRefresh.isGranted;
    
    return PermissionStatus(
      locationGranted: locationGranted,
      backgroundLocationGranted: backgroundGranted,
      backgroundRefreshGranted: backgroundRefresh,
    );
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    permission_handler.PermissionStatus status = await permission_handler.Permission.location.request();
    return status == permission_handler.PermissionStatus.granted;
  }

  // Request background location permission
  Future<bool> requestBackgroundLocationPermission() async {
    permission_handler.PermissionStatus status = await permission_handler.Permission.locationAlways.request();
    return status == permission_handler.PermissionStatus.granted;
  }

  // Request background refresh permission
  Future<bool> requestBackgroundRefreshPermission() async {
    try {
      // Try to request the permission, which will work on iOS
      permission_handler.PermissionStatus status = 
          await permission_handler.Permission.backgroundRefresh.request();
      return status == permission_handler.PermissionStatus.granted;
    } catch (e) {
      // On Android, this permission doesn't exist in the same way
      // We rely on the background location permission instead
      // which should already be requested separately
      return true;
    }
  }
}
