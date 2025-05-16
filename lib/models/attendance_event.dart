import 'package:intl/intl.dart';

enum EventType {
  checkIn,
  checkOut,
  breakStart,
  breakEnd,
  geofenceEnter,
  geofenceExit,
  geofenceDwell
}

class AttendanceEvent {
  final DateTime timestamp;
  final EventType type;
  final String? description;
  final bool isAuto;

  AttendanceEvent({
    required this.timestamp,
    required this.type,
    this.description,
    this.isAuto = false,
  });

  String get formattedTime => DateFormat('HH:mm:ss').format(timestamp);
  String get formattedDate => DateFormat('EEE, MMM d, yyyy').format(timestamp);
  String get formattedDateTime => DateFormat('dd/MM/yyyy h:mm a').format(timestamp);

  String get typeString {
    final prefix = isAuto ? 'Auto ' : '';
    switch (type) {
      case EventType.checkIn:
        return '${prefix}Checked In';
      case EventType.checkOut:
        return '${prefix}Checked Out';
      case EventType.breakStart:
        return '${prefix}Break Started';
      case EventType.breakEnd:
        return '${prefix}Break Ended';
      case EventType.geofenceEnter:
        return 'Entered Geofence';
      case EventType.geofenceExit:
        return 'Exited Geofence';
      case EventType.geofenceDwell:
        return 'Dwelling in Geofence';
    }
  }

  // For storing in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
      'description': description,
      'isAuto': isAuto,
    };
  }

  // For retrieving from SharedPreferences
  factory AttendanceEvent.fromJson(Map<String, dynamic> json) {
    return AttendanceEvent(
      timestamp: DateTime.parse(json['timestamp']),
      type: EventType.values[json['type']],
      description: json['description'],
      isAuto: json['isAuto'] ?? false,
    );
  }

  // For legacy string format conversion
  factory AttendanceEvent.fromLegacyString(String eventString) {
    // Parse old format: "Event: enter At 15/05/2025 7:24 PM"
    if (eventString.startsWith('Event:')) {
      final parts = eventString.split(' At ');
      if (parts.length == 2) {
        final eventTypeStr = parts[0].replaceAll('Event: ', '').trim();
        final dateTimeStr = parts[1].trim();
        
        EventType eventType;
        if (eventTypeStr == 'enter') {
          eventType = EventType.geofenceEnter;
        } else if (eventTypeStr == 'exit') {
          eventType = EventType.geofenceExit;
        } else if (eventTypeStr == 'dwell') {
          eventType = EventType.geofenceDwell;
        } else {
          // Default case
          eventType = EventType.geofenceEnter;
        }
        
        try {
          final timestamp = DateFormat('dd/MM/yyyy h:mm a').parse(dateTimeStr);
          return AttendanceEvent(
            timestamp: timestamp,
            type: eventType,
          );
        } catch (e) {
          // If date parsing fails, use current time
          return AttendanceEvent(
            timestamp: DateTime.now(),
            type: eventType,
            description: 'Parsed from: $eventString',
          );
        }
      }
    }
    
    // For activity log format: "07:24:31 - Checked In"
    if (eventString.contains(' - ')) {
      final parts = eventString.split(' - ');
      if (parts.length == 2) {
        final timeStr = parts[0].trim();
        final actionStr = parts[1].trim();
        
        EventType eventType;
        if (actionStr == 'Checked In') {
          eventType = EventType.checkIn;
        } else if (actionStr == 'Checked Out') {
          eventType = EventType.checkOut;
        } else if (actionStr == 'Break Started') {
          eventType = EventType.breakStart;
        } else if (actionStr == 'Break Ended') {
          eventType = EventType.breakEnd;
        } else {
          // Default case
          eventType = EventType.checkIn;
        }
        
        try {
          // Since we only have time, use today's date
          final now = DateTime.now();
          final timeOnly = DateFormat('HH:mm:ss').parse(timeStr);
          final timestamp = DateTime(
            now.year, 
            now.month, 
            now.day, 
            timeOnly.hour, 
            timeOnly.minute, 
            timeOnly.second
          );
          
          return AttendanceEvent(
            timestamp: timestamp,
            type: eventType,
          );
        } catch (e) {
          // If time parsing fails, use current time
          return AttendanceEvent(
            timestamp: DateTime.now(),
            type: eventType,
            description: 'Parsed from: $eventString',
          );
        }
      }
    }
    
    // Fallback for any other format
    return AttendanceEvent(
      timestamp: DateTime.now(),
      type: EventType.geofenceEnter,
      description: 'Unknown format: $eventString',
    );
  }
}
