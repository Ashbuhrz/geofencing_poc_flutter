import 'package:flutter/material.dart';
import 'package:geofencingpoc/models/attendance_event.dart';
import 'package:geofencingpoc/models/attendance_status.dart';
import 'package:geofencingpoc/models/geofence_location.dart';
import 'package:geofencingpoc/models/permission_status.dart' as app_permission;
import 'package:geofencingpoc/screens/event_list_screen.dart';
import 'package:geofencingpoc/services/attendance_service.dart';
import 'package:geofencingpoc/services/geofence_service.dart';
import 'package:geofencingpoc/services/permission_service.dart';
import 'package:geofencingpoc/services/storage_service.dart';
import 'package:geofencingpoc/theme/theme.dart';
import 'package:geofencingpoc/widgets/activity_log.dart';
import 'package:geofencingpoc/widgets/date_time_card.dart';
import 'package:geofencingpoc/widgets/geofence_config_card.dart';
import 'package:geofencingpoc/widgets/location_card.dart';
import 'package:geofencingpoc/widgets/permission_card.dart';
import 'package:geofencingpoc/widgets/status_card.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Services
  final GeofenceService _geofenceService = GeofenceService();
  final PermissionService _permissionService = PermissionService();
  final AttendanceService _attendanceService = AttendanceService();
  final StorageService _storageService = StorageService();

  // Permission status
  app_permission.PermissionStatus _permissionStatus =
      app_permission.PermissionStatus();

  // Location data
  Position _currentLocation = Position(
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

  int _activeGeofenceCount = 0;

  // Attendance state
  AttendanceState _attendanceState = AttendanceState();

  // Attendance events for statistics
  List<AttendanceEvent> _attendanceEvents = [];

  // Timer for updating current time
  Timer? _timer;
  String _currentTime = "";
  String _currentDate = "";

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    // Initialize services and load data
    _initializeServices();

    // Set up timer to update current time every second
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Update current date and time
  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEE, MMM d, yyyy').format(now);
    });
  }

  // Initialize services and load data
  Future<void> _initializeServices() async {
    // Initialize geofence service
    await _geofenceService.initialize();

    // Initialize attendance service
    await _attendanceService.initialize();

    // Check permissions
    final permissions = await _permissionService.checkAllPermissions();

    // Get active geofence count
    final activeCount = await _geofenceService.getActiveGeofenceCount();

    // Get current location
    Position location;
    try {
      location = await _geofenceService.getCurrentPosition();
    } catch (e) {
      location = _currentLocation;
    }

    // Load attendance events for statistics
    final events = await _storageService.loadAttendanceEvents();

    // Update state
    setState(() {
      _permissionStatus = permissions;
      _activeGeofenceCount = activeCount;
      _currentLocation = location;
      _attendanceState = _attendanceService.currentState;
      _attendanceEvents = events;
    });
  }

  // Handle check-in/check-out
  Future<void> _handleCheckIn() async {
    final updatedState = await _attendanceService.toggleCheckIn();

    // Reload attendance events for statistics
    final events = await _storageService.loadAttendanceEvents();

    setState(() {
      _attendanceState = updatedState;
      _attendanceEvents = events;
    });

    // Update geofence status
    _updateGeofenceStatus();
  }

  // Handle break
  Future<void> _handleBreak() async {
    final updatedState = await _attendanceService.toggleBreak();

    // Reload attendance events for statistics
    final events = await _storageService.loadAttendanceEvents();

    setState(() {
      _attendanceState = updatedState;
      _attendanceEvents = events;
    });
  }

  // Start geofencing
  Future<void> _startGeofence(GeofenceLocation location) async {
    await _geofenceService.startGeofence(location);
    _updateGeofenceStatus();
  }

  // Stop geofencing
  Future<void> _stopGeofence() async {
    await _geofenceService.removeAllGeofences();
    _updateGeofenceStatus();
  }

  // Update geofence status
  Future<void> _updateGeofenceStatus() async {
    final activeCount = await _geofenceService.getActiveGeofenceCount();

    setState(() {
      _activeGeofenceCount = activeCount;
    });
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    await _permissionService.requestLocationPermission();
    _updatePermissionStatus();
  }

  // Request background location permission
  Future<void> _requestBackgroundLocationPermission() async {
    await _permissionService.requestBackgroundLocationPermission();
    _updatePermissionStatus();
  }

  // Request background refresh permission
  Future<void> _requestBackgroundRefreshPermission() async {
    await _permissionService.requestBackgroundRefreshPermission();
    _updatePermissionStatus();
  }

  // Update permission status
  Future<void> _updatePermissionStatus() async {
    final permissions = await _permissionService.checkAllPermissions();

    setState(() {
      _permissionStatus = permissions;
    });
  }

  // Update current location
  Future<void> _updateCurrentLocation() async {
    try {
      final location = await _geofenceService.getCurrentPosition();

      setState(() {
        _currentLocation = location;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unimac',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventListScreen(),
                  ),
                );
              },
              tooltip: 'View History',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeServices,
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Activity'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Dashboard Tab
            _buildDashboardTab(),

            // Activity Tab
            _buildActivityTab(),
            // Settings Tab
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  // Dashboard Tab - Main attendance interface
  Widget _buildDashboardTab() {
    final todayHours = _calculateTodayHours();
    final weekHours = _calculateWeeklyHours();
    final avgBreak = _calculateAvgBreakMinutes();
    final totalWorkHours = _calculateTotalWorkHours();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withOpacity(0.95),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time Card
            DateTimeCard(currentTime: _currentTime, currentDate: _currentDate),

            SizedBox(height: AppDimensions.large),

            // Status Section
            Text(
              'Attendance Status',
              style: AppTextStyles.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.small),
            StatusCard(
              attendanceState: _attendanceState,
              onCheckInPressed: _handleCheckIn,
              onBreakPressed: _handleBreak,
            ),

            SizedBox(height: AppDimensions.large),

            // Work Summary Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppDimensions.medium,
                      right: AppDimensions.medium,
                      top: AppDimensions.medium,
                    ),
                    child: Text(
                      'Work Summary',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.medium,
                      vertical: AppDimensions.small,
                    ),
                    child: Text(
                      'Total Hours: $totalWorkHours',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.medium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Today',
                          todayHours,
                          Icons.today,
                          AppColors.primary,
                        ),
                        _buildStatItem(
                          'This Week',
                          weekHours,
                          Icons.date_range,
                          AppColors.secondary,
                        ),
                        _buildStatItem(
                          'Avg. Break',
                          avgBreak,
                          Icons.free_breakfast,
                          Colors.amber[700]!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.large),

            // Location Section
            Text(
              'Location Information',
              style: AppTextStyles.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.small),
            LocationCard(
              currentLocation: _currentLocation,
              isGeofenceActive: _activeGeofenceCount > 0,
              onUpdateLocation: _updateCurrentLocation,
            ),
          ],
        ),
      ),
    );
  }

  // Build a statistic item
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Calculate today's work hours
  String _calculateTodayHours() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter events for today
    final todayEvents =
        _attendanceEvents
            .where(
              (event) =>
                  event.timestamp.year == today.year &&
                  event.timestamp.month == today.month &&
                  event.timestamp.day == today.day,
            )
            .toList();

    double totalHours = _calculateWorkHours(todayEvents);
    return '${totalHours.toStringAsFixed(1)} hrs';
  }

  // Calculate weekly work hours
  String _calculateWeeklyHours() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    // Filter events for this week
    final weekEvents =
        _attendanceEvents
            .where(
              (event) =>
                  event.timestamp.isAfter(
                    weekStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  event.timestamp.isBefore(now.add(const Duration(seconds: 1))),
            )
            .toList();

    double totalHours = _calculateWorkHours(weekEvents);
    return '${totalHours.toStringAsFixed(1)} hrs';
  }

  // Calculate average break minutes
  String _calculateAvgBreakMinutes() {
    // Sort events by timestamp
    final sortedEvents = List<AttendanceEvent>.from(_attendanceEvents)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    List<double> breakDurations = [];
    DateTime? breakStartTime;

    for (var event in sortedEvents) {
      if (event.type == EventType.breakStart) {
        breakStartTime = event.timestamp;
      } else if (event.type == EventType.breakEnd && breakStartTime != null) {
        final duration = event.timestamp.difference(breakStartTime);
        breakDurations.add(duration.inMinutes.toDouble());
        breakStartTime = null;
      }
    }

    if (breakDurations.isEmpty) return '0 min';
    final avgMinutes =
        breakDurations.reduce((a, b) => a + b) / breakDurations.length;
    return '${avgMinutes.toStringAsFixed(0)} min';
  }

  // Calculate total work hours from all events
  String _calculateTotalWorkHours() {
    final totalHours = _calculateWorkHours(_attendanceEvents);
    return '${totalHours.toStringAsFixed(1)} hrs';
  }

  // Calculate work hours from events
  double _calculateWorkHours(List<AttendanceEvent> filteredEvents) {
    double totalHours = 0;
    DateTime? checkInTime;
    DateTime? breakStartTime;

    // Sort events by timestamp
    filteredEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var i = 0; i < filteredEvents.length; i++) {
      final event = filteredEvents[i];

      switch (event.type) {
        case EventType.checkIn:
          checkInTime = event.timestamp;
          breakStartTime = null;
          break;
        case EventType.checkOut:
          if (checkInTime != null) {
            final duration = event.timestamp.difference(checkInTime);
            totalHours += duration.inMinutes / 60;
            checkInTime = null;
          }
          break;
        case EventType.breakStart:
          breakStartTime = event.timestamp;
          break;
        case EventType.breakEnd:
          if (breakStartTime != null) {
            // Don't count break time in work hours
            final breakDuration = event.timestamp.difference(breakStartTime);
            if (checkInTime != null) {
              // Adjust check-in time to account for break
              checkInTime = checkInTime.add(breakDuration);
            }
            breakStartTime = null;
          }
          break;
        default:
          // Ignore other event types
          break;
      }
    }

    // If still checked in, count hours until now
    if (checkInTime != null) {
      final now = DateTime.now();
      Duration workDuration;

      if (breakStartTime != null) {
        // If on break, only count until break started
        workDuration = breakStartTime.difference(checkInTime);
      } else {
        // Otherwise count until now
        workDuration = now.difference(checkInTime);
      }

      totalHours += workDuration.inMinutes / 60;
    }

    return totalHours;
  }

  // Settings Tab - Configure geofencing and permissions
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permissions Section
          Text('Permissions', style: AppTextStyles.h2),
          SizedBox(height: AppDimensions.small),
          PermissionCard(
            name: "Location",
            status: _permissionStatus.locationStatus,
            onRequest: _requestLocationPermission,
          ),
          PermissionCard(
            name: "Background Location",
            status: _permissionStatus.backgroundLocationStatus,
            onRequest: _requestBackgroundLocationPermission,
          ),
          PermissionCard(
            name: "Background Refresh",
            status: _permissionStatus.backgroundRefreshStatus,
            onRequest: _requestBackgroundRefreshPermission,
          ),

          SizedBox(height: AppDimensions.large),

          // Geofence Configuration
          Text('Geofence Configuration', style: AppTextStyles.h2),
          SizedBox(height: AppDimensions.small),
          GeofenceConfigCard(
            currentLocation: _currentLocation,
            isGeofenceActive: _activeGeofenceCount > 0,
            onStartGeofence: _startGeofence,
            onStopGeofence: _stopGeofence,
          ),
        ],
      ),
    );
  }

  // Activity Tab - Show recent activity
  Widget _buildActivityTab() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.medium),
      child: ActivityLogWidget(
        activityLog: _attendanceState.activityLog,
        onViewFullHistory: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventListScreen()),
          );
        },
      ),
    );
  }
}
