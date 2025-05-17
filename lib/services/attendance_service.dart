import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:geofencingpoc/models/attendance_event.dart';
import 'package:geofencingpoc/models/attendance_status.dart';
import 'package:geofencingpoc/services/storage_service.dart';
import 'package:geofencingpoc/services/geofence_service.dart';

class AttendanceService {
  // Singleton pattern
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final StorageService _storageService = StorageService();
  final GeofenceService _geofenceService = GeofenceService();
  
  // Current attendance state
  AttendanceState _currentState = AttendanceState();
  
  // Getter for current state
  AttendanceState get currentState => _currentState;

  // Initialize the notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Initialize service and load state
  Future<void> initialize() async {
    // Load activity log from storage
    final events = await _storageService.loadAttendanceEvents();
    
    // Get today's events only
    final today = DateTime.now();
    final todayEvents = events.where((event) => 
      event.timestamp.year == today.year && 
      event.timestamp.month == today.month && 
      event.timestamp.day == today.day
    ).toList();
    
    // Convert to activity log format
    final activityLog = todayEvents.map((event) => 
      "${event.formattedTime} - ${event.typeString}"
    ).toList();
    
    // Determine current state based on events
    AttendanceStatus status = AttendanceStatus.notCheckedIn;
    DateTime? checkInTime;
    DateTime? breakStartTime;
    
    // Process events in chronological order to determine current state
    for (final event in todayEvents) {
      switch (event.type) {
        case EventType.checkIn:
          status = AttendanceStatus.checkedIn;
          checkInTime = event.timestamp;
          breakStartTime = null;
          break;
        case EventType.checkOut:
          status = AttendanceStatus.notCheckedIn;
          checkInTime = null;
          breakStartTime = null;
          break;
        case EventType.breakStart:
          if (status == AttendanceStatus.checkedIn) {
            status = AttendanceStatus.onBreak;
            breakStartTime = event.timestamp;
          }
          break;
        case EventType.breakEnd:
          if (status == AttendanceStatus.onBreak) {
            status = AttendanceStatus.checkedIn;
            breakStartTime = null;
          }
          break;
        default:
          // Geofence events don't change attendance status
          break;
      }
    }
    
    // Update current state
    _currentState = AttendanceState(
      status: status,
      checkInTime: checkInTime,
      breakStartTime: breakStartTime,
      activityLog: activityLog,
    );
  }

  // Handle check-in/check-out
  // Auto check-in when entering geofence
  Future<AttendanceState> autoCheckIn() async {
    debugPrint('Starting autoCheckIn...');
    final now = DateTime.now();
    final checkInEvent = AttendanceEvent(
      timestamp: now,
      type: EventType.checkIn,
      isAuto: true,
    );
    
    debugPrint('Created checkInEvent: ${checkInEvent.toJson()}');
    
    // Save event
    await _storageService.saveAttendanceEvent(checkInEvent);
    
    // Update activity log
    final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Auto Checked In";
    final updatedLog = [..._currentState.activityLog, activityLogEntry];
    
    // Update state
    _currentState = _currentState.copyWith(
      status: AttendanceStatus.checkedIn,
      checkInTime: now,
      clearCheckInTime: false,
      clearBreakStartTime: true,
      activityLog: updatedLog,
    );
    
    // Show notification
    await _showNotification('Auto Checked In', 'You have been automatically checked in');
    
    return _currentState;
  }
  
  // Auto check-out when exiting geofence
  Future<AttendanceState> autoCheckOut() async {
    final now = DateTime.now();
    final checkOutEvent = AttendanceEvent(
      timestamp: now,
      type: EventType.checkOut,
      isAuto: true,
    );
    
    // Save event
    await _storageService.saveAttendanceEvent(checkOutEvent);
    
    // Update activity log
    final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Auto Checked Out";
    final updatedLog = [..._currentState.activityLog, activityLogEntry];
    
    // Calculate work duration
    Duration? workDuration;
    if (_currentState.checkInTime != null) {
      workDuration = now.difference(_currentState.checkInTime!);
    }
    
    // Update state
    _currentState = _currentState.copyWith(
      status: AttendanceStatus.notCheckedIn,
      checkInTime: null,
      breakStartTime: null,
      clearCheckInTime: true,
      clearBreakStartTime: true,
      activityLog: updatedLog,
      lastWorkDuration: workDuration,
    );
    
    // Show notification
    await _showNotification('Auto Checked Out', 'You have been automatically checked out');
    
    return _currentState;
  }

