import 'package:flutter/material.dart';
import 'package:geofencingpoc/theme/theme.dart';

class DateTimeCard extends StatelessWidget {
  final String currentTime;
  final String currentDate;

  const DateTimeCard({
    super.key,
    required this.currentTime,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge)),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.medium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        child: Column(
          children: [
            Text(
              currentTime,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: AppDimensions.xs),
            Text(
              currentDate,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
