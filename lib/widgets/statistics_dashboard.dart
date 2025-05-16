import 'package:flutter/material.dart';
import 'package:geofencingpoc/models/attendance_event.dart';
import 'package:geofencingpoc/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsDashboard extends StatelessWidget {
  final List<AttendanceEvent> events;

  const StatisticsDashboard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.medium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Statistics', style: AppTextStyles.h3),
            SizedBox(height: AppDimensions.small),
            _buildSummaryStats(),
            SizedBox(height: AppDimensions.medium),
            Text('Weekly Hours', style: AppTextStyles.h4),
            SizedBox(height: AppDimensions.small),
            SizedBox(height: 200, child: _buildWeeklyHoursChart()),
            SizedBox(height: AppDimensions.medium),
            Text('Check-in Pattern', style: AppTextStyles.h4),
            SizedBox(height: AppDimensions.small),
            SizedBox(height: 150, child: _buildCheckInPatternChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final stats = _calculateStats();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Today',
          '${stats.todayHours.toStringAsFixed(1)} hrs',
          Icons.today,
          AppColors.primary,
        ),
        _buildStatItem(
          'This Week',
          '${stats.weeklyHours.toStringAsFixed(1)} hrs',
          Icons.date_range,
          AppColors.secondary,
        ),
        _buildStatItem(
          'Avg. Break',
          '${stats.avgBreakMinutes.toStringAsFixed(0)} min',
          Icons.free_breakfast,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimensions.small),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.small),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildWeeklyHoursChart() {
    final weeklyData = _getWeeklyHoursData();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxWeeklyHours(weeklyData),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: AppColors.cardBackground.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${weeklyData[groupIndex].hours.toStringAsFixed(1)} hrs',
                TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < weeklyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weeklyData[value.toInt()].dayLabel,
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}h',
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups:
            weeklyData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.hours,
                    color: _getBarColor(data.dayIndex),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCheckInPatternChart() {
    final checkInData = _getCheckInPatternData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 4 == 0 &&
                    value < checkInData.length &&
                    value.toInt() >= 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      checkInData[value.toInt()].timeLabel,
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: checkInData.length.toDouble() - 1,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots:
                checkInData.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.count.toDouble(),
                  );
                }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for data calculation
  _StatsData _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    // Filter events for today and this week
    final todayEvents =
        events
            .where(
              (event) =>
                  event.timestamp.year == today.year &&
                  event.timestamp.month == today.month &&
                  event.timestamp.day == today.day,
            )
            .toList();

    final weekEvents =
        events
            .where(
              (event) =>
                  event.timestamp.isAfter(
                    weekStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  event.timestamp.isBefore(now.add(const Duration(seconds: 1))),
            )
            .toList();

    // Calculate today's hours
    double todayHours = _calculateWorkHours(todayEvents);

    // Calculate weekly hours
    double weeklyHours = _calculateWorkHours(weekEvents);

    // Calculate average break time
    double avgBreakMinutes = _calculateAverageBreakMinutes(events);

    return _StatsData(
      todayHours: todayHours,
      weeklyHours: weeklyHours,
      avgBreakMinutes: avgBreakMinutes,
    );
  }

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
              checkInTime = checkInTime!.add(breakDuration);
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

  double _calculateAverageBreakMinutes(List<AttendanceEvent> allEvents) {
    // Sort events by timestamp
    final sortedEvents = List<AttendanceEvent>.from(allEvents)
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

    if (breakDurations.isEmpty) return 0;
    return breakDurations.reduce((a, b) => a + b) / breakDurations.length;
  }

  List<_WeeklyData> _getWeeklyHoursData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create data for the last 7 days
    List<_WeeklyData> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayIndex = date.weekday - 1; // 0 = Monday, 6 = Sunday

      // Filter events for this day
      final dayEvents =
          events
              .where(
                (event) =>
                    event.timestamp.year == date.year &&
                    event.timestamp.month == date.month &&
                    event.timestamp.day == date.day,
              )
              .toList();

      // Calculate hours worked
      final hours = _calculateWorkHours(dayEvents);

      // Add to data
      weeklyData.add(
        _WeeklyData(
          dayIndex: dayIndex,
          dayLabel: DateFormat('E').format(date),
          hours: hours,
        ),
      );
    }

    return weeklyData;
  }

  List<_TimeData> _getCheckInPatternData() {
    // Group check-ins by hour of day
    Map<int, int> hourCounts = {};

    // Initialize all hours to zero
    for (int i = 0; i < 24; i++) {
      hourCounts[i] = 0;
    }

    // Count check-ins by hour
    for (var event in events) {
      if (event.type == EventType.checkIn) {
        final hour = event.timestamp.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    // Convert to list
    List<_TimeData> timeData = [];
    hourCounts.forEach((hour, count) {
      timeData.add(
        _TimeData(
          hour: hour,
          timeLabel: '${hour.toString().padLeft(2, '0')}:00',
          count: count,
        ),
      );
    });

    // Sort by hour
    timeData.sort((a, b) => a.hour.compareTo(b.hour));

    return timeData;
  }

  double _getMaxWeeklyHours(List<_WeeklyData> data) {
    if (data.isEmpty) return 8.0; // Default max if no data

    double maxHours = data.map((d) => d.hours).reduce((a, b) => a > b ? a : b);
    // Round up to nearest 2 hours and add 2 for padding
    return ((maxHours / 2).ceil() * 2) + 2;
  }

  Color _getBarColor(int dayIndex) {
    final todayIndex = DateTime.now().weekday - 1;
    // Return different colors based on the day of week
    switch (dayIndex) {
      case 5: // Saturday
      case 6: // Sunday
        return AppColors.secondary;
      case 1: // Today
        return AppColors.primary;
      default:
        return AppColors.primaryLight;
    }
  }
}

// Helper classes for data organization
class _StatsData {
  final double todayHours;
  final double weeklyHours;
  final double avgBreakMinutes;

  _StatsData({
    required this.todayHours,
    required this.weeklyHours,
    required this.avgBreakMinutes,
  });
}

class _WeeklyData {
  final int dayIndex;
  final String dayLabel;
  final double hours;

  _WeeklyData({
    required this.dayIndex,
    required this.dayLabel,
    required this.hours,
  });
}

class _TimeData {
  final int hour;
  final String timeLabel;
  final int count;

  _TimeData({required this.hour, required this.timeLabel, required this.count});
}