  Future<AttendanceState> toggleCheckIn() async {
    if (_currentState.status == AttendanceStatus.notCheckedIn) {
      // Check in
      final now = DateTime.now();
      final checkInEvent = AttendanceEvent(
        timestamp: now,
        type: EventType.checkIn,
        isAuto: false,
      );
      
      // Save event
      await _storageService.saveAttendanceEvent(checkInEvent);
      
      // Update activity log
      final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Checked In";
      final updatedLog = [..._currentState.activityLog, activityLogEntry];
      
      // Update state
      _currentState = _currentState.copyWith(
        status: AttendanceStatus.checkedIn,
        checkInTime: now,
        activityLog: updatedLog,
      );
      
      // Start geofencing if not already active
      final activeCount = await _geofenceService.getActiveGeofenceCount();
      if (activeCount == 0) {
        final location = await _storageService.loadGeofenceLocation();
        if (location != null) {
          await _geofenceService.startGeofence(location);
        }
      }
    } else {
      // Check out
      final now = DateTime.now();
      final checkOutEvent = AttendanceEvent(
        timestamp: now,
        type: EventType.checkOut,
      );
      
      // Save event
      await _storageService.saveAttendanceEvent(checkOutEvent);
      
      // Update activity log
      final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Checked Out";
      final updatedLog = [..._currentState.activityLog, activityLogEntry];
      
      // Update state
      _currentState = _currentState.copyWith(
        status: AttendanceStatus.notCheckedIn,
        clearCheckInTime: true,
        clearBreakStartTime: true,
        activityLog: updatedLog,
      );
      
      // Stop geofencing
      final activeCount = await _geofenceService.getActiveGeofenceCount();
      if (activeCount > 0) {
        await _geofenceService.removeAllGeofences();
      }
    }
    
    return _currentState;
  }

  // Show local notification
  Future<void> _showNotification(String title, String body) async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
          FlutterLocalNotificationsPlugin();

      // Initialize settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize settings for iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();

      // Initialize settings for both platforms
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );

      // Create notification channel for Android 8.0+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'auto_check_channel',
        'Auto Check Notifications',
        description: 'Notifications for automatic check-in/check-out',
        importance: Importance.max,
        playSound: true,
      );

      // Create the Android notification details
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        playSound: true,
        priority: Priority.high,
      );

      // Create the iOS notification details
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

      // Show the notification
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: iOSDetails,
        ),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Handle break start/end
  Future<AttendanceState> toggleBreak() async {
    if (_currentState.status == AttendanceStatus.notCheckedIn) {
      // Can't take break if not checked in
      return _currentState;
    }
    
    if (_currentState.status == AttendanceStatus.checkedIn) {
      // Start break
      final now = DateTime.now();
      final breakStartEvent = AttendanceEvent(
        timestamp: now,
        type: EventType.breakStart,
      );
      
      // Save event
      await _storageService.saveAttendanceEvent(breakStartEvent);
      
      // Update activity log
      final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Break Started";
      final updatedLog = [..._currentState.activityLog, activityLogEntry];
      
      // Update state
      _currentState = _currentState.copyWith(
        status: AttendanceStatus.onBreak,
        breakStartTime: now,
        activityLog: updatedLog,
      );
    } else {
      // End break
      final now = DateTime.now();
      final breakEndEvent = AttendanceEvent(
        timestamp: now,
        type: EventType.breakEnd,
      );
      
      // Save event
      await _storageService.saveAttendanceEvent(breakEndEvent);
      
      // Update activity log
      final activityLogEntry = "${DateFormat('HH:mm:ss').format(now)} - Break Ended";
      final updatedLog = [..._currentState.activityLog, activityLogEntry];
      
      // Update state
      _currentState = _currentState.copyWith(
        status: AttendanceStatus.checkedIn,
        clearBreakStartTime: true,
        activityLog: updatedLog,
      );
    }
    
    return _currentState;
  }

  // Get all events for history
  Future<List<AttendanceEvent>> getAllEvents() async {
    return await _storageService.loadAttendanceEvents();
  }

  // Clear all events
  Future<void> clearAllEvents() async {
    await _storageService.clearAttendanceEvents();
    _currentState = _currentState.copyWith(
      activityLog: [],
    );
  }
}
