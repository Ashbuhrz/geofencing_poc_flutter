import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geofencingpoc/theme/theme.dart';

class LocationCard extends StatelessWidget {
  final Position currentLocation;
  final bool isGeofenceActive;
  final VoidCallback onUpdateLocation;

  const LocationCard({
    Key? key,
    required this.currentLocation,
    required this.isGeofenceActive,
    required this.onUpdateLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: AppDimensions.iconMedium),
                SizedBox(width: AppDimensions.small),
                Text(
                  'Current Location',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            SizedBox(height: AppDimensions.medium),
            Container(
              padding: EdgeInsets.all(AppDimensions.small),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude: ${currentLocation.latitude.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: AppDimensions.xs),
                  Text(
                    'Longitude: ${currentLocation.longitude.toStringAsFixed(6)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.small),
            Row(
              children: [
                Icon(
                  isGeofenceActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: AppDimensions.iconSmall,
                  color: isGeofenceActive ? AppColors.success : AppColors.error,
                ),
                SizedBox(width: AppDimensions.xs),
                Text(
                  'Geofence Status: ${isGeofenceActive ? "Active" : "Inactive"}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isGeofenceActive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.medium),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpdateLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Update Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.small),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
