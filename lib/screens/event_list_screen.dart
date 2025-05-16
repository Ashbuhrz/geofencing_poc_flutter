import 'package:flutter/material.dart';
import 'package:geofencingpoc/models/attendance_event.dart';
import 'package:geofencingpoc/services/attendance_service.dart';
import 'package:geofencingpoc/services/storage_service.dart';
import 'package:geofencingpoc/theme/theme.dart';
import 'package:intl/intl.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final StorageService _storageService = StorageService();
  List<AttendanceEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    // First, migrate legacy events if needed
    await _storageService.migrateGeofenceEventsToAttendanceEvents();
    
    // Then load all events
    final events = await _attendanceService.getAllEvents();
    
    // Sort events by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _clearEvents() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all event history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _attendanceService.clearAllEvents();
      await _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _events.isEmpty ? null : _clearEvents,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : _buildEventList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'No events recorded',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    // Group events by date
    final Map<String, List<AttendanceEvent>> groupedEvents = {};
    
    for (final event in _events) {
      final dateKey = DateFormat('yyyy-MM-dd').format(event.timestamp);
      if (!groupedEvents.containsKey(dateKey)) {
        groupedEvents[dateKey] = [];
      }
      groupedEvents[dateKey]!.add(event);
    }
    
    // Sort dates (newest first)
    final sortedDates = groupedEvents.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateEvents = groupedEvents[dateKey]!;
        final headerDate = DateFormat('EEE, MMM d, yyyy')
            .format(dateEvents.first.timestamp);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppDimensions.medium, AppDimensions.medium, AppDimensions.medium, AppDimensions.small),
              child: Text(
                headerDate,
                style: AppTextStyles.h3,
              ),
            ),
            ...dateEvents.map((event) => _buildEventItem(event)).toList(),
            if (index < sortedDates.length - 1)
              Divider(height: 32, thickness: 1, color: AppColors.lightGrey),
          ],
        );
      },
    );
  }

  Widget _buildEventItem(AttendanceEvent event) {
    // Determine icon and color based on event type
    IconData icon;
    Color color;
    
    switch (event.type) {
      case EventType.checkIn:
        icon = Icons.login;
        color = AppColors.success;
        break;
      case EventType.checkOut:
        icon = Icons.logout;
        color = AppColors.error;
        break;
      case EventType.breakStart:
        icon = Icons.pause;
        color = AppColors.warning;
        break;
      case EventType.breakEnd:
        icon = Icons.play_arrow;
        color = AppColors.success;
        break;
      case EventType.geofenceEnter:
        icon = Icons.location_on;
        color = AppColors.primary;
        break;
      case EventType.geofenceExit:
        icon = Icons.location_off;
        color = AppColors.secondary;
        break;
      case EventType.geofenceDwell:
        icon = Icons.home;
        color = AppColors.primaryLight;
        break;
    }
    
    return Card(
      elevation: AppDimensions.elevationXs,
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.medium, vertical: AppDimensions.xs),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          event.typeString,
          style: AppTextStyles.label,
        ),
        subtitle: Text(
          DateFormat('HH:mm:ss').format(event.timestamp),
          style: AppTextStyles.caption,
        ),
        trailing: event.description != null && event.description!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(event.typeString),
                      content: Text(event.description!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
