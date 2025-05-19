import 'package:geofencingpoc/utils/sharePreference.dart';
import 'package:intl/intl.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:geolocator/geolocator.dart';

Future<void> initializeServiceGEO() async {
  await NativeGeofenceManager.instance.initialize();
}

@pragma('vm:entry-point')
Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
  String dateFormated = getDate(
    date: DateTime.now(),
    format: "dd/MM/yyyy h:mm a",
  );
  await saveEventToSharedSpace('Event: ${params.event} At ${dateFormated}');
  print('Event: ${params.event} At ${dateFormated}');
}

void startGeoFenceee(double lat, double lng, double radius) async {
  await removeGeoFens();
  final zone1 = Geofence(
    id: 'zone1',
    location: Location(latitude: lat, longitude: lng), // Times Square
    radiusMeters: radius,
    triggers: {GeofenceEvent.enter, GeofenceEvent.exit},
    iosSettings: IosGeofenceSettings(initialTrigger: true),
    androidSettings: AndroidGeofenceSettings(
      initialTriggers: {GeofenceEvent.enter},
      expiration: const Duration(days: 7),
      loiteringDelay: const Duration(minutes: 1),
      notificationResponsiveness: const Duration(minutes: 5),
    ),
  );
  await NativeGeofenceManager.instance.createGeofence(zone1, geofenceTriggered);
  NativeGeofenceBackgroundManager.instance.demoteToBackground();
  return;
}

Future<int> getisActiveGeofence() async {
  final List<ActiveGeofence> myGeofences =
      await NativeGeofenceManager.instance.getRegisteredGeofences();
  print('There are ${myGeofences.length} active geofences.');
  return myGeofences.length;
}

Future<bool> removeGeoFens() async {
  await NativeGeofenceManager.instance.removeAllGeofences();
  return true;
}

String getDate({var date, String format = "dd/MM/yyyy"}) {
  if (date != null) {
    if (date.runtimeType == String) {
      final DateFormat formatter = DateFormat(format);
      final String formatted = formatter.format(DateTime.parse(date));
      return formatted;
    } else if (date.runtimeType == DateTime) {
      final DateFormat formatter = DateFormat(format);
      final String formatted = formatter.format(date);
      return formatted;
    }
  }
  return "";
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
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
  return await Geolocator.getCurrentPosition();
}
