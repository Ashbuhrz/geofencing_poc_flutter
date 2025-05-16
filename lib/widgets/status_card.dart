import 'package:flutter/material.dart';
import 'package:geofencingpoc/models/attendance_status.dart';
import 'package:geofencingpoc/theme/theme.dart';
import 'package:intl/intl.dart';

class StatusCard extends StatelessWidget {
  final AttendanceState attendanceState;
  final VoidCallback onCheckInPressed;
  final VoidCallback onBreakPressed;

  const StatusCard({
    Key? key,
    required this.attendanceState,
    required this.onCheckInPressed,
    required this.onBreakPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCheckedIn = attendanceState.status != AttendanceStatus.notCheckedIn;
    final bool isOnBreak = attendanceState.status == AttendanceStatus.onBreak;
    final String timeElapsed = attendanceState.getElapsedTime();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCheckedIn
                      ? (isOnBreak ? Icons.pause_circle : Icons.check_circle)
                      : Icons.not_interested,
                  color: isCheckedIn
                      ? (isOnBreak ? AppColors.warning : AppColors.success)
                      : AppColors.error,
                  size: 24,
                ),
                SizedBox(width: AppDimensions.small),
                Text(
                  'Status: ${attendanceState.statusString}',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            if (isCheckedIn && !isOnBreak && attendanceState.checkInTime != null) ...[
              SizedBox(height: AppDimensions.small),
              Text(
                'Checked in at: ${DateFormat('HH:mm:ss').format(attendanceState.checkInTime!)}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: AppDimensions.xs),
              Text(
                'Time elapsed: $timeElapsed',
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (isOnBreak && attendanceState.breakStartTime != null) ...[
              SizedBox(height: AppDimensions.small),
              Text(
                'Break started at: ${DateFormat('HH:mm:ss').format(attendanceState.breakStartTime!)}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
            SizedBox(height: AppDimensions.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: onCheckInPressed,
                  icon: Icon(isCheckedIn ? Icons.logout : Icons.login),
                  label: Text(isCheckedIn ? 'Check Out' : 'Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCheckedIn ? AppColors.error : AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.medium, vertical: AppDimensions.small),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isCheckedIn ? onBreakPressed : null,
                  icon: Icon(isOnBreak ? Icons.play_arrow : Icons.pause),
                  label: Text(isOnBreak ? 'End Break' : 'Take Break'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOnBreak ? AppColors.success : AppColors.warning,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.medium, vertical: AppDimensions.small),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.lightGrey,
                    disabledForegroundColor: AppColors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
