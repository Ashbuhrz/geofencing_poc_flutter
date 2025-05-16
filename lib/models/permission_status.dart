class PermissionStatus {
  final bool locationGranted;
  final bool backgroundLocationGranted;
  final bool backgroundRefreshGranted;

  PermissionStatus({
    this.locationGranted = false,
    this.backgroundLocationGranted = false,
    this.backgroundRefreshGranted = false,
  });

  // Create a copy with updated fields
  PermissionStatus copyWith({
    bool? locationGranted,
    bool? backgroundLocationGranted,
    bool? backgroundRefreshGranted,
  }) {
    return PermissionStatus(
      locationGranted: locationGranted ?? this.locationGranted,
      backgroundLocationGranted: backgroundLocationGranted ?? this.backgroundLocationGranted,
      backgroundRefreshGranted: backgroundRefreshGranted ?? this.backgroundRefreshGranted,
    );
  }

  // Convert boolean to string status
  String getStatusString(bool isGranted) => isGranted ? "Granted" : "Denied";

  // Get location status as string
  String get locationStatus => getStatusString(locationGranted);

  // Get background location status as string
  String get backgroundLocationStatus => getStatusString(backgroundLocationGranted);

  // Get background refresh status as string
  String get backgroundRefreshStatus => getStatusString(backgroundRefreshGranted);
}
