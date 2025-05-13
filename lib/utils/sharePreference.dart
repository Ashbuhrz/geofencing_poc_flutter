import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final String _sharedSpaceKey = 'geofence_events';

Future<void> saveEventToSharedSpace(String event) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> events = prefs.getStringList(_sharedSpaceKey) ?? [];
  events.add(event);

  await prefs.setStringList(_sharedSpaceKey, events);
  return;
}

Future<List<String>> loadEventRecords() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> events = prefs.getStringList(_sharedSpaceKey) ?? [];
  return events;
}

Future<void> clearRecords() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(_sharedSpaceKey);
  return;
}
