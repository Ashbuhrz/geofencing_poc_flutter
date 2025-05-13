import 'package:flutter/material.dart';
import 'package:geofencingpoc/screens/event_list_screen.dart';
import 'package:geofencingpoc/utils/grofence_service.dart';
import 'package:geofencingpoc/utils/permission_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationAccess = "Denied";
  String backgroundLocationAccess = "Denied";
  String backgroundRefresh = "Denied";

  String lat = "0.0";
  String lng = "0.0";
  String radius = "0";
  int activeServiceCount = 0;
  Position currentLocation = Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeServiceGEO();
    onInIt();
  }

  void onInIt() async {
    List<String> permissions = await checkAllPermissions();
    int activeCount = await getisActiveGeofence();
    setState(() {
      locationAccess = permissions[0];
      backgroundLocationAccess = permissions[1];
      backgroundRefresh = permissions[2];
      activeServiceCount = activeCount;
    });
    Position cuLocation = await determinePosition();
    setState(() {
      currentLocation = cuLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Demo App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PermissionCard(
              name: "Location",
              status: locationAccess,
              onRequest: () async {
                await requestLocationPermissions();
                onInIt();
              },
            ),
            PermissionCard(
              name: "Background Location",
              status: backgroundLocationAccess,
              onRequest: () async {
                await requestBackgroundLocationPermissions();
                onInIt();
              },
            ),

            // PermissionCard(
            //   name: "Background Refresh",
            //   status: backgroundRefresh,
            //   onRequest: () async {
            //     await requestBackgroundRefreshPermissions();
            //     onInIt();
            //   },
            // ),
            const SizedBox(height: 16),
            Text(
              "Is Service Active: ${activeServiceCount == 1 ? "Yes" : "No"}",
            ),
            const SizedBox(height: 16),
            Text(
              "Current Location: ${currentLocation.latitude},${currentLocation.longitude}",
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: onInIt, child: Text('Refresh')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      lat = currentLocation.latitude.toString();
                      lng = currentLocation.longitude.toString();
                    });
                  },
                  child: Text('Load Current Location'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        lat = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Latitude',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        lng = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Longitude',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    radius = value;
                  });
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Radius',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (lat != "" && lng != "" && radius != "") {
                  startGeoFenceee(
                    double.parse(lat),
                    double.parse(lng),
                    double.parse(radius),
                  );
                } else {
                  showDialog<String>(
                    context: context,
                    builder:
                        (BuildContext context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Need lat,long and radius'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: Text('Initiate Geofene'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: removeGeoFens,
                  child: Text('Stop Geofene'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EventListScreen(),
                      ),
                    );
                  },
                  child: Text('Event List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionCard extends StatelessWidget {
  final String name;
  final String status;
  final Function()? onRequest;
  const PermissionCard({
    super.key,
    required this.name,
    required this.status,
    this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name)),
        Text(
          status,
          style: TextStyle(
            color: status == "Granted" ? Colors.green : Colors.red,
          ),
        ),
        if (status != "Granted") const SizedBox(width: 16),
        if (status != "Granted")
          ElevatedButton(onPressed: onRequest, child: Text('Request')),
      ],
    );
  }
}
