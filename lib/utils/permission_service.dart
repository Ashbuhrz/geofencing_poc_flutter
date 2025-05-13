import 'package:permission_handler/permission_handler.dart';

Future<List<String>> checkAllPermissions() async {
  bool locationGranted = await Permission.location.isGranted;
  bool backgroundGranted = await Permission.locationAlways.isGranted;
  bool backgroundRefresh = await Permission.backgroundRefresh.isGranted;
  return [
    locationGranted ? "Granted" : "Denied",
    backgroundGranted ? "Granted" : "Denied",
    backgroundRefresh ? "Granted" : "Denied",
  ];
}

Future<void> requestLocationPermissions() async {
  await Permission.location.request();
}

Future<void> requestBackgroundLocationPermissions() async {
  await Permission.locationAlways.request();
}

Future<void> requestBackgroundRefreshPermissions() async {
  await Permission.backgroundRefresh.request();
}
