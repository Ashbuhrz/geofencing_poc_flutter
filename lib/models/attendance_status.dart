enum AttendanceStatus {
  notCheckedIn,
  checkedIn,
  onBreak
}

class AttendanceState {
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? breakStartTime;
  final List<String> activityLog;
  final Duration? lastWorkDuration;

  AttendanceState({
    this.status = AttendanceStatus.notCheckedIn,
    this.checkInTime,
    this.breakStartTime,
    this.activityLog = const [],
    this.lastWorkDuration,
  });

  // Create a copy with updated fields
  AttendanceState copyWith({
    AttendanceStatus? status,
    DateTime? checkInTime,
    DateTime? breakStartTime,
    List<String>? activityLog,
    bool clearCheckInTime = false,
    bool clearBreakStartTime = false,
    Duration? lastWorkDuration,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      breakStartTime: clearBreakStartTime ? null : (breakStartTime ?? this.breakStartTime),
      activityLog: activityLog ?? this.activityLog,
      lastWorkDuration: lastWorkDuration ?? this.lastWorkDuration,
    );
  }

  // Get string representation of status
  String get statusString {
    switch (status) {
      case AttendanceStatus.notCheckedIn:
        return 'Not Checked In';
      case AttendanceStatus.checkedIn:
        return 'Checked In';
      case AttendanceStatus.onBreak:
        return 'On Break';
    }
  }

  // Calculate elapsed time since check-in
  String getElapsedTime() {
    if (checkInTime == null) return "";
    
    final difference = DateTime.now().difference(checkInTime!);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return '$hours hrs $minutes mins';
  }
}
